A more detailed explanation of each step used in the run_analysis.R file to create the final dataset is provided below.

## Initialization

First step is to load the libraries to use for this project, download the dataset and have a quick look at the zip structure

```{r}
# Course 03 Project ----
## Load the library
library(dplyr)

## Download the data ----
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "data.zip")
unzip("data.zip", list=TRUE)
```

## Merges the training and the test sets to create one data set

First, we are going to load the test datasets in our environment and assigned them to R objects.
```{r}
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
```
- `subject_test` will contain the test dataset for the subject
- `X_test` will contain the test dataset for the daata.
- `y_test` will contain the test dataset for the activity

Finally we will bind by columns these three datasets to obtain our test dataset assigned to the `dtaTest` object.

Then, we are going to load the training datasets in our environment and assigned them to R objects.

```{r}
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
```

- `subject_train` will contain the training dataset for the subject
- `X_train` will contain the training dataset for the daata.
- `y_train` will contain the training dataset for the activity

Finally we will bind by columns these three datasets to obtain our training dataset assigned to the `dtaTrain` object.

Eventually, we can bind the test and train datasets together into an R object named `dta`. The binding will be done by row.

```{r}
## Create the full dataset  ----
### Merge the test and training datasets ----
dta <- rbind(dtaTest, dtaTrain)
```

## Extracts only the measurements on the mean and standard deviation for each measurement

To extract only the measurements on the mean and standard deviation for each measurement, we have to select only the variable names containing mean and std. The first step is then to assign names to each variable. Therefore, we will first extract the column names from the `features.txt` file and assigned them to the `columnNames` R object. Then we can change the column names of the `dta` object.

```{r}
### Assign variable names ----
columnNames <- read.table(unz("data.zip", "UCI HAR Dataset/features.txt"))
colnames(dta)[-(1:2)] <- columnNames[,2]
```

Finally, we can now select only the variable with the mean and sd and create the `dtaMeanSd` dataset.

```{r}
## Extracts only the measurements on the mean and standard deviation for each measurement ----
dtaMeanSd <- dta %>% 
  select(contains(c("subjid", "activity","mean()","std()")))
```

## Uses descriptive activity names to name the activities in the data set

The first step is to load the dataset containing the activity id and label. This dataset is located in the `activity_labels.txt` file and will be assigned to the `activityNames` R object.

```{r}
## Uses descriptive activity names to name the activities in the data set ----
### Get the activity id and label ----
activityNames <- read.table(unz("data.zip", "UCI HAR Dataset/activity_labels.txt")) %>% 
  rename(idactivity = V1,
         activity = V2)
```

Then we can merge this dataset (`activityNames`) with the previous dataset (`dtaMeanSd`) in order to get a variable named `activityNames` which will contain the label of the activity. We can remove the `idactivity` which is now not useful.

```{r}
### Merge the activity dataset with the previous dataset to get the activity variable with the label ----
dtaMeanSd <- dtaMeanSd %>% 
  merge(., activityNames, by = "idactivity") %>% 
  select(-idactivity)
```

## Appropriately labels the data set with descriptive variable names.

We are going to change the name of the variable with more descriptive variable names, remove the parenthesis and dash.
```{r}
# Create more intuitive variable name
colnames(dtaMeanSd) <- gsub("-", "", colnames(dtaMeanSd))
colnames(dtaMeanSd) <- gsub("std\\(\\)", "Std", colnames(dtaMeanSd))
colnames(dtaMeanSd) <- gsub("mean\\(\\)", "Mean", colnames(dtaMeanSd))
colnames(dtaMeanSd) <- gsub("^t", "time", colnames(dtaMeanSd))
colnames(dtaMeanSd) <- gsub("^f", "frequency", colnames(dtaMeanSd))
colnames(dtaMeanSd) <- gsub("Acc", "Accelerometer", colnames(dtaMeanSd))
colnames(dtaMeanSd) <- gsub("Gyro", "Gyroscope", colnames(dtaMeanSd))
colnames(dtaMeanSd) <- gsub("Mag", "Magnitude", colnames(dtaMeanSd))
colnames(dtaMeanSd) <- gsub("BodyBody", "Body", colnames(dtaMeanSd))
```
## From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

To create a second, independent tidy data set with the average of each variable for each activity and each subject, we have first to group by subjid and activity, and then calculate the mean of each remaining variable. The new summary dataset will be assigned to the `dtaSummary` R object.

```{r}
# Create tidy data set with the average of each variable for each activity and each subject ----
dtaSummary <- dtaMeanSd %>% 
  group_by(subjid, activity) %>% 
  summarize_all(mean)
```
## Data extraction

Finally, the `dtaSummary` dataset is saved in the `dtaSummary.csv` file.

```{r}
# Extract the final dataset 
write.csv(dtaSummary, file = "dtaSummary.csv")
```