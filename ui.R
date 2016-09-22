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
             headerPanel("NFL Field Pass"),
             sidebarPanel(
               tags$br(),
               actionButton("patriots", "New England Patriots",icon("instagram")),
               tags$br(),
               actionButton("jets", "New York Jets",icon("instagram")),
               tags$br(),
               actionButton("dolphins", "Miami Dolphins",icon("instagram")),
               tags$br(),
               actionButton("bills", "Buffalo Bills",icon("instagram")),
               tags$br(),
               tags$br(),
               actionButton("steelers", "Pittsburgh Steelers",icon("instagram")),
               tags$br(),
               actionButton("browns", "Cleveland Browns",icon("instagram")),
               tags$br(),
               actionButton("bengals", "Cincinnati Bengals",icon("instagram")),
               tags$br(),
               actionButton("ravens", "Baltimore Ravens",icon("instagram")),
               tags$br(),
               tags$br(),
               actionButton("texans", "Houston Texans",icon("instagram")),
               tags$br(),
               actionButton("titans", "Tennessee Titans",icon("instagram")),
               tags$br(),
               actionButton("jaguars", "Jacksonville Jaguars",icon("instagram")),
               tags$br(),
               actionButton("colts", "Indianapolis Colts",icon("instagram")),
               tags$br(),
               tags$br(),
               actionButton("broncos", "Denver Broncos",icon("instagram")),
               tags$br(),
               actionButton("chiefs", "Kansas City Chiefs",icon("instagram")),
               tags$br(),
               actionButton("chargers", "San Diego Chargers",icon("instagram")),
               tags$br(),
               actionButton("raiders", "Oakland Raiders",icon("instagram")),
               tags$br(),
               tags$br(),
               actionButton("giants", "New York Giants",icon("instagram")),
               tags$br(),
               actionButton("eagles", "Philadelphia Eagles",icon("instagram")),
               tags$br(),
               actionButton("cowboys", "Dallas Cowboys",icon("instagram")),
               tags$br(),
               actionButton("redskins", "Washington Redskins",icon("instagram")),
               tags$br(),
               tags$br(),
               actionButton("vikings", "Minnesota Vikings",icon("instagram")),
               tags$br(),
               actionButton("packers", "Green Bay Packers",icon("instagram")),
               tags$br(),
               actionButton("lions", "Detroit Lions",icon("instagram")),
               tags$br(),
               actionButton("bears", "Chicago Bears",icon("instagram")),
               tags$br(),
               tags$br(),
               actionButton("buccaneers", "Tampa Bay Buccaneers",icon("instagram")),
               tags$br(),
               actionButton("panthers", "Carolina Panthers",icon("instagram")),
               tags$br(),
               actionButton("falcons", "Atlanta Falcons",icon("instagram")),
               tags$br(),
               actionButton("saints", "New Orleans Saints",icon("instagram")),
               tags$br(),
               tags$br(),
               actionButton("fortyniners", "San Francisco 49ers",icon("instagram")),
               tags$br(),
               actionButton("rams", "Los Angeles Rams",icon("instagram")),
               tags$br(),
               actionButton("cardinals", "Arizona Cardinals",icon("instagram")),
               tags$br(),
               actionButton("seahawks", "Seattle Seahawks",icon("instagram"))
               
             ),
             mainPanel(wellPanel(id = "tPanel2",style = "overflow-y:scroll; max-height: 800px", 
                                 htmlOutput('instagramCall')
             )
                       
             )
    )
  )
)
