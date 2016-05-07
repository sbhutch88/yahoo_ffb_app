#This file will make calls to acquire NFL stats
#*** Since this data is public, and not associated with our league, it seems like this data should be easy to access. In the documationation
#it says this is a 2-legged call. I'm having trouble making the call for now, but there should definitely be a way.

#Sourcing API access file
source('yahoo_API_call.r')

#A whole bunch can be found about nfl players (ex. drew brees)
nflPlayer.url <- "http://fantasysports.yahooapis.com/fantasy/v2/player/"

season.key <- "223"
player.key <- "5479"
playerCall.key <- paste0(season.key,".p.",player.key)

playerCall.key <- "223.p.5479"
playerCall.key <- "348.p.24901"

nflPlayerStatSearch <- function(playerCall.key){
  nfl.player.stats.json <- GET(paste0(nflPlayer.url, playerCall.key, "/stats?format=json"), config(token = token))
  nfl.player.stats.list <- fromJSON(as.character(nfl.player.stats.json), asText=T)
  nfl.player.draftAnalysis.json <- GET(paste0(nflPlayer.url, playerCall.key, "/draftanalysis?format=json"), config(token = token))
  nfl.player.draftAnalysis.list <- fromJSON(as.character(nfl.player.draftAnalysis.json), asText=T)
return(nfl.player.stats.list) 
}

nflPlayerStatBuildDF <- function(nfl.player.stats.list){
  player.df <- data.frame(cbind(player_id = nfl.player.stats.list$fantasy_content$player[[1]][[2]],
                                full_name = nfl.player.stats.list$fantasy_content$player[[1]][[3]]$name[1],
                                first_name = nfl.player.stats.list$fantasy_content$player[[1]][[3]]$name[2],
                                last_name = nfl.player.stats.list$fantasy_content$player[[1]][[3]]$name[3],
                                nfl_team = nfl.player.stats.list$fantasy_content$player[[1]][[7]],
                                nfl_team_abr = nfl.player.stats.list$fantasy_content$player[[1]][[8]],
                                bye_week = nfl.player.stats.list$fantasy_content$player[[1]][[9]],
                                position = nfl.player.stats.list$fantasy_content$player[[1]][[11]]),
                                season = nfl.player.stats.list$fantasy_content$player[[2]]$player_stats$`0`[2],
                          row.names = NULL)
  return(player.df)
}
