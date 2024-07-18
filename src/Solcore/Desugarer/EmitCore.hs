module Solcore.Desugarer.EmitCore(emitCore) where
import Language.Core qualified as Core
import Data.Map qualified as Map
import Control.Monad(forM, when)
import Control.Monad.IO.Class
import Control.Monad.Reader.Class
import Control.Monad.State
import Data.List(intercalate)
import qualified Data.Map as Map

import Solcore.Frontend.Pretty.SolcorePretty
import Solcore.Frontend.Syntax
import Solcore.Frontend.TypeInference.Id ( Id(..) )
import Solcore.Frontend.TypeInference.TcEnv(TcEnv(..),TypeInfo(..), TypeTable)
import Solcore.Frontend.TypeInference.TcSubst
import Solcore.Frontend.TypeInference.TcUnify
import Solcore.Primitives.Primitives
import System.Exit

emitCore :: Bool -> TcEnv ->  CompUnit Id -> IO [Core.Contract]
emitCore debugp env cu = fmap concat $ runEM debugp env $ mapM emitTopDecl (contracts cu)

type EM a = StateT EcState IO a
runEM :: Bool -> TcEnv -> EM a ->  IO a
runEM debugp env m = evalStateT m (initEcState debugp env)

data EcState = EcState 
    { ecSubst :: VSubst
    , ecTT :: TypeTable
    , ecNest :: Int
    , ecDebug :: Bool
    }   
  
initEcState :: Bool -> TcEnv -> EcState
initEcState debugp env = EcState 
   { ecSubst = emptyVSubst 
   , ecTT = typeTable env
   , ecNest = 0 
   , ecDebug = debugp
   }

type VSubst = Map.Map Name Core.Expr
emptyVSubst :: VSubst
emptyVSubst = Map.empty

emitTopDecl :: TopDecl Id -> EM [Core.Contract]
emitTopDecl (TContr c) = fmap pure (emitContract c)
emitTopDecl _ = pure []

emitContract :: Contract Id -> EM Core.Contract
emitContract c = do
    debug ["debug test"]
    let cname = show (name c)
    writes ["Emitting core for contract ", cname]
    let result = Core.Contract cname []
    writeln (show result)
    pure result

writeln :: MonadIO m => String -> m ()
writeln = liftIO . putStrLn
writes :: MonadIO m => [String] -> m ()
writes = writeln . concat
errors :: [String] -> a
errors = error . concat

debug :: [String] -> EM ()
debug msg = do
    enabled <- gets ecDebug
    when enabled $ writes msg
