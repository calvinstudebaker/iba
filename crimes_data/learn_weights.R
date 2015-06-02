# Author: Narek Tovmasyan (Team IBA)
# Date: 05/28/2015


setwd("~/iba/crimes_data/")


########## Crime Description (cd) Freq. Analysis ###############

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





setwd("~/iba/crimes_data/")
crTable <- read.table("crimes_1_10000.csv")

setwd("~/Desktop/CS 210/")
crTable1 <- read.table("crimes_10001_50000.csv")
crimeTabular.all <- rbind(crTable, crTable1)

crTable <- crimeTabular.all

########## Crime Type/Category (ct) Freq. Analysis ###############

ct.table <- table(crTable$category)
stopifnot( sum(ct.table) == dim(crTable)[1] )
ct.descending <- sort(ct.table, decreasing = T)
ct.df <- as.data.frame(ct.descending)
colnames(ct.df) = "Crime Type Freq."

print( paste("There are found to be a total of", nrow(ct.df), "crime types!") )

############################ The BENCHMARK #######################
subset(ct.df, `Crime Type Freq.` == 1)
subset(ct.df, `Crime Type Freq.` > 1 & `Crime Type Freq.` < 10)
subset(ct.df, `Crime Type Freq.` >= 10 & `Crime Type Freq.` < 100)
subset(ct.df, `Crime Type Freq.` >= 100 & `Crime Type Freq.` < 1000)
subset(ct.df, `Crime Type Freq.` >= 1000)



########## Crime Address/Location Freq. Analysis ###############

crime.freq.by <- function(crimeSpreadSheet, addr.geoloc.toggle = "address", headCount = 25) {
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

caddr.df <- crime.freq.by(crTable, "address", 10)

########## Converthing Into Probabilities crime-category-wise ###############

N = nrow(caddr.df)
probability.any.incident <- caddr.df / N

# Now, address-/location-based prob. calc.'s for every crime type..
#singleAddr <- caddr.df[93,]

all.types.Probs <- function(singleAddr) {
  singleAddr <- names(singleAddr)
  ss.in.addr <- subset(crTable, address == singleAddr)

  # Confirming it keeps all the (crime) factor levels..
  length( levels(ss.in.addr$category) ) == nrow(ct.df)
  m = nrow(ct.df)

  tt <- table(ss.in.addr$category)
  # Doing Laplace smoothing..
  probs.crime.types <- (tt + 1) / (sum(tt) + m)

  # Ensuring these are valid probability values..
  stopifnot( sum(probs.crime.types) == 1 )

  probOfAnything = probability.any.incident[singleAddr,]
  names(probOfAnything) = NULL

  # Finally -- reporting all crime-type prob.'s for this single address!
  pTable = probOfAnything * probs.crime.types
  pTable
}


#all.addr.all.crimes = matrix(nrow = 0, ncol = nrow(ct.df))
#apply(caddr.df, 1, function(x) {
allAddresses = rownames(caddr.df)
allCrimeTypes = rownames(ct.df)
all.addr.all.crimes = matrix(nrow = nrow(caddr.df), ncol = nrow(ct.df), 
                             dimnames = list(allAddresses, allCrimeTypes))
for (idx in 1:nrow(caddr.df)) {
  currRow = caddr.df[idx,]
  #all.addr.all.crimes <- rbind(all.addr.all.crimes, all.types.Probs(x))
  all.addr.all.crimes[idx,] <- all.types.Probs(currRow)
}
all.addr.all.crimes


likelihoods.crime.category <- apply(all.addr.all.crimes, 2, mean)
crimeCategChances <- sort(likelihoods.crime.category, decreasing = T)
likelihoods.crime.type <- as.data.frame(crimeCategChances)
names(likelihoods.crime.type) <- "Likelihood of Crime Type"

probs.crime.type <- likelihoods.crime.type / sum(likelihoods.crime.type)
stopifnot( sum(probs.crime.type) <= 1 )
names(probs.crime.type) <- "Probability of Crime Type"

write.table(probs.crime.type, file = "probOfEveryCrimeType.csv")


# So called un-likelihood (seriousness) of each crime..
# We achieve that by inverting the probability values:
inverseProbs <- 1 / probs.crime.type
names(inverseProbs) <- "Seriousness of Crime"

lhOfRange <- as.numeric( head(inverseProbs, 1) )
rhOfRange <- as.numeric( tail(inverseProbs, 1) )
rangeSize = rhOfRange - lhOfRange

# the size of each weight "step" (in the scale of 1 through 10)..
stepsize = rangeSize / 9
weights <- 1 + (inverseProbs - lhOfRange) / stepsize
names(weights) <- "Weight of Crime Type"

write.table(weights, file = "crimeTypeWeights.csv")



