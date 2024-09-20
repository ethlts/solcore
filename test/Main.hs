module Main where

import Test.Tasty 
import Test.Tasty.Program
import Test.Tasty.ExpectedFailure 

main :: IO ()
main = defaultMain tests 

tests :: TestTree 
tests 
  = testGroup "Tests"
               [
                 cases
               , pragmas
               ]

pragmas :: TestTree 
pragmas 
  = testGroup "Files for pragmas cases"
              [
                expectFail $ runTestForFile "bound.solc" pragmaFolder
              , runTestForFile "coverage.solc" pragmaFolder
              , runTestForFile "patterson.solc" pragmaFolder
              ]
    where 
      pragmaFolder = "./test/examples/pragmas"

cases :: TestTree 
cases 
  = testGroup "Files for folder cases"
              [
                runTestForFile "Ackermann.solc" caseFolder 
              , expectFail $ runTestForFile "BadInstance.solc" caseFolder
              , runTestForFile "BoolNot.solc" caseFolder
              , expectFail $ runTestForFile "Compose.solc" caseFolder
              , expectFail $ runTestForFile "DupFun.solc" caseFolder
              , expectFail $ runTestForFile "DuplicateFun.solc" caseFolder
              , runTestForFile "EitherModule.solc" caseFolder
              , runTestForFile "Id.solc" caseFolder
              , runTestForFile "IncompleteInstDef.solc" caseFolder 
              , runTestForFile "Invokable.solc" caseFolder
              , runTestForFile "ListModule.solc" caseFolder
              , runTestForFile "Logic.solc" caseFolder
              , runTestForFile "Memory1.solc" caseFolder --- FIXME  
              , runTestForFile "Memory2.solc" caseFolder --- FIXME 
              , runTestForFile "Mutuals.solc" caseFolder
              , runTestForFile "NegPair.solc" caseFolder
              , runTestForFile "Option.solc" caseFolder
              , runTestForFile "Pair.solc" caseFolder
              -- , expectFail $ runTestForFile "PairMatch1.solc" caseFolder 
              , expectFail $ runTestForFile"PairMatch2.solc" caseFolder
              , runTestForFile "Peano.solc" caseFolder
              , runTestForFile "PeanoMatch.solc" caseFolder
              , runTestForFile "RefDeref.solc" caseFolder
              , expectFail $ runTestForFile "SillyReturn.solc" caseFolder
              , runTestForFile "SimpleField.solc" caseFolder
              , runTestForFile "SimpleInvoke.solc" caseFolder
              , runTestForFile "SimpleLambda.solc" caseFolder
              , runTestForFile "SingleFun.solc" caseFolder
              , runTestForFile "assembly.solc" caseFolder
              ]
    where 
      caseFolder = "./test/examples/cases"

-- basic infrastructure for tests 

type FileName = String 
type BaseFolder = String 

runTestForFile :: FileName -> BaseFolder -> TestTree 
runTestForFile file folder 
  = testProgram file "cabal" (basicOptions ++ [folder ++ "/" ++ file]) Nothing 

basicOptions :: [String]
basicOptions = [ "new-run"
               , "sol-core"
               , "--"
               , "-f"] 


