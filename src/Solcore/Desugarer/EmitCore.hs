module Solcore.Desugarer.EmitCore(emitCore) where
import Language.Core qualified as Core
import Data.Map qualified as Map
import Control.Monad(forM, when)
import Control.Monad.IO.Class
import Control.Monad.Reader.Class
import Control.Monad.State
import Data.List(intercalate)
import qualified Data.Map as Map

import Solcore.Frontend.Pretty.SolcorePretty
import Solcore.Frontend.Syntax
import Solcore.Frontend.TypeInference.Id ( Id(..) )
import Solcore.Frontend.TypeInference.TcEnv(TcEnv(..),TypeInfo(..), TypeTable)
import Solcore.Frontend.TypeInference.TcSubst
import Solcore.Frontend.TypeInference.TcUnify
import Solcore.Primitives.Primitives
import System.Exit

emitCore :: Bool -> TcEnv ->  CompUnit Id -> IO [Core.Contract]
emitCore debugp env cu = fmap concat $ runEM debugp env $ mapM emitTopDecl (contracts cu)

type EM a = StateT EcState IO a
runEM :: Bool -> TcEnv -> EM a ->  IO a
runEM debugp env m = evalStateT m (initEcState debugp env)

data EcState = EcState
    { ecSubst :: VSubst
    , ecDT :: DataTable
    , ecNest :: Int
    , ecDebug :: Bool
    }

initEcState :: Bool -> TcEnv -> EcState
initEcState debugp env = EcState
   { ecSubst = emptyVSubst
   , ecDT = Map.empty
   , ecNest = 0
   , ecDebug = debugp
   }

type DataTable = Map.Map Name DataTy
-- type DataTable = Map.Map Name TConInfo
type TConInfo = ([Tyvar], [DConInfo]) -- type con: type vars and data cons
type DConInfo = (Name, [Ty])          -- data con: name and argument types


type VSubst = Map.Map Name Core.Expr
emptyVSubst :: VSubst
emptyVSubst = Map.empty

type Translation a = EM (a, [Core.Stmt])

type CoreName = String

emitTopDecl :: TopDecl Id -> EM [Core.Contract]
emitTopDecl (TContr c) = fmap pure (emitContract c)
emitTopDecl (TDataDef dt) = addData dt >> pure []
emitTopDecl _ = pure []

addData :: DataTy -> EM ()
addData dt = modify (\s -> s { ecDT = Map.insert (dataName dt) dt (ecDT s) })

buildTConInfo :: DataTy -> TConInfo
buildTConInfo (DataTy n tvs dcs) = (tvs, map conInfo dcs) where
  conInfo (Constr n ts) = (n, ts)

emitContract :: Contract Id -> EM Core.Contract
emitContract c = do
    let cname = show (name c)
    writes ["Emitting core for contract ", cname]
    coreBody <- concatMapM emitCDecl (decls c)
    let result = Core.Contract cname coreBody
    writeln (show result)
    -- let filename = cname ++ ".core"
    -- use output.core for now to make testing easier
    let filename = "output.core"
    writeln ("Writing to " ++ filename)
    liftIO $ writeFile filename (show result)
    pure result

emitCDecl :: ContractDecl Id -> EM [Core.Stmt]
emitCDecl cd@(CFunDecl f) = do
    -- debug ["!! emitCDecl ", show cd]
    emitFunDef f
emitCDecl cd@(CDataDecl dt) = do
    -- debug ["!! emitCDecl ", show cd]
    addData dt >> pure []
emitCDecl cd = debug ["!! emitCDecl ", show cd] >> pure []

emitFunDef :: FunDef Id -> EM [Core.Stmt]
emitFunDef (FunDef sig body) = do
  (name, args, typ) <- translateSig sig
  coreBody <- concatMapM emitStmt body
  let coreFun = Core.SFunction name args typ coreBody
  return [coreFun]

translateSig :: Signature Id -> EM (CoreName, [Core.Arg], Core.Type)
translateSig sig@(Signature n ctxt args (Just ret)) = do
  dataTable <- gets ecDT
  -- debug ["translateSig ", show sig]
  let name = unName n
  coreTyp <- translateType ret
  coreArgs <- mapM translateArg args
  return (name, coreArgs, coreTyp)
translateSig sig = errors ["No return type in ", show sig]

translateArg :: Param Id -> EM Core.Arg
translateArg p =  Core.TArg (unName n) <$> translateType t
    where Id n t = getParamId p

getParamId :: Param Id -> Id
getParamId (Typed i _) = i
getParamId (Untyped i) = i

