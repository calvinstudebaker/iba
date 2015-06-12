# *------------------------------------------------------------------
# | PROGRAM NAME: geopoint_to_crimeweight.R
# | DATE: 06/07/2015
# | CREATED BY: Narek Tovmasyan (Team IBA)
# | PROJECT FILE: PARQ
# *---------------------------------------------------


# Corresponds to the GitHub repo structure @ https://github.com/cs210/iba
setwd("~/iba/crimes_data/")

crTable <- read.table("Crimes_1_10000.csv")

setwd("~/Desktop/CS 210/")
# Or, set it to the (local) folder where all the CSV files with 
# the remaining (a very large number of) crime incidents are

crTable1 <- read.table("Crimes_10001_50000.csv")
crTable2 <- read.table("Crimes_50001_250000.csv")
crTable3 <- read.table("Crimes_250001_440396.csv")

crime.table.all <- rbind(crTable, crTable1, crTable2, crTable3)
saveRDS(crime.table.all, file = "allCrimesRead.RData")


# Next time running, immediately read the saved/cached object..
setwd("~/Desktop/CS 210/")
# Or, set it to the directory where the huge, stored .RData files are

crimeTable <- readRDS(file = "allCrimesRead.RData")
N = nrow(crimeTable)

print("Number of unique Geo-locations:")
length( levels(crimeTable$location) )

allGeoLocs <- unique(crimeTable$location)
M = length(allGeoLocs)
stopifnot( length(levels(crimeTable$location)) == M )


# Again, matches to the structure of the GitHub repo @ https://github.com/cs210/iba
setwd("~/iba/crimes_data/")
weights <- read.table("crimeTypeWeights_50000.csv")

eachGeoLocToCrimeScore = matrix(nrow = M, ncol = 1, 
                                dimnames = list(allGeoLocs, "Crime Score"))
for (idx in 1:M) {
  singleGeoLoc <- allGeoLocs[idx]

  ss <- subset(crimeTable, location == singleGeoLoc)
  tt <- table(ss$category)
  
  oo <- order(tt, rownames(weights))
  w <- weights[oo, ]
  freqs <- as.numeric(tt)

  score <- weighted.mean(w, freqs)
  eachGeoLocToCrimeScore[idx, ] <- score
}


############### Optimized Version ###############
# Using an optimal algorithm..

eachGeoLocToCrimeScore = matrix(nrow = M, ncol = 1, 
                                dimnames = list(allGeoLocs, "Crime Score"), data = 0)
apply(crimeTable, 1, function(x) {
  geoLoc <- x[["location"]]  # "factor"
  geoLoc <- as.character(geoLoc)

  crimeType <- x[["category"]]  # "factor"
  crimeType <- as.character(crimeType)
  
  eachGeoLocToCrimeScore[geoLoc, ] <<- eachGeoLocToCrimeScore[geoLoc, ] + weights[crimeType, ]
})

setwd("~/Desktop/CS 210/")
# Or, set it to the folder that should have the GeoPoint -> "total" crime weight mapping
saveRDS(eachGeoLocToCrimeScore, file = "totalWeightsPerGeoPoint.RData")


# Next time running, take it from the "cache"..
setwd("~/Desktop/CS 210/")
eachGeoLocToCrimeScore <- readRDS(file = "totalWeightsPerGeoPoint.RData")

geolocFreqTable <- table(crimeTable$location)
stopifnot( sum(geolocFreqTable) == N )

oo <- order(geolocFreqTable, allGeoLocs)
allGeoLocs[oo]

for (idx in 1:M) {
  geoloc <- allGeoLocs[idx]
  count <- geolocFreqTable[geoloc]
  names(count) <- NULL
  
  geoLoc = as.character(geoloc)
  # normalize (divide) the current Geo-location's crime weight by its crime frequency:
  eachGeoLocToCrimeScore[geoLoc, ] <- eachGeoLocToCrimeScore[geoLoc, ] / count
}


# Set back to your (local) folder that's similar to the GitHub @ https://github.com/cs210/iba
setwd("~/iba/crimes_data/")

write.table(eachGeoLocToCrimeScore, file = "EveryGeoPoint_to_CrimeWeight.csv")
