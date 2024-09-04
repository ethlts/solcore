module Solcore.Pipeline.SolcorePipeline where

import Control.Monad

import qualified Data.Map as Map

import Options.Applicative

-- import Solcore.Desugarer.CallDesugarer hiding (info)
-- import Solcore.Desugarer.Defunctionalization
import Solcore.Desugarer.LambdaLifting
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
  let verbose = optVerbose opts
  content <- readFile (fileName opts)
  let r1 = runAlex content parser
  withErr r1 $ \ ast -> do
    withErr (lambdaLifting ast) $ \ ast2 -> do 
      when verbose $ do 
        putStrLn "AST after lambda lifting"
        putStrLn $ pretty ast2 
      r2 <- sccAnalysis ast2 
      withErr r2 $ \ ast' -> do
        r3 <- typeInfer ast'
        withErr r3 $ \ (c', env) -> do
          when verbose $ do 
            putStrLn "Annotated AST:"
            putStrLn $ pretty c' 
            putStrLn "Inferred types:"
            mapM_ putStrLn (reverse $ logs env)
          r4 <- matchCompiler c'
          withErr r4 $ \ res -> do
            when (verbose || optDumpDS opts) do
              putStrLn "Desugared contract:"
              putStrLn (pretty res)
          -- r5 <- defunctionalize env res
          -- withErr r5 $ \ r6 -> do
          --   when (verbose || optDumpDF opts) do
          --     putStrLn "Defunctionalized contract:"
          --     putStrLn (pretty r6)
            unless (optNoSpec opts) do
              r7 <- specialiseCompUnit res (optDebugSpec opts) env
              when (optDumpSpec opts) do
                  putStrLn "Specialised contract:"
                  putStrLn (pretty r7)
              r8 <- emitCore (optDebugCore opts) env r7
              when (optDumpCore opts) do
                  putStrLn "Core contract(s):"
                  forM_ r8 (putStrLn . pretty)


withErr :: Either String a -> (a -> IO ()) -> IO ()
withErr r f = either putStrLn f r

-- parsing command line arguments

data Option
  = Option
    { fileName :: FilePath
    , optNoSpec :: !Bool
    -- Options controlling printing
    , optVerbose :: !Bool
    , optDumpDS :: !Bool
    , optDumpDF :: !Bool
    , optDumpSpec :: !Bool
    , optDumpCore :: !Bool
    -- Options controlling diagnostic output
    , optDebugSpec :: !Bool
    , optDebugCore :: !Bool
    } deriving (Eq, Show)

options :: Parser Option
options
  = Option <$> strOption (
                  long "file"
               <> short 'f'
               <> metavar "FILE"
               <> help "Input file name")
           <*> switch ( long "no-specialise"
               <> short 'n'
               <> help "Skip specialisation and core emission phases")
           -- Options controlling printing
           <*> switch ( long "verbose"
               <> short 'v'
               <> help "Verbose output")
           <*> switch ( long "dump-ds"
               <> help "Dump desugared contract")
           <*> switch ( long "dump-df"
               <> help "Dump defunctionalised contract")
           <*> switch ( long "dump-spec"
               <> help "Dump specialised contract")
           <*> switch ( long "dump-core"
               <> help "Dump low-level core")
           -- Options controlling diagnostic output
           <*> switch ( long "debug-spec"
               <> help "Debug specialisation")
           <*> switch ( long "debug-core"
               <> help "Debug core emission")
argumentsParser :: IO Option
argumentsParser = do
  let opts = info (options <**> helper)
                  (fullDesc <>
                   header "Solcore - solidity core language")
  opt <- execParser opts
  return opt
