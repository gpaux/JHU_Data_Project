# Course 03 Project ----
## Load the library
library(dplyr)

## Download the data and unzip it to get a list of the files contained in it ----
filename <- "data.zip"
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
  unzip("data.zip", list=TRUE)
}

## Get the test dataset ----
### Subject dataset
subject_test <- read.table(unz("data.zip", "UCI HAR Dataset/test/subject_test.txt")) %>% 
  rename(subjid = V1)
### Data dataset
X_test <- read.table(unz("data.zip", "UCI HAR Dataset/test/X_test.txt"))
### Activity dataset
y_test <- read.table(unz("data.zip", "UCI HAR Dataset/test/y_test.txt")) %>% 
  rename(idactivity = V1)
### Bind all datasets
dtaTest <- cbind(subject_test, y_test, X_test)

## Get the training dataset ----
### Subject dataset
subject_train <- read.table(unz("data.zip", "UCI HAR Dataset/train/subject_train.txt")) %>% 
  rename(subjid = V1)
### Data dataset
X_train <- read.table(unz("data.zip", "UCI HAR Dataset/train/X_train.txt"))
### Activity dataset
y_train <- read.table(unz("data.zip", "UCI HAR Dataset/train/y_train.txt")) %>% 
  rename(idactivity = V1)
### Bind all datasets
dtaTrain <- cbind(subject_train, y_train, X_train)

## Create the full dataset  ----
### Merge the test and training datasets ----
dta <- rbind(dtaTest, dtaTrain)

### Assign variable names ----
columnNames <- read.table(unz("data.zip", "UCI HAR Dataset/features.txt"))
colnames(dta)[-(1:2)] <- columnNames[,2]

## Extracts only the measurements on the mean and standard deviation for each measurement ----
dtaMeanSd <- dta %>% 
  select(contains(c("subjid", "idactivity","mean()","std()")))

## Uses descriptive activity names to name the activities in the data set ----
### Get the activity id and label ----
activityNames <- read.table(unz("data.zip", "UCI HAR Dataset/activity_labels.txt")) %>% 
  rename(idactivity = V1,
         activity = V2)
### Merge the activity dataset with the previous dataset to get the activity variable with the label ----
dtaMeanSd <- dtaMeanSd %>% 
  merge(., activityNames, by = "idactivity") %>% 
  select(-idactivity)

# Create more intuitive variable name
colnames(dtaMeanSd) <- gsub("std\\(\\)", "Std", colnames(dtaMeanSd))
colnames(dtaMeanSd) <- gsub("mean\\(\\)", "Mean", colnames(dtaMeanSd))
colnames(dtaMeanSd) <- gsub("^t", "time", colnames(dtaMeanSd))
colnames(dtaMeanSd) <- gsub("^f", "frequency", colnames(dtaMeanSd))
colnames(dtaMeanSd) <- gsub("Acc", "Accelerometer", colnames(dtaMeanSd))
colnames(dtaMeanSd) <- gsub("Gyro", "Gyroscope", colnames(dtaMeanSd))
colnames(dtaMeanSd) <- gsub("Mag", "Magnitude", colnames(dtaMeanSd))
colnames(dtaMeanSd) <- gsub("BodyBody", "Body", colnames(dtaMeanSd))
colnames(dtaMeanSd) <- gsub("-", "", colnames(dtaMeanSd))

# Create tidy data set with the average of each variable for each activity and each subject ----
dtaSummary <- dtaMeanSd %>% 
  group_by(subjid, activity) %>% 
  summarize_all(mean)

# Extract the final dataset 
write.table(dtaSummary, file = "dtaSummary.txt", row.name=FALSE)  
