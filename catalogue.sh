#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD


mkdir -p $LOGS_FOLDER
echo "script starting executing at: $(date)" | tee -a $LOG_FILE

#check if user has root access or not
if [ $USERID -ne 0 ]
then 
echo -e "$R error:: $N please run the script with root access" | tee -a $LOG_FILE
exit 1
else
echo "your running with root access" | tee -a $LOG_FILE
fi

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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disabling default nodejs"

dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "enabling nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "installing nodejs"

id roboshop
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

cd /app 
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "moving to app directory and unzip the catalogue"

npm install &>>$LOG_FILE
VALIDATE $? "installing the dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copiying the catalogue service"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable catalogue  &>>$LOG_FILE
systemctl start catalogue
VALIDATE $? "starting catalogue"


cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "installing mongodb client"

mongosh --host mongodb.banasurekha.shop </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "loading data into mongodb"