#!/bin/bash

apt-get update
apt-get upgrade -y
apt-get install python3-dev python3-pip python3-venv python3-wheel postgresql-client git libpq-dev screen -y


sudo -u ubuntu bash << EOF
cd /home/ubuntu
python3 -m venv venv
source venv/bin/activate
python3 -m pip install --upgrade pip
git clone https://github.com/arkedzierski/aws_simple_app.git aws
pip3 install -r aws/aws_project/requirements.txt
mkdir ~/.aws
echo -e "[default]\nregion = eu-central-1" > ~/.aws/config
cd /home/ubuntu/aws/aws_project
python3 manage.py migrate
screen -d -m python3 manage.py runserver 0.0.0.0:80
EOF
