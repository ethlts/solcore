module Solcore.Frontend.Pretty.SolcorePretty where 

import Data.List

import Prelude hiding ((<>))

import Solcore.Frontend.Syntax.Contract
import Solcore.Frontend.Syntax.Name 
import Solcore.Frontend.Syntax.Stmt 
import Solcore.Frontend.Syntax.Ty
import Solcore.Frontend.TypeInference.NameSupply
import Solcore.Frontend.TypeInference.TcSubst 

import Text.PrettyPrint.HughesPJ

-- top level pretty printer function 

pretty :: Pretty a => a -> String 
pretty = render . ppr

class Pretty a where 
  ppr :: a -> Doc  

instance Pretty a => Pretty (Qual a) where 
  ppr (ps :=> t) 
    = pprContext True ps <+> ppr t

instance Pretty ([Pred],Ty) where 
  ppr (x, y) = ppr (x :=> y)

instance Pretty a => Pretty (CompUnit a) where 
  ppr (CompUnit imps cs)
    = vcat (map ppr imps ++ map ppr cs)

instance Pretty Import where 
  ppr (Import qn) 
    = text "import" <+> ppr qn <+> semi

instance Pretty a => Pretty (TopDecl a) where 
  ppr (TContr c) = ppr c 
  ppr (TFunDef fd) = ppr fd 
  ppr (TClassDef c) = ppr c 
  ppr (TInstDef is) = ppr is 
  ppr (TMutualDef ts)
    = vcat (map ppr ts)
  ppr (TDataDef d) = ppr d

instance Pretty a => Pretty (Contract a) where 
  ppr (Contract n ts ds)
    = text "contract" <+> 
      ppr n <+> 
      pprTyParams (map TyVar ts) <+> 
      lbrace $$ 
      nest 3 (vcat (map ppr ds)) $$ 
      rbrace 

instance Pretty a => Pretty (ContractDecl a) where 
  ppr (CDataDecl dt)
    = ppr dt 
  ppr (CFieldDecl fd)
    = ppr fd 
  ppr (CFunDecl fd)
    = ppr fd
  ppr (CMutualDecl ds) 
    = vcat (map ppr ds)
  ppr (CConstrDecl c)
    = ppr c 

instance Pretty a => Pretty (Constructor a) where 
  ppr (Constructor ps bd)
    =  text "constructor" <+> 
       pprParams ps <+> 
       lbrace $$ 
       nest 3 (vcat (map ppr bd)) $$ 
       rbrace

instance Pretty DataTy where 
  ppr (DataTy n ps cs)
    = text "data" <+> 
      ppr n <+>
      pprTyParams (map TyVar ps) <+> 
      equals <+>  
      hsep (punctuate bar (map ppr cs))
    where 
      bar = text " |"

instance Pretty TySym where 
  ppr (TySym n t) 
    = text "type" <+> ppr n <+> text "=" <+> ppr t

instance Pretty Constr where
  ppr (Constr n []) = ppr n <> text " "
  ppr (Constr n ts)
    = ppr n <> brackets (pprConstrArgs ts)

pprConstrArgs :: [Ty] -> Doc  
pprConstrArgs [] = empty 
pprConstrArgs ts = commaSep $ map ppr ts 

instance Pretty a => Pretty (Class a) where 
  ppr (Class ps n vs v sigs)
    = text "class " <+> 
      pprContext True ps <+> 
      ppr v <+> 
      colon <+> 
      ppr n <+> 
      lbrace $$ 
      nest 3 (pprSignatures sigs) $$  
      rbrace 

pprSignatures :: Pretty a => [Signature a] -> Doc 
pprSignatures 
  = vcat . map ppr

instance Pretty a => Pretty (Signature a) where 
  ppr (Signature n ctx ps ty)
    = text "function" <+> 
      ppr n           <+>
      pprContext False ctx  <+> 
      pprParams ps

