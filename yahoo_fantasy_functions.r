#Sourcing all players within a league


league.url <- "http://fantasysports.yahooapis.com/fantasy/v2/league/"
team.url <- "http://fantasysports.yahooapis.com/fantasy/v2/team/"
player.url <- "http://fantasysports.yahooapis.com/fantasy/v2/player/"

#Very quickly gets info on all players in the league, without stats.
#*** It looks like I can add to the end of this call to get more information. There is some way to choose certain options too
getLeaguePlayers <- function(league.key){
  all.league.players.json <- GET(paste0(league.url, league.key, "/players/ownership/stats?format=json"), config(token = token))
  all.league.players.list <- fromJSON(as.character(all.league.players.json), asText=T)
  return(all.league.players.list)
}  


leagueStandings <- function(league.key,token){
  leagueStandings.json <- GET(paste0(league.url,league.key,"/standings?format=json"), config(token=token))
  leagueStandings.list <- fromJSON(as.character(leagueStandings.json), asText = T)
  print(length(leagueStandings.list))
  #Build DF of useful info
  for(i in 0:11){ #This is going to need to change according to league size
    leagueStandingsDF_temp <- data.frame(
      Team = eval(parse(text=paste0("leagueStandings.list$fantasy_content$league[[2]]$standings[[1]]$teams$", "`", i, "`", "$team[[1]][[3]]"))),
      Rank = eval(parse(text=paste0("leagueStandings.list$fantasy_content$league[[2]]$standings[[1]]$teams$", "`", i, "`", "$team[[3]]$team_standings$rank[1]"))),
      Wins = eval(parse(text=paste0("leagueStandings.list$fantasy_content$league[[2]]$standings[[1]]$teams$", "`", i, "`", "$team[[3]]$team_standings$outcome_totals$wins[1]"))),
      Losses = eval(parse(text=paste0("leagueStandings.list$fantasy_content$league[[2]]$standings[[1]]$teams$", "`", i, "`", "$team[[3]]$team_standings$outcome_totals$losses[1]"))),
      Ties = eval(parse(text=paste0("leagueStandings.list$fantasy_content$league[[2]]$standings[[1]]$teams$", "`", i, "`", "$team[[3]]$team_standings$outcome_totals$ties[1]"))),
      Points = eval(parse(text=paste0("leagueStandings.list$fantasy_content$league[[2]]$standings[[1]]$teams$", "`", i, "`", "$team[[3]]$team_standings$points_for[1]"))),
      Pts_Against = eval(parse(text=paste0("leagueStandings.list$fantasy_content$league[[2]]$standings[[1]]$teams$", "`", i, "`", "$team[[3]]$team_standings$points_against[1]"))),
      Division = eval(parse(text=paste0("leagueStandings.list$fantasy_content$league[[2]]$standings[[1]]$teams$", "`", i, "`", "$team[[1]][[7]][1]"))),
      FAAB = eval(parse(text=paste0("leagueStandings.list$fantasy_content$league[[2]]$standings[[1]]$teams$", "`", i, "`", "$team[[1]][[9]][1]"))),
      Moves = eval(parse(text=paste0("leagueStandings.list$fantasy_content$league[[2]]$standings[[1]]$teams$", "`", i, "`", "$team[[1]][[10]][1]"))),
      Trades = eval(parse(text=paste0("leagueStandings.list$fantasy_content$league[[2]]$standings[[1]]$teams$", "`", i, "`", "$team[[1]][[11]][1]"))),
      Image = eval(parse(text=paste0("leagueStandings.list$fantasy_content$league[[2]]$standings[[1]]$teams$", "`", i, "`", "$team[[1]][[20]]$managers[[1]]$manager['image_url']")))
    )
    if(i==0){
      leagueStandingsDF <- leagueStandingsDF_temp
    }else{
      leagueStandingsDF <- rbind(leagueStandingsDF,leagueStandingsDF_temp)
    }
  }
  return(leagueStandingsDF)
  
}

