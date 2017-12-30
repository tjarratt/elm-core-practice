module Tests exposing (..)

import App
import Elmer
import Elmer.Html
import Elmer.Html.Event
import Elmer.Html.Matchers exposing (element, elementExists, hasText)
import Elmer.Http
import Elmer.Http.Matchers exposing (hasBody)
import Elmer.Http.Route
import Elmer.Http.Status
import Elmer.Http.Stub
import Elmer.Spy
import Test exposing (..)


userOnboarding : Test
userOnboarding =
    describe "Onboarding new users"
        [ test "They should be prompted to tell us their name" <|
            \_ ->
                Elmer.given App.defaultModel App.view App.update
                    |> Elmer.Html.target "#App #Prompt"
                    |> Elmer.Html.expect (element <| hasText "Please tell us your name")
        , test "They should have a textfield to type in their name" <|
            \_ ->
                Elmer.given App.defaultModel App.view App.update
                    |> Elmer.Html.target "#App #MyName"
                    |> Elmer.Html.expect elementExists
        , test "They should see their name as they type" <|
            \_ ->
                Elmer.given App.defaultModel App.view App.update
                    |> Elmer.Html.target "#App #MyName"
                    |> Elmer.Html.Event.input "Rachel McPivotal"
                    |> Elmer.Html.target "#App"
                    |> Elmer.Html.expect (element <| hasText "Hello, Rachel McPivotal !")
        , test "They should be prompted to give us their email address too" <|
            \_ ->
                Elmer.given App.defaultModel App.view App.update
                    |> Elmer.Html.target "#App #MyName"
                    |> Elmer.Html.Event.input "Rachel McPivotal"
                    |> Elmer.Html.target "#App #Prompt"
                    |> Elmer.Html.expect (element <| hasText "Please tell us your email address too...")
        , test "They should be prompted to create an account once they enter an email address" <|
            \_ ->
                Elmer.given App.defaultModel App.view App.update
                    |> Elmer.Html.target "#App #MyName"
                    |> Elmer.Html.Event.input "Rachel McPivotal"
                    |> Elmer.Html.target "#App #MyEmail"
                    |> Elmer.Html.Event.input "r.mcpivotal@pivotal.io"
                    |> Elmer.Html.target "#App #Prompt"
                    |> Elmer.Html.expect (element <| hasText "Great, you're ready to create your account")
        , test "Clicking the submit button sends their name and email to the backend" <|
            \_ ->
                Elmer.given App.defaultModel App.view App.update
                    |> Elmer.Spy.use [ createAccountSpy ]
                    |> Elmer.Html.target "#App #MyName"
                    |> Elmer.Html.Event.input "Rachel McPivotal"
                    |> Elmer.Html.target "#App #MyEmail"
                    |> Elmer.Html.Event.input "r.mcpivotal@pivotal.io"
                    |> Elmer.Html.target "#App button"
                    |> Elmer.Html.Event.click
                    |> Elmer.Http.expectThat
                        (Elmer.Http.Route.post "/api/account")
                        (Elmer.each <|
                            hasBody
                                """{"email":"r.mcpivotal@pivotal.io","name":"Rachel McPivotal"}"""
                        )
        , test "They should see a message when their account is created" <|
            \_ ->
                Elmer.given App.defaultModel App.view App.update
                    |> Elmer.Spy.use [ createAccountSpy ]
                    |> Elmer.Html.target "#App #MyName"
                    |> Elmer.Html.Event.input "Rachel McPivotal"
                    |> Elmer.Html.target "#App #MyEmail"
                    |> Elmer.Html.Event.input "r.mcpivotal@pivotal.io"
                    |> Elmer.Html.target "#App button"
                    |> Elmer.Html.Event.click
                    |> Elmer.Html.target "#App #Prompt"
                    |> Elmer.Html.expect (element <| hasText "Great ! Thanks for signing up !")
        , test "They should see a message when their account cannot be created" <|
            \_ ->
                Elmer.given App.defaultModel App.view App.update
                    |> Elmer.Spy.use [ cannotCreateAccountSpy ]
                    |> Elmer.Html.target "#App #MyName"
                    |> Elmer.Html.Event.input "Rachel McPivotal"
                    |> Elmer.Html.target "#App #MyEmail"
                    |> Elmer.Html.Event.input "r.mcpivotal@pivotal.io"
                    |> Elmer.Html.target "#App button"
                    |> Elmer.Html.Event.click
                    |> Elmer.Html.target "#App #Prompt"
                    |> Elmer.Html.expect (element <| hasText "Whoops. Something went wrong.")
        ]


createAccountSpy : Elmer.Spy.Spy
createAccountSpy =
    Elmer.Http.serve
        [ Elmer.Http.Stub.for (Elmer.Http.Route.post "/api/account")
            |> Elmer.Http.Stub.withBody """[{"message": "Great ! Thanks for signing up !"}]"""
        ]


cannotCreateAccountSpy : Elmer.Spy.Spy
cannotCreateAccountSpy =
    Elmer.Http.serve
        [ Elmer.Http.Stub.for (Elmer.Http.Route.post "/api/account")
            |> Elmer.Http.Stub.withStatus Elmer.Http.Status.serverError
        ]
