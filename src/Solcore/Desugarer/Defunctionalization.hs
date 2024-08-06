module Solcore.Desugarer.Defunctionalization where

import Control.Monad
import Control.Monad.Except
import Control.Monad.Identity
import Control.Monad.State

import Data.Generics hiding (mkConstr, Constr)
import Data.Generics.Schemes
import Data.List
import Data.Map (Map)
import qualified Data.Map as Map 

import Solcore.Frontend.Pretty.SolcorePretty
import Solcore.Frontend.Syntax
import Solcore.Frontend.TypeInference.Id
import Solcore.Frontend.TypeInference.NameSupply
import Solcore.Frontend.TypeInference.TcEnv
import Solcore.Frontend.TypeInference.TcSubst 


-- top level function 

defunctionalize :: TcEnv -> CompUnit Id -> IO ()
defunctionalize env cunit@(CompUnit _ ds)  
  = do 
      runDefunM (defunM cunit) pool fs (Map.keys (ctx env))
      return () 
    where 
      pool = nameSupply env
      fs = map go ds' 
      go f@(FunDef sig _) = (sigName sig, f)
      ds' = concatMap (listify p) ds 
      p (FunDef _ _) = True 

-- definition of the defunctionalization monad 

type DefunM a = StateT DEnv (ExceptT String IO) a 

data DEnv 
  = DEnv {
      names :: NameSupply
    , fundefs :: [(Name, FunDef Id)] -- function definitions 
    , defs :: [Name] 
    }

askFunDef :: Name -> DefunM (FunDef Id)
askFunDef n@(Name s) 
  = do 
      r <- gets (lookup n . fundefs)
      case r of 
        Just sig -> pure sig
        Nothing -> throwError $ "Impossible! Undefined name:" ++ s
             

askSig :: Name -> DefunM (Signature Id)
askSig n = funSignature <$> askFunDef n

