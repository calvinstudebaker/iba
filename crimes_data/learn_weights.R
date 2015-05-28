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



