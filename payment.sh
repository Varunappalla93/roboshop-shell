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


dnf install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "Installing python"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "creating roboshop user"
else
    echo -e "roboshop user already exists $Y Skipping $N"
fi


mkdir -p /app &>> $LOGFILE
VALIDATE $? "creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "Downloading payment app"

cd /app  &>> $LOGFILE
unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "unziping payment app"

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "installing dependencies"


cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "copying payment service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "payment daemon reload" 

systemctl enable payment &>> $LOGFILE
VALIDATE $? "payment daemon enable"

systemctl start payment &>> $LOGFILE
VALIDATE $? "payment daemon start"
