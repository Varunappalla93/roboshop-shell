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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disabling current nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enabling current nodejs"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "installing current nodejs"

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

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "Downloading user app"

cd /app &>> $LOGFILE
unzip /tmp/user.zip &>> $LOGFILE
VALIDATE $? "unzipping user app"

npm install  &>> $LOGFILE
VALIDATE $? "installing dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "copying user service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "user daemon reload" 

systemctl enable user &>> $LOGFILE
VALIDATE $? "user daemon enable"

systemctl start user &>> $LOGFILE
VALIDATE $? "user daemon start"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copying mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "installing mongodb client"


mongo --host mongodb.appalla.shop </app/schema/user.js &>> $LOGFILE
VALIDATE $? "loading user data into mongodb"



