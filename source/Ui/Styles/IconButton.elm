module Ui.Styles.IconButton exposing (style)

import Css.Properties exposing (..)
import Css exposing (..)

import Ui.Styles.Theme as Theme exposing (Theme)
import Ui.Styles.Button

style : Theme -> Node
style theme =
  selector "ui-icon-button"
    (Ui.Styles.Button.styles theme
    ++
    [ selector "ui-icon-button-icon + span:not(:empty)"
      [ marginLeft (em 0.625)
      ]

    , selector "span:not(:empty) + ui-icon-button-icon"
      [ marginLeft (em 0.625)
      ]

    , selector "ui-icon-button-icon"
      [ display inlineFlex

      , selector "> *"
        [ width inherit
        , height inherit
        ]
      , selector "svg"
        [ fill currentColor ]
      ]

    , selector "&[size=medium] ui-icon-button-icon"
      [ height (px 14)
      , width (px 14)
      ]

    , selector "&[size=big] ui-icon-button-icon"
      [ height (px 18)
      , width (px 18)
      ]

    , selector "&[size=small] ui-icon-button-icon"
      [ height (px 10)
      , width (px 10)
      ]
    ]
    )