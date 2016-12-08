#This file is following a blog post by corey nissen: http://blog.corynissen.com/2013/12/using-r-to-analyze-yahoo-fantasy.html

consumer.key = paste(readLines("consumer_key.txt"), collapse=" ")
consumer.secret = paste(readLines("consumer_secret.txt"), collapse=" ")

#Original version of Yahoo Connection (works well but something is wrong with SHiny deploy)
oauth_endpoints("yahoo")
myapp <- oauth_app("yahoo", key = consumer.key, secret = consumer.secret)
#token <- oauth1.0_token(oauth_endpoints("yahoo"), myapp)
token <- oauth1.0_token(oauth_endpoints("yahoo"), myapp, cache=FALSE) #I believe it will ask me to re-authenticate every hour.

#New Connection, originally taken from Dennis Email code
# yahoo_endpoint <- httr::oauth_endpoints("yahoo")
# yahoo_app <- httr::oauth_app("yahoo", key = consumer.key, secret = consumer.secret)
# token <- httr::oauth1.0_token(oauth_endpoints("yahoo"), yahoo_app)

#Getting game id for my league
ff.url <- "http://fantasysports.yahooapis.com/fantasy/v2/game/nfl?format=json"
game.key.json <- GET(ff.url, config(token = token))
game.key.list <- RJSONIO::fromJSON(as.character(game.key.json), asText=T)
game.key <- game.key.list$fantasy_content$game[[1]]["game_key"]

#Personal league id
league.id <-  '42592' #153118' #'42592'
league.key <- paste0(game.key, ".l.", league.id)

# ALL OF THE FOLLOWING ARE EXAMPLES FOR NOW, I'll LIKELY MAKE CALLS IN SEPARATE FILES.

# nfl.url <- "http://fantasysports.yahooapis.com/fantasy/v2/game/nfl"
# #Collecting some NFL stats
# nfl.stat.categories.json <- GET(paste0(nfl.url,"/stat_categories?format=json"), config(token=token))
# nfl.stat.categories.list <- RJSONIO::fromJSON(as.character(nfl.stat.categories.json), asText = T)

games.url <- "http://fantasysports.yahooapis.com/fantasy/v2/users;use_login=1/games"
#Can also add sub-codes like particular games/seasons

roster.url <- "http://fantasysports.yahooapis.com/fantasy/v2/team/223.l.431.t.9/roster/players"
#or /fantasy/v2/team//roster/players

#A whole bunch can be found about nfl players (ex. drew brees)
nflPlayer.url <- "http://fantasysports.yahooapis.com/fantasy/v2/player/223.p.5479/stats"
#or /fantasy/v2/player//metadata

#Get all players within a league
playersLeague.url <-"http://fantasysports.yahooapis.com/fantasy/v2/league/223.l.431/players"
#much more for specific teams too. All different types of calls for FA, owned; specific players, specific teams etc.
#Sorting by certain stats.

# transaction data
transaction.url <- "http://fantasysports.yahooapis.com/fantasy/v2/transaction/223.l.431.tr.26"
#http://fantasysports.yahooapis.com/fantasy/v2/league/223.l.431/transactions
#try this too for more: /fantasy/v2/transaction//metadata

#leage transaction data
leagueTransaction.url <- "http://fantasysports.yahooapis.com/fantasy/v2/league//transaction"

#User information
user.url <- "http://fantasysports.yahooapis.com/fantasy/v2/users;use_login=1"