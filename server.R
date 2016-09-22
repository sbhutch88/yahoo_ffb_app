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
  
  observe({input$patriots
    myLat <<- 42.090925
    myLon <<- -71.26435
    myRadius <<- 200
    location_ids <<- c(215940412, 368070324, 1014210797, 447383197, 294383241, 243014699, 5007283)
    })
  observe({input$jets
    myLat <<- 40.812194
    myLon <<- -74.076983
    myRadius <<- 200
    location_ids <<- c(216284597, 269959922, 273567698)
    })
  observe({input$dolphins
    myLat <<- 25.957919
    myLon <<- -80.238842
    myRadius <<- 200
    location_ids <<- c(282494102131662, 392767600, 799617632, 247807415)
    })
  observe({input$bills
    myLat <<- 42.773739
    myLon <<- -78.786978
    myRadius <<- 200
    location_ids <<- c(229343917, 262851942, 27778994, 421961554, 27774624, 1583485261947765, 402163518, 31658273)
    })
  observe({input$steelers
    myLat <<- 40.446786
    myLon <<- -80.015761
    myRadius <<- 200
    location_ids <<- c(218780045, 943548632)
  })
  observe({input$browns
    myLat <<- 41.506022
    myLon <<- -81.699564
    myRadius <<- 200
    location_ids <<- c(30645, 41191836, 240918194, 378957134, 447717790, 314143714)
  })
  observe({input$bengals
    myLat <<- 39.095442
    myLon <<- -84.516039
    myRadius <<- 200
    location_ids <<- c(601692, 914926701)
  })
  observe({input$ravens
    myLat <<- 39.277969
    myLon <<- -76.622767
    myRadius <<- 200
    location_ids <<- c(238876558, 256583974, 199417760112722, 288149238, 258935295, 1010130626)
  })
  observe({input$texans
    myLat <<- 29.684781
    myLon <<- -95.410956
    myRadius <<- 200
    location_ids <<- c(213349072, 417151033, 384131365, 533807102, 1719369938313762, 669319341, 234622312, 384064798)
  })
  observe({input$titans
    myLat <<- 36.166461
    myLon <<- -86.771289
    myRadius <<- 200
    location_ids <<- c(16430,235934248,40500379,402555461,272032789)#Collected after the search manually)
  }) 
  observe({input$jaguars
    myLat <<- 30.323925
    myLon <<- -81.637356
    myRadius <<- 200
    location_ids <<- c(269087183, 300577964, 300576366, 1009475125, 4135396, 275184167, 226080054, 4453614, 7471759)
  })
  observe({input$colts
    myLat <<- 39.760056
    myLon <<- -86.163806
    myRadius <<- 200
    location_ids <<- c(822212, 1005686253, 417070150, 801724990)
  })
  observe({input$broncos
    myLat <<- 39.743936
    myLon <<- -105.020097
    myRadius <<- 200
    location_ids <<- c(114889283, 243134686, 260960804, 958485122, 6259677, 347570940, 282722888, 250211244)
  })
  observe({input$chiefs
    myLat <<- 39.048914
    myLon <<- -94.484039
    myRadius <<- 200
    location_ids <<- c(735129, 241264997, 25470577, 964972388, 500785668, 791289770)
  })
  observe({input$chargers
    myLat <<- 32.783117
    myLon <<- -117.119525
    myRadius <<- 200
    location_ids <<- c(3003498, 314837581, 916167913, 213547566, 314791335, 364456101, 320314678)
  })
  observe({input$raiders
    myLat <<- 37.751411
    myLon <<- -122.200889
    myRadius <<- 200
    location_ids <<- c(433058742, 244203568, 258303322)
  })
  observe({input$giants
    myLat <<- 40.812194
    myLon <<- -74.076983
    myRadius <<- 200
    location_ids <<- c(216284597, 269959922, 273567698)
  })
  # observe({input$eagles
  #   myLat <<- 39.900775
  #   myLon <<- -75.167453
  #   myRadius <<- 200
  #   location_ids <<- c()
  # })
  observe({input$cowboys
    myLat <<- 32.747778
    myLon <<- -97.092778
    myRadius <<- 200
    location_ids <<- c(1421554, 270509763, 245841013, 215438564, 1027930697, 11408253, 521554028, 43427550, 3044770, 424132860, 3673505)
  })
  observe({input$redskins
    myLat <<- 38.907697
    myLon <<- -76.864517
    myRadius <<- 200
    location_ids <<- c(56329, 276962598, 87846224, 325712)
  })
  observe({input$vikings
    myLat <<- 44.973881
    myLon <<- -93.258094
    myRadius <<- 200
    location_ids <<- c(872194760, 255106339, 262764351, 1026437757473413, 617854421718875, 146366962460461, 652478015)
  })
  observe({input$packers
    myLat <<- 44.501306
    myLon <<- -88.062167
    myRadius <<- 200
    location_ids <<- c(102089, 216634618, 534117443, 143795958, 344785997, 311381408, 7237397, 953259886, 1014580917, 304122652)
  })
  observe({input$lions
    myLat <<- 42.340156
    myLon <<- -83.045808
    myRadius <<- 200
    location_ids <<- c(219182853, 346139417, 424093156, 664894980, 992898462)
  })
  observe({input$bears
    myLat <<- 41.862306
    myLon <<- -87.616672
    myRadius <<- 200
    location_ids <<- c(1077214, 1731652773784098, 349110639, 313153000, 348947744, 235021370, 849984421, 265367041, 224338723, 362054846)
  })
  observe({input$buccaneers
    myLat <<- 27.975967
    myLon <<- -82.50335
    myRadius <<- 200
    location_ids <<- c(366825, 395337093, 241565193, 524571751, 760308458, 402454939)
  })
  observe({input$panthers
    myLat <<- 35.225808
    myLon <<- -80.852861
    myRadius <<- 200
    location_ids <<- c(218155685, 361593653, 352322608, 1027386420, 346781978, 1014044421)
  })
  observe({input$falcons
    myLat <<- 33.757614
    myLon <<- -84.400972
    myRadius <<- 200
    location_ids <<- c(2032, 361815807, 432025881, 6641769, 271285487)
  })
  observe({input$saints
    myLat <<- 29.950931
    myLon <<- -90.081364
    myRadius <<- 200
    location_ids <<- c(1264107, 1019357229, 282171462, 1009478014, 9231668, 215475250)
  })
  observe({input$fortyniners
    myLat <<- 37.713486
    myLon <<- -122.386256
    myRadius <<- 200
    location_ids <<- c()
  })
  observe({input$rams
    myLat <<- 38.632975
    myLon <<- -90.188547
    myRadius <<- 200
    location_ids <<- c(224452139, 1023697744, 424606401)
  })
  observe({input$cardinals
    myLat <<- 33.5277
    myLon <<- -112.262608
    myRadius <<- 200
    location_ids <<- c(580427, 245406708, 216191386, 485634038277192, 255311536, 589947052, 242587450)
  })
  observe({input$seahawks
    myLat <<- 47.595153
    myLon <<- -122.331625
    myRadius <<- 200
    location_ids <<- c(923043, 307733106, 377583488, 468326608, 1015871238)
  })
  
  output$instagramCall <- renderUI({

    if(input$giants==0 & input$patriots==0 & input$jets==0 & input$bills==0 & input$dolphins==0 & input$steelers==0 & input$browns==0 & input$bengals==0
       & input$ravens==0 & input$texans==0 & input$titans==0 & input$jaguars==0 & input$colts==0 & input$broncos==0 & input$chiefs==0 & input$chargers==0
       & input$raiders==0 & input$eagles==0 & input$cowboys==0 & input$redskins==0 & input$vikings==0 & input$lions==0 & input$packers==0 & input$bears==0
       & input$buccaneers==0 & input$panthers==0 & input$falcons==0 & input$saints==0 & input$fortyniners==0 & input$rams==0 & input$cardinals==0 & input$seahawks==0)
      return()
    # myLat <- 36.166461
    # myLon <- -86.771289
    # myRadius <- 400
    withProgress(message = 'Gathering Photos!', value = 0.7, {
      
      #Initial photo search
      photos <- isolate(getInstagramfromJSON(myLat,myLon,myRadius)) #This gets all locations near lat and long, later I'll need to collect stadium ids instead.

      #Use to find id's only.
      # ids_df <- isolate(find_ids_DF(photos))
      # browser()

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


