#!/bin/bash
cd ~
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install python3-dev python3-pip python3-venv python3-wheel postgresql-client git -y
python3 -m venv venv
source venv/bin/activate
python3 -m pip install --upgrade pip
pip3 install boto3
git clone https://github.com/arkedzierski/aws_simple_app.git aws
pip3 install -r aws/aws_project/requirements.txt
mkdir ~/.aws
echo -e "[default]\nregion = eu-central-1" > ~/.aws/config