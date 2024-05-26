#!/bin/bash
sudo yum update 
sudo yum install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
echo "<h1>This message is from Fruit Instance IP: $(hostname -i)</h1>" > /usr/share/nginx/html/index.html
sudo mkdir -p /usr/share/nginx/html/fruit/
echo "<h1>This message is from Fruit Instance IP: $(hostname -i)</h1>" > /usr/share/nginx/html/fruit/index.html