#This function will pull information from your team, and specifically where they are on your roster (bench vs starting etc.)
teamRoster <- function(teamNum){
  teamRoster.json <- GET(paste0(team.url, league.key, ".t.", teamNum, "/roster/players?format=json"), config(token = token))
  teamRoster.list <- fromJSON(as.character(teamRoster.json), asText=T)
  return(teamRoster.list)
}


#Will call player info from a single fantasy team in a league.
singleTeamCall <- function(teamNum){
  team.league.players.json <- GET(paste0(team.url, league.key, ".t.", teamNum, "/players?format=json"), config(token = token))
  team.league.players.list <- fromJSON(as.character(team.league.players.json), asText=T)
  return(team.league.players.list)
}

#Creates list of player id's for each player from a list.
createTeamIDs <- function(teamList){
  for(i in 0:(teamList$fantasy_content$team[[2]]$players$count-1)){
    #This is a quick fix to adjust the calls if a player has the injury status column in their list. Should be improved later.
    shift <- 0
    if(eval(parse(text=paste0("names(teamList$fantasy_content$team[[2]]$players$", "`", i, "`", "$player[[1]][[4]])"))) == "status" | 
       eval(parse(text=paste0("names(teamList$fantasy_content$team[[2]]$players$", "`", i, "`", "$player[[1]][[4]])"))) == "injury_note"){
      shift <- shift+1
    } 
    #It can have both as well.
    if(eval(parse(text=paste0("names(teamList$fantasy_content$team[[2]]$players$", "`", i, "`", "$player[[1]][[5]])"))) == "status" | 
       eval(parse(text=paste0("names(teamList$fantasy_content$team[[2]]$players$", "`", i, "`", "$player[[1]][[5]])"))) == "injury_note"){
      shift <- shift+1
    }
    
    temp <- data.frame(name=eval(parse(text=paste0("teamList$fantasy_content$team[[2]]$players$", "`", i, "`", "$player[[1]][[3]]$name[1]"))),
                       position=eval(parse(text=paste0("teamList$fantasy_content$team[[2]]$players$", "`", i, "`", "$player[[1]][[10+shift]]"))),
                       player_key=eval(parse(text=paste0("teamList$fantasy_content$team[[2]]$players$", "`", i, "`", "$player[[1]][[1]]"))),
                       row.names = NULL)
    if(i == 0){  
      team.league.players.df <- temp 
    }else{
      team.league.players.df <- rbind(team.league.players.df,temp)
    }
  }
  return(team.league.players.df)
}

#Given a player ID, will return stats and info from that player
nflPlayerStatSearch <- function(playerCall.key){
  nfl.player.stats.json <- GET(paste0(player.url, playerCall.key, "/stats?format=json"), config(token = token))
  nfl.player.stats.list <- fromJSON(as.character(nfl.player.stats.json), asText=T)
  nfl.player.draftAnalysis.json <- GET(paste0(player.url, playerCall.key, "/draftanalysis?format=json"), config(token = token))
  nfl.player.draftAnalysis.list <- fromJSON(as.character(nfl.player.draftAnalysis.json), asText=T)
  return(nfl.player.stats.list) 
}

