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
import Expect
import Test exposing (..)


userOnboarding : Test
userOnboarding =
    describe "new users being onboarded"
        [ test "are prompted to tell us their name"
            (\_ ->
                whenThePageLoads
                    |> expectToSeePrompt "Please tell us your name"
            )
        , skip <|
            test "have a textfield to type in their name"
                (\_ ->
                    whenThePageLoads
                        |> expectToHaveInput "#MyName"
                )
        , skip <|
            test "see their name as they type"
                (\_ ->
                    whenThePageLoads
                        |> enterName "Rachel McPivotal"
                        |> expectToSee "Hello, Rachel McPivotal !"
                )
        , skip <|
            test "are prompted to give us their email address too"
                (\_ ->
                    whenThePageLoads
                        |> enterName "Rachel McPivotal"
                        |> expectToSeePrompt "Please tell us your email address too..."
                )
        , skip <|
            test "are prompted to create an account once they enter an email address"
                (\_ ->
                    whenThePageLoads
                        |> enterName "Rachel McPivotal"
                        |> enterEmail "r.mcpivotal@pivotal.io"
                        |> expectToSeePrompt "Great, you're ready to create your account"
                )
        , skip <|
            test "can submit their name and email to our backend"
                (\_ ->
                    whenThePageLoads
                        |> usingSpies representingSuccess
                        |> enterName "Rachel McPivotal"
                        |> enterEmail "r.mcpivotal@pivotal.io"
                        |> clickThatButton
                        |> expectNewAccountRequestWithBody
                            """{"email":"r.mcpivotal@pivotal.io","name":"Rachel McPivotal"}"""
                )
        , skip <|
            test "see a message when their account is created"
                (\_ ->
                    whenThePageLoads
                        |> usingSpies representingSuccess
                        |> enterName "Rachel McPivotal"
                        |> enterEmail "r.mcpivotal@pivotal.io"
                        |> clickThatButton
                        |> expectToSeePrompt "Great ! Thanks for signing up !"
                )
        , skip <|
            test "see a message when their account cannot be created"
                (\_ ->
                    whenThePageLoads
                        |> usingSpies representingFailure
                        |> enterName "Rachel McPivotal"
                        |> enterEmail "r.mcpivotal@pivotal.io"
                        |> clickThatButton
                        |> expectToSeePrompt "Whoops. Something went wrong."
                )
        ]


whenThePageLoads : Elmer.TestState App.Model App.Msg
whenThePageLoads =
    Elmer.given App.defaultModel App.view App.update


expectToSeePrompt : String -> Elmer.TestState a b -> Expect.Expectation
expectToSeePrompt text testState =
    testState
        |> Elmer.Html.target "#App #Prompt"
        |> Elmer.Html.expect (element <| hasText text)


expectToSee : String -> Elmer.TestState a b -> Expect.Expectation
expectToSee text testState =
    testState
        |> Elmer.Html.target "#App"
        |> Elmer.Html.expect (element <| hasText text)


expectToHaveInput : String -> Elmer.TestState a b -> Expect.Expectation
expectToHaveInput selector testState =
    testState
        |> (Elmer.Html.target <| "#App " ++ selector)
        |> Elmer.Html.expect elementExists


enterName : String -> Elmer.TestState a b -> Elmer.TestState a b
enterName name testState =
    testState
        |> Elmer.Html.target "#App #MyName"
        |> Elmer.Html.Event.input name


enterEmail : String -> Elmer.TestState a b -> Elmer.TestState a b
enterEmail email testState =
    testState
        |> Elmer.Html.target "#App #MyEmail"
        |> Elmer.Html.Event.input email


clickThatButton : Elmer.TestState a b -> Elmer.TestState a b
clickThatButton testState =
    testState
        |> Elmer.Html.target "#App button"
        |> Elmer.Html.Event.click


expectNewAccountRequestWithBody : String -> Elmer.TestState a b -> Expect.Expectation
expectNewAccountRequestWithBody httpBody testState =
    testState
        |> Elmer.Http.expectThat
            (Elmer.Http.Route.post "/api/account")
            (Elmer.each <| hasBody httpBody)


usingSpies : Elmer.Spy.Spy -> Elmer.TestState a b -> Elmer.TestState a b
usingSpies spy testState =
    testState |> Elmer.Spy.use [ spy ]


representingSuccess : Elmer.Spy.Spy
representingSuccess =
    Elmer.Http.serve
        [ Elmer.Http.Stub.for (Elmer.Http.Route.post "/api/account")
            |> Elmer.Http.Stub.withBody """{"message": "Great ! Thanks for signing up !"}"""
        ]


representingFailure : Elmer.Spy.Spy
representingFailure =
    Elmer.Http.serve
        [ Elmer.Http.Stub.for (Elmer.Http.Route.post "/api/account")
            |> Elmer.Http.Stub.withStatus Elmer.Http.Status.serverError
        ]
