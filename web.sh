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

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "Enabled nginx"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "Started nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "remove default site contents"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "Download web app"

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "moving to nginx html directory"

unzip -o /tmp/web.zip &>> $LOGFILE
VALIDATE $? "unzipping web app"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATE $? "copied roboshop reverse proxy"

systemctl restart nginx &>> $LOGFILE
VALIDATE $? "restarted nginx"



