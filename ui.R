library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
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
                "Win Predictor",
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
                    plotOutput("teamWinPercentagePlot")
                  )
                ),
                sidebarLayout(
                  sidebarPanel(
                    "Created Teams",
                      dataTableOutput("addedTable"),
                    
                  ),
                  mainPanel(
                    
                  )
                )
              ),

              # tabPanel(# Sidebar with a slider input for number of bins
              #   "Player Clutch Predictor",
              #   sidebarLayout(
              #     sidebarPanel(
              #       uiOutput("category"),
              #       uiOutput("year"),
              #       uiOutput("agegrp")
              #     ),
              # 
              #     # Show a plot of the generated distribution
              #     mainPanel(
              #       plotOutput("distPlot"),
              #       uiOutput("summary1")
              #     )
              #   )
              # ),
              # tabPanel("Drug Use Rate Over Time by Age Group",
              #          sidebarLayout(
              #            sidebarPanel(
              #              uiOutput("category2"),
              #              uiOutput("agegrp2")
              #            ),
              #            mainPanel(
              #              plotOutput("linePlot"),
              #              uiOutput("summary2")
              #            )
              #          )),
              # tabPanel("Age When First Use of Drug",
              #          sidebarLayout(
              #            sidebarPanel(
              #              uiOutput("substance"),
              #              uiOutput("year2")
              #            ),
              #            
              #            # Show a plot of the generated distribution
              #            mainPanel(
              #              plotOutput("barPlot"),
              #              uiOutput("summary3")
              #            )
              #          )),
              # tabPanel(
              #   "Conclusion",
              #   mainPanel(
              #     h3("Notable Insight One"),
              #     uiOutput("notableinsightone"),
              #     h5("Cocaine"),
              #     imageOutput("cocaine"),
              #     h5("LSD"),
              #     imageOutput("lsd"),
              #     h5("Heroin"),
              #     imageOutput("heroin"),
              #     h5("Hallucinogins"),
              #     imageOutput("hallucinogin"),
              #     h3("Notable Insight Two"),
              #     uiOutput("notableinsighttwo"),
              #     h5("Cocaine Use in the Past Year"),
              #     imageOutput("graphImage1"),
              #     h5("Recieved Mental Health Services"),
              #     imageOutput("graphImage2"),
              #     h3("Broader Implications and Quality of Data"),
              #     uiOutput("broaderandquality")
              #     
              #     
              #   )
              # )
              
              
              
  )
))
