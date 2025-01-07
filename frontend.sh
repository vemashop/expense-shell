#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/expense-logs"
TIMESTAMP=$(date +%Y-%m-%d-%H:%M:%S)
LOG_FILE=$(echo $0 | cut -d "." -f1)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE--$TIMESTAMP"


USERID=$(id -u)

# Checking sudo access

mkdir -p $LOG_FOLDER 

if [ $USERID -ne 0 ]; then
  echo "Hi $USER, You do not have required permission to run this script" | tee -a $LOG_FILE_NAME
  echo " $Y Usage $N: Please run through Root / sudo permission" | tee -a $LOG_FILE_NAME
  exit 1 
else 
  echo "Hi $USER, You have permission to run the script" | tee -a $LOG_FILE_NAME
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
      echo -e "$2 ..... $R Failure $N"
      exit 2
    else
      echo -e "$2 ..... $G Success $N" 
    fi     
}

dnf install nginx -y &>> $LOG_FILE_NAME
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>> $LOG_FILE_NAME
VALIDATE $? "Enable Nginx"

systemctl start nginx &>> $LOG_FILE_NAME
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>> $LOG_FILE_NAME
VALIDATE $? "Removing html data"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>> $LOG_FILE_NAME
VALIDATE $? "Downloading Frontend code"

cd /usr/share/nginx/html 
VALIDATE $? "Moving to html dir"

unzip /tmp/frontend.zip &>> $LOG_FILE_NAME
VALIDATE $? "Unzipping"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>> $LOG_FILE_NAME
VALIDATE $? "Copying"

systemctl restart nginx &>> $LOG_FILE_NAME
VALIDATE $? "Restarting Nginx"
