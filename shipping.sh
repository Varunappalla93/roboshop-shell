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



dnf install maven -y
VALIDATE $? "installing maven"

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> LOGFILE
VALIDATE $? "Downloading shipping app"

cd /app &>> LOGFILE
unzip -o /tmp/shipping.zip &>> LOGFILE
VALIDATE $? "unziping shipping app"

mvn clean package &>> LOGFILE
VALIDATE $? "installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> LOGFILE
VALIDATE $? "copying shipping jar file"


cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> LOGFILE
VALIDATE $? "copying shipping service file"

systemctl daemon-reload &>> LOGFILE
VALIDATE $? "shipping daemon reload" 

systemctl enable shipping &>> LOGFILE
VALIDATE $? "shipping daemon enable"

systemctl start shipping &>> LOGFILE
VALIDATE $? "shipping daemon start"

dnf install mysql -y
VALIDATE $? "install mysql client"

mysql -h mysql.appalla.shop -uroot -pRoboShop@1 < /app/schema/shipping.sql 
VALIDATE $? "loadding shipping data to mysql"

systemctl restart shipping
VALIDATE $? "restart shipping service"