#Will build a data frame of the useful information given a list of players.
nflPlayerStatBuildDF <- function(nfl.player.stats.list){
  
  #This is a quick fix to adjust the calls if a player has the injury status column in their list. Should be improved later.
  shift <- 0
  if(names(nfl.player.stats.list$fantasy_content$player[[1]][[4]]) == "status" | 
    names(nfl.player.stats.list$fantasy_content$player[[1]][[4]]) == "injury_note"){
    shift <- shift+1
  } 
  #It can have both as well.
  if(names(nfl.player.stats.list$fantasy_content$player[[1]][[5]]) == "status" | 
     names(nfl.player.stats.list$fantasy_content$player[[1]][[5]]) == "injury_note"){
    shift <- shift+1
  }
  
  player.df <- data.frame(player_id = nfl.player.stats.list$fantasy_content$player[[1]][[2]],
                                full_name = nfl.player.stats.list$fantasy_content$player[[1]][[3]]$name[[1]],
                                first_name = nfl.player.stats.list$fantasy_content$player[[1]][[3]]$name[[2]],
                                last_name = nfl.player.stats.list$fantasy_content$player[[1]][[3]]$name[[3]],
                                nfl_team = nfl.player.stats.list$fantasy_content$player[[1]][[6+shift]],
                                nfl_team_abr = nfl.player.stats.list$fantasy_content$player[[1]][[7+shift]],
                                bye_week = nfl.player.stats.list$fantasy_content$player[[1]][[8+shift]],
                                position = nfl.player.stats.list$fantasy_content$player[[1]][[10+shift]],
                                headshot = nfl.player.stats.list$fantasy_content$player[[1]][[11+shift]]$headshot[1],
                                #image_url = nfl.player.stats.list$fantasy_content$player[[1]][[12+shift]]$image_url,
                                season = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$`0`[2],
                                games_played = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[1]]$stat[[2]],
                                pass_attempts = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[2]]$stat[[2]],
                                complete_passes = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[3]]$stat[[2]],
                                incomplete_passes = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[4]]$stat[[2]],
                                passing_yds = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[5]]$stat[[2]],
                                passing_tds = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[6]]$stat[[2]],
                                interceptions = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[7]]$stat[[2]],
                                num_sacks = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[8]]$stat[[2]],
                                rushing_attempts = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[9]]$stat[[2]],
                                rushing_yds = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[10]]$stat[[2]],
                                rushing_tds = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[11]]$stat[[2]],
                                receptions = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[12]]$stat[[2]],
                                receiving_yds = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[13]]$stat[[2]],
                                receiving_tds = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[14]]$stat[[2]],
                                return_yds = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[15]]$stat[[2]],
                                return_tds = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[16]]$stat[[2]],
                                two_pt_conv = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[17]]$stat[[2]],
                                fumbles = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[18]]$stat[[2]],
                                #fumbles_lost = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[19]]$stat[[2]],
                                #targets = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[28]]$stat[[2]],
                                #passing_FDs = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[29]]$stat[[2]],
                                #receving_FDs = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[30]]$stat[[2]],
                                #rushing_FDs = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$stats[[31]]$stat[[2]],
                          row.names = NULL)
  return(player.df)
}


teamPlayerInfo <- function(player_id){
  playerFantasy.json <- GET(paste0(league.url, league.key, "/players;player_keys=",player_id,"/stats"), config(token = token))
  playerFantasy.list <- fromJSON(as.character(playerFantasy.json), asText=T)
  return(playerFantasy.list)
}

getTransactions <- function(league.key){
  leagueTransactions.json <- GET(paste0(league.url,league.key,"/transactions?format=json"),config(token = token))
  leagueTransactions.list <- fromJSON(as.character(leagueTransactions.json), asText=T)
  return(leagueTransactions.list)
}

getTeamRoster <- function(teamNum){ 
  teamList <- singleTeamCall(teamNum) 
  playerIDs_df <- createTeamIDs(teamList)
  
  #For now I'm going to exclude kicker and defense
  cond1 <- playerIDs_df$position == "K"
  playerIDs_df <- playerIDs_df[!cond1,]
  cond2 <- playerIDs_df$position == "DEF"
  playerIDs_df <- playerIDs_df[!cond2,]
  
  #Call and create DF of full team.
  for(i in 1:nrow(playerIDs_df)){
    playerStats_list <- nflPlayerStatSearch(playerIDs_df[i,3]) #Change the input later to be variable.
    if(i == 1){
      playerStats_df <- nflPlayerStatBuildDF(playerStats_list)
    } else{
      temp <- nflPlayerStatBuildDF(playerStats_list)
      playerStats_df <- rbind(playerStats_df,temp)
    }
  }
  # ISSUE: some players don't have a status(aka "probable" etc.), and maybe others, so the list calls change slightly.
  # SOLUTION: I decided to go with a quick fix and just shift the list call contingent upon the existance of particular columns.
  return(playerStats_df)
}

