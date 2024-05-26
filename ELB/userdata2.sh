#!/bin/bash
sudo yum update 
sudo yum install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
echo "<h1>This message is from Vegetable Instance IP: $(hostname -i)</h1>" > /usr/share/nginx/html/index.html
sudo mkdir -p /usr/share/nginx/html/vegetable/
echo "<h1>This message is from Vegetable Instance IP: $(hostname -i)</h1>" > /usr/share/nginx/html/vegetable/index.html