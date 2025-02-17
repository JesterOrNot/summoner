{- |
Copyright: (c) 2017-2019 Kowainik
SPDX-License-Identifier: MPL-2.0
Maintainer: Kowainik <xrom.xkov@gmail.com>

Contains data type for GHC versions supported by Summoner
and some useful functions for manipulation with them.
-}

module Summoner.GhcVer
       ( GhcVer (..)
       , GhcMeta (..)
       , Pvp (..)
       , showGhcVer
       , parseGhcVer
       , latestLts
       , baseVer
       , cabalBaseVersions
       , ghcTable

       , oldGhcs
       ) where

import Data.List (maximum, minimum)
import Relude.Extra.Enum (inverseMap, universe)

import qualified Text.Show as Show
import qualified Data.Text as T


-- | Represents some selected set of GHC versions.
data GhcVer
    = Ghc7103
    | Ghc802
    | Ghc822
    | Ghc844
    | Ghc865
    | Ghc882
    deriving stock (Eq, Ord, Show, Enum, Bounded)

-- | Converts 'GhcVer' into dot-separated string.
showGhcVer :: GhcVer -> Text
showGhcVer = \case
    Ghc7103 -> "7.10.3"
    Ghc802  -> "8.0.2"
    Ghc822  -> "8.2.2"
    Ghc844  -> "8.4.4"
    Ghc865  -> "8.6.5"
    Ghc882  -> "8.8.2"

-- | These are old GHC versions that are not working with default GHC versions when using Stack.
oldGhcs :: [GhcVer]
oldGhcs = [minBound .. Ghc802]

parseGhcVer :: Text -> Maybe GhcVer
parseGhcVer = inverseMap showGhcVer

-- | Returns latest known LTS resolver for all GHC versions except default one.
latestLts :: GhcVer -> Text
latestLts = \case
    Ghc7103 -> "lts-6.35"
    Ghc802  -> "lts-9.21"
    Ghc822  -> "lts-11.22"
    Ghc844  -> "lts-12.26"
    Ghc865  -> "lts-14.27"
    Ghc882  -> "lts-15.0"

-- | Represents PVP versioning (4 numbers).
data Pvp = Pvp
    { pvpFirst  :: Int
    , pvpSecond :: Int
    , pvpThird  :: Int
    , pvpFourth :: Int
    }

-- | Show PVP version in a standard way: @1.2.3.4@
instance Show Pvp where
    show (Pvp a b c d) = intercalate "." $ map Show.show [a, b, c, d]

-- | Returns base version by 'GhcVer' as 'Pvp'.
baseVerPvp :: GhcVer -> Pvp
baseVerPvp = \case
    Ghc7103 -> Pvp 4 8 0 2
    Ghc802  -> Pvp 4 9 1 0
    Ghc822  -> Pvp 4 10 1 0
    Ghc844  -> Pvp 4 11 1 0
    Ghc865  -> Pvp 4 12 0 0
    Ghc882  -> Pvp 4 13 0 0

-- | Returns corresponding @base@ version of the given GHC version.
baseVer :: GhcVer -> Text
baseVer = show . baseVerPvp

{- | Returns the @base@ bounds for the list of the given GHC versions.

>>> cabalBaseVersions [Ghc844]
"^>= 4.11.1.0"

>>> cabalBaseVersions [Ghc802, Ghc822, Ghc844]
">= 4.9.0.0 && < 4.12"

-}
cabalBaseVersions :: [GhcVer] -> Text
cabalBaseVersions []   = ""
cabalBaseVersions [v]  = "^>= " <> baseVer v
cabalBaseVersions ghcs = ">= " <> baseVer (minimum ghcs) <> " && < " <> upperBound
  where
    upperBound :: Text
    upperBound = let Pvp{..} = baseVerPvp $ maximum ghcs in
        show pvpFirst <> "." <> show (pvpSecond + 1)

-- | Data type to keep meta information for every 'GhcVer'.
data GhcMeta = GhcMeta
    { gmGhc      :: !Text
    , gmBase     :: !Text
    , gmResolver :: !Text
    }

-- | Create corresponding 'GhcMeta' from the given 'GhcVer'.
toGhcMeta :: GhcVer -> GhcMeta
toGhcMeta ghcVer = GhcMeta
    { gmGhc      = "GHC-" <> showGhcVer ghcVer
    , gmBase     = "base-" <> baseVer ghcVer
    , gmResolver = latestLts ghcVer
    }

ghcTable :: [Text]
ghcTable = map (formatGhcMeta . toGhcMeta) universe

{- Formats 'GhcMeta' in a special way.
It aligns the meta to the left, filling on the right with the spaces.

As the pad number it takes the maximum possible length of the data manually.

Example:

@
GHC-8.6.5     base-4.12.0.0   lts-14.17
@
-}
formatGhcMeta :: GhcMeta -> Text
formatGhcMeta GhcMeta{..} =
       T.justifyLeft 12 ' ' gmGhc
    <> "  "
    <> T.justifyLeft 14 ' ' gmBase
    <> "  "
    <> gmResolver
