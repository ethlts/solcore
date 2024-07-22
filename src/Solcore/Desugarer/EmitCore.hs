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
    , ecTT :: TypeTable
    , ecNest :: Int
    , ecDebug :: Bool
    }

initEcState :: Bool -> TcEnv -> EcState
initEcState debugp env = EcState
   { ecSubst = emptyVSubst
   , ecTT = typeTable env
   , ecNest = 0
   , ecDebug = debugp
   }

type VSubst = Map.Map Name Core.Expr
emptyVSubst :: VSubst
emptyVSubst = Map.empty

type Translation a = EM (a, [Core.Stmt])

type CoreName = String

emitTopDecl :: TopDecl Id -> EM [Core.Contract]
emitTopDecl (TContr c) = fmap pure (emitContract c)
emitTopDecl _ = pure []

emitContract :: Contract Id -> EM Core.Contract
emitContract c = do
    tis <- gets (Map.toList . ecTT)
    debug ["TT: ", unlines (map show tis)]
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
emitCDecl (CFunDecl f) = emitFunDef f
emitCDecl _ = pure []

emitFunDef :: FunDef Id -> EM [Core.Stmt]
emitFunDef (FunDef sig body) = do
  (name, args, typ) <- translateSig sig
  coreBody <- concatMapM emitStmt body
  let coreFun = Core.SFunction name args typ coreBody
  return [coreFun]

translateSig :: Signature Id -> EM (CoreName, [Core.Arg], Core.Type)
translateSig sig@(Signature n ctxt args (Just ret)) = do
  typeTable <- gets ecTT
  debug ["translateSig ", show sig]
  let name = unName n
  let coreTyp = translateType typeTable ret
  let coreArgs = map (translateArg typeTable) args
  return (name, coreArgs, coreTyp)
translateSig sig = errors ["No return type in ", show sig]

translateArg :: TypeTable -> Param Id -> Core.Arg
translateArg tt (Typed x t) = Core.TArg (unwrapId x) (translateType tt t)
translateArg tt (Untyped (Id n t)) = Core.TArg (unName n) (translateType tt t)

translateType :: TypeTable -> Ty -> Core.Type
translateType _ (TyCon "Word" []) = Core.TWord
-- translateType _ Fun.TBool = Core.TBool
translateType _ (TyCon "Unit" []) = Core.TUnit
translateType _ t@(u :-> v) = error ("Cannot translate function type " ++ show t)
-- translateType tt (TyCon name tas) = translateTCon tt name tas


emitLit :: Literal -> Core.Expr
emitLit (IntLit i) = Core.EWord i
emitLit (StrLit s) = error "String literals not supported yet"

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
emitExp e = errors ["emitExp not implemented for: ", pretty e, "\n", show e]

emitStmt :: Stmt Id -> EM [Core.Stmt]
emitStmt (StmtExp e) = do
    (e', stmts) <- emitExp e
    pure (stmts ++ [Core.SExpr e'])
emitStmt s@(Return e) = do
    debug ["> emitStmt ", pretty s]
    (e', stmts) <- emitExp e
    let result = stmts ++ [Core.SReturn e']
    debug ["<  emitStmt ", show (Core.Core result)]
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

concatMapM :: (Traversable t, Monad f) => (a -> f [b]) -> t a -> f [b]
concatMapM f xs = concat <$> mapM f xs


unwrapId :: Id -> String
unwrapId = unName . idName
