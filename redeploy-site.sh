#!/bin/bash

cd ~/pe-portfolio-site || exit 1

git fetch && git reset origin/main --hard

source python3-virtualenv/bin/activate
pip3 install -r requirements.txt

sudo systemctl restart myportfolio