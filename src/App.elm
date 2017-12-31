module App exposing (defaultModel, view, update, Model, Msg)

import MyCss
import Html exposing (Html, text, div, h1, img, input, span, button)
import Html.Attributes exposing (src)
import Html.Events exposing (onClick, onInput)
import Html.CssHelpers
import Http
import Json.Decode
import Json.Encode


---- MODEL ----


type alias Model =
    {}


defaultModel : Model
defaultModel =
    {}


init : ( Model, Cmd Msg )
init =
    ( defaultModel, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text "Your Elm App is working!" ]
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }



----- CSS Helpers ----


{ id, class, classList } =
    Html.CssHelpers.withNamespace "index"
