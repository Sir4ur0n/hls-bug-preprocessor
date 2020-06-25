module LibSpec where

import Lib
import Test.Tasty
import Test.Tasty.HUnit

test_someFunc = testCase "1 + 2 = 3" $ someFunc 1 2 @?= 3
