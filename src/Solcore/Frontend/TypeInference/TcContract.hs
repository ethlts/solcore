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
  = runTcM (tcCompUnit c) initTcEnv  

-- type inference for a compilation unit 

tcCompUnit :: CompUnit Name -> TcM (CompUnit Id)
tcCompUnit (CompUnit imps cs)
  = do 
      loadImports imps
      mapM_ checkTopDecl cs
      cs' <- mapM tcTopDecl' cs 
      pure (CompUnit imps cs')
    where 
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
extSignature (Signature n ctx ps t)
  = do
      argTys <- mapM tyParam ps
      t' <- maybe freshTyVar pure t
      let 
        ty = funtype argTys t' 
        vs = fv (ctx :=> ty)
      sch <- generalize (ctx, ty) 
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
      -- FIXME: Should we return the constraints?
      (e', ps', t') <- tcExp e 
      s <- mgu t t' `wrapError` d 
      extEnv n (monotype t)
      return (Field n t (Just e')) 
tcField (Field n t _) 
  = do 
      extEnv n (monotype t)
      pure (Field n t Nothing)

-- type checking instance body 

tcInstance :: Instance Name -> TcM (Instance Id)
tcInstance (Instance ctx n ts t funs) 
  = do
      (funs', _, _) <- unzip3 <$> mapM tcFunDef funs
      pure (Instance ctx n ts t funs')

tcClass :: Class Name -> TcM (Class Id)
tcClass (Class ctx n vs v sigs) 
  = do
      let ns = map sigName sigs 
      schs <- mapM askEnv ns 
      sigs' <- mapM tcSig (zip sigs schs)
      pure (Class ctx n vs v sigs')

tcSig :: (Signature Name, Scheme) -> TcM (Signature Id)
tcSig (sig, (Forall _ (_ :=> t))) 
  = do
      let (ts,r) = unwindType t 
          param (Typed n t) t1 = Typed (Id n t1) t1 
          param (Untyped n) t1 = Typed (Id n t1) t1
          params' = zipWith param (sigParams sig) ts
      pure (Signature (sigName sig)
                      (sigContext sig)
                      params'
                      (Just r))

unwindType :: Ty -> ([Ty], Ty)
unwindType (a :-> b) 
  = let (as, r) = unwindType b in (a:as, r)
unwindType t = ([], t)

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
      info ["Results: ", unlines $ map p $ zip names schs]
      pure funs'


-- type checking a single bind

tcFunDef :: FunDef Name -> TcM (FunDef Id, [Pred], Ty)
tcFunDef d@(FunDef sig bd) 
  = withLocalEnv do
      (params', ts) <- unzip <$> mapM addArg (sigParams sig)
      (bd', ps1, t') <- tcBody bd
      sch <- askEnv (sigName sig)
      (ps :=> t) <- freshInst sch
      let t1 = foldr (:->) t' ts
      s <- unify t t1 `wrapError` d
      rTy <- withCurrentSubst t'
      let sig' = Signature (sigName sig)
                           (sigContext sig) 
                           params' 
                           (Just rTy)
      pure (FunDef sig' bd', ps ++ ps1, t1)

scanFun :: FunDef Name -> TcM (FunDef Name)
scanFun (FunDef sig bd)
  = flip FunDef bd <$> fillSignature sig 
    where 
      f (Typed n t) = pure $ Typed n t
      f (Untyped n) = Typed n <$> freshTyVar
      fillSignature (Signature ctx n ps t)
        = do 
            ps' <- mapM f ps 
            pure (Signature ctx n ps' t)

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
  = mapM_ checkSignature sigs 
    where
      checkSignature sig@(Signature f ctx ps mt)
        = do 
            pst <- mapM tyParam ps
            t' <- maybe freshTyVar pure mt 
            unless (null ctx && v `elem` fv (funtype pst t'))
                   (throwError $ "invalid class declaration: " ++ unName n)
            addClassMethod (InCls n (TyVar v) (TyVar <$> vs))
                           sig 

addClassMethod :: Pred -> Signature Name -> TcM ()
addClassMethod p@(InCls _ _ _) (Signature f _ ps t) 
  = do
      tps <- mapM tyParam ps
      t' <- maybe freshTyVar pure t
      let ty = funtype tps t'
          vs = fv ty
      extEnv f (Forall vs ([p] :=> ty))
addClassMethod p@(_ :~: _) (Signature n _ _ _) 
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
      s <- liftEither (matchPred p ih) `wrapError` ih
      tps <- apply s <$> mapM tyParam (sigParams sig)
      tr <- maybe freshTyVar pure (sigReturn sig)
      let it = funtype tps tr
      match it (apply s ty) `wrapError` ih 
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
  = if measure ps < measure c then return () 
    else throwError $ unlines [ "Instance "
                              , pretty c
                              , "does not satisfy the Patterson conditions."]
