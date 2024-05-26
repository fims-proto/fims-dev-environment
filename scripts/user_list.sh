#!/bin/bash

if ! command -v jq &> /dev/null
then
    echo "`jq` not installed, exit..."
    exit
fi

read -p "Kratos admin API [http://127.0.0.1:4434]: " kratos_admin_api
kratos_admin_api=${kratos_admin_api:-http://127.0.0.1:4434}

echo

response=$(curl --request GET -sL \
    -w "%{http_code}" \
    --header "Accept: application/json" \
    $kratos_admin_api/identities
)

http_code=$(tail -n1 <<< "$response")
content=$(sed '$ d' <<< "$response")

if [ $http_code != "200" ]
then
    echo "[!] Create link request failed: "
    echo "$content"
    exit
fi

echo "==> Identities:"
echo "$content" | jq