#yahoo ffb app server script

library(shiny)

shinyServer(function(input, output) {
  observe(source('initialize.R'))
  #league.key <- reactiveValues(input$getLeague)
  #Collects league data when refresh button is pushed.
  observeEvent(input$getLeague,source('app_control.r'))
  
})