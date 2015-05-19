# Author: Narek Tovmasyan (IBA)
# Date: 05/18/2015

setwd("~/iba/crimes_data/")

install.packages('RJSONIO')
library(RJSONIO)
isValidJSON('Crime.json')

crimeList <- fromJSON('Crime.json')
saveRDS(crimeList, file = "allCrimes.RData")
crimeList = readRDS(file = "allCrimes.RData")

crimeList = crimeList$results  # not idempotent!
singleCrime = crimeList[[1]]
class(singleCrime$location)  # list
class(singleCrime$timestamp)  # character (vector)
names(singleCrime$timestamp)  # "__type" "iso"


thousandCrimes <- crimeList[1:1000]
saveRDS(thousandCrimes, file = "first1000.RData")
myDF <- do.call("rbind", lapply(thousandCrimes, as.data.frame))
write.table(myDF, "first1000.csv")
