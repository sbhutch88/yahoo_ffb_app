#This file will control all of the API calls.

####Things to do:
#Remove Yahoo button push approval.
library(instaR)
library(httr)
library(RJSONIO)
library(ggplot2)
library(httpuv)
library(twitteR)
#library(instaR) THis is masking fromJSON and toJSON from RJSONIO, so from now on I will call fromJSON as RJSONIO::fromJSON
#** Also I have some stringr functions in my handle web-scrape that I need to now put stringr:: before. I think because I installed stringi

source('yahoo_API_call.R')
source('yahoo_fantasy_functions.R')
source('slack_functions.R')

#Connecting to twitter
#source('connectToTwitter.R') #moved to fantasy functions
connectToTwitter()

# # #Sourcing Instagram functions
# ID <- paste(readLines("instagram_client_id.txt"), collapse=" ")
# SECRET <- paste(readLines("instagram_secret.txt"), collapse=" ")
# instagram_token <- instaOAuth(ID, SECRET,  scope = c("basic", "public_content"))

leagueStandingsDF <- leagueStandings(league.key,token)

#NOt sure why I can't get order() to work, for now I'll use this.
leagueStandingsDF <- rbind(leagueStandingsDF[leagueStandingsDF$TeamID == 1,],
                           leagueStandingsDF[leagueStandingsDF$TeamID == 2,],
                           leagueStandingsDF[leagueStandingsDF$TeamID == 3,],
                           leagueStandingsDF[leagueStandingsDF$TeamID == 4,],
                           leagueStandingsDF[leagueStandingsDF$TeamID == 5,],
                           leagueStandingsDF[leagueStandingsDF$TeamID == 6,],
                           leagueStandingsDF[leagueStandingsDF$TeamID == 7,],
                           leagueStandingsDF[leagueStandingsDF$TeamID == 8,],
                           leagueStandingsDF[leagueStandingsDF$TeamID == 9,],
                           leagueStandingsDF[leagueStandingsDF$TeamID == 10,],
                           leagueStandingsDF[leagueStandingsDF$TeamID == 11,],
                           leagueStandingsDF[leagueStandingsDF$TeamID == 12,])
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