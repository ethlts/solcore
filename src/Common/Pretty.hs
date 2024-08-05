module Common.Pretty
( Pretty(..)
, module Text.PrettyPrint
, (><)  -- to avoid hiding Prelude (<>) 
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
