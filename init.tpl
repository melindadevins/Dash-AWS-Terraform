#!/bin/bash
#echo "Hello, Melinda test" > index.html
#nohup busybox httpd -f -p 8080


#echo "*****Begin executing init.tpl*** config_bucket_name: ${config_bucket_name} region: ${region} environment: ${environment}"

echo "******* Step 1. Wait a bit for the network  *******"
sleep 15

mkdir -p ${app_path}
chmod 775 ${app_path}

APP_PATH=${app_path}
CONFIG_BUCKET=${config_bucket_name}
SERVER_PORT=${server_port}

cd $APP_PATH
# Replicate our configuraiton bucket

echo "******* Step 2. Down load config files from S3  *******"
aws s3 sync "s3://${config_bucket_name}/" .

unzip "${s3object_key}" -d $APP_PATH

cd $APP_PATH
chmod 644 vars.tfvars
source vars.tfvars
chmod +x *.sh


echo "Step 3. PIP Install requirements.txt"
pip install -r requirements.txt
sleep 5

echo "Step 4. Launch server"
gunicorn -w 10 -b 0.0.0.0:$SERVER_PORT -t 100000 --max-requests 20 app:server
