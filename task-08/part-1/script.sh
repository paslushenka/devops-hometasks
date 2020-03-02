#!/bin/bash

if [ "${WEB_SITE}" == "static" ]
then
  mv /var/www/html/index.html.bak /var/www/html/index.html

  apache2ctl -D FOREGROUND
else
  apache2ctl -D FOREGROUND
fi