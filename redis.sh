#!/bin/bash

ID=$(id -u) 

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
# exec &>LOGFILE - to run scripts in background in logs

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


dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y 
VALIDATE $? "installing remi release"

dnf module enable redis:remi-6.2 -y 
VALIDATE $? "emabling redis"

dnf install redis -y 
VALIDATE $? "installing redis"


sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf 
VALIDATE $? "allowing remote connections"

systemctl enable redis
VALIDATE $? "enable redis"

systemctl start redis 
VALIDATE $? "start redis"