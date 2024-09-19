module Solcore.Frontend.TypeInference.TcContract where 

import Control.Monad
import Control.Monad.Except
import Control.Monad.Trans
import Control.Monad.State

import Data.Generics
import Data.List
import qualified Data.Map as Map

import Solcore.Frontend.Pretty.SolcorePretty
import Solcore.Frontend.Syntax
import Solcore.Frontend.TypeInference.Id
import Solcore.Frontend.TypeInference.NameSupply
import Solcore.Frontend.TypeInference.TcEnv
import Solcore.Frontend.TypeInference.TcMonad
import Solcore.Frontend.TypeInference.TcStmt
import Solcore.Frontend.TypeInference.TcSubst
import Solcore.Frontend.TypeInference.TcUnify
import Solcore.Primitives.Primitives

-- top level type inference function 

typeInfer :: CompUnit Name -> IO (Either String (CompUnit Id, TcEnv))
typeInfer c 
  = do 
      r <- runTcM (tcCompUnit c) initTcEnv  
      case r of 
        Left err -> pure $ Left err 
        Right (((CompUnit imps ds), ts), env) -> 
          pure (Right ((CompUnit imps (ds ++ ts)), env)) 

-- type inference for a compilation unit 

tcCompUnit :: CompUnit Name -> TcM (CompUnit Id)
tcCompUnit (CompUnit imps cs)
  = do 
      loadImports imps
      mapM_ checkTopDecl cls 
      mapM_ checkTopDecl cs'
      cs' <- mapM tcTopDecl' cs 
      pure (CompUnit imps cs')
    where
      (cls, cs') = partition isClass cs 
      isClass (TClassDef _) = True 
      isClass _ = False 
      tcTopDecl' d = do 
        clearSubst
        d' <- tcTopDecl d 
        s <- getSubst 
        pure (everywhere (mkT (applyI s)) d')


tcTopDecl :: TopDecl Name -> TcM (TopDecl Id)
tcTopDecl (TContr c) 
  = TContr <$> tcContract c
tcTopDecl (TFunDef fd)
  = do
      fd' <- tcBindGroup [fd] 
      case fd' of 
        (fd1 : _) -> pure (TFunDef fd1)
        _ -> throwError "Impossible! Empty binding group!"
tcTopDecl (TClassDef c)
  = TClassDef <$> tcClass c 
tcTopDecl (TInstDef is)
  = TInstDef <$> tcInstance is
tcTopDecl (TMutualDef ts)
  = do 
      let f (TFunDef fd) = fd 
      ts' <- tcBindGroup (map f ts)
      pure (TMutualDef $ map TFunDef ts')
tcTopDecl (TDataDef d)
  = do 
    checkDataType d
    pure (TDataDef d)

checkTopDecl :: TopDecl Name -> TcM ()
checkTopDecl (TClassDef c) 
  = checkClass c 
checkTopDecl (TInstDef is)
  = checkInstance is 
checkTopDecl (TDataDef dt)
  = checkDataType dt
checkTopDecl (TFunDef (FunDef sig _)) 
  = extSignature sig 
checkTopDecl _ = pure ()

-- TODO load import information

loadImports :: [Import] -> TcM ()
loadImports _ = return ()

-- type inference for contracts 

tcContract :: Contract Name -> TcM (Contract Id) 
tcContract c@(Contract n vs decls) 
  = withLocalEnv do
      initializeEnv c
      decls' <- mapM tcDecl' decls
      pure (Contract n vs decls')
    where 
      tcDecl' d 
        = do 
          clearSubst 
          d' <- tcDecl d
          s <- getSubst
          pure (everywhere (mkT (applyI s)) d')

-- initializing context for a contract

initializeEnv :: Contract Name -> TcM ()
initializeEnv (Contract n vs decls)
  = do 
      setCurrentContract n (length vs) 
      mapM_ checkDecl decls 

checkDecl :: ContractDecl Name -> TcM ()
checkDecl (CDataDecl dt) 
  = checkDataType dt 
checkDecl (CFunDecl (FunDef sig _))
  = extSignature sig
checkDecl (CFieldDecl fd)
  = tcField fd >> return ()
checkDecl (CMutualDecl ds) 
  = mapM_ checkDecl ds
checkDecl _ = return ()

extSignature :: Signature Name -> TcM ()
extSignature (Signature _ preds n ps t)
  = do
      -- checking if the function is previously defined
      te <- gets ctx
      when (Map.member n te) (duplicatedFunDef n)
      argTys <- mapM tyParam ps
      t' <- maybe freshTyVar pure t
      let 
        ty = funtype argTys t'
        vs = fv (preds :=> ty)
      sch <- generalize (preds, ty) 
      extEnv n sch

-- including contructors on environment

checkDataType :: DataTy -> TcM ()
checkDataType (DataTy n vs constrs) 
  = do
      vals' <- mapM (\ (n, ty) -> (n,) <$> generalize ([], ty)) vals
      mapM_ (uncurry extEnv) vals'
      modifyTypeInfo n ti
    where 
      ti = TypeInfo (length vs) (map fst vals) []
      tc = TyCon n (TyVar <$> vs) 
      vals = map constrBind constrs        
      constrBind c = (constrName c, (funtype (constrTy c) tc))

-- type inference for declarations

tcDecl :: ContractDecl Name -> TcM (ContractDecl Id)
tcDecl (CFieldDecl fd) = CFieldDecl <$> tcField fd
tcDecl (CFunDecl d) 
  = do 
      d' <- tcBindGroup [d]
      case d' of 
        [] -> throwError "Impossible! Empty function binding!"
        (x : _) -> pure (CFunDecl x)
tcDecl (CMutualDecl ds) 
  = do
      let f (CFunDecl fd) = fd
      ds' <- tcBindGroup (map f ds) 
      pure (CMutualDecl (map CFunDecl ds'))
tcDecl (CConstrDecl cd) = CConstrDecl <$> tcConstructor cd 
tcDecl (CDataDecl d) = pure (CDataDecl d)

-- type checking fields

tcField :: Field Name -> TcM (Field Id)
tcField d@(Field n t (Just e)) 
  = do
      (e', ps', t') <- tcExp e 
      s <- mgu t t' `wrapError` d 
      extEnv n (monotype t)
      return (Field n t (Just e')) 
tcField (Field n t _) 
  = do 
      extEnv n (monotype t)
      pure (Field n t Nothing)

tcInstance :: Instance Name -> TcM (Instance Id)
tcInstance idecl@(Instance ctx n ts t funs) 
  = do
      checkCompleteInstDef n (map (sigName . funSignature) funs) 
      funs' <- buildSignatures n ts t funs  
      (funs1, pss', ts') <- unzip3 <$> mapM tcFunDef  funs' `wrapError` idecl
      withCurrentSubst (Instance ctx n ts t funs1)

checkCompleteInstDef :: Name -> [Name] -> TcM ()
checkCompleteInstDef n ns 
  = do 
      mths <- methods <$> askClassInfo n 
      let remaining = mths \\ ns 
      when (not $ null remaining) do 
        warning $ unlines $ ["Incomplete definition for class:"
                            , pretty n
                            , "missing definitions for:"
                            ] ++ map pretty remaining

buildSignatures :: Name -> [Ty] -> Ty -> [FunDef Name] -> TcM [FunDef Name]
buildSignatures n ts t funs 
  = do 
      cpred <- classpred <$> askClassInfo n 
      sm <- matchPred cpred (InCls n t ts) 
      schs <- mapM (askEnv . sigName . funSignature) funs 
      let  
          app (Forall vs (_ :=> t1)) = apply sm t1
          tinsts = map app schs
      zipWithM buildSignature tinsts funs 

buildSignature :: Ty -> FunDef Name -> TcM (FunDef Name)
buildSignature t (FunDef sig bd)
  = do 
      let (args, ret) = splitTy t 
          sig' = typeSignature args ret sig
      pure (FunDef sig' bd)

typeSignature :: [Ty] -> Ty -> Signature Name -> Signature Name 
typeSignature args ret sig 
  = sig { sigParams = zipWith paramType args (sigParams sig)
        , sigReturn = Just ret
        }
    where 
      paramType t (Typed n _) = Typed n t
      paramType t (Untyped n) = Typed n t 

tcClass :: Class Name -> TcM (Class Id)
tcClass iclass@(Class ctx n vs v sigs) 
  = do
      let ns = map sigName sigs
      schs <- mapM askEnv ns 
      sigs' <- mapM tcSig (zip sigs schs)
      pure (Class ctx n vs v sigs')

tcSig :: (Signature Name, Scheme) -> TcM (Signature Id)
tcSig (sig, (Forall _ (_ :=> t))) 
  = do
      let (ts,r) = splitTy t 
          param (Typed n t) t1 = Typed (Id n t1) t1 
          param (Untyped n) t1 = Typed (Id n t1) t1
          params' = zipWith param (sigParams sig) ts
      pure (Signature (sigVars sig)
                      (sigContext sig)
                      (sigName sig)
                      params'
                      (Just r))

-- type checking binding groups

tcBindGroup :: [FunDef Name] -> TcM [FunDef Id]
tcBindGroup binds 
  = do
      funs <- mapM scanFun binds
      (funs', pss, ts) <- unzip3 <$> mapM tcFunDef funs 
      ts' <- withCurrentSubst ts  
      schs <- mapM generalize (zip pss ts')
      let names = map (sigName . funSignature) funs 
      let p (x,y) = pretty x ++ " :: " ++ pretty y
      mapM_ (uncurry extEnv) (zip names schs)
      mapM_ generateDecls (zip funs' schs)
      info ["Results: ", unlines $ map p $ zip names schs]
      pure funs'

generateDecls :: (FunDef Id, Scheme) -> TcM () 
generateDecls ((FunDef sig bd), sch) 
  = do
      dt <- createUniqueType (sigName sig) sch 
      pure ()

createUniqueType :: Name -> Scheme -> TcM (Maybe (TopDecl Id)) 
createUniqueType (Name n) (Forall vs _)
  | isLambdaGenerated n = pure Nothing 
  | otherwise 
    = do
        m <- incCounter 
        let nt = Name $ "Type" ++ n ++ show m
            dc = Constr nt []
            dt = TDataDef (DataTy nt vs [dc])
        writeDecl dt
        pure (Just dt)

isLambdaGenerated :: String -> Bool 
isLambdaGenerated n 
  = "lambdaimpl" `isPrefixOf` n

-- type checking a single bind

tcFunDef :: FunDef Name -> TcM (FunDef Id, [Pred], Ty)
tcFunDef d@(FunDef sig bd) 
  = withLocalEnv do
      -- checking if the function isn't defined 
      (params', schs, ts) <- tcArgs (sigParams sig)
      (bd', ps1, t') <- withLocalCtx schs (tcBody bd)
      sch <- askEnv (sigName sig)
      (ps :=> t) <- freshInst sch
      let t1 = foldr (:->) t' ts
      s <- match t t1 `wrapError` d
      rTy <- withCurrentSubst t'
      let sig' = Signature (sigVars sig) 
                           (sigContext sig) 
                           (sigName sig)
                           params' 
                           (Just rTy)
      ps2 <- reduceContext (ps ++ ps1)
      pure (apply s $ FunDef sig' bd', apply s ps2, apply s t1)

scanFun :: FunDef Name -> TcM (FunDef Name)
scanFun (FunDef sig bd)
  = flip FunDef bd <$> fillSignature sig 
    where 
      f (Typed n t) = pure $ Typed n t
      f (Untyped n) = Typed n <$> freshTyVar
      fillSignature (Signature vs ctx n ps t)
        = do 
            ps' <- mapM f ps 
            pure (Signature vs ctx n ps' t)

-- type generalization 

generalize :: ([Pred], Ty) -> TcM Scheme 
generalize (ps,t) 
  = do 
      envVars <- getEnvFreeVars
      (ps1,t1) <- withCurrentSubst (ps,t)
      ps2 <- reduceContext ps1 
      t2 <- withCurrentSubst t1 
      let vs = fv (ps2,t2)
          sch = Forall (vs \\ envVars) (ps2 :=> t2)
      return sch

-- context reduction 

reduceContext :: [Pred] -> TcM [Pred]
reduceContext preds 
  = do 
      depth <- askMaxRecursionDepth 
      unless (null preds) $ info ["> reduce context ", pretty preds]
      ps1 <- toHnfs depth preds `wrapError` preds
      ps2 <- withCurrentSubst ps1 
      unless (null preds) $ info ["> reduced context ", pretty (nub ps2)]
      pure (nub ps2)

toHnfs :: Int -> [Pred] -> TcM [Pred]
toHnfs depth ps 
  = do 
      s <- getSubst 
      ps' <- simplifyEqualities ps 
      ps2 <- withCurrentSubst ps'
      toHnfs' depth ps2 

simplifyEqualities :: [Pred] -> TcM [Pred]
simplifyEqualities ps = go [] ps where
    go rs [] = return rs
    go rs ((t :~: u) : ps) = do
      phi <- mgu t u
      extSubst phi
      ps' <- withCurrentSubst ps
      rs' <- withCurrentSubst rs
      go rs' ps'
    go rs (p:ps) = go (p:rs) ps

toHnfs' :: Int -> [Pred] -> TcM [Pred]
toHnfs' _ [] = return []
toHnfs' 0 ps = throwError("Max context reduction depth exceeded")
toHnfs' d preds@(p:ps) = do
  let d' = d - 1
  rs1 <- toHnf d' p
  ps' <- withCurrentSubst ps   -- important, toHnf may have extended the subst
  rs2 <- toHnfs' d' ps'
  return (rs1 ++ rs2)

toHnf :: Int -> Pred -> TcM [Pred]
toHnf _ (t :~: u) = do
  subst1 <- mgu t u
  extSubst subst1
  return []
toHnf depth pred@(InCls n _ _)
  | inHnf pred = return [pred]
  | otherwise = do
      ce <- getInstEnv
      is <- askInstEnv n
      case byInstM ce pred of
        Nothing -> throwError ("no instance of " ++ pretty pred
                  ++"\nKnown instances:\n"++ (unlines $ map pretty is))
        Just (preds, subst') -> do
            extSubst subst'
            toHnfs (depth - 1) preds

inHnf :: Pred -> Bool
inHnf (InCls c t args) = hnf t where
  hnf (TyVar _) = True
  hnf (TyCon _ _) = False
inHnf (_ :~: _) = False

byInstM :: InstTable -> Pred -> Maybe ([Pred], Subst)
byInstM ce p@(InCls i t as) 
  = msum [tryInst it | it <- insts ce i] 
    where
      insts m n = maybe [] id (Map.lookup n m)
      tryInst :: Qual Pred -> Maybe ([Pred], Subst)
      tryInst c@(ps :=> h) =
          case matchPred h p of
            Left _ -> Nothing
            Right u -> let tvs = fv h
                       in  Just (map (apply u) ps, restrict u tvs)

-- type checking contract constructors

tcConstructor :: Constructor Name -> TcM (Constructor Id)
tcConstructor (Constructor ps bd) 
  = do
      -- building parameters for constructors
      ps' <- mapM tcParam ps
      let f (Typed (Id n t) _) = pure (n, monotype t)
          f (Untyped (Id n _)) = ((n,) . monotype) <$> freshTyVar
      lctx <- mapM f ps' 
      (bd', _ ,_) <- withLocalCtx lctx (tcBody bd) 
      pure (Constructor ps' bd')
  
-- checking class definitions and adding them to environment 

checkClasses :: [Class Name] -> TcM ()
checkClasses = mapM_ checkClass 

checkClass :: Class Name -> TcM ()
checkClass (Class ps n vs v sigs) 
  = do 
      let p = InCls n (TyVar v) (TyVar <$> vs)
          ms' = map sigName sigs 
      addClassInfo n (length vs) ms' p
      mapM_ (checkSignature p) sigs 
    where
      checkSignature p sig@(Signature vs ctx f ps mt)
        = do
            pst <- mapM tyParam ps
            t' <- maybe freshTyVar pure mt
            let ft = funtype pst t' 
            unless (v `elem` fv ft)
                   (signatureError n v sig ft)
            addClassMethod p sig 

addClassInfo :: Name -> Arity -> [Method] -> Pred -> TcM ()
addClassInfo n ar ms p
  = do 
      ct <- gets classTable
      when (Map.member n ct) (duplicatedClassDecl n)
      modify (\ env -> 
        env{ classTable = Map.insert n (ClassInfo ar ms p) (classTable env)})

addClassMethod :: Pred -> Signature Name -> TcM ()
addClassMethod p@(InCls _ _ _) sig@(Signature _ ctx f ps t) 
  = do
      tps <- mapM tyParam ps
      t' <- maybe freshTyVar pure t
      let ty = funtype tps t'
          vs = fv ty
          ctx' = [p] `union` ctx
      extEnv f (Forall vs (ctx' :=> ty))
addClassMethod p@(_ :~: _) (Signature _ _ n _ _) 
  = throwError $ unlines [
                    "Invalid constraint:"
                  , pretty p 
                  , "in class method:"
                  , unName n
                  ]

-- checking instances and adding them in the environment

checkInstances :: [Instance Name] -> TcM ()
checkInstances = mapM_ checkInstance 

checkInstance :: Instance Name -> TcM ()
checkInstance (Instance ctx n ts t funs)
  = do
      let ipred = InCls n t ts
      -- checking the coverage condition 
      insts <- askInstEnv n `wrapError` ipred
      checkOverlap ipred insts
      coverage <- askCoverage
      when coverage (checkCoverage n ts t `wrapError` ipred)
      -- checking Patterson condition 
      checkMeasure ctx ipred `wrapError` ipred
      -- checking instance methods
      mapM_ (checkMethod ipred) funs
      let ninst = anfInstance $ ctx :=> InCls n t ts 
      -- add to the environment
      addInstance n ninst 

checkOverlap :: Pred -> [Inst] -> TcM ()
checkOverlap _ [] = pure ()
checkOverlap p@(InCls _ t _) (i:is) 
  = do 
        i' <- renameVars (fv t) i
        case i' of 
          (ps :=> (InCls _ t' _)) -> 
            case mgu t t' of
              Right _ -> throwError (unlines ["instance:"
                                             , pretty p
                                             , "with:"
                                             , pretty i'])
              Left _ -> checkOverlap p is
        return ()

checkCoverage :: Name -> [Ty] -> Ty -> TcM ()
checkCoverage cn ts t 
  = do 
      let strongTvs = fv t 
          weakTvs = fv ts 
          undetermined = weakTvs \\ strongTvs
      unless (null undetermined) $ 
          throwError (unlines [
            "Coverage condition fails for class:"
          , unName cn 
          , "- the type:"
          , pretty t 
          , "does not determine:"
          , intercalate ", " (map pretty undetermined)
          ])

checkMethod :: Pred -> FunDef Name -> TcM () 
checkMethod ih@(InCls n t ts) (FunDef sig _) 
  = do
      -- getting current method signature in class
      st@(Forall _ (qs :=> ty)) <- askEnv (sigName sig)
      p <- maybeToTcM (unwords [ "Constraint for"
                               , unName n
                               , "not found in type of"
                               , unName $ sigName sig])
                      (findPred n qs)
      -- matching substitution of instance head and class predicate
      _ <- liftEither (matchPred p ih) `wrapError` ih
      pure ()

tyParam :: Param Name -> TcM Ty 
tyParam (Typed _ t) = pure t 
tyParam (Untyped _) = freshTyVar

findPred :: Name -> [Pred] -> Maybe Pred 
findPred _ [] = Nothing 
findPred n (p@(InCls n' _ _) : ps) 
  | n == n' = Just p 
  | otherwise = findPred n ps

anfInstance :: Inst -> Inst
anfInstance inst@(q :=> p@(InCls c t [])) = inst
anfInstance inst@(q :=> p@(InCls c t as)) = q ++ q' :=> InCls c t bs 
  where
    q' = zipWith (:~:) bs as
    bs = map TyVar $ take (length as) freshNames
    tvs = fv inst
    freshNames = filter (not . flip elem tvs) (TVar <$> namePool)

-- checking Patterson conditions 

checkMeasure :: [Pred] -> Pred -> TcM ()
checkMeasure ps c 
  = if all smaller ps then return ()
    else throwError $ unlines [ "Instance "
                              , pretty c
                              , "does not satisfy the Patterson conditions."]
    where smaller p = measure p < measure c

-- error for class definitions 

signatureError :: Name -> Tyvar -> Signature Name -> Ty -> TcM ()
signatureError n v sig@(Signature _ ctx f _ _) t
  | null ctx = throwError $ unlines ["Impossible! Class context is empty in function:" 
                                    , pretty f
                                    , "which is a membre of the class declaration:"
                                    , pretty n 
                                    ]
  | v `notElem` fv t = throwError $ unlines ["Main class type variable"
                                            , pretty v
                                            , "does not occur in type"
                                            , pretty t 
                                            , "which is the defined type for function"
                                            , pretty f 
                                            , "that is a member of class definition"
                                            , pretty n 
                                            ]

duplicatedClassDecl :: Name -> TcM ()
duplicatedClassDecl n 
  = throwError $ "Duplicated class definition:" ++ pretty n

duplicatedClassMethod :: Name -> TcM ()
duplicatedClassMethod n 
  = throwError $ "Duplicated class method definition:" ++ pretty n 

duplicatedFunDef :: Name -> TcM () 
duplicatedFunDef n 
  = throwError $ "Duplicated function definition:" ++ pretty n

-- Instances for elaboration 

instance HasType (FunDef Id) where 
  apply s (FunDef sig bd)
    = FunDef (apply s sig) (apply s bd)
  fv (FunDef sig bd)
    = fv sig `union` fv bd

instance HasType (Instance Id) where 
  apply s (Instance ctx n ts t funs) 
    = Instance (apply s ctx) n (apply s ts) (apply s t) (apply s funs)
  fv (Instance ctx n ts t funs) 
    = fv ctx `union` fv (t : ts) `union` fv funs