freshName :: DefunM Name 
freshName 
  = do  
      ns <- gets names
      let (n, ns') = newName ns 
      modify (\ denv -> denv {names = ns'})
      return n

runDefunM :: DefunM a -> 
             NameSupply -> 
             [(Name, FunDef Id)] -> 
             [Name] -> IO (Either String (a, DEnv))
runDefunM m pool funs defs
  = runExceptT (runStateT m (DEnv pool funs defs))

-- definition of the algorithm

defunM :: CompUnit Id -> DefunM (CompUnit Id)
defunM cunit@(CompUnit imps decls)
  = do 
      let ldefs = collectLam decls
          step k m ac = (k, Map.toList m) : ac 
          mdef = Map.foldrWithKey step [] ldefs
      dts <- mapM createDataTy mdef  
      liftIO $ mapM (putStrLn . pretty) dts
      -- FIXME Need to create an unique apply for function!
      dap <- zipWithM createApply mdef dts
      liftIO $ mapM (putStrLn . pretty) dap
      return cunit

-- definition of a type to hold lambda abstractions in code 

data LamDef 
  = LamDef { 
      lamArgs :: [Param Id] -- lambda arguments 
    , lamBody :: Body Id    -- lambda body
    , lamTy :: Ty           -- Type of the lambda abstraction 
    } deriving (Eq, Ord)

instance Show LamDef where 
  show (LamDef args bd _) = pretty $ Lam args bd Nothing

-- create apply function 

createApply :: (Name, [(Int, [LamDef])]) -> DataTy -> DefunM (FunDef Id)
createApply x@(n, ldefs) dt 
  = do 
      (lp, sig) <- createApplySignature x dt
      let cons = zip (concatMap snd ldefs) (dataConstrs dt)
      bd <- createApplyBody sig lp cons 
      pure (FunDef sig bd)

createApplySignature :: (Name, [(Int, [LamDef])]) -> 
                        DataTy -> 
                        DefunM (Param Id, Signature Id) 
createApplySignature (v@(Name n), pdefs) dt 
  = do 
      let (pos, ldefs) = unzip pdefs 
          n' = Name ("apply_" ++ n)
      -- getting function signature 
      sig <- askSig v 
      lts <- mapM (lamParam (sigParams sig)) pos 
      lp <- mkParam dt
      let args' = lp : (sigParams sig \\ lts)
      pure (lp, Signature n' [] args' (sigReturn sig))

lamParam :: [Param Id] -> Int -> DefunM (Param Id) 
lamParam ts p 
  = case splitAt (p + 1) ts of 
      (ts', _) -> 
        case unsnoc ts' of 
          Just (_, lt) -> pure lt 
          Nothing -> throwError "Impossible! lamType!"

mkParam :: DataTy -> DefunM (Param Id)
mkParam dt 
  = do 
      let tc = TyCon (dataName dt) (TyVar <$> dataParams dt)
      n <- freshName 
      pure (Typed (Id n tc) tc)


createApplyBody :: Signature Id -> 
                   Param Id -> 
                   [(LamDef, Constr)] -> DefunM (Body Id)
createApplyBody sig p@(Typed v t) ldefs 
  = do 
      let args = (sigParams sig) \\ [p]
      eqns <- mapM (mkEquation sig t args) ldefs 
      pure [Match [Var v] eqns]

mkEquation :: Signature Id -> 
              Ty ->
              [Param Id] -> 
              (LamDef, Constr) -> 
              DefunM (Equation Id)
mkEquation sig t args (ldef, c) 
  = do
      p <- mkPat t c
      bd <- mkBody sig p ldef t args  
      pure ([p], bd)

mkPat :: Ty -> Constr -> DefunM (Pat Id)
mkPat t (Constr n ts)
  = do 
      ps <- mapM mkPVar ts 
      let tf = funtype ts t 
      pure (PCon (Id n tf) ps)
    where 
      mkPVar t' = do 
        n' <- freshName 
        pure (PVar (Id n' t'))

mkBody :: Signature Id -> 
          Pat Id -> 
          LamDef -> 
          Ty -> 
          [Param Id] -> 
          DefunM (Body Id)
mkBody sig p ldef t args 
  = do
      ns <- gets defs
      apid <- idFromSignature sig
      let s = mkRename ns p ldef args
          bd = renameBody s (lamBody ldef)
      everywhereM (mkM (changeCall apid p t)) bd

idFromSignature :: Signature Id -> DefunM Id 
idFromSignature sig 
  = do 
      t <- maybe err pure (sigReturn sig)
      pure $ Id (sigName sig) (funtype ts t)
    where
      ts = map tyParam (sigParams sig)
      err = throwError "Impossible --- idFromSignature"
      tyParam (Typed (Id _ t) _) = t
      tyParam (Untyped (Id _ t)) = t

changeCall :: Id -> Pat Id -> Ty -> Exp Id -> DefunM (Exp Id)
changeCall fid (PCon _ ps) t e@(Call me cid args) 
  | (idName cid) `elem` (map idName $ vars ps)
    = do
        let args' = Var (Id (idName cid) t) : args
        pure $ Call me fid args'
  | otherwise = pure e
changeCall _ _ _ e = pure e

renameBody :: [(Name, Name)] -> Body Id -> Body Id
renameBody s bd 
  = everywhere (mkT (applyN s)) bd 
    where 
      applyN s (Id n' t) 
        = Id (maybe n' id (lookup n' s)) t 

mkRename :: [Name] -> Pat Id -> LamDef -> [Param Id] -> [(Name, Name)]
mkRename ns p ldef args 
      = let imgvars = map idName $ vars p
            imgvars1 = map idName $ vars args 
            domvars1 = map idName $ vars (lamArgs ldef)
            domvars = (map idName $ vars ldef) \\ ns
        in zip domvars imgvars ++ zip domvars1 imgvars1
--  
-- create data types for each lambda abstraction parameter 
-- of a high-order function. 

createDataTy :: (Name, [(Int, [LamDef])]) -> DefunM DataTy 
createDataTy (Name f, lams) 
  = do 
      ns <- gets defs
      cs <- mapM (mkConstrs ns n') lams
      let
        cs' = concat cs
        tvs = fv (concatMap constrTy cs')
      pure $ DataTy (Name n') tvs cs'
    where 
      n' = "Lam_" ++ f
 

mkConstrs :: [Name] -> String -> (Int, [LamDef]) -> DefunM [Constr]
mkConstrs ns s (i,ldefs)  
  = mapM (mkConstr ns s i) ldefs

mkConstr :: [Name] -> String -> Int -> LamDef -> DefunM Constr 
mkConstr ns s i ldef 
  = Constr n' <$> mapM (mkConstrParam s tvs (lamTy ldef) . idType) 
                       (filter valid $ vars ldef)
    where 
      valid (Id n _) = n `notElem` ns 
      tvs = fv (lamTy ldef)
      n' = Name (s ++ show i)

mkConstrParam :: String -> [Tyvar] -> Ty -> Ty -> DefunM Ty 
mkConstrParam s vs rt t@(_ :-> _) 
  | rt @= t 
    = pure $ TyCon (Name s) (TyVar <$> (fv t))
  | otherwise = pure t 
mkConstrParam _ _ _ t = pure t 

(@=) :: Ty -> Ty -> Bool 
(TyVar _) @= (TyVar _) = True 
(TyCon n ts) @= (TyCon n' ts')
  | n == n' && length ts == length ts' 
    = and (zipWith (@=) ts ts')
  | otherwise = False 

-- determining free variables 

class Vars a where 
  vars :: a -> [Id]

instance Vars a => Vars [a] where 
  vars = foldr (union . vars) []

instance Vars (Pat Id) where 
  vars (PVar v) = [v]
  vars (PCon _ ps) = vars ps 
  vars _ = []

instance Vars (Param Id) where 
  vars (Typed n _) = [n]
  vars (Untyped n) = [n]

instance Vars (Stmt Id) where 
  vars (e1 := e2) = vars [e1,e2]
  vars (Let _ _ (Just e)) = vars e
  vars (Let _ _ _) = []
  vars (StmtExp e) = vars e 
  vars (Return e) = vars e 
  vars (Match e eqns) = vars e `union` vars eqns 

instance Vars (Equation Id) where 
  vars (_, ss) = vars ss 

instance Vars (Exp Id) where 
  vars (Var n) = [n]
  vars (Con _ es) = vars es 
  vars (FieldAccess e _) = vars e
  vars (Call (Just e) n es) = [n] `union` vars (e : es)
  vars (Call Nothing n es) = [n] `union` vars es 
  vars (Lam ps bd _) = vars bd \\ vars ps
  vars _ = []

instance Vars LamDef where 
  vars (LamDef ps ss _) 
    = vars ss \\ ps' 
      where 
        vs = vars ps 
        isFun (_ :-> _) = True 
        isFun _ = False
        ps' = filter (not . isFun . idType) vs


-- collecting all lambdas that are parameter of high-order functions 

class CollectLam a where 
  -- mapping function names to lambda position parameters
  collectLam :: a -> Map Name (Map Int [LamDef])

instance CollectLam a => CollectLam [a] where 
  collectLam = foldr step Map.empty 
    where 
      step x ac = Map.unionWith (Map.unionWith (union)) (collectLam x) ac

instance CollectLam (CompUnit Id) where 
  collectLam (CompUnit _ cs) = collectLam cs

instance CollectLam (Contract Id) where 
  collectLam (Contract _ _ decls) = collectLam decls

instance CollectLam (ContractDecl Id) where 
  collectLam (CFieldDecl fd) = collectLam fd 
  collectLam (CFunDecl fd) = collectLam fd 
  collectLam (CMutualDecl ds) = collectLam ds 
  collectLam (CConstrDecl cs) = collectLam cs 
  collectLam _ = Map.empty 

instance CollectLam (TopDecl Id) where 
  collectLam (TContr cd) = collectLam cd 
  collectLam (TFunDef fd) = collectLam fd 
  collectLam (TInstDef is) = collectLam is 
  collectLam (TMutualDef ts) = collectLam ts 
  collectLam _ = Map.empty 

instance CollectLam (Constructor Id) where 
  collectLam (Constructor _ bd) = collectLam bd 

instance CollectLam (Field Id) where 
  collectLam (Field _ _ (Just e)) = collectLam e 
  collectLam _ = Map.empty 

instance CollectLam (Instance Id) where 
  collectLam (Instance _ _ _ _ fs) 
    = collectLam fs

instance CollectLam (FunDef Id) where 
  collectLam (FunDef _ bd) = collectLam bd 

instance CollectLam (Stmt Id) where 
  collectLam (_ := e) = collectLam e 
  collectLam (Let _ _ (Just e)) = collectLam e
  collectLam (StmtExp e) = collectLam e 
  collectLam (Return e) = collectLam e 
  collectLam (Match es eqns)
    = Map.unionWith (Map.unionWith (union)) (collectLam es) (collectLam eqns)

instance CollectLam (Equation Id) where 
  collectLam (_, bd) = collectLam bd 

instance CollectLam (Exp Id) where 
  collectLam (Con _ es) = collectLam es 
  collectLam (FieldAccess e _) = collectLam e 
  collectLam (Call (Just e) (Id n _) es) 
    = Map.unionWith (Map.unionWith (union)) 
                    (collectLam e) 
                    (collectArgs n (zip [0..] es))
  collectLam (Call _ (Id n _) es) = collectArgs n (zip [0..] es) 
  collectLam _ = Map.empty 

collectArgs :: Name -> [(Int, Exp Id)] -> Map Name (Map Int [LamDef])
collectArgs n = foldr step Map.empty 
  where 
    step (p, (Lam args bd (Just bt))) ac 
      = Map.insertWith (Map.unionWith (union)) n 
                       (Map.singleton p [LamDef args bd bt]) ac
    step e ac = Map.union (collectLam (snd e)) ac
    mkTy args t 
      = funtype (map paramTy args) t 
    paramTy (Typed _ t) = t

