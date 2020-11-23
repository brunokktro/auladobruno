#!/bin/bash -ex
yum -y install httpd php
chkconfig httpd on
service httpd start
cd /var/www/html
wget https://jondion-public.s3.amazonaws.com/demo-aph.tar.gz
tar xvfz demo-aph.tar.gz