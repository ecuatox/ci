#!/bin/bash

repo_name=$(awk -F': ' '/repo_name/ {print $2}' local_settings.txt)
repo_url=$(awk -F': ' '/repo_url/ {print $2}' local_settings.txt)
requirements=$(awk -F': ' '/requirements/ {print $2}' local_settings.txt)
signature=$1
message=$2

mkdir ci_test_$signature
cd ci_test_$signature

virtualenv -p python3 env
. env/bin/activate

git clone $repo_url
cd $repo_name

pip install -r $requirements
python manage.py test
exitcode=$?

cd ../..
sudo rm -r ci_test_$signature

now=$(date +"%F %T")

if [ $exitcode -eq 0 ]
then
	echo "$now  passed  $message" >> ci.log
	sudo ./update.sh
else
	echo "$now  failed  $message" >> ci.log
fi
