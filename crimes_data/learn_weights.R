# *------------------------------------------------------------------
# | PROGRAM NAME: learn_weights.R
# | DATE: 05/28/2015
# | CREATED BY: Narek Tovmasyan (Team IBA)
# | PROJECT FILE: PARQ
# *---------------------------------------------------


# Corresponds to the GitHub repo structure @ https://github.com/cs210/iba
setwd("~/iba/crimes_data/")

crTable <- read.table("crimes_1_10000.csv")

setwd("~/Desktop/CS 210/")
# Or, set it to the folder where the CSV file with a large number of crimes is
crTable1 <- read.table("crimes_10001_50000.csv")

crime.table.all <- rbind(crTable, crTable1)

crTable <- crime.table.all



########## Crime Type/Category (ct) Frequency Analysis ##########

ct.table <- table(crTable$category)
stopifnot( sum(ct.table) == dim(crTable)[1] )
ct.descending <- sort(ct.table, decreasing = T)
ct.df <- as.data.frame(ct.descending)
colnames(ct.df) = "Crime Type Freq."

m = nrow(ct.df)
print( paste("There are found to be a total of", m, "crime types!") )

############### Establishing The Benchmark ###############
subset(ct.df, `Crime Type Freq.` == 1)
subset(ct.df, `Crime Type Freq.` > 1 & `Crime Type Freq.` < 10)
subset(ct.df, `Crime Type Freq.` >= 10 & `Crime Type Freq.` < 100)
subset(ct.df, `Crime Type Freq.` >= 100 & `Crime Type Freq.` < 1000)
subset(ct.df, `Crime Type Freq.` >= 1000)



########## Crime Address/Location Frequency Analysis ##########

####
# Computes the crime frequency of each unique location and displays the
# supplied number of top (higher-frequency) ones, after sorting.
#
# @param crimeSpreadSheet: data frame, each row describing a crime incident.
# @param addr.geoloc.toggle: character, to switch between address and geo-location.
# @param headCount: integer, the # of top "hot" addresses/geo-locations for crime.
#
# @return: data frame, the whole, sorted crime location - crime frequency table.
#
# @examples
# CrimeFreqBy(crimesCSV, "location", 5)
##
CrimeFreqBy <- function(crimeSpreadSheet, addr.geoloc.toggle = "address", headCount = 25) {
  if (addr.geoloc.toggle == "address") {
    caddr.table <- table(crimeSpreadSheet$address)
  } else if (addr.geoloc.toggle == "location") {
    cloc.table <- table(crimeSpreadSheet$location)
  }
  print("Counts for total crime incidents per unique address/location:")
  if (addr.geoloc.toggle == "address" ) {
    print( dim(caddr.table) )
  } else if (addr.geoloc.toggle == "location") {
    print( dim(cloc.table) )
  }
  
  if (addr.geoloc.toggle == "address" ) {
    caddr.descending <- sort(caddr.table, decreasing = T)
    caddr.df <- as.data.frame(caddr.descending)
    colnames(caddr.df) = "Crime Address Freq."
  } else if (addr.geoloc.toggle == "location") {
    cloc.descending <- sort(cloc.table, decreasing = T)
    cloc.df <- as.data.frame(cloc.descending)
    colnames(cloc.df) = "Crime Location Freq."
  }
  
  print( paste("Showing top", headCount, "addresses/locations by crime frequency:") )
  if (addr.geoloc.toggle == "address" ) {
    print( head(caddr.df, headCount) )
    caddr.df
  } else if (addr.geoloc.toggle == "location") {
    print( head(cloc.df, headCount) )
    cloc.df
  }
}

caddr.df <- CrimeFreqBy(crTable, "address", 10)



########## Converthing Into Probabilities Crime-Category-Wise ##########

n = nrow(caddr.df)
N = sum(caddr.df)
probability.any.incident <- caddr.df / N

# Now, address- / location-based probability calculations for every crime type..

####
# Estimates all the recognized crime types' probabilities for the given address.
#
# @param singleAddr: "named" integer, a single address + crimes' count.
#
# @return: table, having a probability value for each crime type.
# @note: These are joint probability values, not conditional probabilities!
#
# @examples
# ProbsOfAllTypes(caddr.df[7, ])
##
ProbsOfAllTypes <- function(singleAddr) {
  singleAddr <- names(singleAddr)
  ss.in.addr <- subset(crTable, address == singleAddr)

  # Confirming it keeps all the (crime) factor levels..
  stopifnot( length( levels(ss.in.addr$category) ) == m )

  tt <- table(ss.in.addr$category)
  # Doing Laplace smoothing..
  probs.crime.types <- (tt + 1) / (sum(tt) + m)

  # Ensuring these are valid probability values..
  #stopifnot( sum(probs.crime.types) == 1 )

  probOfAnything <- probability.any.incident[singleAddr, ]
  names(probOfAnything) = NULL

  # Reporting all crime-type probabilities for this single address:
  pTable <- probOfAnything * probs.crime.types
  pTable
}


allAddresses = rownames(caddr.df)
allCrimeTypes = rownames(ct.df)
all.addr.all.crimes = matrix(nrow = n, ncol = m, 
                             dimnames = list(allAddresses, allCrimeTypes))
