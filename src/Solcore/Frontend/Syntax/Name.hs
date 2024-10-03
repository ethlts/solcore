{-# LANGUAGE OverloadedStrings #-}
module Solcore.Frontend.Syntax.Name where 

import Data.Generics (Data, Typeable)
import Data.String

data Name 
  = Name {unName :: String}
  | QualName Name String 
    deriving (Eq, Ord, Data, Typeable)

instance Show Name where 
  show = unName

instance IsString Name where 
  fromString = Name
