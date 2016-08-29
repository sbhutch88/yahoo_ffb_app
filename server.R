#yahoo ffb app server script

library(shiny)
library(shinydashboard)
library(httr)
library(RJSONIO)
library(ggplot2)
library(httpuv)
#source('initialize.R')
#source('app_control.R')
#source('yahoo_API_call.R')
source('yahoo_fantasy_functions.r')

shinyServer(function(input, output) {
  #league.key <- reactiveValues(input$getLeague)
  #Collects league data when refresh button is pushed.
  #observeEvent(input$getLeague, {leagueStandings(league.key=paste0(game.key, ".l.", input$league.id),token)})
  #leagueStandingsDF <- eventReactive(input$getLeague, {leagueStandings(league.key,token)})
  withProgress(message = 'Retrieving Roster', value = 0, {
    teamRoster <- eventReactive(list(input$getRoster), {getTeamRoster(input$teamNames)})
  })
  #eventReactive(input$getLeague,input$league.id)
  output$FAAB <- renderPlot({
    if (input$getLeague == 0)
      return()
    build_horiz_bar(data = leagueStandingsDF,
                    x = leagueStandingsDF$Team,
                    y = as.numeric(as.character(leagueStandingsDF$FAAB)),
                    title = "FAAB Dollars",
                    fill_color = "blue",
                    x_max = 55
                    )
  })
  
  output$Trades <- renderPlot({
    if (input$getLeague == 0)
      return()
    build_horiz_bar(data = leagueStandingsDF,
                    x = leagueStandingsDF$Team,
                    y = as.numeric(as.character(leagueStandingsDF$Trades)),
                    title = "Trades",
                    fill_color = "yellow",
                    x_max = (max(as.numeric(as.character(leagueStandingsDF$Trades))) + 3)
    )
  })
  
  output$Moves <- renderPlot({
    if (input$getLeague == 0)
      return()
    build_horiz_bar(data = leagueStandingsDF,
                    x = leagueStandingsDF$Team,
                    y = as.numeric(as.character(leagueStandingsDF$Moves)),
                    title = "Moves",
                    fill_color = "green",
                    x_max = (max(as.numeric(as.character(leagueStandingsDF$Moves))) + 3)
    )
  })
  
  output$Total_points <- renderPlot({
    if (input$getLeague == 0)
      return()
    isolate(
      build_horiz_bar(data = leagueStandingsDF,
                      x = leagueStandingsDF$Team,
                      y = as.numeric(as.character(leagueStandingsDF$Points)),
                      title = "Total Points",
                      fill_color = "red",
                      x_max = (max(as.numeric(as.character(leagueStandingsDF$Points))) + 50)
      )
    )
  })
  
  #Keeps league id from user updated
  updateLeagueID <- reactive({
    
    league.id = input$league.id

    return(league.id)
  })


  # #THIS SEEMS TO NOW BE WORKING, BESIDES THE FACT THAT IT WON'T DISPLAY
  # #*** THE CAT PRINTS IN THE BEGINNING BUT NOT ON A BUTTON CLICK.
  # output$leagueOwners <- renderText({
  #   cat('Gathering League Owners')
  #   leagueOwners <- getLeagueStandings()
  #   leagueOwnerList <- toString(leagueOwners$Teams)
  #   cat(leagueOwnerList)
  #   return(leagueOwnerList)
  # })
    
    
    #observeEvent(input$getLeague,vars=data, source('app_control.r'))
  
  output$teamRoster <- renderDataTable({
    if (input$getRoster == 0)
      return()
    withProgress(message = 'Retrieving Roster', value = 0, {
    roster <- isolate(getTeamRoster(which(leagueStandingsDF$Team == input$teamNames)))
    })
    return(roster)
  })
  
  output$QB <- renderTable({
    if (input$getRoster == 0)
      return()
    withProgress(message = 'Retrieving Roster', value = 0, {
      roster <<- isolate(getTeamRoster(which(leagueStandingsDF$Team == input$teamNames)))
    })
    QB <- roster[roster$position == 'QB',]
    QB_df <- roster[roster$position == 'QB',c('position','full_name','nfl_team','passing_yds','passing_tds',
                                              'interceptions','rushing_yds','rushing_tds')]
    names(QB_df) <- c('Position','Player','Team','Passing Yds','Passing TDs','Interceptions','Rushing Yds','Rushing TDs')
    row.names(QB_df) <- NULL
    QB_df
  })
  
  output$WR <- renderTable({
    if (input$getRoster == 0)
      return()
    # withProgress(message = 'Retrieving Roster', value = 0, {
    #   roster <- isolate(getTeamRoster(which(leagueStandingsDF$Team == input$teamNames)))
    # })
    WR <- roster[roster$position == 'WR',]
    WR_df <- roster[roster$position == 'WR',c('position','full_name','nfl_team','rushing_yds','rushing_tds','receiving_yds','receiving_tds')]
    names(WR_df) <- c('Position','Player','Team','Rusing Yds', 'Rushing TDs','Receiving Yds','Receiving TDs')
    row.names(WR_df) <- NULL
    WR_df
  })
  
  output$TE <- renderTable({
    if (input$getRoster == 0)
      return()
    # withProgress(message = 'Retrieving Roster', value = 0, {
    #   roster <- isolate(getTeamRoster(which(leagueStandingsDF$Team == input$teamNames)))
    # })
    TE <- roster[roster$position == 'TE',]
    TE_df <- roster[roster$position == 'WR',c('position','full_name','nfl_team','rushing_yds','rushing_tds','receiving_yds','receiving_tds')]
    names(TE_df) <- c('Position','Player','Team','Rusing Yds', 'Rushing TDs','Receiving Yds','Receiving TDs')
    row.names(TE_df) <- NULL
    TE_df
  })
  
  output$RB <- renderTable({
    if (input$getRoster == 0)
      return()
    # withProgress(message = 'Retrieving Roster', value = 0, {
    #   roster <- isolate(getTeamRoster(which(leagueStandingsDF$Team == input$teamNames)))
    # })
    RB <- roster[roster$position == 'RB',]
    RB_df <- roster[roster$position == 'WR',c('position','full_name','nfl_team','rushing_yds','rushing_tds','receiving_yds','receiving_tds')]
    names(RB_df) <- c('Position','Player','Team','Rusing Yds', 'Rushing TDs','Receiving Yds','Receiving TDs')
    row.names(RB_df) <- NULL
    RB_df
  })
})
