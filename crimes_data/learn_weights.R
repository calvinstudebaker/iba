# Author: Narek Tovmasyan (Team IBA)
# Date: 05/28/2015


setwd("~/iba/crimes_data/")

crTable <- read.table("crimes_1_10000.csv")

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

all.addr.all.crimes = NULL
apply(caddr.df, 1, function(x) {
  all.addr.all.crimes <- rbind(all.addr.all.crimes, all.types.Probs(x))
})
all.addr.all.crimes # matrix
rownames(all.addr.all.crimes) <- NULL


probs.crime.category <- apply(all.addr.all.crimes, 2, mean)
crimeCategProbs <- sort(probs.crime.category, decreasing = T)
probs.crime.type <- as.data.frame(crimeCategProbs)





