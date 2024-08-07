module Common.Pretty
( Pretty(..)
, module Text.PrettyPrint
, (><)  -- to avoid hiding Prelude (<>) 
, dotSep
, commaSep
, angles
) where
import Text.PrettyPrint hiding((<>))
import Text.PrettyPrint qualified as PP

-- in Prelude (<>) is defined as infixr 6 
-- in pretty, it is defined as infixl 6 
-- Prelude infixr 6 <> cannot mix with infixl 6 <+>
-- Hence to avoid hiding Prelude (<>) define (><)
infixl 6 ><
(><) :: Doc -> Doc -> Doc
(><) = (PP.<>)

class Pretty a where
  ppr :: a -> Doc

dotSep :: [Doc] -> Doc
dotSep = hcat . punctuate dot
         where
          dot = text "."

commaSep :: [Doc] -> Doc
commaSep = hsep . punctuate comma

angles :: Doc -> Doc
angles d = char '<' >< d ><  char '>'
