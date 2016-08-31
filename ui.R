#Yahoo ffb app UI
#initializing for displays

source('initialize.r')
source('app_control.R')
library(shiny)
library(shinydashboard)

shinyUI(
  tabsetPanel(
    tabPanel("Dashboard",
             fluidPage(theme = "bootstrap.css",
             headerPanel("FFB League Explorer"),
             sidebarPanel(
               textInput("league.id", label="League ID", value = "42592",placeholder="Type your league id here"),
               actionButton("getLeague", "Get My League Data",icon("refresh"))
             ),
             mainPanel(id = "image",
               column(6,plotOutput('Total_points')),
               column(6,plotOutput('Trades')),
               column(6,plotOutput('FAAB')),
               column(6,plotOutput('Moves'))
             )
    )),
    tabPanel("Rosters",
             theme = "bootstrap.css",
             includeCSS("www/styles.css"),
             headerPanel("FFB League Rosters"),
             sidebarPanel(
               tags$div(
                 tags$p(selectInput(inputId = "teamNames",
                                    label="Team:",
                                    choices = as.character(coaches[[1]]))),
                 actionButton("getRoster", "Get Roster",icon("refresh")),
                 tags$br(),
                 tags$br(),
                 uiOutput('Image')
               )),
             mainPanel(#id="table",
               tableOutput('QB'),
               tableOutput('RB'),
               tableOutput('WR'),
               tableOutput('TE')
             )
    )
  )
)
