# Author: Narek Tovmasyan (IBA)
# Date: 04/28/2015

#setwd("/Users/narektovmasyan/Desktop/CS 210/")
setwd("~/iba/crimes_data/")
filename = "CrimeSample.csv"

crData <- read.csv(filename)

setWeights <- crData$weight

dt <- crData$timestamp
addrStr <- as.character(crData$addresss)

crimeTypes <- as.character(crData$category)
stopifnot( class(crimeTypes) == "character" )
tt <- table(crimeTypes)
plot(tt)

#####################################
loc <- crData$location

desc <- as.character(crData$descript)
table(desc)
#####################################

library(plyr)
# Equivalent to as.data.frame(table(df))
freq.crimeTypes <- count(crData, vars = "crimeTypes")
stopifnot( sum(freq.crimeTypes$freq) == nrow(crData) )

#freq.descs <- count(crData, vars = "desc")



