##download a file, save it in the project folder and unzip it
if(!file.exists("./Project"))
  (dir.create("./Project"))
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile = "./project/getdata-projectfiles-UCI HAR Dataset.zip")
unzip(zipfile = "./Project/getdata-projectfiles-UCI HAR Dataset.zip", exdir="./Project")

## Check what are in the UCI HAR Dataset folder 
directory <- getwd()
directory
files <-list.files(directory, recursive = TRUE)
files 

## Project info
## [4] "README.txt": Project overview
## [3] "features_info.txt" : project methodology in details  

## variables
## [1] "activity_labels.txt"  : the list of assessed (six) activities
## [2] "features.txt": sample data 
## (volunteers (total = 30 volunteers (70%: train; 30%:test))


## data 
## per feature  
## [15] "test/X_test.txt" 
## [27] "train/X_train.txt" 
## per activity
## [16] "test/y_test.txt"    
## [28] "train/y_train.txt"
## per subject (data point)
## [14] "test/subject_test.txt"
## [26] "train/subject_train.txt" 
## per subject by each feature
## [5] "test/Inertial Signals/body_acc_x_test.txt"   
## [6] "test/Inertial Signals/body_acc_y_test.txt"   
## [7] "test/Inertial Signals/body_acc_z_test.txt"   
## [8] "test/Inertial Signals/body_gyro_x_test.txt"  
## [9] "test/Inertial Signals/body_gyro_y_test.txt"  
## [10] "test/Inertial Signals/body_gyro_z_test.txt"  
## [11] "test/Inertial Signals/total_acc_x_test.txt"  
## [12] "test/Inertial Signals/total_acc_y_test.txt"  
## [13] "test/Inertial Signals/total_acc_z_test.txt"  
## [17] "train/Inertial Signals/body_acc_x_train.txt" 
## [18] "train/Inertial Signals/body_acc_y_train.txt" 
## [19] "train/Inertial Signals/body_acc_z_train.txt" 
## [20] "train/Inertial Signals/body_gyro_x_train.txt"
## [21] "train/Inertial Signals/body_gyro_y_train.txt"
## [22] "train/Inertial Signals/body_gyro_z_train.txt"
## [23] "train/Inertial Signals/total_acc_x_train.txt"
## [24] "train/Inertial Signals/total_acc_y_train.txt"
## [25] "train/Inertial Signals/total_acc_z_train.txt"


## Q1. Combine training and test dataset (rbind)

## Activity
### Read files
TestActivity <- read.table ("test/y_test.txt", header = FALSE)
TrainActivity <- read.table ("train/y_train.txt", header = FALSE)

### check data structure
str(TestActivity)
str (TrainActivity)

### add (merge) test to train
allActivity <- rbind(TrainActivity, TestActivity)

### Assign variable name
colnames(allActivity) <- "activity"

str(allActivity)

## Subject
### Read files
TestSubject <- read.table ("test/subject_test.txt", header = FALSE)
TrainSubject <- read.table ("train/subject_train.txt", header = FALSE)

### check data structure
str(TestSubject)
str (TrainSubject)

### add (merge) test to train
allSubject <- rbind(TrainSubject, TestSubject)

### Assign variable name
colnames(allSubject) <- "subject"

str(allSubject)

## Feature
### Read files
TestFeature <- read.table ("test/X_test.txt", header = FALSE)
TrainFeature <- read.table ("train/X_train.txt", header = FALSE)

### check data structure
str(TestFeature)
str (TrainFeature)

### add (merge) test to train
allFeature <- rbind(TrainFeature,TestFeature)

### Assign variable name by tranposing V2
Varnames <- read.table ("features.txt", header = FALSE, stringsAsFactors = FALSE)
colnames (allFeature) <-t(Varnames[2])

str(allFeature)

## Combine (merge) all three variables (Activity, Subject and Feature)
SubAct <- cbind(allSubject, allActivity)
Alldata <- cbind(allFeature,SubAct)
str(Alldata)


## Q2 Display only the measurement on the mean and standard deviation (std) 
## for each measurement

### I assume this question meant to show the variable names (measurement) 
## that contain "mean" or "std"

varmeanstd <- grep("mean|std", Varnames$V2, ignore.case = TRUE, value=TRUE)
str(varmeanstd)

##Q3 Use descriptive activity names to name the activities in the dataset
activity <- read.table ("activity_labels.txt", header = FALSE, stringsAsFactors = FALSE) 
str (activity)
for (i in 1:6)
  {
  Alldata$activity[Alldata$activity == i] <- activity[i,2]
  }
head(Alldata,3)

##Q4 Appropriately labels the dataset with discriptive varialbe names

names(Alldata)

#### Change "t" to "Time"
names(Alldata) <- gsub("^t", "Time", names(Alldata))

#### Change "f" to "Frequency"
names(Alldata) <- gsub("^f", "Frequency", names(Alldata))

### Change "AccMean" to "Accelerometer-mean()"
names(Alldata) <- gsub("AccMean", "Accelerometer-mean()", names(Alldata))

### Change "Acc" to "Accelerometer"
names(Alldata) <- gsub("Acc", "Accelerometer", names(Alldata))

### Change "JerkMean" to "Jerk-mean()"
names(Alldata) <- gsub("JerkMean", "Jerk-mean()", names(Alldata))

### Change "GyroMean" to "Gyroscope-mean()"
names(Alldata) <- gsub("GyroMean", "Gyroscope-mean()", names(Alldata))

### Change "Gyro" to "Gyroscope"
names(Alldata) <- gsub("Gyro", "Gyroscope", names(Alldata))

#### Change "gravityMean" to "Gravity-mean()"
names(Alldata) <- gsub("gravityMean", "Gravity-mean()", names(Alldata))

#### Change "maxInds" to "maxInds()"
names(Alldata) <- gsub("maxInds", "maxInds()", names(Alldata))

### Change "Mag" to "Magnitude"
names(Alldata) <- gsub("Mag", "Magnitude", names(Alldata))

#### Change "BodyBody" to "Body"
names(Alldata) <- gsub("BodyBody", "Body", names(Alldata))

names(Alldata)

## Q5 With the dataset created in Q4,
## create a second, independent tidy dataset  
## with average of each variable 
## for each activity and each subject

library (plyr)
Alltidydata <- aggregate(. ~subject + activity, Alldata, mean)
Alltidydata <- Alltidydata[order(Alltidydata$subject, Alltidydata$activity),]
head(Alltidydata,3)

###saved the results in the txt format
write.table(Alltidydata, file="tidydata.txt", row.names = FALSE)

