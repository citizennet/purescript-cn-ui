module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Now (now)
import Data.DateTime.Instant (unInstant)
import Data.Maybe (Maybe)
import Data.Set as Set
import Data.Time.Duration (Milliseconds(..))
import Data.Tuple (Tuple(..))
import Debug.Trace (traceM)
import Ocelot.Data.Record (makeDefaultFormInputs)
import Ocelot.HTML.Properties (appendIProps, css, extract)
import Halogen.HTML as HH
import Test.Unit (suite, test)
import Test.Unit.Assert (equal)
import Test.Unit.Console (log)
import Test.Unit.Main (runTest)
import Type.Prelude (RProxy(..))

type Fields =
  ( email :: String
  , password :: Maybe String
  )

main :: Effect Unit
main = runTest do
  -- suite "Validation" do
    -- traceM $ makeDefaultFormInputs (RProxy :: RProxy Fields)
    -- pure unit
  suite "HTML.Properties" do
    test "appendIProps" do
      let ipropsA = [ css "m-10 p-10 px-5 pb-12 min-w-80 w-full shadow overflow-hidden" ]
          ipropsB = [ css "p-5 pb-10 min-w-100 overflow-auto h-full" ]
          (Tuple results _) = extract $ appendIProps ipropsA ipropsB
          results' = Set.fromFoldable results
          expected = Set.fromFoldable
            [ "m-10"
            , "p-5"
            , "px-5"
            , "pb-10"
            , "min-w-100"
            , "w-full"
            , "shadow"
            , "overflow-auto"
            , "h-full"
            ]
      equal expected results'

    -- naive appendIProps:
    -- 5 tests at 100,000 computations took
    -- 19940.0, 16041.0, 16339.0, 15695.0, 15185.0
    -- milliseconds to run
    -- 5 tests at 10,000 computations took
    -- 2270.0, 1960.0, 1804.0, 1600.0, 1598.0
    -- milliseconds to run
    test "appendIProps profile" do
      start <- liftEffect now
      _ <- log $ "Start time: " <> ( show start )
      let ipropsA = [ css "m-10 p-10 px-5 pb-12 min-w-80 w-full shadow overflow-hidden" ]
          ipropsB = [ css "p-5 pb-10 min-w-100 overflow-auto h-full" ]
          go x acc
            | x <= 0     = acc
            | otherwise  = go (x - 1) $ appendIProps ipropsA ipropsB
          run = go 10000 []
      end <- liftEffect now
      _ <- log $ "End time: " <> ( show end )
      let (Milliseconds start') = unInstant start
          (Milliseconds end')   = unInstant end
      log $ "Total ellapsed time: " <> ( show $ end' - start' )
