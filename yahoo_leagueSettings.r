#This file will control all of the API calls.

library(httr)
library(RJSONIO)
library(httpuv)


source('yahoo_API_call.r')

league.url <- "http://fantasysports.yahooapis.com/fantasy/v2/league/"

leagueSettings <- function(league.key){
  leagueSettings.json <- GET(paste0(league.url, league.key, "/settings?format=json"), config(token = token))
  leagueSettings.list <- fromJSON(as.character(leagueSettings.json), asText=T)
  return(leagueSettings.list)
}

leagueSettings.list <- leagueSettings(league.key)
print(leagueSettings.list)