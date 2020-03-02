FROM debian:latest
SHELL ["/bin/bash", "-c"]
RUN apt-get -y update && apt-get -y install php apache2 \
 && mv /var/www/html/index.html /var/www/html/index.html.bak \
 && chmod -R 777 /var/run/apache2
COPY ./files/index.php /var/www/html/index.php
COPY ./script.sh /tmp/script.sh
RUN chmod +x /tmp/script.sh
ENTRYPOINT /tmp/script.sh
