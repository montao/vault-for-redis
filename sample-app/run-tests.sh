#!/bin/sh
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


APP_ADDRESS="http://localhost:8080"

# bring up hello-vault-go service and its dependencies
docker compose up -d --build --quiet-pull

# bring down the services on exit
trap 'docker compose down --volumes' EXIT

# TEST 1: POST /payments (static secrets)
output1=$(docker exec sample-app-cache-1 redis-cli AUTH wrongpass)

echo "[TEST 1]: output: $output1"

if [ "${output1}" != 'WRONGPASS invalid username-password pair or user is disabled.' ]
then
    echo "[TEST 1]: FAILED: unexpected output"
    exit 1
else
    echo "[TEST 1]: OK"
fi

# TEST 2: rotate redis 
output2=$(docker exec sample-app-vault-server-1 vault write -force database/rotate-root/my-redis-database)

echo "[TEST 2]: output: $output2"

if [ "${output2}" != 'Success! Data written to: database/rotate-root/my-redis-database' ]
then
    echo "[TEST 2]: FAILED: unexpected output"
    exit 1
else
    echo "[TEST 2]: OK"
fi
