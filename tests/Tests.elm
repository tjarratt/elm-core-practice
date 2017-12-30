module Tests exposing (..)

import App
import Elmer
import Elmer.Html
import Elmer.Html.Matchers exposing (elementExists)
import Expect
import Test exposing (..)


userOnboarding : Test
userOnboarding =
    describe "Onboarding new users"
        [ test "They should be prompted to type in their name" <|
            \_ ->
                Elmer.given App.defaultModel App.view App.update
                    |> Elmer.Html.target "#App input[type=text]"
                    |> Elmer.Html.expect elementExists
        ]
