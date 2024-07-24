module Solcore.Desugarer.Defunctionalization where

import Control.Monad
import Control.Monad.Except
import Control.Monad.Identity
import Control.Monad.State

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
defunctionalize env cunit  
  = runDefunM  (defunM cunit) env >> return () 

-- definition of the defunctionalization monad 

type DefunM a = StateT DEnv (ExceptT String IO) a 

data DEnv 
  = DEnv {
      names :: NameSupply
    , tyCtx :: Map Name Scheme -- typing context 
    }

askType :: Name -> DefunM Ty 
askType n@(Name s) 
  = do 
      r <- gets (Map.lookup n . tyCtx)
      case r of 
        Just (Forall _ (_ :=> t)) -> pure t
        Nothing -> throwError $ "Impossible! Undefined name:" ++ s
             

runDefunM :: DefunM a -> TcEnv -> IO (Either String (a, DEnv))
runDefunM m env 
  = runExceptT (runStateT m (DEnv (nameSupply env) (ctx env)))

-- definition of the algorithm

defunM :: CompUnit Id -> DefunM (CompUnit Id)
defunM cunit@(CompUnit imps decls)
  = do 
      ns <- gets (Map.keys . tyCtx)
      let ldefs = collectLam decls
          mdef = concatMap (\ (n, m) -> map (n,) (Map.toList m)) 
                           (Map.toList ldefs)
      dts <- mapM createDataTy mdef  
      liftIO $ mapM (putStrLn . pretty) dts
      -- dap <- zipWithM createApply mdef dts
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

createApply :: (Name, (Int, [LamDef])) -> DataTy -> DefunM (FunDef Id)
createApply x@(n, (p, ldefs)) dt 
  = FunDef <$> createApplySignature x dt <*> 
               createApplyBody (zip ldefs (dataConstrs dt)) 

createApplySignature :: (Name, (Int, [LamDef])) -> DataTy -> DefunM (Signature Id)
createApplySignature (v@(Name n), (p, ldefs)) dt 
  = do
      -- getting the function type 
      (ts,t) <- splitTy <$> askType v
      -- getting the type of the lambda parameter 
      let lt = ts !! p      
      undefined 
    where 
      n' = Name ("apply_" ++ n)

createApplyBody :: [(LamDef, Constr)] -> DefunM (Body Id)
createApplyBody = undefined 

-- create data types for each lambda abstraction parameter 
-- of a high-order function. 

createDataTy :: (Name, (Int, [LamDef])) -> DefunM DataTy 
createDataTy (Name f, (n, lams)) 
  = do 
      ns <- gets (Map.keys . tyCtx)
      cs <- zipWithM (mkConstr ns n') lams [0..]
      let tvs = fv (concatMap constrTy cs)
      pure $ DataTy (Name n') tvs cs
    where 
      n' = "Lam_" ++ f ++ show n
 

mkConstr :: [Name] -> String -> LamDef -> Int -> DefunM Constr 
mkConstr ns s ldef i  
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
    = Map.unionWith (Map.unionWith (union)) (collectLam e) 
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


