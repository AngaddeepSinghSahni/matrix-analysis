module Main (main) where

import Data.Ratio (numerator, denominator)
import RowReduction

-- Prints a matrix with the columns lined up.
printMatrix :: Matrix -> IO ()
printMatrix m = mapM_ (putStrLn . unwords . map pad) strs
  where
    strs  = map (map showQ) m
    width = maximum (1 : map length (concat strs))
    pad s = replicate (width - length s) ' ' ++ s

-- Replays the steps from the original matrix and prints each one
-- followed by the matrix it produced.
printSteps :: Matrix -> [Step] -> IO ()
printSteps original steps = do
  putStrLn "Start:"
  printMatrix original
  mapM_ showOne (zip steps (drop 1 matrices))
  where
    matrices = scanl (flip applyStep) original steps
    showOne (step, mat) = do
      putStrLn ""
      putStrLn (describeStep step)
      printMatrix mat

main :: IO ()
main = do
  let m = [[0,1,2],[2,4,6],[1,1,1]]
      (result, steps) = rref m
  putStrLn "Matrix:"
  printMatrix m
  putStrLn ("\nAfter " ++ show (length steps) ++ " row operations:")
  printMatrix result
