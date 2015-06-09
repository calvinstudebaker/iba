# Author: Narek Tovmasyan (IBA)
# Date: 05/18/2015


setwd("~/iba/crimes_data/")
setwd('~/Desktop/CS 210/')

install.packages('RJSONIO')
library(RJSONIO)
stopifnot( isValidJSON('Crime.json') )

crimeList <- fromJSON('Crime.json')
#saveRDS(crimeList, file = "allCrimes.RData")
crimeList = readRDS(file = "allCrimes.RData")

crimes.all = crimeList$results
singleCrime = crimes.all[[1]]
class(singleCrime$location)  # list
class(singleCrime$timestamp)  # character (vector)
names(singleCrime$timestamp)  # "__type" "iso"

# Sample:
#location$`__type`
#[1] "GeoPoint"
#location$latitude
#[1] 37.78844
#location$longitude
#[1] -122.4144

length(crimes.all)  # there are a total of 840,396 crime incidents!


#options(error = traceback)
toCSV <- function(selectedCrimes, filename) {
  result <- do.call("rbind", lapply(selectedCrimes, function(crime) {
    geoLocation = paste(crime$location[['__type']], crime$location$latitude, crime$location$longitude, sep = "|")
    tsVec = crime$timestamp
    tstamp <- paste(tsVec[1], tsVec[2], sep="|")
    df = data.frame(address = crime$addresss, category = crime$category, createdAt = crime$createdAt,
                    descript = crime$descript, incidentId = crime$indicentId, location = geoLocation,
                    objectId = crime$objectId, pdDistrict = crime$pdDiscrict, pdId = crime$pdId,
                    resolution = crime$resolution, timestamp = tstamp, updatedAt = crime$updatedAt)
    df
  }))
  write.table(result, filename)
}

processCrimes <- function(fromIndex, toIndex) {
  fname <- paste(paste("crimes", fromIndex, toIndex, sep = "_"), ".csv", sep = "")
  toCSV(crimes.all[fromIndex:toIndex], fname)
}

processCrimes(1, 10000)
processCrimes(10001, 50000)
processCrimes(50001, 250000)

processCrimes(250001, 440396)

