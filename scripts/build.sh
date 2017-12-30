#!/usr/bin/env bash

set -ex

elm-format src tests --yes
elm-css src/Stylesheets.elm --output=public
elm app build --yes
npx postcss public/index.css --use autoprefixer -d public