build_horiz_bar <- function(data,x,y,title,fill_color,x_max){
  ggplot(data=data, aes(x=x, y=y)) + 
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          panel.background = element_blank()) +
    theme(axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank()) +
    theme(axis.text=element_text(size=16), 
          plot.title = element_text(size = 20, face = "bold")) + 
    geom_bar(colour="black", fill=fill_color, width=.9,stat="identity") + 
    ggtitle(title) +
    ylim(c(0,x_max)) +
    geom_text(aes(label=as.numeric(as.character(y))), vjust=0, hjust=-.8, size = 6) +
    coord_flip()
}

build_DT <- function(df){
  DT::datatable(df, options = list(dom = 't'), escape = FALSE)
}

################Twitter connections

connectToTwitter<-function(){
  # Keys linked to Richard's account:
  api_key <- "AtQtjjw2E91n2APFYOIlqd9Ur" 
  api_secret <- "hA6Xnjd6jRddfgvVMzlfWGqd1M1X68EAwEO4yqYIzUTb51jlCr" 
  token <- "558889232-ljdFmtDDZPeeJPZG3bYQhYZO75eXa5t1hVDjrdAd" 
  token_secret <- "5gVYRr0fKbpsT6hRqLVhDAxHTu4COxTVCOLsaDjx8aiFV"
  
  #Create Twitter Connection
  setup_twitter_oauth(api_key, api_secret, token, token_secret)  
}

# Get twitter handles for a list of URLs
getTwitterHandles<-function(locations.df){
  websites <- as.character(locations.df$website)
  twitter_handles<-scrapeForHandle(websites)
  return(twitter_handles)
}

getTweets<-function(twitter_handles){
  tweets <- lapply(twitter_handles, function(x) if (length(x) != 0) searchTwitter(x,n=3))  
  tweets.df <- lapply(tweets, function(x) twListToDF(x))
  return(as.data.frame(tweets.df))
}

tweetOrganize <- function(){
  withProgress(message = 'Connecting to Twitter!', value = 0.2, {
    allTweets <- getTweets(as.character(roster$full_name))
    handles <- as.character(roster$full_name)
    handles <- sapply(handles, function(x) paste("<i class=\"fa fa-twitter-square\" style=\"color:blue\"> </i>", x, "<br/>"))
    tweets <- "<br/>"
    for(i in 0:(nrow(roster)-1)){
      j <- i + 1 #because df starts at 1
      if(i == 0){
        tweets <- paste(tweets,
                        handles[j],
                        "<i class=\"fa fa-twitter-square\" style=\"color:blue\"> </i>", allTweets$text[1],"<br/>",
                        "<i class=\"fa fa-twitter-square\" style=\"color:blue\"> </i>", allTweets$text[2],"<br/>",
                        "<i class=\"fa fa-twitter-square\" style=\"color:blue\"> </i>", allTweets$text[3],
                        "<br/>",
                        "<br/>"
        )
      } else {
        tweets <- paste(tweets,
                        handles[j],
                        "<i class=\"fa fa-twitter-square\" style=\"color:blue\"> </i>", eval(parse(text=paste0("allTweets$text.", i, "[1]"))),"<br/>",
                        "<i class=\"fa fa-twitter-square\" style=\"color:blue\"> </i>", eval(parse(text=paste0("allTweets$text.", i, "[2]"))),"<br/>",
                        "<i class=\"fa fa-twitter-square\" style=\"color:blue\"> </i>", eval(parse(text=paste0("allTweets$text.", i, "[3]"))),
                        "<br/>",
                        "<br/>"
        )
      }
    }
    #removing problem characters that are UTF-8
    Encoding(tweets) <- "UTF-8"
    tweets <- iconv(tweets, "UTF-8", "UTF-8",sub='')

    return(tweets)
  })
}
   