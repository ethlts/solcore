module Solcore.Desugarer.CallDesugarer where 

import Control.Monad.Except
import Control.Monad.State

import Data.List
import Data.Maybe

import Solcore.Frontend.Syntax
import Solcore.Frontend.Pretty.SolcorePretty
import Solcore.Frontend.TypeInference.TcSubst (fv)
import Solcore.Primitives.Primitives 

desugarCalls :: CompUnit Name -> IO (CompUnit Name)
desugarCalls cunit 
  = do 
       (cunit', env') <- runCallM (desugar' cunit) (mkEnv cunit)
       pure (addNewDefs cunit' (declarations env'))
       
        
desugar' :: CompUnit Name -> CallM (CompUnit Name)
desugar' cunit 
  = do 
      cunit' <- desugarIndirectCalls cunit 
      desugarLambdas cunit' 

addNewDefs :: CompUnit Name -> [TopDecl Name] -> CompUnit Name 
addNewDefs (CompUnit imps ds) ds' 
  = CompUnit imps (ds ++ ds')

-- desugaring lambdas

class DesugarLambdas a where 
  desugarLambdas :: a -> CallM a 

instance DesugarLambdas a => DesugarLambdas [a] where 
  desugarLambdas = mapM desugarLambdas

instance DesugarLambdas (CompUnit Name) where 
  desugarLambdas (CompUnit imps ds)
    = CompUnit imps <$> desugarLambdas ds 

instance DesugarLambdas (TopDecl Name) where 
  desugarLambdas (TContr cd) 
    = TContr <$> desugarLambdas cd 
  desugarLambdas (TFunDef fd)
    = TFunDef <$> desugarLambdas fd 
  desugarLambdas (TInstDef ins)
    = TInstDef <$> desugarLambdas ins 
  desugarLambdas (TMutualDef ts)
    = TMutualDef <$> desugarLambdas ts 
  desugarLambdas t = pure t

instance DesugarLambdas (Contract Name) where
  desugarLambdas (Contract n ts ds) 
    = Contract n ts <$> desugarLambdas ds 

instance DesugarLambdas (FunDef Name) where 
  desugarLambdas (FunDef sig bd)
    = FunDef sig <$> desugarLambdas bd 

instance DesugarLambdas (ContractDecl Name) where 
  desugarLambdas (CFunDecl fd) 
    = CFunDecl <$> desugarLambdas fd 
  desugarLambdas (CMutualDecl cs)
    = CMutualDecl <$> desugarLambdas cs 
  desugarLambdas (CConstrDecl cc)
    = CConstrDecl <$> desugarLambdas cc 
  desugarLambdas cd = pure cd 

instance DesugarLambdas (Constructor Name) where 
  desugarLambdas (Constructor ps bd)
    = Constructor ps <$> desugarLambdas bd 

instance DesugarLambdas (Instance Name) where 
  desugarLambdas (Instance ps n ts t fs)
    = Instance ps n ts t <$> desugarLambdas fs 
    
instance DesugarLambdas (Stmt Name) where 
  desugarLambdas (e1 := e2)
    = (:=) <$> desugarLambdas e1 <*> desugarLambdas e2 
  desugarLambdas (Let v mt (Just e))
    = do 
        e' <- desugarLambdas e 
        pure (Let v mt (Just e'))
  desugarLambdas (StmtExp e)
    = StmtExp <$> desugarLambdas e 
  desugarLambdas (Return e)
    = Return <$> desugarLambdas e 
  desugarLambdas (Match es eqns)
    = Match <$> desugarLambdas es <*> desugarLambdas eqns 
  desugarLambdas s = pure s 

instance DesugarLambdas (Equation Name) where 
  desugarLambdas (ps, bd) 
    = (ps,) <$> desugarLambdas bd 

instance DesugarLambdas (Exp Name) where 
  desugarLambdas (Con n es)
    = Con n <$> desugarLambdas es 
  desugarLambdas (FieldAccess e n)
    = flip FieldAccess n <$> desugarLambdas e 
  desugarLambdas e@(Lam ps bd mt)
    | isCaptureFree e 
      = desugarCaptureFreeLam e 
    | otherwise = pure e 
  desugarLambdas (Call me n es) 
    = do 
        me' <- maybe (pure Nothing)
                     (\ e -> Just <$> desugarLambdas e)
                     me 
        es' <- desugarLambdas es 
        pure (Call me' n es')
  desugarLambdas e = pure e 

isCaptureFree :: Exp Name -> Bool 
isCaptureFree e@(Lam ps bd mt)
  = null (vars e) &&                                        -- no free program variables in scope 
    null (fv (map paramType ps) `union` maybe [] fv mt) ||  -- no type variables
    not (any isUntyped ps) || -- parameters without types, should be considered polymorphic for now.  
    not (isNothing mt)        -- no return types.
  where 
    isUntyped (Untyped _) = True 
    isUntyped _ = False 

desugarCaptureFreeLam :: Exp Name -> CallM (Exp Name)
desugarCaptureFreeLam e@(Lam ps bd mt) 
  = do 
      n <- freshCounter
      let s = Name ("lambda_impl" <> show n)
          -- for now, lambdas do not have context in syntax 
          sig = Signature s [] ps mt
          ce = Call Nothing s [] 
          fd = FunDef sig bd 
      addFunDef fd
      debugDesugarCaptureFreeLam e ce fd
      mkFunctionType sig 
      pure ce
desugarCaptureFreeLam e = pure e 

-- desugarCaptureLam :: Exp Name -> CallM (Exp Name)
-- desugarCaptureLam e@(Lam ps bd mt) 
--   = do 
--       -- first we conver all untyped 
--       -- parameters to typed ones with 
--       -- fresh variables 
--       n <- freshCounter 
--       ps' <- mapM typedParam ps
--       mt' <- maybe freshTyVar pure mt 
--       let s = Name ("lambda_impl" <> show n)
--           vs = vars e -- free variables inside lambda 
--       ps'' <- mapM (typedParam . Untyped) vs 
--       let sig = Signature s [] (ps'' ++ ps') (Just mt')
--       addFunDef (FunDef sig bd)
--       pure e
-- desugarCaptureLam e = pure e 
--

debugDesugarCaptureFreeLam :: Exp Name -> Exp Name -> FunDef Name -> CallM ()
debugDesugarCaptureFreeLam e cd fd 
  = do 
      let s = unlines ["Desugaring for capture free lambda:"
                      , pretty e 
                      ,"Resulting function definition:"
                      , pretty fd 
                      ,"Resulting call:"
                      , pretty cd]
      addDebugInfo s

-- desugaring indirect calls 

class IndirectCalls a where 
  desugarIndirectCalls :: a -> CallM a 

instance IndirectCalls a => IndirectCalls [a] where 
  desugarIndirectCalls = mapM desugarIndirectCalls

instance IndirectCalls (CompUnit Name) where 
  desugarIndirectCalls (CompUnit imps ds)
    = CompUnit imps <$> desugarIndirectCalls ds 

instance IndirectCalls (TopDecl Name) where 
  desugarIndirectCalls (TContr cd) 
    = TContr <$> desugarIndirectCalls cd 
  desugarIndirectCalls (TFunDef fd)
    = TFunDef <$> desugarIndirectCalls fd 
  desugarIndirectCalls (TInstDef ins)
    = TInstDef <$> desugarIndirectCalls ins 
  desugarIndirectCalls (TMutualDef ts)
    = TMutualDef <$> desugarIndirectCalls ts 
  desugarIndirectCalls t = pure t

instance IndirectCalls (Contract Name) where
  desugarIndirectCalls (Contract n ts ds) 
    = Contract n ts <$> desugarIndirectCalls ds 

instance IndirectCalls (FunDef Name) where 
  desugarIndirectCalls (FunDef sig bd)
    = FunDef sig <$> desugarIndirectCalls bd 

instance IndirectCalls (ContractDecl Name) where 
  desugarIndirectCalls (CFunDecl fd) 
    = CFunDecl <$> desugarIndirectCalls fd 
  desugarIndirectCalls (CMutualDecl cs)
    = CMutualDecl <$> desugarIndirectCalls cs 
  desugarIndirectCalls (CConstrDecl cc)
    = CConstrDecl <$> desugarIndirectCalls cc 
  desugarIndirectCalls cd = pure cd 

instance IndirectCalls (Constructor Name) where 
  desugarIndirectCalls (Constructor ps bd)
    = Constructor ps <$> desugarIndirectCalls bd 

instance IndirectCalls (Instance Name) where 
  desugarIndirectCalls (Instance ps n ts t fs)
    = Instance ps n ts t <$> desugarIndirectCalls fs 
    
instance IndirectCalls (Stmt Name) where 
  desugarIndirectCalls (e1 := e2)
    = (:=) <$> desugarIndirectCalls e1 <*> desugarIndirectCalls e2 
  desugarIndirectCalls (Let v mt (Just e))
    = do 
        e' <- desugarIndirectCalls e 
        pure (Let v mt (Just e'))
  desugarIndirectCalls (StmtExp e)
    = StmtExp <$> desugarIndirectCalls e 
  desugarIndirectCalls (Return e)
    = Return <$> desugarIndirectCalls e 
  desugarIndirectCalls (Match es eqns)
    = Match <$> desugarIndirectCalls es <*> desugarIndirectCalls eqns 
  desugarIndirectCalls s = pure s 

instance IndirectCalls (Equation Name) where 
  desugarIndirectCalls (ps, bd) 
    = (ps,) <$> desugarIndirectCalls bd 

instance IndirectCalls (Exp Name) where 
  desugarIndirectCalls (Con n es)
    = Con n <$> desugarIndirectCalls es 
  desugarIndirectCalls (FieldAccess e n)
    = flip FieldAccess n <$> desugarIndirectCalls e 
  desugarIndirectCalls (Lam ps bd mt)
    = Lam ps <$> desugarIndirectCalls bd <*> pure mt 
  desugarIndirectCalls x@(Call (Just e) n es) 
    = mkInvokeCall x e es 
  desugarIndirectCalls (Call Nothing n es)
    = Call Nothing n <$> desugarIndirectCalls es 
  desugarIndirectCalls e = pure e 

mkInvokeCall :: Exp Name -> Exp Name -> [Exp Name] -> CallM (Exp Name)
mkInvokeCall x e args 
  = do
      e' <- desugarIndirectCalls e 
      args' <- desugarIndirectCalls args 
      let
        n = Name "invoke"
        r = Call Nothing n (e' : args')
      debugMkInvokeCall x r 
      pure r 

debugMkInvokeCall :: Exp Name -> Exp Name -> CallM ()
debugMkInvokeCall org nw 
  = do 
      let s = unlines ["Original call:"
                      , pretty org 
                      , "Transformed call:"
                      , pretty nw 
                      ]
      addDebugInfo s

-- creating types for each function definition 

mkFunctionTypes :: [FunDef Name] -> CallM ()
mkFunctionTypes 
  = mapM_ (mkFunctionType . funSignature)

mkFunctionType :: Signature Name -> CallM ()
mkFunctionType sig@(Signature (Name f) ctx ps mt)
  = do
      i <- freshCounter 
      let
        vs = fv ctx `union` tr `union` fv ts  
        tr = maybe [] fv mt
        ts = concatMap paramType ps 
        s = concat ["Type_", f, "_", show i]
        n = Name s 
        c = Name (s ++ "_Con")
        tc = TyCon n []
        dc = Constr c [tc]
        dt = DataTy n vs [dc]
      addDataTy dt 
      debugMkFunctionType sig dt

debugMkFunctionType :: Signature Name -> DataTy -> CallM ()
debugMkFunctionType sig dt 
  = do 
      let s = unlines [ "Creating type"
                      , pretty dt 
                      , "for function"
                      , pretty sig 
                      ]
      addDebugInfo s 

paramType :: Param Name -> [Ty]
paramType (Typed _ t) = [t]
paramType _ = []

typedParam :: Param Name -> CallM (Param Name)
typedParam t@(Typed _ _) = pure t 
typedParam (Untyped n) 
  = Typed n <$> freshTyVar 
      
-- monad for the whole call desugar transform 

data Env 
  = Env {
      info :: ModuleInfo 
    , fresh :: Int
    , declarations :: [TopDecl Name]
    , debugInfo :: [String]
    } 

type CallM a = (StateT Env IO) a 

runCallM :: CallM a -> Env -> IO (a, Env)
runCallM m env 
  = runStateT m env

mkEnv :: CompUnit Name -> Env 
mkEnv cunit = Env (collect cunit) 0 [] []

-- basic monad operations 

addDebugInfo :: String -> CallM () 
addDebugInfo s 
  = modify (\ env -> env {debugInfo = s : debugInfo env})

freshCounter :: CallM Int 
freshCounter 
  = do 
      env <- get 
      let n = fresh env 
      put (env {fresh = n + 1})
      pure n 

freshTyVar :: CallM Ty 
freshTyVar 
  = do 
      n <- freshCounter 
      pure (TyVar (TVar (Name $ "v" ++ show n)))

moduleInfo :: CallM ModuleInfo 
moduleInfo = gets info 

addDecl :: TopDecl Name -> CallM ()
addDecl d = 
  modify (\env -> env {declarations = d : declarations env})

addFunDef :: FunDef Name -> CallM ()
addFunDef fd 
  = addDecl (TFunDef fd)

addDataTy :: DataTy -> CallM ()
addDataTy dt 
  = addDecl (TDataDef dt)

-- collecting all definitions generating 
-- calls

type Lambda = ([Param Name], Body Name, Maybe Ty)

data ModuleInfo 
  = ModuleInfo {
      functions :: [FunDef Name]
    , lambdas   :: [Lambda]
    , classes :: [Class Name]
    , instances :: [Instance Name]
    } deriving Eq 

buildModuleInfo :: CompUnit Name -> ModuleInfo
buildModuleInfo (CompUnit _ cs) = collect cs

instance Semigroup ModuleInfo where 
  (ModuleInfo fs ls cls ins) <> (ModuleInfo fs' ls' cls' ins')
    = ModuleInfo (fs <> fs') 
          (ls <> ls')
          (cls <> cls')
          (ins <> ins')

instance Monoid ModuleInfo where 
  mempty = ModuleInfo [] [] [] []

class Collect a where 
  collect :: a -> ModuleInfo

instance Collect a => Collect [a] where 
  collect = foldr step mempty  
      where
        step x ac = collect x <> ac

insertFunction :: FunDef Name -> ModuleInfo -> ModuleInfo
insertFunction fd env
  = env { functions = fd : (functions env) } 

insertLambda :: Lambda -> ModuleInfo -> ModuleInfo 
insertLambda ld env 
  = env { lambdas = ld : lambdas env }

insertClass :: Class Name -> ModuleInfo -> ModuleInfo 
insertClass cls env 
  = env { classes = cls : classes env }

insertInstance :: Instance Name -> ModuleInfo -> ModuleInfo 
insertInstance ins env 
  = env { instances = ins : instances env }

instance Collect (CompUnit Name) where 
  collect (CompUnit _ ds) = collect ds 

instance Collect (TopDecl Name) where 
  collect (TContr c) 
    = collect c 
  collect (TFunDef fd) 
    = insertFunction fd (collect fd)  
  collect (TInstDef ids)
    = insertInstance ids (collect ids)
  collect (TClassDef cls)
    = insertClass cls (collect cls)
  collect (TMutualDef tds)
    = collect tds 
  collect _ = mempty 

instance Collect (Contract Name) where 
  collect (Contract _ _ ds) = collect ds

instance Collect (ContractDecl Name) where 
  collect (CFunDecl fd)
    = insertFunction fd (collect fd)
  collect (CMutualDecl cs)
    = collect cs 
  collect (CFieldDecl fd)
    = collect fd 
  collect (CConstrDecl cd)
    = collect cd 
  collect _ = mempty 

instance Collect (Class Name) where 
  collect _ = mempty 

instance Collect (Instance Name) where 
  collect ins 
    = foldr insertFunction mempty (instFunctions ins)

instance Collect (Constructor Name) where 
  collect cons 
    = collect (constrBody cons)

instance Collect (Field Name) where 
  collect fd 
    = maybe mempty collect (fieldInit fd)

instance Collect (FunDef Name) where 
  collect fd 
    = collect (funDefBody fd)

instance Collect (Stmt Name) where 
  collect (e1 := e2) = collect [e1, e2]
  collect (Let _ _ me)
    = maybe mempty collect me 
  collect (StmtExp e) = collect e 
  collect (Return e) = collect e 
  collect (Match _ eqns) = collect eqns 
  collect _ = mempty 

instance Collect (Equation Name) where 
  collect (_ , bd) = collect bd 

instance Collect (Exp Name) where 
  collect (Con _ es) = collect es 
  collect (FieldAccess e _) = collect e 
  collect (Call (Just e) _ es)
    = collect (e : es)
  collect (Lam ps bd mt) 
    = insertLambda (ps,bd,mt) (collect bd)
  collect _ = mempty 

-- determining free variables 

class Vars a where 
  vars :: a -> [Name]

instance Vars a => Vars [a] where 
  vars = foldr (union . vars) []

instance Vars (Pat Name) where 
  vars (PVar v) = [v]
  vars (PCon _ ps) = vars ps 
  vars _ = []

instance Vars (Param Name) where 
  vars (Typed n _) = [n]
  vars (Untyped n) = [n]

instance Vars (Stmt Name) where 
  vars (e1 := e2) = vars [e1,e2]
  vars (Let _ _ (Just e)) = vars e
  vars (Let _ _ _) = []
  vars (StmtExp e) = vars e 
  vars (Return e) = vars e 
  vars (Match e eqns) = vars e `union` vars eqns 

instance Vars (Equation Name) where 
  vars (_, ss) = vars ss 

instance Vars (Exp Name) where 
  vars (Var n) = [n]
  vars (Con _ es) = vars es 
  vars (FieldAccess e _) = vars e
  vars (Call (Just e) n es) = [n] `union` vars (e : es)
  vars (Call Nothing n es) = [n] `union` vars es 
  vars (Lam ps bd _) = vars bd \\ vars ps
  vars _ = []
