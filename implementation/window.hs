
import Data.List.Split

smooth' :: (Fractional a) => [a] -> [a]
smooth' [] = []
smooth' (x:xs) =
  (sum w)/fromIntegral (length w):smooth' xs
    where w = x:(take 3 xs)

smooth :: (Fractional a) => [a] -> [a]
smooth xs = reverse (smooth' (reverse xs))

-- ((n-i)*2)/((n-1)*n)
--weights :: (Fractional a) => Int -> [a]
weights :: (Num b, Fractional b, Enum b) => b -> [b]
weights n =
  map (\i -> ((n-i)*2)/((n-1)*n)) [1.0..n]
--    where n = len*1.0

expected :: (Fractional a, Enum a) => [a] -> a
expected xs = sum $ map (\(w,v) -> w*v) $ zip (weights $ fromIntegral $ length xs) xs

predict' :: (Fractional a, Enum a) => Int -> Int -> [a] -> [a]
predict' num now series
  | num-now > 0 = predict' num (now+1) (expected (take width series):series)
  | otherwise = series
  where width = 7+now*2

predict :: (Fractional a, Enum a) => Int -> [a] -> [a]
predict n series = reverse $ predict' n 0 (reverse $ smooth series)

store :: (Fractional a) => [a] -> IO ()
store xs = writeFile "../dataset/toshl_predict.txt"
           (foldr (\x acc -> x++"\r\n"++acc) "" (map show xs))
main = do
  lines <- readFile "../dataset/toshl.txt"
  store $ predict 10 $ map (\x -> read x::Double) (splitOn "\r\n" lines)
