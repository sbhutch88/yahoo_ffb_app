#yahoo ffb app server script

library(shiny)
library(shinydashboard)
library(httr)
library(RJSONIO)
library(ggplot2)
library(httpuv)
#source('initialize.R')
source('yahoo_API_call.R')
source('yahoo_fantasy_functions.r')

shinyServer(function(input, output) {
  #league.key <- reactiveValues(input$getLeague)
  #Collects league data when refresh button is pushed.
  
  #Keeps league id from user updated
  updateLeagueID <- reactive({
    league.id = input$league.id
    return(league.id)
  })
  
#  observe({
#    league.id <- updateLeagueID()
#    leagueStandingsDF <- observeEvent(input$getLeague,
#                                      leagueStandings(league.key=paste0(game.key, ".l.", league.id),token))
#  })

  getLeagueStandings <- reactive({
    league.id <- updateLeagueID()
    leagueStandingsDF <- observeEvent(input$getLeague,
                                      leagueStandings(league.key=paste0(game.key, ".l.", league.id),token))
    return(leagueStandingsDF)
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
  
})