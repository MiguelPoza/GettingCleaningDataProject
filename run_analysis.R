## Read the file Readme.md for any question. 

## Step 1 Merges the training and the test sets to create one data set.

## Read the files with the help of data.table package
## the path are relative

library(data.table)
subject_train <- fread("./data/UCI HAR Dataset/train/subject_train.txt")
Y_train <- fread("./data/UCI HAR Dataset/train/y_train.txt")
X_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt",  strip.white=TRUE)
subject_test <- fread("./data/UCI HAR Dataset/test/subject_test.txt")
Y_test <- fread("./data/UCI HAR Dataset/test/y_test.txt")
X_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt",  strip.white=TRUE)

## use cbind and rbind to make just one file
test = cbind(subject_test,Y_test,X_test)
train = cbind (subject_train, Y_train, X_train)
DF = rbind(test, train)

## remove the unuseful files
rm(subject_train, Y_train, X_train, subject_test, Y_test, X_test, test, train)

##Extracts only the measurements on the mean and standard deviation for each measurement. 

features <- fread("./data/UCI HAR Dataset/features.txt")
colnames(DF) <- c("subject", "activity", features$V2)
var_ext <-c(1, 2, grep("(mean\\(\\))|(std\\(\\))", names(DF))) 
#cols 1 & 2 are subject and activity and only mean(), discard freqmean() and final variables
DF_little <- subset(DF, select=var_ext)
rm(DF)

##Uses descriptive activity names to name the activities in the data set
activs <- fread("./data/UCI HAR Dataset/activity_labels.txt")
DF_little$activity <- as.character(DF_little$activity)
for (i in activs$V1){
     DF_little$activity[DF_little$activity==i]<- activs$V2[i]
}
DF_little$activity <- as.factor(DF_little$activity)
 


##Appropriately labels the data set with descriptive variable names. 
labels <- gsub("(\\()|(\\))|(-)","",colnames(DF_little)) ## remove this characteres
labels <- tolower(labels)
colnames(DF_little) <- labels


##Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
## I use the plyr package to generate the data set.
library(plyr)
tinyDF <- ddply(DF_little, c("activity", "subject"), numcolwise(mean))
write.table(tinyDF, "TinyDataSet.txt", row.names=FALSE)
