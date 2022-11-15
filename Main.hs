#!/usr/bin/env cabal
{- cabal:
build-depends:
  , base
  , primitive
  , vector
-}

{-# LANGUAGE BangPatterns        #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE MagicHash           #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main (main) where

import Control.Exception
import Control.Monad.Primitive
import Data.Char
import Data.List qualified as L
import Data.Traversable
import Data.Vector qualified as V
import Data.Vector.Mutable qualified as VM
import Data.Vector.Unboxed qualified as U

{-# NOINLINE process #-}
process
  :: V.MVector (PrimState IO) (U.Vector Int)
  -> [U.Vector Int]
  -> V.Vector Int
  -> IO Int
process store haystacks needle = do
  fmap L.minimum $ for haystacks $ \haystack -> do
    V.iforM_ needle $ \idx i -> do
      VM.write store idx (U.slice i 5 haystack)

    -- -- GOOD
    -- store' <- V.freeze store

    -- BAD
    store' <- V.unsafeFreeze store

    evaluate $ processOne store' 0

{-# NOINLINE processOne #-}
processOne
  :: V.Vector (U.Vector Int)
  -> Int
  -> Int
processOne !items !acc
  | V.null items
  = acc
  | otherwise
  = let !curr = V.head items
    in processOne (V.tail items) $! (acc `max` U.head curr + 1)

main :: IO ()
main = do

  let n :: Int
      n = 10000

  let haystacks :: [U.Vector Int]
      haystacks =
        map (U.fromList . map ord) $ map (\k -> "abcdefghijklmnopqrstuvwxyz" ++ show k) [1..n]

      needle :: V.Vector Int
      needle = V.fromList [1..10]

  !res <- do
    store <- VM.new (V.length needle)
    process store haystacks needle

  putStrLn $ "res = " ++ show res

  pure ()