instance Pretty a => Pretty (Instance a) where 
  ppr (Instance ctx n tys ty funs)
    = text "instance" <+> 
      pprContext True ctx  <+> 
      ppr ty          <+>
      colon           <+> 
      ppr n           <+> 
      pprTyParams tys <+> 
      lbrace          $$ 
      nest 3 (pprFunBlock funs) $$ 
      rbrace 

pprContext :: Bool -> [Pred] -> Doc 
pprContext _ [] = empty 
pprContext b ps 
  = parens $ (commaSep $ map ppr ps) <+> if b then text "=>" else empty 

instance Pretty [Pred] where 
  ppr = hsep . map ppr 

pprFunBlock :: Pretty a => [FunDef a] -> Doc 
pprFunBlock 
  = vcat . map ppr

instance Pretty a => Pretty (Field a) where 
  ppr (Field n ty e)
    = ppr n <+> colon <+> (ppr ty) <+> pprInitOpt e

instance Pretty a => Pretty (FunDef a) where 
  ppr (FunDef sig bd)
    = ppr sig <+>
      lbrace $$ 
      nest 3 (vcat (map ppr bd)) $$ 
      rbrace

pprRetTy :: Maybe Ty -> Doc  
pprRetTy (Just t) = text "->" <+> ppr t
pprRetTy Nothing = empty 

pprParams :: Pretty a => [Param a] -> Doc  
pprParams = parens . commaSep . map ppr

instance Pretty a => Pretty (Param a) where 
  ppr (Typed n ty) 
    = ppr n <+> colon <+> ppr ty
  ppr (Untyped n)
    = ppr n

instance Pretty a => Pretty (Stmt a) where 
  ppr (n := e) 
    = ppr n <+> equals <+> ppr e <+> semi 
  ppr (Let n ty m)
    = text "let" <+> ppr n <+> pprOptTy ty <+> pprInitOpt m 
  ppr (StmtExp e)
    = ppr e <> semi
  ppr (Return e)
    = text "return" <+> ppr e
  ppr (Match e eqns)
    = text "match" <+> 
      (parens $ commaSep $ map ppr e) <+> 
      lbrace $$ 
      vcat (map ppr eqns) $$ 
      rbrace
  ppr (Asm yblk) 
    = text "assembly" <+> lbrace $$ 
      ppr yblk $$
      rbrace 

instance Pretty YulStmt where 
  ppr (YAssign ns e) 
    = commaSep (map ppr ns) <+> 
      text ":=" <+> 
      ppr e 
  ppr (YBlock yblk) 
    = ppr yblk  
  ppr (YLet ns e)
    = text "let" <+> 
      commaSep (map ppr ns) <+>
      text ":=" <+> 
      ppr e 
  ppr (YExp e) = ppr e 
  ppr (YIf e yblk)
    = text "if" <+> ppr e <+> ppr yblk 
  ppr (YSwitch e cs d)
    = text "switch" <+> ppr e <+> 
      lbrace $$
      nest 3 (vcat (map ppr cs ++ [pprDefault d])) $$
      rbrace 
  ppr (YFor init e bdy upd)
    = text "for" <+> 
      ppr init <+> 
      ppr e <+> 
      ppr bdy <+> 
      ppr upd
  ppr YContinue = text "continue"
  ppr YBreak = text "break"
  ppr YLeave = text "leave"

instance Pretty (Literal, YulBlock) where 
  ppr (l,yblk) = text "case " <+> ppr l <+> ppr yblk

instance Pretty YulBlock where 
  ppr yblk 
    = lbrace $$ 
      nest 3 (vcat (map ppr yblk)) $$ 
      rbrace 

instance Pretty YulExp where 
  ppr (YLit l) = ppr l 
  ppr (YIdent n) = ppr n 
  ppr (YCall n es) 
    = ppr n <> parens (commaSep (map ppr es))

