module Solcore.Desugarer.EmitCore(emitCore) where
import Language.Core(Core(..))
import Language.Core qualified as Core
import Data.Map qualified as Map
import Control.Monad(forM)
import Control.Monad.IO.Class
import Control.Monad.Reader.Class
import Control.Monad.State(gets)
import Data.List(intercalate)
import qualified Data.Map as Map

import Solcore.Frontend.Pretty.SolcorePretty
import Solcore.Frontend.Syntax
import Solcore.Frontend.TypeInference.Id ( Id(..) )
import Solcore.Frontend.TypeInference.TcEnv(TcEnv(..),TypeInfo(..))
import Solcore.Frontend.TypeInference.TcSubst
import Solcore.Frontend.TypeInference.TcUnify
import Solcore.Primitives.Primitives
import System.Exit

emitCore :: CompUnit Id -> IO [Core]
emitCore cu = mapM emitTopDecl (contracts cu)

emitTopDecl :: TopDecl Id -> IO Core
emitTopDecl (TContr c) = emitContract c
emitTopDecl _ = return (Core [])

emitContract :: Contract Id -> IO Core
emitContract c = do
    writes ["Emitting core for contract ", show (name c)]
    pure (Core [])

writeln :: MonadIO m => String -> m ()
writeln = liftIO . putStrLn
writes :: MonadIO m => [String] -> m ()
writes = writeln . concat
errors :: [String] -> a
errors = error . concat
