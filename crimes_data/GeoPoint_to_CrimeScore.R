
setwd("~/iba/crimes_data/")
crTable <- read.table("crimes_1_10000.csv")

setwd("~/Desktop/CS 210/")
crTable1 <- read.table("crimes_10001_50000.csv")

crTable2 <- read.table("crimes_50001_250000.csv")
crTable3 <- read.table("crimes_250001_440396.csv")

crimeTabular.all <- rbind(crTable, crTable1, crTable2, crTable3)

saveRDS(crimeTabular.all, file = "allCrimesRead.RData")



# Next time reading, immediately read the saved/cached object..
setwd("~/Desktop/CS 210/")
crimeTable <- readRDS(file = "allCrimesRead.RData")

print("Number of unique Geo-locations:")
length( levels(crimeTable$location) )
stopifnot( length(levels(crimeTable$location)) == length(unique(crimeTable$location)) )

allGeoLocs <- unique(crimeTable$location)
M = length(allGeoLocs)

setwd("~/iba/crimes_data/")
weights <- read.table("crimeTypeWeights_50000.csv")

eachGeoLocToCrimeScore = matrix(nrow = M, ncol = 1, 
                                dimnames = list(allGeoLocs, "Crime Score"))
for (idx in 1:M) {
  singleGeoLoc <- allGeoLocs[idx]
  ss <- subset(crimeTable, location == singleGeoLoc)
  tt <- table(ss$category)
  
  oo <- order(tt, rownames(weights))
  w = weights[oo,]
  freqs = as.numeric(tt)
  #score <- weighted.mean(freqs, weights)
  score <- weighted.mean(w, freqs)
  
  eachGeoLocToCrimeScore[idx,] <- score
}


########## Optimized Version #############
# Using an optimal algorithm..

eachGeoLocToCrimeScore = matrix(nrow = M, ncol = 1, 
                                dimnames = list(allGeoLocs, "Crime Score"), data = 0)
#some = crimeTable[1:10,]
apply(crimeTable, 1, function(x) {
  geoLoc = x[["location"]]  # "factor"
  geoLoc = as.character(geoLoc)
  crimeType = x[["category"]]  # "factor"
  crimeType = as.character(crimeType)
  
  eachGeoLocToCrimeScore[geoLoc,] <<- eachGeoLocToCrimeScore[geoLoc,] + weights[crimeType,]
})
setwd("~/Desktop/CS 210/")
saveRDS(eachGeoLocToCrimeScore, file = "totalWeightsPerGeoPoint.RData")


# Next time reading, take it from the "cache"..
setwd("~/Desktop/CS 210/")
eachGeoLocToCrimeScore <- readRDS(file = "totalWeightsPerGeoPoint.RData")

geolocFreqTable <- table(crimeTable$location)
stopifnot( sum(geolocFreqTable) == nrow(crimeTable) )

oo <- order(geolocFreqTable, allGeoLocs)
allGeoLocs[oo]

for (idx in 1:M) {
  geoloc = allGeoLocs[idx]
  count = geolocFreqTable[geoloc]
  names(count) <- NULL
  
  geoLoc = as.character(geoloc)
  eachGeoLocToCrimeScore[geoLoc,] = eachGeoLocToCrimeScore[geoLoc,] / count
}

setwd("~/iba/crimes_data/")
write.table(eachGeoLocToCrimeScore, file = "EveryGeoPoint_to_Weight.csv")
