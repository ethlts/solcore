module Solcore.Frontend.Pretty.Name where
import Common.Pretty
import Solcore.Frontend.Syntax.Name


instance Pretty Name where
  ppr = text . unName

instance Pretty QualName where
  ppr = dotSep . map ppr . unQName