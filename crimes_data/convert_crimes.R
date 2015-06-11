# *------------------------------------------------------------------
# | PROGRAM NAME: convert_crimes.R
# | DATE: 05/18/2015
# | CREATED BY: Narek Tovmasyan (Team IBA)
# | PROJECT FILE: PARQ
# *---------------------------------------------------


# Matches to the GitHub repo structure @ https://github.com/cs210/iba
setwd("~/iba/crimes_data/")

setwd('~/Desktop/CS 210/')
# Or, set it to the (local) directory where the very large JSON file (for all crimes) is,
# which you can export from https://www.parse.com/apps/parq--3/collections#class/Crime

install.packages('RJSONIO')
library(RJSONIO)

# Skip this line if confident the JSON file is well-formed!
stopifnot( isValidJSON('Crime.json') )

crimeList <- fromJSON('Crime.json')
saveRDS(crimeList, file = "allCrimes.RData")


# Next time reading, restore the serialized object from file! 
crimeList <- readRDS(file = "allCrimes.RData")

crimes.all = crimeList$results
singleCrime <- crimes.all[[1]]
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

kNumCrimeIncidents <- length(crimes.all)  # a total of 840,396 crime incidents!
print( paste("There are a total of", kNumCrimeIncidents, "crime incidents in the city of SF!") )


####
# Converts the selected list of crime incidents into a data frame, and 
# writes the result into the specified CSV file.
#
# @param selectedCrimes: list of crimes, each being a "list" of crime properties.
# @param filename: character, the name of a .csv file.
#
# @examples
# ToCSV(crimeIncidents[1:1000], "Crimes_1_1000.csv")
##
#options(error = traceback)
ToCSV <- function(selectedCrimes, filename) {
  result <- do.call("rbind", lapply(selectedCrimes, function(crime) {
    geoLocation = paste(crime$location[['__type']], crime$location$latitude, crime$location$longitude, sep = "|")

    tsVec <- crime$timestamp
    tStamp <- paste(tsVec[1], tsVec[2], sep="|")

    df = data.frame(address = crime$addresss, category = crime$category, createdAt = crime$createdAt,
                    descript = crime$descript, incidentId = crime$indicentId, location = geoLocation,
                    objectId = crime$objectId, pdDistrict = crime$pdDiscrict, pdId = crime$pdId,
                    resolution = crime$resolution, timestamp = tStamp, updatedAt = crime$updatedAt)
    df
  }))
  write.table(result, filename)
}


####
# Process all crime incidents falling into the specified index range.
#
# @param fromeIndex: integer index as to where to start.
# @param toIndex: integer index as to where to end.
#
# @examples
# ProcessCrimes(1, 1000)
##
ProcessCrimes <- function(fromIndex, toIndex) {
  fname <- paste(paste("Crimes", fromIndex, toIndex, sep = "_"), ".csv", sep = "")
  ToCSV(crimes.all[fromIndex:toIndex], fname)
}


# Processed the crimes data in 4 phases..

ProcessCrimes(1, 10000)
ProcessCrimes(10001, 50000)

ProcessCrimes(50001, 250000)

ProcessCrimes(250001, 440396)

# Finally!..
ProcessCrimes(440397, kNumCrimeIncidents)

