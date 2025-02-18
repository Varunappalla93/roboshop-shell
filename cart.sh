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

dnf module disable nodejs -y &>> LOGFILE
VALIDATE $? "disabling current nodejs"

dnf module enable nodejs:18 -y &>> LOGFILE
VALIDATE $? "enabling current nodejs"

dnf install nodejs -y &>> LOGFILE
VALIDATE $? "installing current nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "creating roboshop user"
else
    echo -e "roboshop user already exists $Y Skipping $N"
fi

mkdir -p /app &>> LOGFILE
VALIDATE $? "creating app directory"


curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> LOGFILE
VALIDATE $? "Downloading cart app"

cd /app &>> LOGFILE
unzip -o /tmp/cart.zip &>> LOGFILE
VALIDATE $? "unziping cart app"

npm install  &>> LOGFILE
VALIDATE $? "installing dependencies"


cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> LOGFILE
VALIDATE $? "copying cart service file"

systemctl daemon-reload &>> LOGFILE
VALIDATE $? "cart daemon reload" 

systemctl enable cart &>> LOGFILE
VALIDATE $? "cart daemon enable"

systemctl start cart &>> LOGFILE
VALIDATE $? "cart daemon start"systemctl enable cart