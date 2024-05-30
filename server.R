library(shiny)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(DT)

shinyServer(function(input, output) {
  
  clutch_data <- read_csv("nba_clutch.csv")

  
  # INTRODUCTION
  
  output$introduction <- renderText({
    #
    HTML(
      "<h2>Project Overview</h2>
      <p>This project aims to analyze and understand NBA player and team clutch performance using data from:</p>
      <ul>
        <li>Clutch free throw attempts/percent made compared to overall free throw attempt/percent made</li>
        <li>Clutch shots taken, made, and percentage</li>
      </ul>
      <p>Clutch moments in basketball games are high pressure and show how players deal with that pressure and use their skills. Some research questions include:</p>
      <ul>
        <li>Does clutch shot efficiency rise with more attempts?</li>
        <li>How much does a player's clutch factor play into winning games?</li>
        <li>How do clutch situations impact free throws and field goals made?</li>
      </ul>
      <p>These questions are important because they can enhance people's appreciation for players' skills when they matter most and how pressure impacts performance efficiency in general.</p>"
    )
    
  })
  
  output$coverImage <- renderImage({
    filename <- normalizePath(file.path('cover.jpg'))
    list(src = filename,
         alt = paste("Cover Image"),
         width = "100%")
  }, deleteFile = FALSE)
  
  output$dataSetInfo <- renderText({
    HTML("
        <h3>Data Set Information</h3>
        <p><strong>Link to Data Set used</strong></p>
        <p><a href='https://github.com/the-pudding/data/tree/master/clutch' target='_blank'>https://github.com/the-pudding/data/tree/master/clutch</a></p>
        
        <p><strong>Who collected the data?</strong></p>
        <p>The Pudding</p>
        
        <p><strong>How was the data collected or generated?</strong></p>
        <p>The data was collected on all the clutch shots taken since the 1996-97 season until last season.</p>
        
        <p><strong>Why was the data collected?</strong></p>
        <p>To quantify clutchness in a number.</p>
        
        <p><strong>What are possible limitations or problems with this data?</strong></p>
        <p>
            Some possible limitations with this data set could be exactly what defines a clutch shot,
            for example, how many possessions back still count as well as how much time left still counts.
            This makes it more difficult to understand and use the data more accurately.
            In addition, the clutch shots are grouped by players and there is no grouping for year,
            which can make it difficult to do anything with the data that involves seasons.
            Also, another problem is that only players who have attempted a clutch shot are recorded,
            which makes it hard to assume what a player that hasn't attempted one yet could do.
            Finally, another problem is that the spread of clutch shots attempted is very wide,
            which can make predictions for some players much better for someone with hundreds of
            clutch attempts versus someone with only a handful.
        </p>
    ")
  })
  
  
  
  
  
  
  # Chart 1
  
  userSample <- reactive({
    clutch_data_filtered <- clutch_data %>% filter(pct_clutch >= input$shotPercentage)
    
    validate(need(nrow(clutch_data_filtered) != 0, "No players found with given shot percentage"))
    
    clutch_data_filtered
  })
  
  # User Input
  output$pct_clutch <- renderUI ({
    sliderInput("shotPercentage", label = h3("Shot Percentage"), min = 0, max = 100, value = 50, step = 0.1)
  })
  
  # Plot rendering
  output$shotPercentagePlot <- renderPlot({
    
    if (nrow(userSample()) >= 40) {
    ggplot(userSample(), aes(x = total_clutch_shots, y = pct_clutch, label = name)) +
      geom_point(size = 3, alpha = 0.7) +
      labs(title = paste0("Player Clutch Attempts VS Shot Percentage above ", input$shotPercentage, "%"),
           x = "Attempts",
           y = "Shot Percentage")
    }
    else {
      ggplot(userSample(), aes(x = total_clutch_shots, y = pct_clutch, label = name)) +
        geom_point(size = 3, alpha = 0.7) +
        geom_text(vjust = -0.75, size = 3) +
        labs(title = paste0("Player Clutch Attempts VS Shot Percentage above ", input$shotPercentage, "%"),
        x = "Attempts",
        y = "Shot Percentage")
    }
      
  })
  
  # List of Players
  output$playerList <- renderDataTable({
    data.frame(userSample()[, c("name", "total_clutch_shots", "pct_clutch")])
  })
  
  # Summary Info
  output$shotPercentSummary <- renderText({
    "This graph shows players based on clutch shots attempted and their completion percentages. This visualization is particularly useful to show how some of the most efficient players in the league stand/stood in clutch situations as well as where players with the most clutch attempts are."
  })
  
  
  
  
  
  
  # Chart 2
  
  addedDataTeam1 <- reactiveVal()
  
  addedDataTeam2 <- reactiveVal()
  
  output$searchInput <- renderUI({
    textInput("searchInput", "Enter a Player Name:")
  })
  
  filteredData <- reactive({
    search_term <- input$searchInput
    if (nchar(search_term) == 0) {
      return(NULL)
    } else {
      return(clutch_data[grep(search_term, clutch_data$name, ignore.case = TRUE), ])
    }
  })
  
  # Show current search
  output$filteredTable <- renderDataTable({
    datatable(filteredData()[, c("name")], options = list(scrollY = "200px", paging = FALSE))
  })
  
  # Add to teams
  observeEvent(input$addButton, {
    selected_team <- input$teamSelector
    selected_rows <- input$filteredTable_rows_selected
    if (length(selected_rows) > 0) {
      if (selected_team == "team1") {
        current_added <- addedDataTeam1()
        new_data <- filteredData()[selected_rows, ]
        addedDataTeam1(rbind(current_added, new_data))
      }
      else {
        current_added <- addedDataTeam2()
        new_data <- filteredData()[selected_rows, ]
        addedDataTeam2(rbind(current_added, new_data))
      }
    }
  })
  
  # Show current selected Team
  output$addedTable <- renderDT({
    selected_team <- input$teamSelector
    if (selected_team == "team1") {
      datatable(addedDataTeam1()[, c("name")], options = list(scrollY = "200px", paging = FALSE, searching = FALSE), selection = "none")
    }
    else {
      datatable(addedDataTeam2()[, c("name")], options = list(scrollY = "200px", paging = FALSE, searching = FALSE), selection = "none")
    }
  })
  
  # Calcualate win percentages
  observeEvent(input$calculateButton, {
    
    team1_data <- addedDataTeam1()
    team2_data <- addedDataTeam2()
    
    tryCatch({ 
    team1_total_swg <- team1_data %>%
      summarise(total_swg = sum(swg_made_per_game)) %>% pull(total_swg)
    team2_total_swg <- team2_data %>%
      summarise(total_swg = sum(swg_made_per_game)) %>% pull(total_swg)
    
    total_swg_sum <- team1_total_swg + team2_total_swg
    team1_percentage <- team1_total_swg / total_swg_sum * 100
    team2_percentage <- team2_total_swg / total_swg_sum * 100
    
    team_data <- data.frame(
      Team = c("Team 1", "Team 2"),
      Percentage = c(team1_percentage, team2_percentage)
    )

    output$teamWinPercentagePlot <- renderPlot({
      ggplot(team_data, aes(x = "", y = Percentage, fill = Team)) +
        geom_bar(stat = "identity", position = "stack") +
        geom_text(aes(label = paste0(round(Percentage, 1), "%")), 
                  position = position_stack(vjust = 0.5)) +
        labs(title = "Win Chance based on Swing Made Per Game",
             x = NULL,
             y = "Win Percentage") +
        coord_flip() +
        scale_fill_manual(values = c("Team 1" = "red", "Team 2" = "blue"))
    })
    
    },
    error = function(e) {
      #Crashes if there are no players in a team so try catch just ignores when it errors
      NULL
      
    })
  })
  
  output$winPredictorSummary <- renderText({
    HTML("<p>This predictor uses each players swing made per game to calculate their impact on any given game. Swing is the affect of a teams win probability if a player makes a clutch shot or not. A player's specific Swing made per game is essentially a players impact on a teams win probability. By adding players to 2 teams, this predictor shows the chances of which team will win.</p>
    <p>Note: Only players who have attempted clutch shots will have a Swing made per game.</p>")
  })
  
  
  
  
  
  # Chart 3
  
  variable_options <- c("clutch free throw pct" = "ft_pct_clutch",
                        "total clutch attempts" = "total_clutch_shots",
                        "clutch shot pct" = "pct_clutch",
                        "clutch shot pct difficulty adjusted" = "pct_clutch_adjusted",
                        "swing made per game" = "swg_made_per_game")
   
  # options
  output$multiSelector <- renderUI({
    selectInput("selectedVariable", "Choose a variable to center the chart around:",
                choices = variable_options, selected = variable_options[0])
  })
   
  # show graph from selected options
  output$variableSpecificPlayerGraph <- renderPlot({
    
    selected_Var <- input$selectedVariable
    
    bar_width <- 5
    
    if (selected_Var == "total_clutch_shots") {
      bar_width <- 50
    }
    else if (selected_Var == "swg_made_per_game") {
      bar_width <- 0.002
    }
    
    ggplot(clutch_data, aes_string(x = input$selectedVariable)) +
      geom_histogram(binwidth = bar_width, fill = "blue", color = "black", alpha = 0.7) +
      labs(title = paste("Player Spread Centered Around", selected_Var),
           x = selected_Var,
           y = "Player Frequency")
    
  })
  
  output$clutchVariableSummary <- renderText({
    HTML("<p>This chart will display a histogram showing where all players in the data set fall in frequency for each variable selected. </p>
    <p><Strong>Clutch free throw pct </Strong>is a players free throw percentage in high pressure clutch situations.</p>
    <p><Strong>Total clutch attempts </Strong>is how many times a player has attempted a clutch shot or clutch free throw.</p>
    <p><Strong>Clutch shot pct </Strong>is a players percentage for clutch shots in general.</p>
    <p><Strong>clutch shot pct difficulty adjusted </Strong>has the players clutch shot percentage adjusted for how difficult each shot was.</p>
    <p><Strong>Swing made per game</Strong> is a players impact on the game, more specifically, how many clutch shots a player makes that affects a teams win probablility.</p>")
  })
  
  
  
  
  
  # Conclusion 
  
  output$conclusionIntroText <- renderText({
    "Since the 1996-97 NBA season, 39903 clutch shots have been taken, with an average of 48% success percentage. When looking at that number compared to normal shots, it is obvious the affect of pressure has on players. Free throw percentage is also down a considerable percent. Surprisingly, harder shots are made very slightly more on average by 1.38 percent, though, the range for adjusted shot percent very high. Finally the best player based on impact is Kobe, this number is the \"difference between the team's win probability if the shot is made vs. if it was missed.\" Players with higher number have much higher impact on a team chances of winning. From this project there were a couple important insights that I will go over here."
  })
  
  output$conclusionInsight1Text <- renderText({
    "The first notable insight found from this project was over time, the more clutch shots a player attempts, the more their average will trend toward 50%. The graph provided shows this trend, as players with more and more attempts converge toward 50%. It shows how varied players who don't attempt many shots are, players with less than 200 attempts fall into a large range between 30%-70%."
  })
  
  output$conclusionGraph1 <- renderPlot({
    ggplot(clutch_data, aes(x = total_clutch_shots, y = pct_clutch, label = name)) +
      geom_point(size = 3, alpha = 0.7) +
      labs(title = "Clutch Shots Attempted vs. Shot Percentage by Player", 
           x = "Clutch Shots Attempted", y = "Shot Percentage")
  
  })
  
  output$conclusionInsight2Text <- renderText({
    "The second insight was on the overall impact of players and how most fall into the area of 0.008-0.016. This histogram visualizes where players fall for impact on a team. This number is found by looking at the swing (effect on team win probability based on a shot going in or not) made per game. The histogram is also right skew meaning most players fall in the height of the bell curve while the farther right you look the less and less players there are."
  })
  
  output$conclusionGraph2 <- renderPlot({
    ggplot(clutch_data, aes(x = swg_made_per_game)) +
      geom_histogram(binwidth = 0.001, fill = "black", boundary = 0) +
      scale_x_continuous(limits = c(0, 0.06)) +
      labs(title = "Swing Made per Game per Player", x = "SWG per Game", y = "Frequency")
  })
  
  output$conclusionInsight3Text <- renderText({
    "The final insight I found was how games played, which essentially translates to experience, do not end up affecting how often a player can make more and more difficult clutch shots. This scatter plot displays players' games played and their adjusted clutch shot percentage, which is based on the difficulty of a shot. \"Clutch\" players end up falling into the positives for making difficult shots regardless of games played and only slightly compacts as the number of games played increases. The distribution is still about equal for a positive or negative adjusted percentage."
  })
  
  output$conclusionGraph3 <- renderPlot({
    ggplot(clutch_data, aes(x = pct_clutch_adjusted, y = gp_all)) +
      geom_point(size = 3, alpha = 0.7) +
      labs(title = "Adjusted Clutch Shot Percentage vs. Games Played",
           x = "Adjusted Clutch Shot Percentage",
           y = "Number of Games Played (including playoffs)")
  })
  
  output$conclusionImportantInsightText <- renderText({
    "From these 3 key insights, I see the first one as the most important as it shows that experience does have an important affect on if a player can make high-pressure shots. While it ends up being closer to 50/50, the high variability in low attempts makes less experienced clutch players from being much more volatile/unpredictable."
  })
  
  output$conclusionBroaderImplications <- renderText({
    "The broader implications can be used to decide who takes crucial game-winning shots when the time comes. Beyond raw talent, the ability to thrive under pressure emerges as a defining trait of elite athletes. This trait can be improved through experience but from this project's insights, many players have more inherent \"clutchness\" compared to others. Coaches and team management must weigh this intangible quality alongside conventional metrics when crafting game plans and roster decisions."
  })
  
})
