#yahoo ffb app server script

library(shiny)
library(httr)
library(RJSONIO)
library(ggplot2)
library(httpuv)
source('initialize.R')
source('yahoo_API_call.R')
source('yahoo_fantasy_functions.r')

shinyServer(function(input, output) {
  #league.key <- reactiveValues(input$getLeague)
  #Collects league data when refresh button is pushed.
  eventReactive(input$getLeague,input$league.id)
  leagueStandingsDF <- observeEvent(input$getLeague,
                                    leagueStandings(league.key=paste0(game.key, ".l.", input$league.id),token))
  

  
  
  output$leagueOwners <- renderDataTable({
    
    #observeEvent(input$getLeague,vars=data, source('app_control.r'))

  })
  
})