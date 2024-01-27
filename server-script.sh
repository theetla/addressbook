#! /bin/bash

sudo yum install java-1.8.0-openjdk-devel -y
sudo yum install git -y
sudo yum install maven -y

if [ -d "addressbook" ]
then
   echo "repo already cloned and exists"
   cd /home/ec2-user/addressbook
   git checkout test
   git pull origin test
else
   git clone https://github.com/theetla/addressbook.git
   git checkout test
fi
cd addressbook
mvn package