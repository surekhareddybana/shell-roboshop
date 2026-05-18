#!/bin/bash
source ./common.sh
app_name=mongodb
check_root



cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copiying Mongodb repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enable Mongod"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting mongod"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
VALIDATE $? "Editing Mongodb conf file for remote connections"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restart mongodb"
print_time