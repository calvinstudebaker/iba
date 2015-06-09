

# GeoLocation-based (GoePoint|latitude|longitude) 
# probability calculations for every crime type..


setwd("~/iba/crimes_data/")
crTable <- read.table("crimes_1_10000.csv")

setwd("~/Desktop/CS 210/")
crTable1 <- read.table("crimes_10001_50000.csv")
crimeTabular.all <- rbind(crTable, crTable1)

crTable <- crimeTabular.all

aggregateByCrimeType <- function(df, decreasing = T) {
  ct.table <- table(df$category)
  stopifnot( sum(ct.table) == nrow(df) )
  
  ct.df <- as.data.frame( sort(ct.table, decreasing) )
  colnames(ct.df) = "Crime Type Freq."
  ct.df
}
ct.df <- aggregateByCrimeType(crTable)


#source("learn_weights.R")
cloc.df <- crime.freq.by(crTable, "location", 10)

N = nrow(cloc.df)
probability.any.incident <- cloc.df / N


all.types.Chances <- function(singleGeoLoc) {
  singleLoc <- names(singleGeoLoc)
  ss.in.geoloc <- subset(crTable, location == singleLoc)
  
  # Confirming it keeps all the (crime) factor levels..
  length( levels(ss.in.geoloc$category) ) == nrow(ct.df)
  m = nrow(ct.df)
  
  tt <- table(ss.in.geoloc$category)
  # Doing Laplace smoothing..
  probs.crime.types <- (tt + 1) / (sum(tt) + m)
  
  probOfAnything = probability.any.incident[singleLoc,]
  names(probOfAnything) = NULL
  
  # Finally -- reporting all crime-type "chances" (likelihoods) for this single Geo-location!
  pTable = probOfAnything * probs.crime.types
  pTable
}


allGeolocations = rownames(cloc.df)
allCrimeTypes = rownames(ct.df)
all.geoloc.all.crimes = matrix(nrow = nrow(cloc.df), ncol = nrow(ct.df), 
                             dimnames = list(allGeolocations, allCrimeTypes))
for (idx in 1:nrow(cloc.df)) {
  currRow = cloc.df[idx,]
  #all.addr.all.crimes <- rbind(all.addr.all.crimes, all.types.Probs(x))
  all.geoloc.all.crimes[idx,] <- all.types.Probs(currRow)
}
all.geoloc.all.crimes




