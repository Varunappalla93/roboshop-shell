#!/bin/bash

ID=$(id -u) 

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>>$LOGFILE


VALIDATE()
{
if [ $1 -ne 0 ]
    then
        echo -e "ERROR:: $2 is $R failed $N"
        exit 1
    else
        echo -e "$2 is $G successful $N"
fi
}


if [ $ID -ne 0 ]
then
    echo -e "$R Error, pls try with root user $N"
    exit 1 # non-zero
else
   echo "you are root user"
fi


dnf module disable mysql -y &>> $LOGFILE
VALIDATE $? "disabling current mysql version"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
VALIDATE $? "Copied mysql repo"

dnf install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "installing mysql server"

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "enabling mysql server"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "starting mysql server"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "Setting mysql root password"

