{-# LANGUAGE OverloadedStrings #-}
module Main where
import Language.Core(Contract(..))
import Language.Core.Parser
import Common.Pretty(Pretty(..), nest, render)
import TM
import Translate
import Language.Yul(wrapInSolFunction, wrapInContract)
import Options
import Control.Monad(when)
import Data.String(fromString)


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
        putStrLn (render (nest 2 (ppr coreContract)))
        putStrLn "*/"
    generatedYul <- runTM (translateStmts core)
    let fooFun = wrapInSolFunction "wrapper" generatedYul
    let doc = wrapInContract (fromString (ccName coreContract)) "wrapper()" fooFun
    -- putStrLn (render doc)
    putStrLn ("writing output to " ++ output options)
    writeFile (output options) (render doc)



