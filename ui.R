#Yahoo ffb app UI
#initializing for displays
source('initialize.r')

library(shiny)

shinyUI(
  fluidPage(
    pageWithSidebar(
    
    # Application title
    headerPanel("FFB League Explorer"),
    
    sidebarPanel(
      textInput("league.id", label="League ID", value = "42592",placeholder="Type your league id here"),
      actionButton("getLeague", "Refresh",icon("refresh")),
      selectInput("variable", label="Team:",
                   choices = leagueStandingsDF$Team),
      
      checkboxInput("team1", leagueStandingsDF$Team[1], FALSE)
      
    ),
    
    mainPanel()
))
)

#list("Cylinders" = "cyl", 
#     "Transmission" = "am", 
#     "Gears" = "gear"))