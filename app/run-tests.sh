#!/bin/bash

docker compose up -d --build --quiet-pull

# bring down the services on exit
trap 'docker compose down --volumes' EXIT

output0=$(docker exec sample-app-cache-1 redis-cli ping)

# TEST 1: Fail authentication to redis
output1=$(docker exec sample-app-cache-1 redis-cli AUTH wrongpass)

echo "[TEST 1]: output: $output1"

if [ "${output1}" != 'WRONGPASS invalid username-password pair or user is disabled.' ]
then
    echo "[TEST 1]: FAILED: unexpected output"
    exit 1
else
    echo "[TEST 1]: OK"
fi

# TEST 2: rotate redis credentials
output2=$(docker exec sample-app-vault-server-1 vault write -force database/rotate-root/my-redis-database)

echo "[TEST 2]: output: $output2"

if [ "${output2}" != 'Success! Data written to: database/rotate-root/my-redis-database' ]
then
    echo "[TEST 2]: FAILED: unexpected output"
    exit 1
else
    echo "[TEST 2]: OK"
fi

# TEST 3: read redis credentials
output3=$(docker exec sample-app-vault-server-1 vault read database/creds/my-dynamic-role)

echo "[TEST 3]: output: $output3"

# TEST 4: read redis credentials
username=$(docker exec sample-app-vault-server-1 vault read database/creds/my-dynamic-role|grep username|awk '{print $2}')

echo "[TEST 4]: username: $username"

while read -r id val; do
    if [[ $id = "username" ]]; then
        export var1=$val
    elif [[ $id = "password" ]]; then
        export var2=$val
    fi
done < <(docker exec sample-app-vault-server-1 vault read database/creds/my-all-role | grep -iE "username|password")

docker exec sample-app-cache-1 redis-cli --user $var1 --pass $var2 SET k42 "TESTED BY $var1 SUCCESSFULLY!"
docker exec sample-app-cache-1 redis-cli --user $var1 --pass $var2 GET k42 
