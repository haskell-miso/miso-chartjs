-----------------------------------------------------------------------------
{-# LANGUAGE CPP               #-}
{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE OverloadedStrings #-}
-----------------------------------------------------------------------------
module Main where
-----------------------------------------------------------------------------
import           Miso
import           Miso.Html.Element as H
import           Miso.Html.Property as P
import           Miso.Lens
import           Miso.String
import qualified Miso.CSS as CSS
-----------------------------------------------------------------------------
newtype Model = Model { _value :: Int }
  deriving (Show, Eq)
-----------------------------------------------------------------------------
instance ToMisoString Model where
  toMisoString (Model v) = toMisoString v
-----------------------------------------------------------------------------
value :: Lens Model Int
value = lens _value $ \m v -> m { _value = v }
-----------------------------------------------------------------------------
data Action
  = InitBarChart DOMRef
  | InitLineChart DOMRef
  | InitPieChart DOMRef
  | InitPolarChart DOMRef
-----------------------------------------------------------------------------
#ifdef WASM
foreign export javascript "hs_start" main :: IO ()
#endif
-----------------------------------------------------------------------------
main :: IO ()
main = run $ do
#ifdef WASM
  _ <- $(evalFile "js/chart.js")
#endif
  startApp app
-----------------------------------------------------------------------------
app :: App Model Action
app = (component (Model 0) updateModel viewModel)
#ifndef WASM
  { styles = [ Href "static/styles.css" ]
  , scripts = [ Src "https://cdn.jsdelivr.net/npm/chart.js" ]
  }
#endif
-----------------------------------------------------------------------------
updateModel :: Action -> Transition Model Action
updateModel = \case
  InitBarChart domRef ->
    io_ $ global # ("initBarChart" :: MisoString) $ [domRef]
  InitLineChart domRef ->
    io_ $ global # ("initLineChart" :: MisoString) $ [domRef]
  InitPieChart domRef ->
    io_ $ global # ("initPieChart" :: MisoString) $ [domRef]
  InitPolarChart domRef ->
    io_ $ global # ("initPolarChart" :: MisoString) $ [domRef]
-----------------------------------------------------------------------------
githubStar :: View parent action
githubStar = H.iframe_
    [ P.title_ "GitHub"
    , P.height_ "30"
    , P.width_ "170"
    , textProp "scrolling" "0"
    , textProp "frameborder" "0"
    , P.src_
      "https://ghbtns.com/github-btn.html?user=haskell-miso&repo=miso-chartjs&type=star&count=true&size=large"
    ]
    []
-----------------------------------------------------------------------------
viewModel :: Model -> View Model Action
viewModel _ = 
  div_
    [class_ "container"]
    [ githubStar
    , header_
        []
        [ h1_
          [ CSS.style_ [ CSS.fontFamily "monospace" ]
          ]
          [ "🍜 📊 miso chart.js"
          ]
        , p_
            [class_ "subtitle"]
            ["Visualizing data with multiple chart types"]
        ]
    , div_
        [class_ "dashboard"]
        [ div_
            [class_ "chart-container"]
            [ h2_
                [class_ "chart-title"]
                ["Monthly Sales Performance"]
            , div_
                [class_ "chart-wrapper"]
                [ canvas_ [ id_ "barChart"
                          , onCreatedWith InitBarChart
                          ]
                  []
                ]
            -- , div_
            --     [class_ "controls"]
            --     [ button_ [id_ "addData"] ["Add Random Data"]
            --     , button_ [id_ "changeColors"] ["Change Colors"]
            --     ]
            ]
        , div_
            [class_ "chart-container"]
            [ h2_ [class_ "chart-title"] ["Revenue Trends"]
            , div_
                [class_ "chart-wrapper"]
                [canvas_ [ id_ "lineChart"
                         , onCreatedWith InitLineChart
                         ] []]
            -- , div_
            --     [class_ "controls"]
            --     [ button_
            --         [id_ "toggleSmoothing"]
            --         ["Toggle Smoothing"]
            --     , button_ [id_ "addDataset"] ["Add Dataset"]
            --     ]
            ]
        , div_
            [class_ "chart-container"]
            [ h2_
                [class_ "chart-title"]
                ["Product Distribution"]
            , div_
                [class_ "chart-wrapper"]
                [canvas_ [ id_ "pieChart"
                         , onCreatedWith InitPieChart
                         ] []]
            -- , div_
            --     [class_ "controls"]
            --     [ button_ [id_ "randomizePie"] ["Randomize Data"]
            --     , button_
            --         [id_ "switchToDoughnut"]
            --         ["Switch to Doughnut"]
            --     ]
            ]
        , div_
            [class_ "chart-container"]
            [ h2_
                [class_ "chart-title"]
                ["Customer Demographics"]
            , div_
                [class_ "chart-wrapper"]
                [canvas_ [ id_ "polarChart"
                         , onCreatedWith InitPolarChart
                         ] []]
            -- , div_
            --     [class_ "controls"]
            --     [ button_ [id_ "animatePolar"] ["Animate"]
            --     , button_ [id_ "resetPolar"] ["Reset"]
            --     ]
            ]
        ]
    , div_
        [class_ "summary"]
        [ h2_ [] ["Performance Summary"]
        , div_
            [class_ "stats"]
            [ div_
                [class_ "stat-card"]
                [ div_ [class_ "stat-label"] ["Total Revenue"]
                , div_
                    [id_ "totalRevenue", class_ "stat-value"]
                    ["$124,580"]
                ]
            , div_
                [class_ "stat-card"]
                [ div_
                    [class_ "stat-label"]
                    ["Avg. Monthly Growth"]
                , div_
                    [id_ "avgGrowth", class_ "stat-value"]
                    ["+12.4%"]
                ]
            , div_
                [class_ "stat-card"]
                [ div_ [class_ "stat-label"] ["Top Product"]
                , div_
                    [id_ "topProduct", class_ "stat-value"]
                    ["Widget Pro"]
                ]
            , div_
                [class_ "stat-card"]
                [ div_
                    [class_ "stat-label"]
                    ["Customer Satisfaction"]
                , div_
                    [id_ "satisfaction", class_ "stat-value"]
                    ["94%"]
                ]
            ]
        ]
    , footer_
        []
        [ p_
            []
            [ "Interactive Dashboard with Chart.js | Try hovering over charts and clicking the buttons!"
            ]
        ]
    ]
-----------------------------------------------------------------------------
