#Sourcing all players within a league


league.url <- "http://fantasysports.yahooapis.com/fantasy/v2/league/"
team.url <- "http://fantasysports.yahooapis.com/fantasy/v2/team/"
player.url <- "http://fantasysports.yahooapis.com/fantasy/v2/player/"

#all.league.players.json <- GET(paste0(league.url, league.key, "/players?format=json"), config(token = token))
#all.league.players.list <- fromJSON(as.character(all.league.players.json), asText=T)


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
  
  player.df <- data.frame(cbind(player_id = nfl.player.stats.list$fantasy_content$player[[1]][[2]],
                                full_name = nfl.player.stats.list$fantasy_content$player[[1]][[3]]$name[[1]],
                                first_name = nfl.player.stats.list$fantasy_content$player[[1]][[3]]$name[[2]],
                                last_name = nfl.player.stats.list$fantasy_content$player[[1]][[3]]$name[[3]],
                                nfl_team = nfl.player.stats.list$fantasy_content$player[[1]][[6+shift]],
                                nfl_team_abr = nfl.player.stats.list$fantasy_content$player[[1]][[7+shift]],
                                bye_week = nfl.player.stats.list$fantasy_content$player[[1]][[8+shift]],
                                position = nfl.player.stats.list$fantasy_content$player[[1]][[10+shift]]),
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
   