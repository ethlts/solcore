{-# LANGUAGE OverloadedStrings #-}
module Translate where
import Data.List(union)
import GHC.Stack
import Language.Core hiding(Name)
import qualified Language.Core as Core
import TM
import Language.Yul
import Solcore.Frontend.Syntax.Name
import Data.String

genExpr :: Expr -> TM ([YulStmt], Location)
genExpr (EWord n) = pure ([], LocWord n)
genExpr (EBool b) = pure ([], LocBool b)
genExpr (EVar name) = do
    loc <- lookupVar name
    pure ([], loc)
genExpr (EPair e1 e2) = do
    (stmts1, loc1) <- genExpr e1
    (stmts2, loc2) <- genExpr e2
    pure (stmts1 ++ stmts2, LocPair loc1 loc2)
genExpr (EFst e) = do
    (stmts, loc) <- genExpr e
    case loc of
        LocPair l _ -> pure (stmts, l)
        _ -> error "EFst: type mismatch"
genExpr (ESnd e) = do
    (stmts, loc) <- genExpr e
    case loc of
        LocPair _ r -> pure (stmts, r)
        _ -> error "ESnd: type mismatch"
genExpr (EInl e) = do
    (stmts, loc) <- genExpr e
    pure (stmts, LocSum (LocBool False) loc (LocUndefined)) -- FIXME tag
genExpr (EInr e) = do
    (stmts, loc) <- genExpr e
    pure (stmts, LocSum (LocBool True) (LocUndefined) loc) -- FIXME tag
genExpr EUnit = pure ([], LocUnit)
genExpr (ECall name args) = do
    (argCodes, argLocs) <- unzip <$> mapM genExpr args
    let argsCode = concat argCodes
    let yulArgs = concatMap flattenRhs argLocs
    funInfo <- lookupFun name
    (resultCode, resultLoc) <- coreAlloc (fun_result funInfo)
    let callExpr = YulCall name yulArgs
    let callCode = [YAssign (flattenLhs resultLoc) callExpr]
    pure (argsCode++resultCode++callCode, resultLoc)
genExpr e = error ("genExpr: not implemented for "++show e)

flattenRhs :: Location -> [YulExpression]
flattenRhs (LocWord n) = [yulInt n]
flattenRhs (LocBool b) = [yulBool b]
flattenRhs (LocStack i) = [YulIdentifier (stkLoc i)]
flattenRhs (LocPair l r) = flattenRhs l ++ flattenRhs r
flattenRhs (LocSum t l r) = flattenRhs t ++ flattenRhs l ++ flattenRhs r
flattenRhs LocUnit = []
flattenRhs LocUndefined = []
flattenRhs l = error ("flattenRhs: not implemented for "++show l)

flattenLhs :: Location -> [Name]
flattenLhs (LocStack i) = [stkLoc i]
flattenLhs (LocPair l r) = flattenLhs l ++ flattenLhs r
flattenLhs (LocSum t l r) = flattenLhs t ++ flattenLhs l ++ flattenLhs r
flattenLhs LocUnit = []
flattenLhs LocUndefined = []
flattenLhs l = error ("flattenLhs: not implemented for "++show l)

genStmtWithComment :: Stmt -> TM [YulStmt]
genStmtWithComment (SComment c) = pure [YComment c]
genStmtWithComment s = do
    let comment = YComment (show s)
    body <- genStmt s
    pure (comment : body)

genStmt :: Stmt -> TM [YulStmt]
genStmt (SAssembly stmts) = pure stmts
genStmt (SAlloc name typ) = allocVar name typ
genStmt (SAssign name expr) = coreAssign name expr

genStmt (SReturn expr) = do
    (stmts, loc) <- genExpr expr
    resultLoc <- lookupVar "_result"
    let stmts' = copyLocs resultLoc loc
    pure (stmts ++ stmts')

genStmt (SBlock stmts) = withLocalEnv do genStmts stmts
genStmt (SMatch e alts) = do
    (stmts, loc) <- genExpr e
    case loc of
        LocSum loctag l r -> do
            yulAlts <- genAlts l r alts
            pure (stmts ++ [YSwitch (yultag loctag) yulAlts Nothing]) where
                yultag (LocStack i) = YulIdentifier (stkLoc i)
                yultag (LocBool b) = yulBool b
                yultag (LocWord n) = yulInt n
                yultag t = error ("invalid tag: "++show t)
        _ -> error "SMatch: type mismatch"

genStmt (SFunction name args ret stmts) = withLocalEnv do
    yulArgs <- placeArgs args
    yulResult <- place "_result" ret  -- TODO: special handling of unit
    yulBody <- genStmts stmts
    return [YFun (fromString name) yulArgs (YReturns yulResult) yulBody]
    where
        placeArgs :: [Arg] -> TM [Name]
        placeArgs as = concat <$> mapM placeArg as
        placeArg :: Arg -> TM [Name]
        placeArg (TArg name typ) = place name typ
        place :: Core.Name -> Type -> TM [Name]
        place name typ = do
            loc <- buildLoc typ
            insertVar name loc
            return (flattenLhs loc)

genStmt (SRevert s) = pure
  [ YExp $ YulCall "mstore" [yulInt 0, YulLiteral (YulString s)]
  , YExp $ YulCall "revert" [yulInt 0, yulInt (length s)]
  ]

genStmt e = error $ "genStmt unimplemented for: " ++ show e

-- If the statement is a function definition, record its type
scanStmt :: Stmt -> TM ()
scanStmt (SFunction name args ret stmts) = do
    let argTypes = map (\(TArg _ t) -> t) args
    let info = FunInfo argTypes ret
    insertFun name info
scanStmt _ = pure ()

genAlts :: Location -> Location -> [Alt] -> TM [(YulLiteral, [YulStmt])]
genAlts locL locR [Alt lname lstmt, Alt rname rstmt] = do
    yulLStmts <- withName lname locL lstmt
    yulRStmts <- withName rname locR rstmt
    pure [(YulFalse, yulLStmts), (YulTrue, yulRStmts)]
    where
        withName name loc stmt = withLocalEnv do
            insertVar name loc
            genStmt stmt
genAlts _ _ _ = error "genAlts: invalid number of alternatives"


allocVar :: Core.Name -> Type -> TM [YulStmt]
allocVar name typ = do
    (stmts, loc) <- coreAlloc typ
    insertVar name loc
    return stmts

buildLoc :: Type -> TM Location
buildLoc TWord = LocStack <$> freshId
buildLoc TBool = LocStack <$> freshId
buildLoc (TPair t1 t2) = do
    l1 <- buildLoc t1
    l2 <- buildLoc t2
    return (LocPair l1 l2)
buildLoc (TSum t1 t2) = do
    -- Make sum branches share stack slots
    tag <- LocStack <$> freshId
    mark <- getCounter
    l1 <- buildLoc t1
    leftMark <- getCounter
    setCounter mark
    l2 <- buildLoc t2
    rightMark <- getCounter
    setCounter (max leftMark rightMark)
    return (LocSum tag l1 l2)
buildLoc TUnit = pure LocUnit
buildLoc t = error ("cannot build location for "++show t)

coreAlloc :: Type -> TM ([YulStmt], Location)
coreAlloc t = do
    loc <- buildLoc t
    let stmts = allocLoc loc
    pure (stmts, loc)

stackSlots :: Location -> [Int]
stackSlots (LocStack i) = [i]
stackSlots (LocPair l r) = stackSlots l `union` stackSlots r
stackSlots (LocSum tag l r) = stackSlots tag `union` stackSlots l `union` stackSlots r
stackSlots _ = []

allocLoc :: Location -> [YulStmt]
allocLoc loc = [YulAlloc (stkLoc i) | i <- stackSlots loc]

allocWord :: TM ([YulStmt], Location)
allocWord = do
    n <- freshId
    let loc = LocStack n
    pure ([YulAlloc (stkLoc n)], loc)


coreAssign :: Expr -> Expr -> TM [YulStmt]
coreAssign lhs rhs = do
    (stmts1, locLhs) <- genExpr lhs
    (stmts2, locRhs) <- genExpr rhs
    let stmts3 = copyLocs locLhs locRhs
    pure (stmts1 ++ stmts2 ++ stmts3)

loadLoc :: Location -> YulExpression
loadLoc (LocWord n) = YulLiteral (YulNumber (fromIntegral n))
loadLoc (LocBool b) = YulLiteral (if b then YulTrue else YulFalse)
loadLoc (LocStack i) = YulIdentifier (stkLoc i)
loadLoc loc = error ("cannot loadLoc "++show loc)

-- copyLocs l r copies the value of r to l
copyLocs :: HasCallStack => Location -> Location -> [YulStmt]
copyLocs (LocStack i) r@(LocWord _) = [YAssign [stkLoc i] (loadLoc r)]
copyLocs (LocStack i) r@(LocBool _) = [YAssign [stkLoc i] (loadLoc r)]
copyLocs (LocStack i) r@(LocStack _) = [YAssign [stkLoc i] (loadLoc r)]
copyLocs (LocStack _) LocUndefined = [YComment "impossible"]
copyLocs (LocPair l1 l2) (LocPair r1 r2) = copyLocs l1 r1 ++ copyLocs l2 r2
copyLocs (LocSum ltag l1 l2) (LocSum rtag r1 r2) =  copyLocs ltag rtag ++ (copySum rtag) where
    copySum (LocBool b) = case b of
        False -> copyLocs l1 r1   -- explicit inl
        True -> copyLocs l2 r2    -- explicit inr

    copySum (LocStack i) = [YSwitch (YulIdentifier (stkLoc i))
                [ (YulNumber 0, copyLocs l1 r1)
                , (YulNumber 1, copyLocs l2 r2)
                ]
                Nothing]
    copySum l = error ("Invalid tag location: "++show l)
copyLocs LocUnit LocUnit = []
copyLocs l r = error $ "copy: type mismatch - LHS: " ++ show l ++ " RHS: " ++ show r

genStmts :: [Stmt] -> TM [YulStmt]
genStmts stmts = do
    mapM_ scanStmt stmts   -- scan for functions and record their types
    concat <$> mapM genStmtWithComment stmts

translateCore :: Core -> TM Yul
translateCore (Core stmts) = translateStmts stmts

translateStmts :: [Stmt] -> TM Yul
translateStmts stmts = do
    -- assuming the result goes into `_wrapresult`
    let hasMain = any isMain stmts
    if hasMain
      then writeln "found main"
      else writeln "no main found, adding one"
    let stmts' = if hasMain then stmts else addMain stmts
    payload <- genStmts stmts'
    let resultExp = YulCall "main" []
    let epilog = [YAssign1 "_wrapresult" resultExp]
    return $ Yul ( payload ++ epilog )


isMain :: Stmt -> Bool
isMain (SFunction "main" _ _ _) = True
isMain _ = False
-- TODO: analyse main type
-- e.g. mainType :: Stmt -> Maybe Type

isFunction (SFunction {}) = True
isFunction _ = False

addMain :: [Stmt] -> [Stmt]
addMain stmts = functions ++ [SFunction "main" [] TWord other]
  where (functions, other) = span isFunction stmts
