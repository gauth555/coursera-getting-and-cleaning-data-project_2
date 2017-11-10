library(reshape2)

fname <- "getdata_dataset.zip"

## Downloading and preparing the files 

## Download and unzip the DS:
if (!file.exists(fname)){
  URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(URL, fname)
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(fname) 
}

# Load activity labels and ftres
activity <- read.table("UCI HAR Dataset/activity_labels.txt")
activity[,2] <- as.character(activity[,2])
ftres <- read.table("UCI HAR Dataset/features.txt")
ftres[,2] <- as.character(ftres[,2])

# Extract the data based on mean and standard deviation
ftresWanted <- grep(".*mean.*|.*std.*", ftres[,2])
ftresWanted.names <- ftres[ftresWanted,2]
ftresWanted.names = gsub('-mean', 'Mean', ftresWanted.names)
ftresWanted.names = gsub('-std', 'Std', ftresWanted.names)
ftresWanted.names <- gsub('[-()]', '', ftresWanted.names)


# Loading DS
trn <- read.table("UCI HAR Dataset/train/X_train.txt")[ftresWanted]
trnActivities <- read.table("UCI HAR Dataset/train/y_train.txt")
trnSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
trn <- cbind(trnSubjects, trnActivities, trn)

tst <- read.table("UCI HAR Dataset/test/X_test.txt")[ftresWanted]
tstActivities <- read.table("UCI HAR Dataset/test/y_test.txt")
tstSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
tst <- cbind(tstSubjects, tstActivities, tst)

# Merging DS & Adding Labels
aDta <- rbind(trn, tst)
colnames(aDta) <- c("subject", "activity", ftresWanted.names)

# Turning Activities & Subjects into factors
aDta$activity <- factor(aDta$activity, levels = activity[,1], labels = activity[,2])
aDta$subject <- as.factor(aDta$subject)

aDta.melted <- melt(aDta, id = c("subject", "activity"))
aDta.mean <- dcast(aDta.melted, subject + activity ~ variable, mean)

write.table(aDta.mean, "tidy.txt", row.names = FALSE, quote = FALSE)