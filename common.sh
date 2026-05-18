#!/bin/bash
START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
mkdir -p $LOGS_FOLDER
echo "script starting executing at: $(date)" | tee -a $LOG_FILE


app_setup(){
id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]
then 

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "creating roboshop user"
else 
echo  -e "systemuser roboshop already created $Y skipping $N"
fi

mkdir -p /app
VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "downloading the catalogue"


rm -rf /app/*
cd /app 

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "moving to app directory and unzip the catalogue"

}
nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling default nodejs"
    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "enabling nodejs:20"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "installing nodejs:20"
}
check_root(){
if [ $USERID -ne 0 ]
then 
echo -e "$R error:: $N please run the script with root access" | tee -a $LOG_FILE
exit 1
else
echo "your running with root access" | tee -a $LOG_FILE
fi
}

#validate functions take input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
then
echo -e "$2 is  $G successfull $N" | tee -a $LOG_FILE
else
echo -e "$2 is $R failure $N" | tee -a $LOG_FILE
exit 1
fi
}

print_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo -e "script executed successfully, $Y Time taken: $TOTAL_TIME TIME seconds $N"
}