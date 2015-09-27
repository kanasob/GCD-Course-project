---
title: "CodeBook"
author: "KanakoSobajima"
date: "26 September 2015"
output: html_document
---
# Getting and Cleaning Data Course Project
## Project overview
### Goal
To prepare tidy data that can be used for later analysis

### Requirement
1) a tidy data set as a txt file created with write.table() using row name = FALSE,  
2) a link to a Github pository with your script for performing the analysis,  
3) a code book that describes the variables, the data, and any transformations or work performed to clean up the data (CodeBook.md),  
4) a README.md in the repository,  
5) a R script in the repository (run_analysis.R)  

### Dataset
Data collected from the accelerometers from the Samsung Galaxy S smartphone. For details, see the following link:  
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The link to the data for the project:  
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

### Requirement for R script  
The R script should perform the following questions:  
Q1. Merges the training and the test sets to create one data set.  
Q2. Extracts only the measurements on the mean and standard deviation for each measurement.  
Q3. Changes the name of the activities in the dataset to descriptive name  
Q4. Appropriately labels the data set with descriptive variable names.  
Q5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Script
This is a brief description about "run_analysis.R".   
For the full script and the result of each script described below, please run "run_analysis.R"  

#### 1. Download a file to the `Project` folder from the link and unzip it
```{r eval=FALSE}
if(!file.exists("./Project"))
  (dir.create("./Project"))
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile = "./project/getdata-projectfiles-UCI HAR Dataset.zip")
unzip(zipfile = "./Project/getdata-projectfiles-UCI HAR Dataset.zip", exdir="./Project")
```


#### 2. Check the files in the UCI HAR Dataset folder (`directory`) 
```{r eval=FALSE}
directory <- getwd()
directory
files <-list.files(directory, recursive = TRUE)
files 
```


The UCI HAR Dataset contains the following files:  

**Project overview and methodology**  
`README.txt` : project overview   
`features_info.txt` : methodology in details   

**Variables**  
`activity_labels.txt`  : the list of six activities assessed  
`features.txt`: the list of all features     

**Data**   
*per feature*  
`test/X_test.txt`; `train/X_train.txt`   
*per activity*  
`test/y_test.txt` ; `train/y_train.txt`  
*per subject (volunteer)* (total: 30 volunteers (21 volunteers generate training data; 9 volunteers generate testdata ))  
`test/subject_test.txt` ; `train/subject_train.txt`   
*Internal sensor data (19 files)* : data obtained from all the performed activities (not used for this project)  


#### 3. (Q1) Create one data set  
#####Process  

1.**Combine training and test data sets per category (`Activity`, `Subject` and `Feature`)**  

+ Read the `train` and `test` files (`read.table()`),   
+ Check the data structure of the files (`str()`)  
+ Combine training and test data in the files with `rbind()` (`AllActivty`, `AllSubject`, `AllFeature`)  
+ Assign the variable names to the combined data set  

*Example: Activity (Note: the same process applies for Subject)*

+ Read the files    
```{r eval=FALSE}
TestActivity <- read.table ("test/y_test.txt", header = FALSE)
TrainActivity <- read.table ("train/y_train.txt", header = FALSE)
```

+ Check the data structure of the files   
```{r eval=FALSE}
str(TestActivity)
str (TrainActivity)  
```


+ Add the test data to the train data  
```{r eval=FALSE}
allActivity <- rbind(TrainActivity, TestActivity)
```

+ Assign variable name  
```{r eval=FALSE}
colnames(allActivity) <- "activity"
```

+ Check the data structure      
```{r eval=FALSE}
str(allActivity)
```


*Example: Feature*  
Apply the above process from reading files to combining data, then  

+ Assign variable name   
```{r eval=FALSE}
Varnames <- read.table ("features.txt", header = FALSE, stringsAsFactors = FALSE)
colnames (allFeature) <-t(Varnames[2])
```

2.**Combine (merge) all three data set (allActivity, allSubject and allFeature) with `cbind`**
```{r eval=FALSE}
SubAct <- cbind(allSubject, allActivity)
Alldata <- cbind(allFeature,SubAct)
```

*Check the new data set (`Alldata`):*  
```{r, eval=FALSE}
str(Alldata)
```
The result should start with `'data.frame':	10299 obs. of  563 variables:` and a list of variables with class and data starting from `$ tBodyAcc-mean()-X` .  


#### 4. (Q2) Show only the measurement on the mean and standard deviation (std) for each measurement

*I assumed that this question meant to say that "show the variable names (measurement) contain "mean" or "std"* 


**Show the column names (variables) that contain `mean` or `std` with `grep ()`**

```{r, eval=FALSE}
varmeanstd <- grep("mean|std", Varnames$V2, ignore.case = TRUE, value=TRUE)
```


*Check the changes made:* 
```{r, eval=FALSE}
str(varmeanstd)
```

The result should be shown in one line with `char [1:86]  "tBodyAcc-mean()-X"` ... .    


#### 5. (Q3) Use descriptive activity names to name the activities in the data set

1. **read the `activity_labels.txt` file**

```{r, eval=FALSE}
activity <- read.table ("activity_labels.txt", header = FALSE, stringsAsFactors = FALSE) 
```


2. **change the data in `Alldata` with the following function**

```{r, eval=FALSE}
for (i in 1:6)
  {
  Alldata$activity[Alldata$activity == i] <- activity[i,2]
}
```

*Check the changes made:* 
```{r, eval=FALSE}
head(Alldata,3)
```
The result should show three valuse (`STANDING`) in the `activity` column.  


#### 6.(Q4) Appropriately labels the dataset with discriptive varialbe names

1. **Check the current variable names in `Alldata`**
```{r, eval=FALSE}
names(Alldata)
```


2. **Replace the variable names with `gsub()`**    

From the output, the following names can be replaced:   

+ `t` to "Time""  
+ `f` to "Frequency"  
+ `AccMean` to "Accelerometer-mean()"   
+ `Acc` to "Accelerometer"  
+ `JerkMean` to "Jerk-mean()"  
+ `GyroMean` to "Gyroscope-mean()"
+ `Gyro` to "Gyroscope"
+ `gravityMean` to "Gravity-mean()"
+ `maxInds` to "maxInds()"
+ `Mag` to "Magnitude"
+ `BodyBody` to "Body"

by using `gsub()`. for example...

```{r, eval=FALSE}
names(Alldata) <- gsub("^t", "Time", names(Alldata))

names(Alldata) <- gsub("BodyBody", "Body", names(Alldata))

```

*Check the changes made:* 
```{r, eval=FALSE}
names(Alldata)
```
The result should show 563 rows of the new variable names starting from `"TimeBodyAccelerometer-mean()-X"`.  


#### 6.(Q5) With the dataset created in Q4,create a second, independent tidy dataset with average of each variable for each activity and each subject

**Using the plyr package, aggregate the data by subject and then by activity** 
```{r, eval=FALSE}
library (plyr)
Alltidydata <- aggregate(. ~subject + activity, Alldata, mean)
Alltidydata <- Alltidydata[order(Alltidydata$subject, Alltidydata$activity),]
```



*Check the result:* 
```{r, eval=FALSE}
head(Alltidydata,3)
```
The result should show the values in the first three rows (1,31,61) with variable names from `subject` to `angle(Z,Gravity-mean())`   

#### Save the results in the txt format
```{r, eval=FALSE}
write.table(Alltidydata, file="tidydata.txt", row.names = FALSE)
```
