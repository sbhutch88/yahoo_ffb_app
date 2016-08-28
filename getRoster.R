#get a Roster

#At the moment, singleTeamCall doesn't work. I think it's because yahoo
#has updated to the new season, and I now have to make an archived call.
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
