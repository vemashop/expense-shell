#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[32m"
N="\e[0m"

USERID=$(id -u)

# Checking sudo access

if [ $USERID -ne 0 ]; then
  echo "You do not have required permission to run this script"
  echo " $Y Usage $N: Please run through Root / sudo permission"
  exit 1 
else 
  echo "Hi $USER, You have permission to run the script"
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
      echo "$2 ..... $R Failure $N"
      exit 2
    else
      echo "$2 ..... $G Success $N" 
    fi     
}

sleep 1

echo "Installing Mysql server" 
 dnf install mysql-server -y
 VALIDATE $? "Installing Mysql server"

echo "Enableing mysql server"
 systemctl enable mysqld 
 VALIDATE $? "Enableing Mysql server"

echo "Starting Mysql server"
 systemctl start mysqld
 VALIDATE $? "Starting Mysql server"

echo "Setting Root password"
  mysql -h mysql.vemas.shop -u root -pExpenseApp@1 -e 'show databases;' 
   if [ $? -ne 0 ]; then
     mysql_secure_installation --set-root-pass ExpenseApp@1
     VALIDATE $? "Setting Root password"
   else
     echo "Root password setup already done.... $Y Skipping $N" 
   fi 
   
       


