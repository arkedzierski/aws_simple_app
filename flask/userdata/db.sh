#!/bin/bash

sudo apt-get update
apt-get install python3-dev python3-pip python3-venv python3-wheel postgresql-client git libpq-dev screen -y
export FLASK_ENV=development
sudo iptables -A PREROUTING -t nat -p tcp --dport 80 -j REDIRECT --to-ports 5000

sudo -u ubuntu bash << EOF
cd /home/ubuntu
python3 -m venv venv
source venv/bin/activate
python3 -m pip install --upgrade pip
git clone https://github.com/arkedzierski/aws_simple_app.git aws
pip3 install -r aws/flask/requirements.txt
mkdir ~/.aws
echo -e "[default]\nregion = us-east-2" > ~/.aws/config
cd /home/ubuntu/aws/flask/flask_aws_rds
screen -d -m flask run --host=0.0.0.0
EOF