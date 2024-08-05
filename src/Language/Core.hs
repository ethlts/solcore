module Language.Core where
import Common.Pretty
import Language.Yul

-- type Name = String

data Type
    = TWord
    | TBool
    | TPair Type Type
    | TSum Type Type
    | TFun [Type] Type
    | TUnit
    deriving (Show)

data Expr
    = EWord Integer
    | EBool Bool
    | EVar Name
    | EPair Expr Expr
    | EFst Expr
    | ESnd Expr
    | EInl Expr
    | EInr Expr
    | ECall Name [Expr]
    | EUnit
instance Show Expr where
    show = render . ppr

pattern SAV :: Name -> Expr -> Stmt
pattern SAV x e = SAssign (EVar x) e
data Stmt
    = SAssign Expr Expr
    | SAlloc Name Type
    | SExpr Expr
    | SAssembly [YulStatement]
    | SReturn Expr
    | SComment String
    | SBlock [Stmt]
    | SMatch Expr [Alt]
    | SFunction Name [Arg] Type [Stmt]
    | SRevert String
    -- deriving Show

data Arg = TArg Name Type
instance Show Stmt where show = render . ppr

data Alt = Alt Name Stmt

newtype Core = Core [Stmt]
instance Show Core where show = render . ppr

instance Pretty Type where
    ppr TWord = text "word"
    ppr TBool = text "bool"
    ppr TUnit = text "unit"
    ppr (TPair t1 t2) = parens (ppr t1 <+> text "*" <+> ppr t2)
    ppr (TSum t1 t2) = parens (ppr t1 <+> text "+" <+> ppr t2)
    ppr (TFun ts t) = parens (hsep (map ppr ts) <+> text "->" <+> ppr t)

instance Pretty Expr where
    ppr (EWord i) = text (show i)
    ppr (EBool b) = text (show b)
    ppr EUnit = text "()"
    ppr (EVar x) = text x
    ppr (EPair e1 e2) = parens (ppr e1 >< comma <+> ppr e2)
    ppr (EFst e) = text "fst" >< parens (ppr e)
    ppr (ESnd e) = text "snd" >< parens (ppr e)
    ppr (EInl e) = text "inl" >< parens (ppr e)
    ppr (EInr e) = text "inr" >< parens (ppr e)
    ppr (ECall f es) = text f >< parens(hsep (punctuate comma (map ppr es)))

instance Pretty Stmt where
    ppr (SAssign lhs rhs) = ppr lhs <+> text ":=" <+> ppr rhs
    ppr (SAlloc x t) = text "let" <+> text x <+> text ":" <+> ppr t
    ppr (SExpr e) = ppr e
    ppr (SAssembly stmts) = vcat (map ppr stmts)
    ppr (SReturn e) = text "return" <+> ppr e
    ppr (SComment c) = text "//" <+> text c
    ppr (SBlock stmts) = lbrace $$ nest 4 (vcat (map ppr stmts)) $$ rbrace
    ppr (SMatch e [left, right]) =
        text "match" <+> ppr e <+> text "with" $$ lbrace
           $$ nest 2 (vcat [prettyAlt "inl" left, prettyAlt "inr" right]) $$ rbrace
        where
            prettyAlt tag (Alt n s) = text tag <+> text n <+> text "=>" <+> ppr s
    ppr (SFunction f args ret stmts) =
        text "function" <+> text f <+> parens (hsep (punctuate comma (map ppr args))) <+> text "->" <+> ppr ret <+> lbrace
           $$ nest 2 (vcat (map ppr stmts))  $$ rbrace
    ppr (SRevert s) = text "revert" <+> text s

instance Pretty Arg where
    ppr (TArg n t) = text n <+> text ":" <+> ppr t

instance Pretty Core where
    ppr (Core stmts) = vcat (map ppr stmts)
