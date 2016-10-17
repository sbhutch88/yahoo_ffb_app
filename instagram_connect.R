#Connecting to instagram

# Instagram module

# Mode of use:
#> source("apiInstagram.R")
#> x <- getInstagramfromJSON(51.517640,-0.080291,500)
#> df <- convertInstagramToDF(x) # minimal dataframe grouped by places
#> df_full <- convertInstagramToFullDF(x) # big dataframe all items
#> x <- getInstagramLocationMedia(602308441) # single place request, for testing

library(RCurl)
library(RJSONIO)

getInstagramfromJSON <- function(myLat,myLon,myRadius){
  # given latitude=myLat,longitude=myLong, myRadius (in meters)
  # returns list from JSON-file with pictures/videos in that area
  
  ACCESS_TOKEN <- paste(readLines("instagram_key.txt"), collapse=" ")
  url <- paste("https://api.instagram.com/v1/locations/search?",
               "lat=",myLat,
               "&lng=",myLon,
               "&distance=",myRadius,
               "&access_token=", ACCESS_TOKEN,
               sep="")
  
  doc <- getURL(url)
  
  x <- fromJSON(doc,simplify = FALSE)
  if(x$meta$code==200) {
    return(x)
  } else {
    print("error in InstagramfromJSON")
    print(x$meta$code)
    return(x)
  }
}


convertInstagramToDF <- function(x){
  # given list from JSON-file, it extracts dataframe with:
  
  if(length(x$data)>0){
    myname=""
    myid=""
    mylat=""
    mylng=""
    
    for(i in (1:length(x$data))){
      myname[i] <- x$data[[i]]$name
      myid[i] <- x$data[[i]]$id
      mylat[i] <- x$data[[i]]$latitude
      mylng[i] <- x$data[[i]]$longitude
    }
    
    df <- data.frame(id=myid,
                     name=myname,
                     lat=as.double(mylat),
                     lng=as.double(mylng),
                     stringsAsFactors = FALSE
    )
    
  }else{
    df <- data.frame(id=character(0),
                     name=character(0),
                     lat=numeric(0),
                     lng=numeric(0),
                     stringsAsFactors = FALSE
    )
  }
  return(df)
  
}


convertInstagramToFullDF <- function(x){
  if(length(x$data)>0){
    myname=""
    myid=""
    mylat=""
    mylng=""
    mytype=""
    mytags=""
    mycreated_at=""
    mylink=""
    mylikes=""
    myurl=""
    mytext=""
    
    for(j in (1:length(x$data))){
      y <- getInstagramLocationMedia(x$data[[j]]$id)
      if(y$meta$code==200 && length(y$data)>0){
        for(i in (1:length(y$data))){
          myname <- append(myname,safeEntry(y$data[[i]]$location$name))
          myid <- append(myid,y$data[[i]]$location$id)
          mylat <- append(mylat,y$data[[i]]$location$latitude)
          mylng <- append(mylng,y$data[[i]]$location$longitude)
          mytype <- append(mytype,safeEntry(y$data[[i]]$type))
          if(length(y$data[[i]]$tags)>0){
            tmp <- do.call("paste",y$data[[i]]$tags)
          } else{
            tmp <- ""
          }
          mytags <- append(mytags,tmp)
          mycreated_at <- append(mycreated_at,safeEntry(y$data[[i]]$created_time))
          mylink <- append(mylink,safeEntry(y$data[[i]]$link))
          mylikes <- append(mylikes,safeEntry(y$data[[i]]$likes$count))
          myurl <- append(myurl,safeEntry(y$data[[i]]$images$thumbnail$url)) # change here for larger image size
          mytext <- append(mytext,safeEntry(y$data[[i]]$caption$text))
        }
      } else if(y$meta$code!=200) {
        print("error in convertInstagramToFullDF")
        print(y$meta$code)
        print("call number:j,i")
        print(c(j,i))
      }
    }
    df <- data.frame( name=myname,
                      id=myid,
                      lat=as.double(mylat),
                      lng=as.double(mylng),
                      type=mytype,
                      tags=mytags,
                      created_at=mycreated_at,
                      link=mylink,
                      likes=mylikes,
                      url=myurl,
                      text=mytext,
                      stringsAsFactors = FALSE
    )
    
  } else {
    df <- data.frame(id=character(0),
                     name=character(0),
                     lat=as.double(0),
                     lng=as.double(0),
                     stringsAsFactors = FALSE
    )
  }
  return(df)
}

getInstagramLocationMedia <- function(location_id){
  # Given an instagram location_id, it returns recent pics/videos
  # from the location
  
  ACCESS_TOKEN <- "2141374003.10eedc4.187e985ba9d04a6f827ffa683a4caf72"
  url <- paste("https://api.instagram.com/v1",
               "/locations/",location_id,
               "/media/recent?",
               "access_token=", ACCESS_TOKEN,
               sep="")
  doc <- getURL(url)
  x <- fromJSON(doc,simplify = FALSE)
  if(x$meta$code==200) {
    return(x)
  } else {
    print("error in InstagramLocationMedia query")
    print(x$meta$code)
    return(x)
  }
}


safeEntry <- function(x){
  out <- if (is.null(x)) "" else x
  return(out)
}