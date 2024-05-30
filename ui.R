library(shiny)

shinyUI(fluidPage(
  includeCSS("styles.css"),

  navbarPage( "NBA Clutch Predictor",
              tabPanel(
                "Introduction",
                mainPanel(
                  uiOutput("introduction"),
                  div(style = "text-align:center; margin: 10% 0%;", imageOutput("coverImage")),
                  uiOutput("dataSetInfo")
                )
              ),
              
              tabPanel(
                "Shot Percentage",
                sidebarLayout(
                  sidebarPanel(
                    uiOutput("pct_clutch"),
                    uiOutput("shotPercentSummary")
                  ),
                  mainPanel(
                    plotOutput("shotPercentagePlot"),
                    dataTableOutput("playerList")
                  )
                )
              ),
              
              tabPanel(
                "Clutch Win Predictor",
                sidebarLayout(
                  sidebarPanel(
                    uiOutput("searchInput"),
                    dataTableOutput("filteredTable"),
                    radioButtons("teamSelector", "Select a Team:",
                                 choices = list("Team 1" = "team1", "Team 2" = "team2"),
                                 selected = "team1", inline = TRUE),
                    actionButton("addButton", "Add Selected")
                  ),
                  mainPanel(
                    actionButton("calculateButton", "Predict Winner"),
                    plotOutput("teamWinPercentagePlot")
                  )
                ),
                sidebarLayout(
                  sidebarPanel(
                    "Created Teams",
                    dataTableOutput("addedTable"),
                  ),
                  mainPanel(
                    uiOutput("winPredictorSummary")
                  )
                )
              ),
              
              tabPanel(
                "Stat Frequency",
                sidebarLayout(
                  sidebarPanel(
                    uiOutput("multiSelector"),
                    uiOutput("clutchVariableSummary")
                  ),
                  mainPanel(
                    plotOutput("variableSpecificPlayerGraph")
                  )
                )
              ),
    
              tabPanel(
                "Conclusion",
                mainPanel(
                  h2("Conclusion"),
                  uiOutput("conclusionIntroText"),
                  h3("Insight 1:"),
                  uiOutput("conclusionInsight1Text"),
                  plotOutput("conclusionGraph1"),
                  h3("Insight 2:"),
                  uiOutput("conclusionInsight2Text"),
                  plotOutput("conclusionGraph2"),
                  h3("Insight 3:"),
                  uiOutput("conclusionInsight3Text"),
                  plotOutput("conclusionGraph3"),
                  h3("Most Important Insight:"),
                  uiOutput("conclusionImportantInsightText"),
                  h3("Broader Implications:"),
                  uiOutput("conclusionBroaderImplications")
                )
              )
   )
))
