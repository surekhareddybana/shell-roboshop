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
dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "disabling default nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "enabling nginx 1.24"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx 
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading frontend"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzipping frontend"

rm -rf /etc/nginx/nginx.conf
VALIDATE $? "remove default content nginx"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "copying nginx.conf"

systemctl restart nginx 
VALIDATE $? "nginx restarted"
