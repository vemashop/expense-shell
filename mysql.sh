#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[32m"
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

echo "Installing Mysql server" | tee -a $LOG_FILE_NAME
 dnf install mysql-server -y &>> $LOG_FILE_NAME
 VALIDATE $? "Installing Mysql server"

echo "Enableing mysql server" | tee -a $LOG_FILE_NAME
 systemctl enable mysqld &>> $LOG_FILE_NAME
 VALIDATE $? "Enableing Mysql server"

echo "Starting Mysql server" | tee -a $LOG_FILE_NAME
 systemctl start mysqld &>> $LOG_FILE_NAME
 VALIDATE $? "Starting Mysql server"

echo "Setting Root password" | tee -a $LOG_FILE_NAME
  mysql -h mysql.vemas.shop -u root -pExpenseApp@1 -e 'show databases;' &>> $LOG_FILE_NAME
   if [ $? -ne 0 ]; then
     mysql_secure_installation --set-root-pass ExpenseApp@1 &>> $LOG_FILE_NAME
     VALIDATE $? "Setting Root password"
   else
     echo -e "Root password setup already done.... $Y Skipping $N" 
   fi 




