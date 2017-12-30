module MyCss exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)


type CssClasses
    = NoClassesDefined
    | AddMoreThings


type CssIds
    = Whoops
    | NothingHereYet


css : Css.Stylesheet
css =
    (stylesheet << namespace "")
        [ id Whoops
            []
        , id NothingHereYet
            []
        , class NoClassesDefined
            []
        , class AddMoreThings
            []
        ]
