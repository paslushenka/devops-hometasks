#!/bin/bash

/scripts/configure_nexus.sh >> /scripts/log &
/opt/sonatype/start-nexus-repository-manager.sh