for (idx in 1:n) {
  currRow = caddr.df[idx, ]
  all.addr.all.crimes[idx, ] <- ProbsOfAllTypes(currRow)
}
all.addr.all.crimes


likelihoods.crime.category <- apply(all.addr.all.crimes, 2, mean)
crimeCategChances <- sort(likelihoods.crime.category, decreasing = T)
likelihoods.crime.type <- as.data.frame(crimeCategChances)
names(likelihoods.crime.type) <- "Likelihood of Crime Type"

total <- sum(likelihoods.crime.type)
crime.types.aggregate.probs <- likelihoods.crime.type / total
stopifnot( sum(crime.types.aggregate.probs) == 1 )
names(crime.types.aggregate.probs) <- "Probability of Crime Type"

# Write to disk, locally!
setwd("~/Desktop/CS 210/")
write.table(crime.types.aggregate.probs, file = "aggregateChanceOfEveryCrimeType.csv")


####
# Determines (on the scale 1 through 10) the "weight" of each crime type,
# higher value denoting a more dangerous crime.
#
# @param overallChanceOfEveryCrimeType: data frame, self-explanatory.
#
# @return: table, having a net weight value (crime score) for each crime type.
##
WeighEachCrimeType <- function(overallChanceOfEveryCrimeType) {
  # So called un-likelihood (seriousness) of each crime..
  # We achieve that by inverting the probability values:
  inverseProbs <- 1 / overallChanceOfEveryCrimeType
  names(inverseProbs) <- "Seriousness of Crime"

  lhOfRange <- as.numeric( head(inverseProbs, 1) )
  rhOfRange <- as.numeric( tail(inverseProbs, 1) )
  rangeSize <- rhOfRange - lhOfRange

  # the size of each weight "step" (in the scale of 1 through 10)..
  stepsize = rangeSize / 9
  weights <- 1 + (inverseProbs - lhOfRange) / stepsize
  names(weights) <- "Weight of Crime Type"
  weights
}
learnedWeights <- WeighEachCrimeType(crime.types.aggregate.probs)

#write.table(learnedWeights, file = "~/iba/crimes_data/learnedWeights.csv")













#################### CLUSTERING METHOD ####################

# Now we define 3 clusters / high-level "categories" of crime types 
# on which to do the samy probabilistic method-based weight estimation, individually..

category.I <- c("SEX OFFENSES, FORCIBLE", "KIDNAPPING", "ARSON", "ASSAULT", "WEAPON LAWS", "ROBBERY")
category.II <- c("MISSING PERSON", "SUSPICIOUS OCC", "BURGLARY", "VEHICLE THEFT", "FAMILY OFFENSES", "SEX OFFENSES, NON FORCIBLE", "TRESPASS", "STOLEN PROPERTY", "DRIVING UNDER THE INFLUENCE", "RUNAWAY", "LARCENY/THEFT", "OTHER OFFENSES")
category.III <- c("WARRANTS", "VANDALISM", "DRUG/NARCOTIC", "SECONDARY CODES", "PORNOGRAPHY/OBSCENE MAT", "TREA", "GAMBLING", "LIQUOR LAWS", "LOITERING", "DRUNKENNESS", "PROSTITUTION", "DISORDERLY CONDUCT", "NON-CRIMINAL")

#stopifnot( length(category.I) + length(category.II) + length(category.III) == nrow(ct.df) )
allClustered <- c(category.I, category.II, category.III)
crimeTypes.leftout = setdiff(allCrimeTypes, allClustered)
crimeTypes.extra = setdiff(allClustered, allCrimeTypes)
stopifnot( crimeTypes.extra == character(length=0) )

if (! identical(crimeTypes.leftout, character(0)) ) {
  for (ct in crimeTypes.leftout) {
    # for each, we expand the corresponding category/cluster,
    # according to that crime type frequency..
    freq <- ct.df[ct,]
    if (freq < 100) {
      category.I <- c(ct, category.I)
    } else if (freq < 1000) {
      category.II <- c(ct, category.II)
    } else {
      category.III <- c(ct, category.III)
    }
  }
}

print( paste("There are", length(category.I), "crime types of high-level Category I..") )
print( paste("There are", length(category.II), "crime types of high-level Category II..") )
print( paste("There are", length(category.III), "crime types of high-level Category III..") )



ct.array.I <- ct.df[category.I, ]
ct.sorted.I <- sort(ct.array.I, decreasing = T)
ct.df.I <- as.data.frame(ct.sorted.I)
colnames(ct.df.I) = "Crime Type Freq."

ct.array.II <- ct.df[category.II, ]
ct.sorted.II <- sort(ct.array.II, decreasing = T)
ct.df.II <- as.data.frame(ct.sorted.II)
colnames(ct.df.II) = "Crime Type Freq."

ct.array.III <- ct.df[category.III, ]
ct.sorted.III <- sort(ct.array.III, decreasing = T)
ct.df.III <- as.data.frame(ct.sorted.III)
colnames(ct.df.III) = "Crime Type Freq."






############### Crime Description (cd) Freq. Analysis ###############

cd.table <- table(crTable$descript)
dim(cd.table) # hence:
cd.table[order(cd.table)]

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


