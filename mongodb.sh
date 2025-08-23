#!\bin\bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33"
N="\e[0m"
LOGS_FOLDER="var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

if [ $USERID -ne 0 ]
then 
echo -e "$R error:: $N please run the script with root access" | tee -a $LOG_FILE
exit 1
else
echo "your running with root access" &>>$LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]
then
echo -e "installing $2 is  $G successfull $N" &>>$LOG_FILE
else
echo -e "installing $2 is $R failure $N" &>>$LOG_FILE
exit 1
fi
}