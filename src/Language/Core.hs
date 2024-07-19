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
    show = render . pretty

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
instance Show Stmt where show = render . pretty

data Alt = Alt Name Stmt

data Contract = Contract { ccName :: Name, ccStmts ::  [Stmt] }

newtype Core = Core [Stmt]
instance Show Core where show = render . pretty
instance Show Contract where show = render . pretty

instance Pretty Contract where
    pretty (Contract n stmts) = text "contract" <+> text n <+> lbrace $$ nest 4 (vcat (map pretty stmts)) $$ rbrace

instance Pretty Type where
    pretty TWord = text "word"
    pretty TBool = text "bool"
    pretty TUnit = text "unit"
    pretty (TPair t1 t2) = parens (pretty t1 <+> text "*" <+> pretty t2)
    pretty (TSum t1 t2) = parens (pretty t1 <+> text "+" <+> pretty t2)
    pretty (TFun ts t) = parens (hsep (map pretty ts) <+> text "->" <+> pretty t)

instance Pretty Expr where
    pretty (EWord i) = text (show i)
    pretty (EBool b) = text (show b)
    pretty EUnit = text "()"
    pretty (EVar x) = text x
    pretty (EPair e1 e2) = parens (pretty e1 >< comma <+> pretty e2)
    pretty (EFst e) = text "fst" >< parens (pretty e)
    pretty (ESnd e) = text "snd" >< parens (pretty e)
    pretty (EInl e) = text "inl" >< parens (pretty e)
    pretty (EInr e) = text "inr" >< parens (pretty e)
    pretty (ECall f es) = text f >< parens(hsep (punctuate comma (map pretty es)))

instance Pretty Stmt where
    pretty (SAssign lhs rhs) = pretty lhs <+> text ":=" <+> pretty rhs
    pretty (SAlloc x t) = text "let" <+> text x <+> text ":" <+> pretty t
    pretty (SExpr e) = pretty e
    pretty (SAssembly stmts) = vcat (map pretty stmts)
    pretty (SReturn e) = text "return" <+> pretty e
    pretty (SComment c) = text "//" <+> text c
    pretty (SBlock stmts) = lbrace $$ nest 4 (vcat (map pretty stmts)) $$ rbrace
    pretty (SMatch e [left, right]) =
        text "match" <+> pretty e <+> text "with" $$ lbrace
           $$ nest 2 (vcat [prettyAlt "inl" left, prettyAlt "inr" right]) $$ rbrace
        where
            prettyAlt tag (Alt n s) = text tag <+> text n <+> text "=>" <+> pretty s
    pretty (SFunction f args ret stmts) =
        text "function" <+> text f <+> parens (hsep (punctuate comma (map pretty args))) <+> text "->" <+> pretty ret <+> lbrace
           $$ nest 2 (vcat (map pretty stmts))  $$ rbrace
    pretty (SRevert s) = text "revert" <+> text s

instance Pretty Arg where
    pretty (TArg n t) = text n <+> text ":" <+> pretty t

instance Pretty Core where
    pretty (Core stmts) = vcat (map pretty stmts)


instance Pretty [Stmt] where
    pretty stmts = vcat (map pretty stmts)
