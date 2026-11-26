module MatrixOps where
import RowReduction

validate :: Matrix -> Either String Matrix
validate m
  | isRectangular m = Right m
  | otherwise       = Left "All rows must have the same number of entries."

matrixSize :: Matrix -> (Int,Int)
matrixSize mat = (numRows, numCols)
  where
    numRows = length mat
    numCols = case mat of
      (firstRow : _) -> length firstRow
      [] -> 0

isRectangular :: Matrix -> Bool
isRectangular [] = False
isRectangular (firstRow : rest) =
  not (null firstRow) && all (== length firstRow) (map length rest)

isSquare :: Matrix -> Bool
isSquare matrix = isRectangular matrix && length matrix == numCols matrix

stepFactor :: Step -> Rational
stepFactor (Swap _ _)        = -1
stepFactor (Scale k _)       = k
stepFactor (AddScaled _ _ _) = 1

totalFactor :: [Step] -> Rational
totalFactor []       = 1
totalFactor (s : ss) = stepFactor s * totalFactor ss

diagonal :: Matrix -> [Rational]
diagonal matrix = [ (matrix !! i) !! i | (i, row) <- zip [0..] matrix ]

determinant :: Matrix -> Maybe Rational
determinant matrix
  | isSquare matrix = Just ((product (diagonal reduced)) / totalFactor steps)
  | otherwise       = Nothing
  where
    (reduced, steps) = ref matrix

identity :: Int -> Matrix
identity n
  | n <= 0 = []
  | otherwise = [[ if r == c then 1 else 0 | c <- [0 .. n - 1] ] | r <- [0 .. n - 1]]

inverse :: Matrix -> Maybe Matrix
inverse matrix
  | not (isSquare matrix) = Nothing
  | leftHalf == identity n = Just rightHalf
  | otherwise = Nothing
  where
    n = length matrix
    augmented = zipWith (++) matrix (identity n)
    (reduced, _) = rref augmented
    leftHalf  = map (take n) reduced
    rightHalf = map (drop n) reduced

pivotPositions :: Matrix -> [(Int, Int)]
pivotPositions matrix = [ (r, c) | (r, row) <- zip [0..] rrefMatrix, Just c <- [findLeadingCol row 0] ]
  where
    (rrefMatrix, _) = rref matrix

pivotColumns :: Matrix -> [Int]
pivotColumns matrix = map snd (pivotPositions matrix)

rank :: Matrix -> Int
rank matrix = length (pivotColumns matrix)

nullity :: Matrix -> Int
nullity matrix = numCols matrix - rank matrix

columnsIndependent :: Matrix -> Bool
columnsIndependent matrix = numCols matrix == rank matrix

rowsIndependent :: Matrix -> Bool
rowsIndependent matrix = numRows == rank matrix
  where
    numRows = length matrix