translateType :: Ty -> EM Core.Type
translateType (TyCon "Word" []) = pure Core.TWord
-- translateType _ Fun.TBool = Core.TBool
translateType (TyCon "Unit" []) = pure Core.TUnit
translateType t@(u :-> v) = error ("Cannot translate function type " ++ show t)
translateType (TyCon name tas) = translateTCon name tas
translateType t = error ("Cannot translate type " ++ show t)

translateTCon :: Name -> [Ty] -> EM Core.Type
translateTCon tycon tas = do
    dumpDT
    mti <- gets (Map.lookup tycon . ecDT)
    case mti of
        Just (DataTy n tvs cs) -> do
            let subst = Subst $ zip tvs tas
            buildSumType <$> mapM (translateDCon subst) cs
        Nothing -> errors["translateTCon: unknown type ", pretty tycon, "\n", show tycon]
  where
      buildSumType [] = errors["empty sum ", pretty tycon] -- Core.TUnit
      buildSumType ts = foldr1 Core.TSum ts


translateDCon :: Subst -> Constr -> EM Core.Type
translateDCon subst  (Constr name tas) = translateProductType (apply subst tas)

translateProductType :: [Ty] -> EM Core.Type
translateProductType [] = pure Core.TUnit
translateProductType ts = foldr1 Core.TPair <$> mapM translateType ts

emitLit :: Literal -> Core.Expr
emitLit (IntLit i) = Core.EWord i
emitLit (StrLit s) = error "String literals not supported yet"

emitConApp :: Id -> [Exp Id] -> Translation Core.Expr
emitConApp (Id n (TyCon tcname tas)) as = do
  mti <- gets (Map.lookup tcname . ecDT)
  case mti of
    Just (DataTy _ tvs allCons) -> do
        (prod, code) <- translateProduct as
        let result = encodeCon n allCons prod
        pure (result, code)
    Nothing -> errors ["emitConApp: unknown type ", pretty tcname, "\n", show tcname]

translateProduct :: [Exp Id] -> Translation Core.Expr
translateProduct [] = pure (Core.EUnit, [])
translateProduct es = do
    (coreExps, codes) <- unzip <$> mapM emitExp es
    let product = foldr1 (Core.EPair) coreExps
    pure (product, concat codes)

encodeCon :: Name -> [Constr] -> Core.Expr -> Core.Expr
encodeCon n [c] e | constrName c == n = e
encodeCon n (con:cons) e
    | constrName con == n = Core.EInl e
    | otherwise = Core.EInr (encodeCon n cons e)

emitExp :: Exp Id -> Translation Core.Expr
emitExp (Lit l) = pure (emitLit l, [])
emitExp (Var x) = do
    subst <- gets ecSubst
    case Map.lookup (idName x) subst of
        Just e -> pure (e, [])
        Nothing -> pure(Core.EVar (unwrapId x), [])
emitExp (Call Nothing f as) = do
    (coreArgs, codes) <- unzip <$> mapM emitExp as
    let call =  Core.ECall (unwrapId f) coreArgs
    pure (call, concat codes)
emitExp e@(Con i as) = emitConApp i as
emitExp e = errors ["emitExp not implemented for: ", pretty e, "\n", show e]

emitStmt :: Stmt Id -> EM [Core.Stmt]
emitStmt (StmtExp e) = do
    (e', stmts) <- emitExp e
    pure (stmts ++ [Core.SExpr e'])
emitStmt s@(Return e) = do
    (e', stmts) <- emitExp e
    let result = stmts ++ [Core.SReturn e']
    --- debug ["<  emitStmt ", show (Core.Core result)]
    return result

writeln :: MonadIO m => String -> m ()
writeln = liftIO . putStrLn
writes :: MonadIO m => [String] -> m ()
writes = writeln . concat
errors :: [String] -> a
errors = error . concat

debug :: [String] -> EM ()
debug msg = do
    enabled <- gets ecDebug
    when enabled $ writes msg

dumpDT :: EM ()
dumpDT = do
    tis <- gets (Map.toList . ecDT)
    -- debug ["Data: ", unlines (map show tis)]
    debug ["Data: ", show tis]

concatMapM :: (Traversable t, Monad f) => (a -> f [b]) -> t a -> f [b]
concatMapM f xs = concat <$> mapM f xs


unwrapId :: Id -> CoreName
unwrapId = unName . idName

unwrapTyvar :: Tyvar -> CoreName
unwrapTyvar (TVar n) = unName n
