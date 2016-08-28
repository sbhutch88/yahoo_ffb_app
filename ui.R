#Yahoo ffb app UI
#initializing for displays

source('initialize.r')
source('app_control.R')
library(shiny)
library(shinydashboard)

shinyUI(
  tabsetPanel(
    tabPanel("Dashboard",
             fluidPage(
               pageWithSidebar(
                 # Application title
                 headerPanel("FFB League Explorer"),
                 sidebarPanel(
                   textInput("league.id", label="League ID", value = "42592",placeholder="Type your league id here"),
                   actionButton("getLeague", "Get My League Data",icon("refresh"))
                   # tagList(column(12,
                   #                checkboxInput("team1", leagueStandingsDF$Team[1], TRUE),
                   #                checkboxInput("team2", leagueStandingsDF$Team[2], TRUE),
                   #                checkboxInput("team3", leagueStandingsDF$Team[3], TRUE),
                   #                checkboxInput("team4", leagueStandingsDF$Team[4], TRUE),
                   #                checkboxInput("team5", leagueStandingsDF$Team[5], TRUE),
                   #                checkboxInput("team6", leagueStandingsDF$Team[6], TRUE),
                   #                checkboxInput("team7", leagueStandingsDF$Team[7], TRUE),
                   #                checkboxInput("team8", leagueStandingsDF$Team[8], TRUE),
                   #                checkboxInput("team9", leagueStandingsDF$Team[9], TRUE),
                   #                checkboxInput("team10", leagueStandingsDF$Team[10], TRUE),
                   #                checkboxInput("team11", leagueStandingsDF$Team[11], TRUE),
                   #                checkboxInput("team12", leagueStandingsDF$Team[12], TRUE))
                 # )
                 ),
                 mainPanel(
                   bar_tl <- tagList(
                     column(6,plotOutput('Total_points')),
                     column(6,plotOutput('Trades')),
                     column(6,plotOutput('FAAB')),
                     column(6,plotOutput('Moves'))
                   )
                 )
               )
    )
  ),
    tabPanel("Rosters",
             headerPanel("FFB League Rosters"),
             Roster_tl <- tagList(
               sidebarPanel(
                      selectInput(inputId = "teamNames",
                                  label="Team:",
                                  choices = as.character(coaches[[1]])),
                      actionButton("getRoster", "refresh",icon("refresh"))
               ),
               mainPanel(
                 dataTableOutput('teamRoster')
               )
             ))
  )
)
