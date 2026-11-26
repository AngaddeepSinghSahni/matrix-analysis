module RowReduction where
import Data.Ratio

type Matrix = [[Rational]]
data Step
  = Swap Int Int
  | Scale Rational Int
  | AddScaled Rational Int Int
  deriving (Show, Eq)

numCols :: Matrix -> Int
numCols []          = 0
numCols (row : _)   = length row

applyStep :: Step -> Matrix -> Matrix
applyStep (Swap r1 r2) m = swap r1 r2 m
applyStep (Scale k r) m = scale k r m
applyStep (AddScaled k src dst) m = addScaledRow k src dst m

describeStep :: Step -> String
describeStep (Swap i j) = "R" ++ show (i + 1) ++ " <-> R" ++ show (j + 1)
describeStep (Scale k i) = "R" ++ show (i + 1) ++ " -> R" ++ show (i + 1) ++ "(" ++ showQ (k) ++ ")"
describeStep (AddScaled k src dst) = "R" ++ show (dst + 1) ++ " -> R" ++ show (dst + 1) ++ " + " ++ "(R" ++ show (src + 1) ++ "(" ++ showQ (k) ++ ")" ++ ")"

showQ :: Rational -> String
showQ q
  | denominator q == 1 = show (numerator q)
  | otherwise          = show (numerator q) ++ "/" ++ show (denominator q)

scale :: Rational -> Int -> Matrix -> Matrix
scale k r matrix
  | r < 0 || k == 0 || null rest = matrix
  | otherwise = before ++ map (* k) target : after
  where
    (before, rest) = splitAt r matrix
    target : after = rest

swap :: Int -> Int -> Matrix -> Matrix
swap r1 r2 matrix
  | r1 < 0 || r2 < 0 || r1 >= numRows || r2 >= numRows || r1 == r2 = matrix
  | otherwise = replaceRow r1 row2 (replaceRow r2 row1 matrix)
  where
    numRows = length matrix
    row1 = matrix !! r1
    row2 = matrix !! r2

replaceRow :: Int -> [Rational] -> Matrix -> Matrix
replaceRow r newRow matrix 
  | r < 0 || r >= numRows = matrix
  | otherwise = before ++ newRow : after
 where
    numRows = length matrix
    (before, rest) = splitAt r matrix
    target : after = rest

addScaledRow :: Rational -> Int -> Int -> Matrix -> Matrix
addScaledRow k src dst matrix
  | src < 0 || src >= numRows || dst < 0 || dst >= numRows || src == dst = matrix
  | otherwise = replaceRow dst (zipWith (+) dstRow scaledSrc) matrix
 where
    numRows = length matrix
    srcRow = matrix !! src
    dstRow = matrix !! dst
    scaledSrc = map (* k) srcRow

findPivot :: Int -> Int -> Matrix -> Maybe Int
findPivot _ _ [] = Nothing
findPivot r c matrix
  | r < 0 || r >= numRows || c < 0 || c >= numCols matrix || null matrix = Nothing
  | (matrix !! r) !! c /= 0 = Just r
  | otherwise = findPivot (r+1) c matrix
 where
    numRows = length matrix

pivotStep :: Int -> Int -> Int -> (Matrix, [Step]) -> (Matrix, [Step])
pivotStep r c pivotRow (m, steps) = (m2, scaleStep : swapSteps ++ steps)
  where
    swapSteps = if pivotRow /= r then [Swap r pivotRow] else []
    m1        = foldl (flip applyStep) m swapSteps
    val       = (m1 !! r) !! c
    scaleStep = Scale (1 / val) r
    m2        = applyStep scaleStep m1

findLeadingCol :: [Rational] -> Int -> Maybe Int
findLeadingCol [] _ = Nothing
findLeadingCol (x : xs) c
  | x /= 0 = Just c
  | otherwise = findLeadingCol xs (c + 1)

ref :: Matrix -> (Matrix, [Step])
ref mat = (finalMat, reverse finalSteps)
  where
    (finalMat, finalSteps) = go 0 0 (mat, [])
    numRows = length mat

    go :: Int -> Int -> (Matrix, [Step]) -> (Matrix, [Step])
    go r c (currentMat, steps)
      | r >= numRows || c >= numCols mat = (currentMat, steps)
      | otherwise = case findPivot r c currentMat of
          Nothing       -> go r (c + 1) (currentMat, steps)
          Just pivotRow ->
            let pivoted = pivotStep r c pivotRow (currentMat, steps)
                cleared = eliminateBelow r c (r + 1) pivoted
            in go (r + 1) (c + 1) cleared

    eliminateBelow :: Int -> Int -> Int -> (Matrix, [Step]) -> (Matrix, [Step])
    eliminateBelow r c i (matSoFar, steps)
      | i >= numRows = (matSoFar, steps)
      | factor == 0  = eliminateBelow r c (i + 1) (matSoFar, steps)
      | otherwise    = eliminateBelow r c (i + 1) (applyStep step matSoFar, step : steps)
      where
        factor = -((matSoFar !! i) !! c)
        step   = AddScaled factor r i

rref :: Matrix -> (Matrix, [Step])
rref mat = (finalMat, reverse finalSteps)
  where
    (refMat, refSteps)     = ref mat
    (finalMat, finalSteps) = go 0 (refMat, reverse refSteps)
    numRows = length mat

    go :: Int -> (Matrix, [Step]) -> (Matrix, [Step])
    go r (currentMat, steps)
      | r >= numRows = (currentMat, steps)
      | otherwise = case findLeadingCol (currentMat !! r) 0 of
          Nothing -> go (r + 1) (currentMat, steps)
          Just c  -> go (r + 1) (eliminateAbove r c 0 (currentMat, steps))

    eliminateAbove :: Int -> Int -> Int -> (Matrix, [Step]) -> (Matrix, [Step])
    eliminateAbove r c i (matSoFar, steps)
      | i >= r       = (matSoFar, steps)
      | factor == 0  = eliminateAbove r c (i + 1) (matSoFar, steps)
      | otherwise    = eliminateAbove r c (i + 1) (applyStep step matSoFar, step : steps)
      where
        factor = -((matSoFar !! i) !! c)
        step   = AddScaled factor r i