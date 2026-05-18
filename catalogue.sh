#!/bin/bash

source ./common.sh
app_name=catalogue

check_root
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "installing mongodb client"

STATUS=$(mongosh --host mongodb.banasurekha.shop --eval 'db.getMongo().getDbNmames().indexof("catalogue")')
if [ $STATUS -ne 1 ]
then

mongosh --host mongodb.banasurekha.shop </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "loading data into mongodb"
else 
echo -e "data is already loaded $Y skipping $N"
fi
print_time