module Solcore.Desugarer.EmitCore(emitCore) where
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

emitCore :: CompUnit Id -> IO [Core.Contract]
emitCore cu = concat <$> mapM emitTopDecl (contracts cu)

emitTopDecl :: TopDecl Id -> IO [Core.Contract]
emitTopDecl (TContr c) = fmap pure (emitContract c)
emitTopDecl _ = pure []

emitContract :: Contract Id -> IO Core.Contract
emitContract c = do
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
