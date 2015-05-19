# Author: Narek Tovmasyan (IBA)
# Date: 05/18/2015

setwd("~/iba/crimes_data/")

install.packages('RJSONIO')
library(RJSONIO)
stopifnot( isValidJSON('Crime.json') )

crimeList <- fromJSON('Crime.json')
saveRDS(crimeList, file = "allCrimes.RData")
crimeList = readRDS(file = "allCrimes.RData")

crimeList = crimeList$results  # not idempotent!
singleCrime = crimeList[[1]]
class(singleCrime$location)  # list
class(singleCrime$timestamp)  # character (vector)
names(singleCrime$timestamp)  # "__type" "iso"

location$`__type`
[1] "GeoPoint"
location$latitude
[1] 37.78844
location$longitude
[1] -122.4144

thousandCrimes <- crimeList[1:1000]
#saveRDS(thousandCrimes, file = "first1000.RData")
crimes.1st.1000 <- readRDS(file = "first1000.RData")
myDF <- do.call("rbind", lapply(crimes.1st.1000, function(crime) {
  geoLocation = paste(crime$location[['__type']], crime$location$latitude, crime$location$longitude, sep = "|")
  tsVec = crime$timestamp
  tstamp <- paste(tsVec[1], tsVec[2], sep="|")
  df = data.frame(address = crime$addresss, category = crime$category, createdAt = crime$createdAt,
                  descript = crime$descript, incidentId = crime$indicentId, location = geoLocation,
                  objectId = crime$objectId, pdDistrict = crime$pdDiscrict, pdId = crime$pdId,
                  resolution = crime$resolution, timestamp = tstamp, updatedAt = crime$updatedAt)
  df
}))
write.table(myDF, "first1000.csv")
