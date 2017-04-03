#!/bin/bash

repo_root=$(awk -F': ' '/repo_root/ {print $2}' local_settings.txt)
pyenv=$(awk -F': ' '/pyenv/ {print $2}' local_settings.txt)
prod_requirements=$(awk -F': ' '/prod_requirements/ {print $2}' local_settings.txt)

cd $repo_root
git reset --hard
git checkout master
git fetch --all
git reset --hard origin/master
sudo $pyenv/pip3 install -r $prod_requirements
sudo $pyenv/python3 manage.py makemigrations
sudo $pyenv/python3 manage.py migrate
sudo $pyenv/python3 manage.py collectstatic --noinput
sudo systemctl restart gunicorn
sudo systemctl restart nginx
