module Ui.ButtonGroup exposing (Model, view, init) -- where

{-| Groups a series of buttons together.

# Model
@docs Model, init

# View
@docs view
-}
import Html.Events.Extra exposing (onKeys)
import Html exposing (node)

import Ui.Button

{-| Representation of a button group:
  - **disabled** - Whether or not the button group is disabled
  - **items** - The label and action for each button
  - **kind** - The type of the buttons
  - **size** - The size of the buttons
-}
type alias Model msg =
  { items : List (String, msg)
  , disabled : Bool
  , kind : String
  , size : String
  }

{-| Initializes a button group with the given data.

    ButtonGroup.init [ ("Label", Action1)
                     , ("Label2", Action2)
                     ]
-}
init : List (String, msg) -> Model msg
init items =
  { disabled = False
  , items = items
  , kind = "primary"
  , size = "medium"
  }

{-| Renders a button group. -}
view : Model msg -> Html.Html msg
view model =
  render model

-- Render intrenal
render : Model msg -> Html.Html msg
render model =
  node "ui-button-group" []
    (List.map (renderButton model) model.items)

-- Renders a button
renderButton : Model msg -> (String, msg) -> Html.Html msg
renderButton model (label, action) =
  Ui.Button.view
    action
    { disabled = model.disabled
    , kind = model.kind
    , size = model.size
    , text = label
    }
