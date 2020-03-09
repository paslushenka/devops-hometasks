#!/bin/bash

echo "Started Sonatype Nexus..."
until [[ -n $(cat /nexus-data/log/nexus.log | grep "Started Sonatype Nexus") ]]
do
  sleep 1
done

NEW_PASSWORD="admin"

CURRENT_PASSWORD() {
  if [[ -n $(curl -v -X HEAD -u admin:`cat /nexus-data/admin.password` http://localhost:8081/service/rest/v1/script 2>&1 | grep 200) ]]
  then
    echo $(cat /nexus-data/admin.password)
  else
    echo "$NEW_PASSWORD"
  fi
}

PASS=$(CURRENT_PASSWORD)

DECLARING_GROOVY() {
  # Removing (potential) previously declared Groovy script
  curl -u admin:${PASS} \
  -H "Content-Type: application/json" \
  -X DELETE \
  http://localhost:8081/service/rest/v1/script/${1}

  DATA_SCRIPT() {
    cat <<EOF
{"name": "${1}","type": "groovy","content": "$(cat /scripts/${1}.groovy | sed ':a;N;$!ba;s/\n/\\n/g')"}
EOF
  }
  # echo -e "Declaring Groovy script\n$(DATA_SCRIPT ${1}) \n\n\n"

  curl -u admin:${PASS} \
  -H "Content-Type: application/json" \
  -X POST --data "$(DATA_SCRIPT ${1})" \
  http://localhost:8081/service/rest/v1/script
}

# Declaring Groovy script
DECLARING_GROOVY update_admin_password
DECLARING_GROOVY create_repo_raw_hosted

# change admin password
curl -u admin:${PASS} \
-H "Content-Type: application/json" \
-X POST --data '{"new_password":"admin"}' \
http://localhost:8081/service/rest/v1/script/update_admin_password/run

# add repositary
PASS=$(CURRENT_PASSWORD)
curl -u admin:${PASS} \
-H "Content-Type: application/json" \
-X POST --data '{"name":"word-cloud-generator", "write_policy":"ALLOW", "blob_store":"default", "strict_content_validation":"false"}' \
http://localhost:8081/service/rest/v1/script/create_repo_raw_hosted/run
