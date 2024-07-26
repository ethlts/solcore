module Language.Yul where

import Common.Pretty

newtype Yul = Yul { yulStmts :: [YulStatement] }
instance Show Yul where show = render . ppr
instance Show YulStatement where show = render . ppr
instance Show YulExpression where show = render . ppr
instance Show YulLiteral where show = render . ppr

type Name = String
type YArg = Name
type YReturns = Maybe [Name]
pattern YNoReturn :: Maybe a
pattern YNoReturn = Nothing
pattern YReturns :: a -> Maybe a
pattern YReturns a = Just a
pattern YulAlloc :: Name -> YulStatement
pattern YulAlloc name = YulLet [name] Nothing
pattern YulAssign1 :: Name -> YulExpression -> YulStatement
pattern YulAssign1 name expr = YulAssign [name] expr

data YulStatement
  = YulBlock [YulStatement]
  | YulFun String [YArg] YReturns [YulStatement]
  | YulLet [String] (Maybe YulExpression)
  | YulAssign [String] YulExpression
  | YulIf YulExpression [YulStatement]
  | YulSwitch YulExpression [(YulLiteral, [YulStatement])] (Maybe [YulStatement])
  | YulForLoop [YulStatement] YulExpression [YulStatement] [YulStatement]
  | YulBreak
  | YulContinue
  | YulLeave
  | YulComment String
  | YulExpression YulExpression

data YulExpression
  = YulCall String [YulExpression]
  | YulIdentifier String
  | YulLiteral YulLiteral

data YulLiteral
  = YulNumber Integer
  | YulString String
  | YulTrue
  | YulFalse

yulInt :: Integral i => i -> YulExpression
yulInt = YulLiteral . YulNumber . fromIntegral

yulBool :: Bool -> YulExpression
yulBool True = YulLiteral YulTrue
yulBool False = YulLiteral YulFalse

instance Pretty Yul where
  ppr (Yul stmts) = vcat (map ppr stmts)

instance Pretty YulStatement where
  ppr (YulBlock stmts) =
    lbrace
      $$ nest 4 (vcat (map ppr stmts))
      $$ rbrace
  ppr (YulFun name args rets stmts) =
    text "function"
      <+> text name
      <+> prettyargs
      <+> prettyrets rets
      <+> lbrace
      $$ nest 4 (vcat (map ppr stmts))
      $$ rbrace
    where
        prettyargs = parens (hsep (punctuate comma (map text args)))
        prettyrets Nothing = empty
        prettyrets (Just rs) = text "->" <+> (hsep (punctuate comma (map text rs)))
  ppr (YulLet vars expr) =
    text "let" <+> hsep (punctuate comma (map text vars))
               <+> maybe empty (\e -> text ":=" <+> ppr e) expr
  ppr (YulAssign vars expr) = hsep (punctuate comma (map text vars)) <+> text ":=" <+> ppr expr
  ppr (YulIf cond stmts) = text "if" <+> parens (ppr cond) <+> ppr (YulBlock stmts)
  ppr (YulSwitch expr cases def) =
    text "switch"
      <+> (ppr expr)
      $$ nest 4 (vcat (map (\(lit, stmts) -> text "case" <+> ppr lit <+> ppr (YulBlock stmts)) cases))
      $$ maybe empty (\stmts -> text "default" <+> ppr (YulBlock stmts)) def
  ppr (YulForLoop pre cond post stmts) =
    text "for" <+> braces (hsep  (map ppr pre))
               <+> ppr cond
               <+> hsep (map ppr post) <+> ppr (YulBlock stmts)
  ppr YulBreak = text "break"
  ppr YulContinue = text "continue"
  ppr YulLeave = text "leave"
  ppr (YulComment c) = text "/*" <+> text c <+> text "*/"
  ppr (YulExpression e) = ppr e

instance Pretty YulExpression where
  ppr (YulCall name args) = text name >< parens (hsep (punctuate comma (map ppr args)))
  ppr (YulIdentifier name) = text name
  ppr (YulLiteral lit) = ppr lit

instance Pretty YulLiteral where
  ppr (YulNumber n) = integer n
  ppr (YulString s) = doubleQuotes (text s)
  ppr YulTrue = text "true"
  ppr YulFalse = text "false"

{- | wrap a Yul chunk in a Solidity function with the given name
   assumes result is in a variable named "_result"
-}
wrapInSolFunction :: Pretty a => Name -> a -> Doc
wrapInSolFunction name yul = text "function" <+> text name <+> prettyargs <+> text " public pure returns (uint256 _wrapresult)" <+> lbrace
  $$ nest 2 assembly
  $$ rbrace
  where
    assembly = text "assembly" <+> lbrace
      $$ nest 2 (ppr yul)
      $$ rbrace
    prettyargs = parens empty

wrapInContract :: Name -> Name -> Doc -> Doc
wrapInContract name entry body = empty
  $$ text "// SPDX-License-Identifier: UNLICENSED"
  $$ text "pragma solidity ^0.8.23;"
  $$ text "import {console,Script} from \"lib/stdlib.sol\";"
  $$ text "contract" <+> text name <+> text "is Script"<+> lbrace
  $$ nest 2 run
  $$ nest 2 body
  $$ rbrace

  where
    run = text "function run() public view" <+> lbrace
      $$ nest 2 (text "console.log(\"RESULT --> \","<+> text entry >< text ");")
      $$ rbrace $$ text ""
