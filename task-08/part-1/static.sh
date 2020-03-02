#!/bin/bash

docker run --rm -d --name static -p 8081:80 -e WEB_SITE='static' hometask-image
