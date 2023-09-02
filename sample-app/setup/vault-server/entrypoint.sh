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
vault write database/roles/my-dynamic-role \
    db_name="my-redis-database" \
    creation_statements='["+@admin"]' \
    default_ttl="15m" \
    max_ttl="1h"

vault write database/roles/my-all-role \
    db_name="my-redis-database" \
    creation_statements='["~*", "&*", "+@all"]' \
    default_ttl="15m" \
    max_ttl="1h"

#vault write database/roles/my-readonly-role \
##    db_name="my-redis-database" \
 #   username="readonly" \
 #   creation_statements='["~readonly", "+@read"]' \
 #   rotation_period=5m

# this container is now healthy
touch /tmp/healthy

# keep container alive
tail -f /dev/null & trap 'kill %1' TERM ; wait
