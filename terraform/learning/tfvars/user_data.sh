#!/bin/bash
apt-get update --fix-missing
apt-get install nginx -y 
echo "<h2>WebServer with PrivateIP: RANJEET</h2><br>Built by Terraform" > /var/www/html/index.html
service nginx start
systemctl enable nginx