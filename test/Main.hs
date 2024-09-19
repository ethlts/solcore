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
              , expectFail $ runTestForFile "EitherModule.solc" caseFolder -- XXX remove warning (check with Marcin)
              , runTestForFile "Enum.solc" caseFolder
              , runTestForFile "Eq.solc" caseFolder
              , expectFail $ runTestForFile "EvenOdd.solc" caseFolder --- FIXME
              , runTestForFile "Filter.solc" caseFolder
              , runTestForFile "Foo.solc" caseFolder
              , expectFail $ runTestForFile "GetSet.solc" caseFolder --- FIXME
              , runTestForFile "GoodInstance.solc" caseFolder
              , expectFail $ runTestForFile "Id.solc" caseFolder --- FIXME remove warning (check with Marcin)
              , runTestForFile "IncompleteInstDef.solc" caseFolder 
              , runTestForFile "Invokable.solc" caseFolder
              , expectFail $ runTestForFile "ListModule.solc" caseFolder --- FIXME remove warning (check with Marcin)
              , expectFail $ runTestForFile "Logic.solc" caseFolder --- FIXME remove warning (check with Marcin)
              , expectFail $ runTestForFile "Memory1.solc" caseFolder --- FIXME  
              , expectFail $ runTestForFile "Memory2.solc" caseFolder --- FIXME 
              , runTestForFile "Mutuals.solc" caseFolder
              , runTestForFile "NegPair.solc" caseFolder
              , expectFail $ runTestForFile "Option.solc" caseFolder --- FIXME remove warning (check with Marcin)
              , expectFail $ runTestForFile "Pair.solc" caseFolder -- FIXME remove warning
              , expectFail $ runTestForFile "PairMatch1.solc" caseFolder 
              , expectFail $ runTestForFile"PairMatch2.solc" caseFolder
              , expectFail $ runTestForFile "Peano.solc" caseFolder -- FIXME remove warning (check with Marcin)
              , runTestForFile "PeanoMatch.solc" caseFolder
              , runTestForFile "RefDeref.solc" caseFolder
              , expectFail $ runTestForFile "SillyReturn.solc" caseFolder
              , expectFail $ runTestForFile "SimpleField.solc" caseFolder -- FIXME remove warning (check with Marcin)
              , expectFail $ runTestForFile "SimpleInvoke.solc" caseFolder -- FIXME
              , expectFail $ runTestForFile "SimpleLambda.solc" caseFolder -- FIXME remove warning (check with Marcin)
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


