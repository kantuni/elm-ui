module Ui.DatePicker
  (Model, Action, init, update, view, setValue) where

{-| Date picker input component.

# Model
@docs Model, Action, init, update

# View
@docs view

# Functions
@docs setValue
-}
import Html.Extra exposing (onKeysWithDimensions, onWithDropdownDimensions)
import Html.Events exposing (onBlur, onClick)
import Html.Attributes exposing (classList)
import Html exposing (node, div, text)
import Html.Lazy

import Signal exposing (forwardTo)
import Ext.Signal
import Effects
import Dict

import Date.Format exposing (format)
import Time
import Date

import Ui.Helpers.Dropdown as Dropdown
import Ui.Calendar as Calendar
import Ui

{-| Representation of a date picker component:
  - **calendar** - The model of a calendar
  - **format** - The format of the date to render in the input
  - **closeOnSelect** - Whether or not to close the dropdown after selecting
  - **disabled** - Whether or not the chooser is disabled
  - **readonly** - Whether or not the dropdown is readonly
  - **open** - Whether or not the dropdown is open
-}
type alias Model =
  { mailbox : Signal.Mailbox Time.Time
  , valueSignal : Signal Time.Time
  , calendar : Calendar.Model
  , dropdownPosition : String
  , signal : Signal Action
  , closeOnSelect : Bool
  , format : String
  , disabled : Bool
  , readonly : Bool
  , open : Bool
  }

{-| Actions that a date picker can make:
  - **Focus** - Opens the dropdown
  - **Close** - Closes the dropdown
  - **Toggle** - Toggles the dropdown
  - **Decrement** - Selects the previous day
  - **Increment** - Selects the next day
  - **Calendar** - Calendar actions
-}
type Action
  = Focus Html.Extra.DropdownDimensions
  | Increment Html.Extra.DropdownDimensions
  | Decrement Html.Extra.DropdownDimensions
  | Close Html.Extra.DropdownDimensions
  | Toggle Html.Extra.DropdownDimensions
  | Calendar Calendar.Action
  | Select Time.Time
  | Tasks ()
  | Blur

{-| Initializes a date picker with the given values.

    DatePicker.init date
-}
init : Date.Date -> Model
init date =
  let
    calendar = Calendar.init date
    mailbox = Signal.mailbox 0
  in
    { signal = Signal.map Select calendar.valueSignal
    , valueSignal = mailbox.signal
    , dropdownPosition = "bottom"
    , closeOnSelect = False
    , calendar = calendar
    , format = "%Y-%m-%d"
    , mailbox = mailbox
    , disabled = False
    , readonly = False
    , open = False
    }

{-| Updates a date picker. -}
update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Calendar act ->
      let
        (calendar, effect) = Calendar.update act model.calendar
      in
        ({ model | calendar = calendar }, Effects.map Calendar effect)

    Select time ->
      let
        updatedModel =
          if model.closeOnSelect then
            Dropdown.close model
          else
            model
      in
        (updatedModel, Ext.Signal.sendAsEffect model.mailbox.address time Tasks)

    _ ->
      (update' action model, Effects.none)

update' : Action -> Model -> Model
update' action model =
  case action of
    Focus dimensions ->
      Dropdown.openWithDimensions dimensions model

    Close _ ->
      Dropdown.close model

    Blur ->
      Dropdown.close model

    Toggle dimensions ->
      Dropdown.toggleWithDimensions dimensions model

    Decrement dimensions ->
      { model | calendar = Calendar.previousDay model.calendar }
        |> Dropdown.openWithDimensions dimensions

    Increment dimensions ->
      { model | calendar = Calendar.nextDay model.calendar }
        |> Dropdown.openWithDimensions dimensions

    _ -> model

{-| Renders a date picker. -}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Html.Lazy.lazy2 render address model

-- Renders a date picker.
render : Signal.Address Action -> Model -> Html.Html
render address model =
  let
    actions =
      Ui.enabledActions model
        [ onWithDropdownDimensions "focus" address Focus
        , onBlur address Blur
        , onKeysWithDimensions address [ (27, Close)
                                       , (13, Toggle)
                                       , (40, Increment)
                                       , (38, Decrement)
                                       , (39, Increment)
                                       , (37, Decrement)
                                       ]
        ]
  in
    node "ui-date-picker" ([ classList [ ("dropdown-open", model.open)
                                       , ("disabled", model.disabled)
                                       , ("readonly", model.readonly)
                                       ]
                           ] ++ actions ++ (Ui.tabIndex model))
      [ div [] [text (format model.format model.calendar.value)]
      , Ui.icon "calendar" False []
      , Dropdown.view model.dropdownPosition
        [ node "ui-dropdown-overlay" [onClick address Blur] []
        , Calendar.view (forwardTo address Calendar) model.calendar
        ]
      ]

{-| Sets the value of a date picker -}
setValue : Date.Date -> Model -> Model
setValue date model =
  { model | calendar = Calendar.setValue date model.calendar }
