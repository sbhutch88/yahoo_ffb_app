
source('yahoo_API_call.R')


num.teams <- 12
num.weeks <- 13 #regular season only.
owner.names <- c("Heil", "Steve", "John", "Drew", "Scott", "Sean", "Matt", "Frates", "Bsak", "Kev", "Al", "Larson")


#gathering some data from Beverly League
for(i in 1:num.teams){
  #1:Heil; 2:Steve; 3:John; 4:Drew; 5:Scott; 6:Sean; 7:Matt; 8:Frates; 9:Bsak; 10:Kev; 11:Al; 12:Larson
  my.team.id <- toString(i)
  my.team.key <- paste0(league.key, ".t.", my.team.id)
  #The url must be changed to make different calls
  team.url <- "http://fantasysports.yahooapis.com/fantasy/v2/team/"
  league.url <- "http://fantasysports.yahooapis.com/fantasy/v2/league/"
  
  #Calling some data about the owners in our league
  league.owners.json <- GET(paste0(league.url, league.key, "/teams?format=json"), 
                            config(token = token))
  league.owners.list <- fromJSON(as.character(league.owners.json), asText=T)
  
  # lots of endpoints to play with, more here... 
  # http://developer.yahoo.com/fantasysports/guide/
  my.team.stats.json <- GET(paste0(team.url, my.team.key, "/stats?format=json"), 
                            config(token = token))
  my.team.stats.list <- fromJSON(as.character(my.team.stats.json), asText=T)
  my.team.standings.json <- GET(paste0(team.url, my.team.key, 
                                       "/standings?format=json"), config(token = token))
  my.team.matchups.json <- GET(paste0(team.url, my.team.key, 
                                      "/matchups?format=json"), config(token = token))
  my.team.matchups.list <- fromJSON(as.character(my.team.matchups.json), asText=T)
  my.team.draftResults.json <- GET(paste0(team.url, my.team.key, 
                                      "/draftresults?format=json"), config(token = token))
  my.team.draftResults.list <- fromJSON(as.character(my.team.draftResults.json), asText=T)

  # number of games played
  game.num <- 13
  
  # get the opponent scores for my matchups for the entire season
  tmp <- my.team.matchups.list$fantasy_content["team"][[1]][[2]]$matchups
  opp.score <- tmp$'0'$matchup$`0`$teams$`1`$team[[2]]$team_points["total"]
  opp.score <- c(opp.score, sapply(as.character(1:(game.num-1)),   
                                   function(x)tmp[x][[x]]$matchup$`0`$teams$`1`$team[[2]]$team_points$total))
  my.score <- tmp$'0'$matchup$`0`$teams$`0`$team[[2]]$team_points["total"]
  my.score <- c(my.score, sapply(as.character(1:(game.num-1)),   
                                 function(x)tmp[x][[x]]$matchup$`0`$teams$`0`$team[[2]]$team_points$total))
  
  #Data frame creation
  my.df <- data.frame(cbind(game=rep(1:length(my.score), 2), 
                            team=c(rep("me", length(my.score)), rep("them", length(my.score))),
                            score=as.numeric(c(my.score, opp.score))))
  my.df$game <- factor(my.df$game, levels=1:game.num)
  my.df$score <- as.numeric(as.character(my.df$score))
  
  
  print(my.score)
  if(i==1){
    full.df <- data.frame(cbind(my.df$score[1:num.weeks]))
  } else {
    temp.df <- data.frame(cbind(my.df$score[1:num.weeks]))
    full.df <- data.frame(cbind(full.df,temp.df))
  }
  
  single_forPlot <- data.frame(cbind(week=rep(1:num.weeks),2), team=c(rep(owner.names[i],num.weeks)), 
                          score=as.numeric(my.score))
  
  if(i==1){
    full_forplot.df <- single_forPlot
  } else {
    temp.df <- single_forPlot
    full_forplot.df <- data.frame(rbind(full_forplot.df,temp.df))
  }
  
  
}

names(full.df) <- owner.names


#Plotting
p1 <- ggplot(my.df, aes(x=game, y=score, color=team, group=team)) + 
  geom_point() + geom_line() + scale_y_continuous()

p2 <- ggplot(full_forplot.df,aes(x=week, y=score, color=team, group=team)) + 
  geom_point() + geom_line() + scale_y_continuous()
#ggsave("FF_regular_season.jpg")