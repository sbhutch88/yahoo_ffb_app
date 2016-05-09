#Yahoo ffb app UI
#initializing for displays
#source('initialize.r')

library(shiny)
library(shinydashboard)

dashboardBody(
  fluidPage(
    pageWithSidebar(
    
    # Application title
    headerPanel("FFB League Explorer"),
    
    sidebarPanel(
      textInput("league.id", label="League ID", value = "42592",placeholder="Type your league id here"),
      actionButton("getLeague", "Refresh",icon("refresh")),
      selectInput("variable", label="Team:",
                   choices = textOutput("leagueOwners"))
      
      #checkboxInput("team1", leagueStandingsDF$Team[1], FALSE)
      
    ),
    
    mainPanel(textOutput("leagueOwners"))
))
)

#list("Cylinders" = "cyl", 
#     "Transmission" = "am", 
#     "Gears" = "gear"))