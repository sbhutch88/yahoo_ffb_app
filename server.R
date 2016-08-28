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


  #THIS SEEMS TO NOW BE WORKING, BESIDES THE FACT THAT IT WON'T DISPLAY
  #*** THE CAT PRINTS IN THE BEGINNING BUT NOT ON A BUTTON CLICK.
  output$leagueOwners <- renderText({
    cat('Gathering League Owners')
    leagueOwners <- getLeagueStandings()
    leagueOwnerList <- toString(leagueOwners$Teams)
    cat(leagueOwnerList)
    return(leagueOwnerList)
  })
    
    
    #observeEvent(input$getLeague,vars=data, source('app_control.r'))
  
  output$teamRoster <- renderDataTable({
    teamRoster
  })
    #observeEvent(input$getLeague,vars=data, source('app_control.r'))
})
