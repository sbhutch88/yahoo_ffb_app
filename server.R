#yahoo ffb app server script

library(shiny)
library(shinydashboard)
library(httr)
library(RJSONIO)
library(ggplot2)
library(httpuv)
library(DT)
#source('initialize.R')
#source('app_control.R')
#source('yahoo_API_call.R')
source('yahoo_fantasy_functions.r')

shinyServer(function(input, output) {
  #league.key <- reactiveValues(input$getLeague)
  #Collects league data when refresh button is pushed.
  #observeEvent(input$getLeague, {leagueStandings(league.key=paste0(game.key, ".l.", input$league.id),token)})
  #leagueStandingsDF <- eventReactive(input$getLeague, {leagueStandings(league.key,token)})
  withProgress(message = 'Retrieving Roster', value = 0.7, {
    teamRoster <- eventReactive(list(input$getRoster), {getTeamRoster(input$teamNames)})
  })
  #eventReactive(input$getLeague,input$league.id)
  output$FAAB <- renderPlot({
    if (input$getLeague == 0)
      return()
    input$getLeague
    isolate(
      build_horiz_bar(data = leagueStandingsDF,
                      x = leagueStandingsDF$Team,
                      y = as.numeric(as.character(leagueStandingsDF$FAAB)),
                      title = "FAAB Dollars",
                      fill_color = "blue",
                      x_max = 55
      )
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
  
  output$image <- renderUI({
    if (input$getRoster == 0)
      return()
    image_address <- tags$img(src = as.character(leagueStandingsDF$Image[which(leagueStandingsDF$Team == input$teamNames)]), width = "200px", height = "200px")
    return(image_address)
  })

  
  #Keeps league id from user updated
  updateLeagueID <- reactive({
    
    league.id = input$league.id
  })


  # #THIS SEEMS TO NOW BE WORKING, BESIDES THE FACT THAT IT WON'T DISPLAY
  # #*** THE CAT PRINTS IN THE BEGINNING BUT NOT ON A BUTTON CLICK.
  # output$leagueOwners <- renderText({
  #   cat('Gathering League Owners')
  #   leagueOwners <- getLeagueStandings()
  #   leagueOwnerList <- toString(leagueOwners$Teams)
  #   cat(leagueOwnerList)
  #   return(leagueOwnerList)
  # })
    
    
    #observeEvent(input$getLeague,vars=data, source('app_control.r'))
  
  output$teamRoster <- renderDataTable({
    if (input$getRoster == 0)
      return()
    print(input$teamNames)
    withProgress(message = 'Retrieving Roster', value = 0.7, {
      #Keeping roster global
    roster <<- isolate(getTeamRoster(leagueStandingsDF$teamID[which(leagueStandingsDF$Team == input$teamNames)]))   #getTeamRoster(which(leagueStandingsDF$Team == input$teamNames)))
    })
    return(roster)
  })
  
  output$QB <- DT::renderDataTable({
    if (input$getRoster == 0)
      return()
    withProgress(message = 'Retrieving Roster', value = 0, {
      roster <<- isolate(getTeamRoster(which(leagueStandingsDF$Team == input$teamNames)))
    })
    QB <- roster[roster$position == 'QB',]
    QB_pic <- data.frame(pic = matrix(0,ncol=1,nrow=nrow(QB)))
    names(QB_pic) <- NULL
    
    for(i in 1:nrow(QB)){
      QB_pic[i,1] <- paste0('\'<img src = \"',as.character(QB$headshot[i]),'\"></img>\'')
    }
    QB_df <- QB[,c('position','full_name','nfl_team','passing_yds','passing_tds',
                                              'interceptions','rushing_yds','rushing_tds')]
    names(QB_df) <- c('Position','Player','Team','Passing Yds','Passing TDs','Interceptions','Rushing Yds','Rushing TDs')
    
    QB_df <- cbind(pic = QB_pic,QB_df) #binding images with data
    row.names(QB_df) <- NULL
    DT::datatable(QB_df, 
                  options = list(dom = 't', columnDefs = list(list(className = 'dt-center', targets = 0:ncol(QB_df)))),
                  escape = FALSE)
  })
  
  output$WR <- DT::renderDataTable({
    if (input$getRoster == 0)
      return()
    WR <- roster[roster$position == 'WR',]
    WR_pic <- data.frame(pic = matrix(0,ncol=1,nrow=nrow(WR)))
    
    for(i in 1:nrow(WR)){
      WR_pic[i,1] <- paste0('\'<img src = \"',as.character(WR$headshot[i]),'\"></img>\'')
    }
    
    WR_df <- roster[roster$position == 'WR',c('position','full_name','nfl_team','rushing_yds','rushing_tds','receiving_yds','receiving_tds')]
    names(WR_df) <- c('Position','Player','Team','Rushing Yds', 'Rushing TDs','Receiving Yds','Receiving TDs')
    row.names(WR_df) <- NULL
    WR_df <- cbind(WR_pic,WR_df) #binding images with data
    DT::datatable(WR_df, options = list(dom = 't',
                                        columnDefs = list(list(className = 'dt-center', targets = 0:ncol(WR_df)))), 
                  escape = FALSE)
  })
  
  output$TE <- DT::renderDataTable({
    if (input$getRoster == 0)
      return()
    TE <- roster[roster$position == 'TE',]
    TE_pic <- data.frame(pic = matrix(0,ncol=1,nrow=nrow(TE)))
    
    for(i in 1:nrow(TE)){
      TE_pic[i,1] <- paste0('\'<img src = \"',as.character(TE$headshot[i]),'\"></img>\'')
    }
    TE_df <- roster[roster$position == 'TE',c('position','full_name','nfl_team','rushing_yds','rushing_tds','receiving_yds','receiving_tds')]
    names(TE_df) <- c('Position','Player','Team','Rushing Yds', 'Rushing TDs','Receiving Yds','Receiving TDs')
    row.names(TE_df) <- NULL
    TE_df <- cbind(TE_pic,TE_df) #binding images with data
    DT::datatable(TE_df, options = list(dom = 't', 
                                        columnDefs = list(list(className = 'dt-center', targets = 0:ncol(TE_df)))), 
                  escape = FALSE)
  })
  
  output$RB <- DT::renderDataTable({
    if (input$getRoster == 0)
      return()
    RB <- roster[roster$position == 'RB',]
    RB_pic <- data.frame(pic = matrix(0,ncol=1,nrow=nrow(RB)))
    
    for(i in 1:nrow(RB)){
      RB_pic[i,1] <- paste0('\'<img src = \"',as.character(RB$headshot[i]),'\"></img>\'')
    }
    RB_df <- roster[roster$position == 'RB',c('position','full_name','nfl_team','rushing_yds','rushing_tds','receiving_yds','receiving_tds')]
    names(RB_df) <- c('Position','Player','Team','Rushing Yds', 'Rushing TDs','Receiving Yds','Receiving TDs')
    row.names(RB_df) <- NULL
    RB_df <- cbind(RB_pic,RB_df) #binding images with data
    DT::datatable(RB_df, options = list(dom = 't',
                                        columnDefs = list(list(className = 'dt-center', targets = 0:ncol(RB_df)))), 
                  escape = FALSE)
  })
  
  ## Format and display the output news
  output$outputTweets <- renderUI({
    if (input$getTweets == 0)#|input$getRoster == 0)
      return()
    isolate(tweets <- tweetOrganize())
    return(HTML(as.character(tweets)))
  })
  
  observe({input$titans
    myLat <<- 36.166461
    myLon <<- -86.771289
    myRadius <<- 200
    location_ids <<- c(16430,235934248,40500379,402555461,272032789)}) #Collected after the search manually)
  observe({input$giants
    myLat <<- 40.812194
    myLon <<- -74.076983
    myRadius <<- 200
    location_ids <<- c(216284597, 269959922, 273567698)})
  observe({input$patriots
    myLat <<- 42.090925
    myLon <<- -71.26435
    myRadius <<- 200
    location_ids <<- c(215940412, 368070324, 1014210797, 447383197, 294383241, 243014699, 5007283)})
  
  output$instagramCall <- renderUI({
    
    # if(input$titans){
    #   myLat <- 36.166461
    #   myLon <- -86.771289
    #   myRadius <- 200
    #   location_ids <- c(16430,235934248,40500379,402555461,272032789) #Collected after the search manually
    # } else if(input$giants){
    #   myLat <- 40.812194
    #   myLon <- -74.076983
    #   myRadius <- 200
    #   location_ids <- c(216284597, 269959922, 273567698)
    # } else if(input$patriots){
    #   myLat <- 42.090925
    #   myLon <- -71.26435
    #   myRadius <- 200
    #   location_ids <- c(215940412, 368070324, 1014210797, 447383197, 294383241, 243014699, 5007283)
    # } else {
    #   return()
    # }
    
    if(input$titans == 0 & input$giants == 0 & input$patriots == 0)
      return()
    # myLat <- 36.166461
    # myLon <- -86.771289
    # myRadius <- 400
    withProgress(message = 'Gathering Photos!', value = 0.7, {
      
      #Initial photo search
      photos <- isolate(getInstagramfromJSON(myLat,myLon,myRadius)) #This gets all locations near lat and long, later I'll need to collect stadium ids instead.
      
      #Use to find id's only.
      #ids_df <- isolate(find_ids_DF(photos))
      
      #Now only using photos from the field's ids
      photos_df <- isolate(convertInstagramToFullDF(photos,location_ids)) 
      photos_df <- isolate(subset(photos_df,photos_df$type == 'image')) #maybe try videos later
      photos_df$likes <- isolate(as.numeric(photos_df$likes))#changes data type from character to integer.
      
      #Sorting according to most liked photos for now
      liked_photos <- isolate(photos_df[with(photos_df, order(-xtfrm(likes))),])#For some reason this doesn't work perfectly and I can't figure out why.

      #Create output tags
      tags$ol(
        tags$img(src = liked_photos$url[1], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[2], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[3], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[4], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[5], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[6], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[7], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[8], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[9], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[10], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[11], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[12], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[13], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[14], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[15], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[16], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[17], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[18], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[19], height = "250px", width = "250px"),
        tags$img(src = liked_photos$url[20], height = "250px", width = "250px")
      )
    })
    #Shutting off inputs
    # shinyjs::disable("titans")
    # shinyjs::disable("giants")
    # shinyjs::disable("patriots")
    # shinyjs::addClass("titans", "btn-disable")
    
    # shinyjs::removeClass(id, "btn-disable")
    # shinyjs::removeClass(id, "btn-enable")
    # shinyjs::addClass(id, "btn-new")
    
  })
})

# #####TWITTER OUTPUT
# ## Get the news feed, and only do so if the news button gets clicked
# getNews<-reactive({
#   ## Only do it if the button gets clicked
#   buttonclick <- input$getRoster
#   if(is.null(buttonclick))
#     return()
#   ## Add progress bar (not necessarily accurate!)
#   withProgress(message = 'Getting Roster!', value = 0.2, {
#     #detailed_locations.df <- isolate(getDetailedPlacesOnCurrentMap())
#     playerTweets<-getTeamRoster(detailed_locations.df)
#   })
#   getTweets(roster$full_name)
# })


