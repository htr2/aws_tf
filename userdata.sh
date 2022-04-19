#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
EC2AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone) 
EC2lIPv4=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4) 
echo '<center><h1>This Amazon EC2 instance IP v4 address is: lIPv4 and is located in Availability Zone: AZID </h1></center>' > /var/www/html/index.txt
sed -e "s/AZID/$EC2AZ/" -e "s/lIPv4/$EC2lIPv4/" /var/www/html/index.txt > /var/www/html/index.html