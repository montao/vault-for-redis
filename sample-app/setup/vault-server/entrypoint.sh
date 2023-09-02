#!/bin/sh

set -e
export VAULT_ADDR='http://127.0.0.1:8200'
vault server -dev &
sleep 5s
vault login -no-print "${VAULT_DEV_ROOT_TOKEN_ID}"
vault secrets enable database
vault write database/config/my-redis-database \
  plugin_name="redis-database-plugin" \
  host="cache" \
  port=6379 \
  tls=false \
  ca_cert="$CACERT" \
  username="default" \
  password="pass" \
  allowed_roles="my-*-role"

vault write -force database/rotate-root/my-redis-database

# this container is now healthy
touch /tmp/healthy

# keep container alive
tail -f /dev/null & trap 'kill %1' TERM ; wait
