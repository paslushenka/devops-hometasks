#!/bin/bash

docker run --rm -d --name dynamic -p 8080:80 -e WEB_SITE='dynamic' hometask-image
