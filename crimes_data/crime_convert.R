# Author: Narek Tovmasyan (IBA)
# Date: 05/18/2015

setwd("~/iba/crimes_data/")

install.packages('RJSONIO')
library(RJSONIO)
stopifnot( isValidJSON('Crime.json') )

crimeList <- fromJSON('Crime.json')
#saveRDS(crimeList, file = "allCrimes.RData")
#crimeList = readRDS(file = "allCrimes.RData")

crimes.all = crimeList$results  # not idempotent!
singleCrime = crimeList[[1]]
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




crTable <- read.table("crimes_1_10000.csv")

########## Crime Description (cd) Freq. Analysis ###############

cd.table <- table(crTable$descript)
dim(cd.table) # hence:
cd.table[order(cd.table)]
# same as
sort(cd.table)

sort(cd.table, decreasing = T)
# same as
cd.table[order(-cd.table)]
# same as
cd.descending <- cd.table[order(cd.table, decreasing = T)] # an "array"

cd.df <- as.data.frame(cd.descending)
colnames(cd.df) = "Crime Freq."
cd.text <- names(cd.table)
#paste(cd.text, sep = "/") == cd.text
#allText <- paste(cd.text, collapse = "   ")
#nchar(allText) / length(cd.text)
allWords <- paste(cd.text, collapse = " ")
strsplit(allWords, split = " ")



########## Crime Type/Category (ct) Freq. Analysis ###############

ct.table <- table(crTable$category)
ct.descending <- sort(ct.table, decreasing = T)
ct.df <- as.data.frame(ct.descending)
colnames(ct.df) = "Crime Type Freq."

subset(ct.df, `Crime Type Freq.` == 1)
subset(ct.df, `Crime Type Freq.` > 1 & `Crime Type Freq.` < 10)
subset(ct.df, `Crime Type Freq.` >= 10 & `Crime Type Freq.` < 100)
subset(ct.df, `Crime Type Freq.` >= 100 & `Crime Type Freq.` < 1000)
subset(ct.df, `Crime Type Freq.` >= 1000)



########## Crime Address/Location Freq. Analysis ###############

caddr.table <- table(crTable$address)
dim(caddr.table)
caddr.descending <- sort(caddr.table, decreasing = T)
caddr.df <- as.data.frame(caddr.descending)
colnames(caddr.df) = "Crime Address Freq."
head(caddr.df, 50)

cloc.table <- table(crTable$location)
dim(cloc.table)
cloc.descending <- sort(cloc.table, decreasing = T)
cloc.df <- as.data.frame(cloc.descending)
colnames(cloc.df) = "Crime Location Freq."
head(cloc.df, 25)







