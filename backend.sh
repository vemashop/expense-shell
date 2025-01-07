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

sleep 1

echo "Disableing nodejs" | tee -a $LOG_FILE_NAME
  dnf module disable nodejs -y &>> $LOG_FILE_NAME
  VALIDATE $? "Disableing nodejs"

sleep 1

echo "Enabling nodejs" | tee -a $LOG_FILE_NAME
  dnf module enable nodejs:20 -y &>> $LOG_FILE_NAME
  VALIDATE $? "Enabling nodejs"

sleep 1

echo "Installing nodejs" | tee -a $LOG_FILE_NAME
  dnf install nodejs -y &>> $LOG_FILE_NAME
  VALIDATE $? "Installing nodejs"

sleep 1

echo "Creating expense user" | tee -a $LOG_FILE_NAME
USERVAR=$(id expense)
 if [ $? -ne 0 ]
  then
   useradd expense &>> $LOG_FILE_NAME
   VALIDATE $? "Creating expense user"
 else
   echo -e " expense user alreay exists... $Y Skipping $N"  
 fi

sleep 1

echo "Creating App directory" | tee -a $LOG_FILE_NAME
  mkdir -p /app
  VALIDATE $? "Creating App directory"

sleep 1

echo "Downloading code" | tee -a $LOG_FILE_NAME
 curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> $LOG_FILE_NAME
 VALIDATE $? "Downloading code"

sleep 1

echo "Moving to App dirc" | tee -a $LOG_FILE_NAME
 cd /app
 VALIDATE $? "Moving to App dirc"

echo "Unzipping downloaded code to App dir"
 unzip /tmp/backend.zip &>> $LOG_FILE_NAME
 VALIDATE $? "Unzipping downloaded code to App dir"

sleep 1

echo "Installing dependencies" | tee -a $LOG_FILE_NAME
 npm install &>> $LOG_FILE_NAME
 VALIDATE $? "Installing dependencies"

sleep 1

echo "Copying .service file" | tee -a $LOG_FILE_NAME
 cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service
 VALIDATE $? "Copying .service file"

sleep 1

echo "Daemon reload, Enable and Start backend" | tee -a $LOG_FILE_NAME
 systemctl daemon-reload &>> $LOG_FILE_NAME && systemctl enable backend &>> $LOG_FILE_NAME && systemctl start backend &>> $LOG_FILE_NAME
 VALIDATE $? "Daemon reload, Enable and Start backend"

sleep 1

echo "Installing Mysql client" | tee -a $LOG_FILE_NAME
 dnf install mysql -y &>> $LOG_FILE_NAME
 VALIDATE $? "Installing Mysql client"

echo "Loading transaction schema and tables" | tee -a $LOG_FILE_NAME
 mysql -h mysql.vemas.shop -uroot -pExpenseApp@1 < /app/schema/backend.sql &>> $LOG_FILE_NAME
 VALIDATE $? "Loading transaction schema and tables" 
sleep 1

echo "Restarting service" | tee -a $LOG_FILE_NAME
 systemctl restart backend &>> $LOG_FILE_NAME
 VALIDATE $? "Restarting service" 

 
