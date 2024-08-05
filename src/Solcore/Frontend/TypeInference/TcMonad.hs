module Solcore.Frontend.TypeInference.TcMonad where

import Control.Monad
import Control.Monad.Except
import Control.Monad.State 

import Data.List 
import Data.Map (Map)
import qualified Data.Map as Map

import Solcore.Frontend.Pretty.SolcorePretty hiding((<>))
import Solcore.Frontend.Syntax
import Solcore.Frontend.TypeInference.NameSupply
import Solcore.Frontend.TypeInference.TcEnv
import Solcore.Frontend.TypeInference.TcSubst
import Solcore.Frontend.TypeInference.TcUnify
import Solcore.Primitives.Primitives


-- definition of type inference monad infrastructure 

type TcM a = StateT TcEnv (ExceptT String IO) a 

runTcM :: TcM a -> TcEnv -> IO (Either String (a, TcEnv))
runTcM m env = runExceptT (runStateT m env)

freshVar :: TcM Tyvar 
freshVar 
  = do 
      ns <- gets nameSupply
      let (n, ns') = newName ns
      modify (\ ctx -> ctx {nameSupply = ns'})
      return (TVar n)

freshTyVar :: TcM Ty 
freshTyVar = TyVar <$> freshVar

getEnvFreeVars :: TcM [Tyvar]
getEnvFreeVars 
  = concat <$> gets (Map.map fv . ctx)

unify :: Ty -> Ty -> TcM Subst
unify t t' 
  = do
      -- info ["Unifying:", pretty t, " with ", pretty t']
      s <- getSubst 
      s' <- mgu (apply s t) (apply s t')
      extSubst s'

-- type instantiation 

freshInst :: Scheme -> TcM (Qual Ty)
freshInst (Forall vs qt)
  = renameVars vs qt

renameVars :: HasType a => [Tyvar] -> a -> TcM a 
renameVars vs t 
  = do 
      s <- mapM (\ v -> (v,) <$> freshTyVar) vs
      pure $ apply (Subst s) t

-- substitution 

withCurrentSubst :: HasType a => a -> TcM a
withCurrentSubst t = do
  s <- gets subst
  pure (apply s t)

getSubst :: TcM Subst 
getSubst = gets subst

extSubst :: Subst -> TcM Subst
extSubst s = modify ext >> getSubst where
    ext st = st{ subst = s <> subst st }

withLocalSubst :: HasType a => TcM a -> TcM a 
withLocalSubst m 
  = do 
      s <- getSubst 
      r <- m 
      modify (\ st -> st {subst = s})
      pure (apply s r)

clearSubst :: TcM ()
clearSubst = modify (\ st -> st {subst = mempty})

-- current contract manipulation 

setCurrentContract :: Name -> Arity -> TcM ()
setCurrentContract n ar 
  = modify (\ ctx -> ctx{ contract = Just n })

askCurrentContract :: TcM Name 
askCurrentContract 
  = do 
      n <- gets contract
      maybe (throwError "Impossible! Lacking current contract name!")
            pure  
            n 

-- manipulating contract field information

askField :: Name -> Name -> TcM Scheme 
askField cn fn 
  = do 
      ti <- askTypeInfo cn 
      when (fn `notElem` fieldNames ti) 
           (undefinedField cn fn)
      askEnv fn

-- manipulating data constructor information 

checkConstr :: Name -> Name -> TcM ()
checkConstr tn cn 
  = do 
      ti <- askTypeInfo tn 
      when (cn `notElem` constrNames ti)
           (undefinedConstr tn cn)

-- extending the environment with a new variable 

extEnv :: Name -> Scheme -> TcM ()
extEnv n t 
  = modify (\ sig -> sig {ctx = Map.insert n t (ctx sig)})

withExtEnv :: Name -> Scheme -> TcM a -> TcM a 
withExtEnv n s m 
  = withLocalEnv (extEnv n s >> m)

withLocalCtx :: [(Name, Scheme)] -> TcM a -> TcM a 
withLocalCtx ctx m 
  = withLocalEnv do 
        mapM_ (\ (n,s) -> extEnv n s) ctx 
        a <- m
        pure a

-- Updating the environment 

putEnv :: Env -> TcM ()
putEnv ctx 
  = modify (\ sig -> sig{ctx = ctx})

-- Extending the environment 

withLocalEnv :: TcM a -> TcM a 
withLocalEnv ta 
  = do 
      ctx <- gets ctx 
      a <- ta 
      putEnv ctx 
      pure a 

envList :: TcM [(Name, Scheme)]
envList = gets (Map.toList . ctx)

-- environment operations: variables 

maybeAskEnv :: Name -> TcM (Maybe Scheme)
maybeAskEnv n = gets (Map.lookup n . ctx)

askEnv :: Name -> TcM Scheme 
askEnv n 
  = do
      s <- maybeAskEnv n
      maybe (undefinedName n) pure s

-- type information

maybeAskTypeInfo :: Name -> TcM (Maybe TypeInfo)
maybeAskTypeInfo n 
  = gets (Map.lookup n . typeTable)

askTypeInfo :: Name -> TcM TypeInfo 
askTypeInfo n 
  = do 
      ti <- maybeAskTypeInfo n 
      maybe (undefinedType n) pure ti

modifyTypeInfo :: Name -> TypeInfo -> TcM ()
modifyTypeInfo n ti 
  = do 
        tenv <- gets typeTable
        let tenv' = Map.insert n ti tenv
        modify (\env -> env{typeTable = tenv'})


-- manipulating the instance environment 

askInstEnv :: Name -> TcM [Inst]
askInstEnv n 
  = maybe [] id . Map.lookup n <$> gets instEnv

getInstEnv :: TcM InstTable 
getInstEnv = gets instEnv

addInstance :: Name -> Inst -> TcM ()
addInstance n inst 
  = modify (\ ctx -> 
      ctx{instEnv = Map.insertWith (++) n [inst] (instEnv ctx)})  
      

maybeToTcM :: String -> Maybe a -> TcM a 
maybeToTcM s Nothing = throwError s 
maybeToTcM _ (Just x) = pure x

-- checking coverage pragma 

askCoverage :: TcM Bool 
askCoverage = gets enableCoverage

setCoverage :: Bool -> TcM ()
setCoverage b 
  = modify (\env -> env{ enableCoverage = b})

-- recursion depth 

askMaxRecursionDepth :: TcM Int 
askMaxRecursionDepth = gets maxRecursionDepth 

-- logging utilities

setLogging :: Bool -> TcM ()
setLogging b = modify (\ r -> r{enableLog = b})

isLogging :: TcM Bool 
isLogging = gets enableLog

info :: [String] -> TcM ()
info ss = do
            logging <- isLogging
            when logging $ modify (\ r -> r{ logs = concat ss : logs r })

warn :: [String] -> TcM ()
warn ss 
  = modify (\ r -> r{ logs = concat ss : logs r })

-- wrapping error messages 

wrapError :: Pretty b => TcM a -> b -> TcM a
wrapError m e 
  = catchError m handler 
    where 
      handler msg = throwError (decorate msg)
      decorate msg = msg ++ "\n - in:" ++ pretty e

-- error messages 

undefinedName :: Name -> TcM a 
undefinedName n 
  = throwError $ unwords ["Undefined name:", pretty n]

undefinedType :: Name -> TcM a 
undefinedType n 
  = do
      s <- (unlines . reverse) <$> gets logs 
      throwError $ unwords ["Undefined type:", pretty n, "\n", s]

undefinedField :: Name -> Name -> TcM a 
undefinedField n n'
  = throwError $ unlines ["Undefined field:"
                         , pretty n
                         , "in type:"
                         , pretty n'
                         ]

undefinedConstr :: Name -> Name -> TcM a 
undefinedConstr tn cn 
  = throwError $ unlines [ "Undefined constructor:"
                         , pretty cn 
                         , "in type:"
                         , pretty tn]

undefinedFunction :: Name -> Name -> TcM a 
undefinedFunction t n 
  = throwError $ unlines [ "The type:"
                         , pretty t 
                         , "does not define function:"
                         , pretty n
                         ]
