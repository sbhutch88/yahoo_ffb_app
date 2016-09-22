#Yahoo ffb app UI
#initializing for displays

source('initialize.r')
source('app_control.R')
library(shiny)
library(shinydashboard)
library(DT)

shinyUI(
  tabsetPanel(
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
                 uiOutput('image'),
                 tags$br(),
                 wellPanel(id = "tPanel2",style = "overflow-y:scroll; max-height: 600px",
                           #tabBox(width = NULL, style = "overflow-y:scroll; max-height: 800px", 
                           id = "tabbedBox", height = "250px",
                           div(
                             tags$br(),
                             actionButton("getTweets","Get Tweets", icon("twitter")),
                             htmlOutput('outputTweets')
                           )
                 ))
             ),
             mainPanel(#id="table",
               wellPanel(id = "tPanel1",style = "overflow-y:scroll; max-height: 1000px",
                         DT::dataTableOutput('QB'),
                         DT::dataTableOutput('RB'),
                         DT::dataTableOutput('WR'),
                         DT::dataTableOutput('TE')
               )
             )
    ),
    tabPanel("Dashboard",
             fluidPage(theme = "bootstrap.css",
                       headerPanel("FFB League Explorer"),
                       sidebarPanel(
                         textInput("league.id", label="League ID", value = "42592",placeholder="Type your league id here"),
                         actionButton("getLeague", "Get My League Data",icon("refresh"))
                       ),
                       mainPanel(
                         column(6,plotOutput('Total_points')),
                         column(6,plotOutput('Trades')),
                         column(6,plotOutput('FAAB')),
                         column(6,plotOutput('Moves'))
                       )
             )),
    tabPanel("Field Pass",
             sidebarPanel(
               tags$br(),
               actionButton("titans", "Tennessee Titans",icon("instagram")),
               tags$br(),
               tags$br(),
               actionButton("giants", "New York Giants",icon("instagram")),
               tags$br(),
               tags$br(),
               actionButton("patriots", "New England Patriots",icon("instagram"))
             ),
             mainPanel(htmlOutput('instagramCall')
                       
             )
    )
  )
)
