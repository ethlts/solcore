module Main where
import Language.Core(Contract(..))
import Language.Core.Parser
import Common.Pretty(Pretty(..), nest, render)
import TM
import Translate
import Language.Yul(wrapInSolFunction, wrapInContract)
import Options.Applicative
import Control.Monad(when)

data Options = Options
    { input :: FilePath
    , contract :: String
    , output :: FilePath
    , verbose :: Bool
    } deriving Show

optionsParser :: Parser Options
optionsParser = Options
    <$> argument str
        ( metavar "FILE"
        <> help "Input file" )
    <*> strOption
        ( long "contract"
        <> short 'c'
        <> metavar "NAME"
        <> help "Contract name"
        <> value "Output")
    <*> strOption
        ( long "output"
        <> short 'o'
        <> metavar "FILE"
        <> help "Output file"
        <> value "Output.sol")
    <*> switch
        ( long "verbose"
        <> short 'v'
        <> help "Verbosity level"
        <> showDefault
        )

main :: IO ()
main = do
    options <- parseOptions
    -- print options
    let filename = input options
    src <- readFile filename
    let coreContract = parseContract filename src
    let core = ccStmts coreContract
    when (verbose options) $ do
        putStrLn "/* Core:"
        putStrLn (render (nest 2 (pretty coreContract)))
        putStrLn "*/"
    generatedYul <- runTM (translateStmts core)
    let fooFun = wrapInSolFunction "wrapper" generatedYul
    let doc = wrapInContract (ccName coreContract) "wrapper()" fooFun
    -- putStrLn (render doc)
    putStrLn ("writing output to " ++ output options)
    writeFile (output options) (render doc)


parseOptions :: IO Options
parseOptions = execParser opts
  where
    opts = info (optionsParser <**> helper)
      ( fullDesc
     <> progDesc "Compile a Core program to Yul"
     <> header "yule - experiments with Yul codegen" )

