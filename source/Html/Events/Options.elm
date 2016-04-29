module Html.Events.Options exposing (..)

-- where

import Html.Events exposing (Options)

{-| Prevent default options.
-}
preventDefaultOptions : Options
preventDefaultOptions =
  { stopPropagation = False
  , preventDefault = True
  }


{-| Stop propagation options.
-}
stopPropagationOptions : Options
stopPropagationOptions =
  { stopPropagation = True
  , preventDefault = False
  }


{-| Options for completely stopping an event and
preventing it's default behavior.
-}
stopOptions : Options
stopOptions =
  { stopPropagation = True
  , preventDefault = True
  }
