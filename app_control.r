#This file will control all of the API calls.

####Things to do:
#Remove Yahoo button push approval.

library(httr)
library(RJSONIO)
library(ggplot2)
library(httpuv)

source('yahoo_API_call.r')
source('yahoo_fantasy_functions.r')

leagueStandingsDF <- leagueStandings(league.key,token)
leagueStandingsDF <- rbind(leagueStandingsDF[12,],
                           leagueStandingsDF[8,],
                           leagueStandingsDF[9,],
                           leagueStandingsDF[10,],
                           leagueStandingsDF[11,],
                           leagueStandingsDF[7,],
                           leagueStandingsDF[6,],
                           leagueStandingsDF[2,],
                           leagueStandingsDF[1,],
                           leagueStandingsDF[3,],
                           leagueStandingsDF[4,],
                           leagueStandingsDF[5,])
#Not sure why this is different than the other search,
#but for now this will allow singleTeamCall to work correctly.

#This will be a variable input later.
coaches <- list(leagueStandingsDF$Team)
# #At the moment, singleTeamCall doesn't work. I think it's because yahoo 
# #has updated to the new season, and I now have to make an archived call.
# teamList <- singleTeamCall(teamNum)
# playerIDs_df <- createTeamIDs(teamList)
# 
# #For now I'm going to exclude kicker and defense
# cond1 <- playerIDs_df$position == "K"
# playerIDs_df <- playerIDs_df[!cond1,]
# cond2 <- playerIDs_df$position == "DEF"
# playerIDs_df <- playerIDs_df[!cond2,]
# 
# #Call and create DF of full team.
# for(i in 1:nrow(playerIDs_df)){
#  playerStats_list <- nflPlayerStatSearch(playerIDs_df[i,3]) #Change the input later to be variable.
#  if(i == 1){
#    playerStats_df <- nflPlayerStatBuildDF(playerStats_list)
#  } else{
#    temp <- nflPlayerStatBuildDF(playerStats_list)
#    playerStats_df <- rbind(playerStats_df,temp)
#  }
# }
# ISSUE: some players don't have a status(aka "probable" etc.), and maybe others, so the list calls change slightly.
# SOLUTION: I decided to go with a quick fix and just shift the list call contingent upon the existance of particular columns.


#playerFantasy <- teamPlayerInfo(playerIDs_df[1,3])