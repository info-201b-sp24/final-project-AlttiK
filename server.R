library(shiny)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(DT)

shinyServer(function(input, output) {
  
  clutch_data <- read_csv("nba_clutch.csv")
  
  addedDataTeam1 <- reactiveVal()
  
  addedDataTeam2 <- reactiveVal()
  
  
  
  
  
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
        <li>How do clutch situations impact free throws and field goals made?</li>
        <li>How much does a player's clutch factor play into winning games?</li>
        <li>Does clutch shot efficiency rise with more attempts?</li>
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
        <p><strong>Where did you find the data?</strong></p>
        <p><a href='https://github.com/the-pudding/data/tree/master/clutch' target='_blank'>https://github.com/the-pudding/data/tree/master/clutch</a></p>
        
        <p><strong>Who collected the data?</strong></p>
        <p>The Pudding</p>
        
        <p><strong>How was the data collected or generated?</strong></p>
        <p>The data was collected on all the clutch shots taken since the 1996-97 season until last season.</p>
        
        <p><strong>Why was the data collected?</strong></p>
        <p>To quantify clutchness in a number.</p>
        
        <p><strong>How many observations (rows) are in your data?</strong></p>
        <p>There are 288 observations in the data set.</p>
        
        <p><strong>How many features (columns) are in the data?</strong></p>
        <p>There are 11 features in the data set.</p>
        
        <p><strong>What, if any, ethical questions or questions of power do you need to consider when working with this data?</strong></p>
        <p>There does not seem to be any questions of power to consider.</p>
        
        <p><strong>What are possible limitations or problems with this data? (at least 200 words)</strong></p>
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
    
    validate(
      need(nrow(clutch_data_filtered) != 0, "No players found with given shot percentage")
    )
    
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
  
  # List of PLayers
  output$playerList <- renderDataTable({
    data.frame(userSample()[, c("name", "total_clutch_shots", "pct_clutch")])
  })
  
  # Summary Info
  output$shotPercentSummary <- renderText({
    "This graph shows players based on clutch shots attempted and their completion percentages. This visualization is particularly useful to show how some of the most efficient players in the league stand/stood in clutch situations as well as where players with the most clutch attempts are."
  })
  
  
  
  
  
  
  # Chart 2
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
  
  output$filteredTable <- renderDataTable({
    datatable(filteredData()[, c("name")], options = list(scrollY = "200px", paging = FALSE))
  })
  
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
  
  output$addedTable <- renderDT({
    selected_team <- input$teamSelector
    if (selected_team == "team1") {
      datatable(addedDataTeam1()[, c("name")], options = list(scrollY = "200px", paging = FALSE, searching = FALSE), selection = "none")
    }
    else {
      datatable(addedDataTeam2()[, c("name")], options = list(scrollY = "200px", paging = FALSE, searching = FALSE), selection = "none")
    }
  })
  
  output$teamWinPercentagePlot <- renderPlot({
    
  })
  
  
  
  
  
  
  
  
  
  
  # Chart 3
  
  

  # # CHART 1 WORK
  # sample <- reactive({
  #   eg <-  data %>%
  #     filter(year == input$year) %>%
  #     filter(agegrp == input$age) %>%
  #     filter(outname == input$category)
  # 
  #   validate(
  #     need(nrow(eg) != 0, "Data not available. Please change age group or year.")
  #   )
  # 
  #   data %>%
  #     filter(year == input$year) %>%
  #     filter(agegrp == input$age) %>%
  #     filter(outname == input$category) %>%
  #     left_join(us, data, by = "region")
  # 
  # })
  # output$distPlot <- renderPlot({
  # 
  #   ggplot(sample(), aes(x = long, y = lat, group=group, fill = BSAE)) +
  #     geom_polygon(col = "grey") +
  #     ggtitle(str_to_title(paste(input$category, "in the USA in", input$year))) +
  #     theme(axis.title.x=element_blank(),
  #           axis.text.x=element_blank(),
  #           axis.ticks.y=element_blank(),
  #           axis.title.y=element_blank(),
  #           axis.text.y=element_blank()) +
  #     coord_quickmap()
  # 
  # 
  # })
  # 
  # output$agegrp <- renderUI ({
  #   radioButtons("age", label = h3("Select Age Group"), 
  #                choices = list("12 or older" = 0, "12 to 17" = 1, "18 to 25" = 2,
  #                               "26 or older" = 3, "18 or older" = 4), 
  #                selected = 4)
  # })
  # 
  # output$year <- renderUI({
  #   sliderInput("year", label = h3("Year"), min = 1999, 
  #               max = 2018, value = 2018, step = 1)
  # })
  # 
  # output$category <- renderUI({
  #   selectInput("category", label = h3("Drug Usage or Mental Health Category"),
  #               choices = unique(data$outname), 
  #               selected = "alcohol use in the past month")
  # })
  # 
  # output$summary1 <- renderText ({
  #   "This chart shows drug usage by the state for a specified drug, year, 
  #       and age group. Ideally, this could better inform lawmakers and 
  #       institutions about where more information on drugs is most relevant and 
  #       inform healthcare providers in some states about what drug-related 
  #       topics they should cover with their patients and at what ages."
  # })
  # 
  # # CHART 3 WORK
  # output$substance <- renderUI ({
  #   radioButtons("substance", label = h3("Select Substance Type"), 
  #                choices = list("Cigarettes" = "CIGTRY", "Alchohol"= "ALCTRY", "Marijuana" = "MJAGE",
  #                               "Cocaine" = "COCAGE", "Heroin" = "HERAGE", "Hallucinogens" = "HALLUCAGE",
  #                               "LSD" = "LSDAGE", "Inhalants" = "INHALAGE"),
  #                selected = "CIGTRY")
  # })
  # 
  # output$year2 <- renderUI({
  #   sliderInput("year2", label = h3("Year"), min = 2015, 
  #               max = 2019, value = 2019, step = 1)
  # })
  # 
  # 
  # barSample <- reactive({
  #   barDf %>%
  #     filter(Year == input$year2) %>%
  #     filter(substance == input$substance) %>%
  #     filter(age < 80) 
  #   
  #   
  # })
  # 
  # output$barPlot <- renderPlot({
  #   ggplot(barSample(), aes(x = age)) +
  #     geom_bar(fill = "grey")
  # })
  # 
  # output$summary3 <- renderText ({
  #   "This bar chart, which purely focuses on age and substance type, would 
  #       be most useful for healthcare providers and academic institutions. The 
  #       chart could allow these groups to better understand the demographics 
  #       they are working with and the information most relevant to that group. 
  #       For example, in recent years, inhalants have skewed much younger than 
  #       cocaine. "
  # })
  # 
  # # CHART 2 WORK
  # lineData <- reactive({
  #   eg <-  data %>%
  #     filter(agegrp == input$age2) %>%
  #     filter(outname == input$category2) %>%
  #     filter(region == "national")
  #   
  #   validate(
  #     need(nrow(eg) != 0, "Data not available. Please change age group or year.")
  #   )
  #   
  #   data %>%
  #     filter(agegrp == input$age2) %>%
  #     filter(outname == input$category2) %>%
  #     filter(region == "national")
  #   
  # })
  # 
  # #chart 2 line plot output
  # output$linePlot <- renderPlot({
  #   group <- switch((strtoi(input$age2) + 1), "12 or older", "12 to 17", "18 to 25",
  #                   "26 or older", "18 or older")
  #   
  #   ggplot(lineData(), aes(x = year, y = BSAE, color = group)) +
  #     geom_line() +
  #     geom_point() +
  #     labs(title = "Drugs BSAE from 1999-2019 for different Age Groups", 
  #          x = "Year",
  #          y = "BSAE",
  #          color = "Age Group"
  #     ) 
  #   
  #   
  # })
  # 
  # output$category2 <- renderUI({
  #   selectInput("category2", label = h3("Drug Usage or Mental Health Category"),
  #               choices = unique(data$outname), 
  #               selected = "alcohol use in the past month")
  # })
  # 
  # output$agegrp2 <- renderUI ({
  #   radioButtons("age2", label = h3("Select Age Group"), 
  #                choices = list("12 or older" = 0, "12 to 17" = 1, "18 to 25" = 2,
  #                               "26 or older" = 3, "18 or older" = 4), 
  #                selected = 4)
  # })
  # 
  # output$summary2 <- renderText ({
  #   "This chart, which shows drug usage by an age group over time (meaning 
  #       the number of people in a given age group who used a specified drug for 
  #       a given time), might help policymakers better understand the impact 
  #       that their policies and messaging have had on drug usage. This also 
  #       shows various trends for certain drugs over time, such as with marijuana 
  #       which has seen a dramatic rise in the past decade. This information
  #       would be useful for healthcare providers trying to better understand 
  #       the demographics whom they serve."
  # })
  # # CONCLUSION
  # output$notableinsightone <- renderText({
  #   "One notable insight discovered in our project was that the average age 
  #       when first using for hard subtances such as cocaine, heroin, LSD, and 
  #       hallucinogens is around 20 years old. The average 
  #       age stayed consistent from 2015-2019. When choosing the different 
  #       substances and changing the year you can see how the graphs are
  #       positively skewed." })
  # 
  # output$graphImage1 <- renderImage({
  #   filename <- normalizePath(file.path('cocaineUse.png'))
  #   list(src = filename,
  #        width = 600, height = 300,
  #        alt = paste("Graph_1", input$n))
  # }, deleteFile = FALSE)
  # 
  # output$graphImage2 <- renderImage({
  #   filename <- normalizePath(file.path('mentalHealth.png'))
  #   list(src = filename,
  #        width = 600, height = 300,
  #        alt = paste("Graph_2", input$n))
  # }, deleteFile = FALSE)
  # 
  # output$cocaine <- renderImage({
  #   filename <- normalizePath(file.path('cocaine.png'))
  #   list(src = filename,
  #        width = 600, height = 300,
  #        alt = paste("cocaine", input$n))
  # }, deleteFile = FALSE)
  # 
  # output$lsd <- renderImage({
  #   filename <- normalizePath(file.path('lsd.png'))
  #   list(src = filename,
  #        width = 600, height = 300,
  #        alt = paste("lsd", input$n))
  # }, deleteFile = FALSE)
  # 
  # output$heroin <- renderImage({
  #   filename <- normalizePath(file.path('heroin.png'))
  #   list(src = filename,
  #        width = 600, height = 300,
  #        alt = paste("Gheroin", input$n))
  # }, deleteFile = FALSE)
  # 
  # output$hallucinogin <- renderImage({
  #   filename <- normalizePath(file.path('hallucinogin.png'))
  #   list(src = filename,
  #        width = 600, height = 300,
  #        alt = paste("hallucinogin", input$n))
  # }, deleteFile = FALSE)
  # 
  # output$notableinsighttwo <- renderText({
  #   "The second notable insight discovered in our project 
  #       was that cocaine usage and mental health services received for the age 
  #       group 18 and older both have a postive trend line from 2010-2019. 
  #       While we cannot assume directly that the two are correlated,
  #       it is interesting to see how more people are getting 
  #       mental health services and that more people are also using cocaine."
  # })
  # 
  # output$broaderandquality <- renderText({
  #   "The broader implications of the insight show that 
  #       most people start to experiment with hard drugs is around 
  #       the age of 20. This could be due to easier access in college and having 
  #       more financial independence. The quality of the data 
  #       was not perfect as there were gaps for certain years regarding the Drug
  #       Misuse and the Mental Health graph. There were also some years of 
  #       data not available for the Drug Use Rate Over Time by Age Group. 
  #       The data was also collected by offering a $30 incentive to participants. 
  #       This makes the results biased towards people of lower income versus 
  #       people of higher income that would not care too much about a 
  #       $30 incentive. An idea to advance this project in the 
  #       future would be to compare drug usage in states based on income."
  #   
  #   
  #   
  # })
  
  
})