#!\bin\bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33"
N="\e[0m"
LOGS_FOLDER="var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
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

systemctl restrt mongod &>>$LOG_FILE
VALIDATE $? "Restart mongodb"