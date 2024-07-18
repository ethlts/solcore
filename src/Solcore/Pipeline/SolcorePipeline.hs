module Solcore.Pipeline.SolcorePipeline where

import Control.Monad

import Options.Applicative

import Solcore.Desugarer.MatchCompiler
import Solcore.Frontend.Lexer.SolcoreLexer
import Solcore.Frontend.Parser.SolcoreParser
import Solcore.Frontend.Pretty.SolcorePretty
import Solcore.Frontend.TypeInference.SccAnalysis
import Solcore.Frontend.TypeInference.TcContract
import Solcore.Frontend.TypeInference.TcEnv
import Solcore.Desugarer.Specialise(specialiseCompUnit)
import Solcore.Desugarer.EmitCore(emitCore)

-- main compiler driver function

pipeline :: IO ()
pipeline = do
  opts <- argumentsParser
  content <- readFile (fileName opts)
  let r1 = runAlex content parser
  withErr r1 $ \ ast -> do
    r2 <- sccAnalysis ast
    withErr r2 $ \ ast' -> do
      r3 <- typeInfer ast'
      withErr r3 $ \ (c', env) -> do
        when (enableLog env) (mapM_ putStrLn (reverse $ logs env))
        r4 <- matchCompiler c'
        withErr r4 $ \ res -> do
          when (optVerbose opts) do
            putStrLn "Desugared contract:"
            putStrLn (pretty res)
          r5 <- specialiseCompUnit res env
          putStrLn "Specialised contract:"
          putStrLn (pretty r5)
          let debugp = optVerbose opts
          r6 <- emitCore debugp env r5
          return ()

withErr :: Either String a -> (a -> IO ()) -> IO ()
withErr r f = either putStrLn f r

-- parsing command line arguments

data Option
  = Option
    { fileName :: FilePath
    , optVerbose :: !Bool
    } deriving (Eq, Show)

options :: Parser Option
options
  = Option <$> strOption (
                  long "file"
               <> short 'f'
               <> metavar "FILE"
               <> help "Input file name")
           <*> switch ( long "verbose"
               <> short 'v'
               <> help "Verbose output" )

argumentsParser :: IO Option
argumentsParser = do
  let opts = info (options <**> helper)
                  (fullDesc <>
                   header "Solcore - solidity core language")
  opt <- execParser opts
  return opt