pprDefault :: Maybe YulBlock -> Doc 
pprDefault Nothing = empty 
pprDefault (Just yblk) 
  = text "default" <+> ppr yblk

instance Pretty a => Pretty (Equation a) where 
  ppr (p,ss) 
    = text "|" <+> commaSep (map ppr p) <+> text "=>" $$ 
      nest 3 (vcat (map ppr ss))

pprOptTy :: Maybe Ty -> Doc 
pprOptTy Nothing = empty 
pprOptTy (Just t)
  | isVar t = empty 
  | otherwise = text "::" <+> ppr t 

isVar (TyVar _) = True 
isVar _ = False 

pprInitOpt :: Pretty a => Maybe (Exp a) -> Doc
pprInitOpt Nothing = semi
pprInitOpt (Just e) = equals <+> ppr e <+> semi 

instance Pretty a => Pretty (Exp a) where 
  ppr (Var v) = ppr v 
  ppr (Con n es) 
    = ppr n <> (brackets $ commaSep $ map ppr es)
  ppr (Lit l) = ppr l 
  ppr (Call e n es) 
    = pprE e <> ppr n <> (parens $ commaSep $ map ppr es)
  ppr (Lam args bd _) 
    = text "lam" <+> 
      pprParams args <+> 
      lbrace $$ 
      nest 3 (vcat (map ppr bd)) $$
      rbrace

pprE :: Pretty a => Maybe (Exp a) -> Doc  
pprE Nothing = ""
pprE (Just e) = ppr e <> text "."

instance Pretty a => Pretty (Pat a) where 
  ppr (PVar n) 
    = ppr n
  ppr (PCon n []) = ppr n
  ppr (PCon n ps@(_ : _)) 
    = ppr n <> (brackets $ commaSep $ map ppr ps )
  ppr PWildcard 
    = text "_"
  ppr (PLit l)
    = ppr l

instance Pretty Literal where 
  ppr (IntLit l) = integer (toInteger l)
  ppr (StrLit l) = quotes (text l)

instance Pretty Tyvar where 
  ppr (TVar n) = ppr n 

instance Pretty Pred where 
  ppr (InCls n t ts) =
    ppr t <+> colon <+> ppr n <+> pprTyParams ts 
  ppr (t1 :~: t2) = 
    ppr t1 <+> text "~" <+> ppr t2

instance Pretty Scheme where
  ppr (Forall vs ty) = ppr' (Forall vs' ty') 
    where 
      vs' = TVar <$> take (length vs) namePool 
      s = Subst (zip vs (TyVar <$> vs'))
      ty' = apply s ty
      ppr' (Forall [] (ctx :=> t))
        = pprContext True ctx <+> ppr t
      ppr' (Forall vs (ctx :=> t)) 
        = text "forall"       <+> 
          hsep (map ppr vs)   <+>
          text "."            <+> 
          pprContext True ctx <+>
          ppr t 

instance Pretty Ty where 
  ppr (TyVar v) = ppr v
  ppr (t1@(_ :-> _) :-> t2) 
    = parens (ppr t1) <+> text "->" <+> ppr t2
  ppr (t1 :-> t2) 
    = ppr t1 <+> (text "->") <+> ppr t2
  ppr (TyCon n ts)
    = ppr n <> (pprTyParams ts)

pprTyParams :: [Ty] -> Doc 
pprTyParams [] = empty 
pprTyParams ts 
  = brackets (commaSep (map ppr ts))

instance Pretty Name where 
  ppr = text . unName

instance Pretty QualName where 
  ppr = dotSep . map ppr . unQName

instance Pretty Subst where 
  ppr = braces . commaSep . map go . unSubst
    where 
      go (v,t) = ppr v <+> text "+->" <+> ppr t

dotSep :: [Doc] -> Doc
dotSep = hcat . punctuate dot 
         where 
          dot = text "."

commaSep :: [Doc] -> Doc
commaSep = hsep . punctuate comma 


