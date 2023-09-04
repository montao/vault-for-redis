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

# Enable the pki secrets engine at the pki path.
vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki
vault write -field=certificate pki/root/generate/internal \
     common_name="example.com" \
     issuer_name="root-2023" \
     ttl=87600h > root_2023_ca.crt

key=$( vault list pki/issuers/ | tail -1 )
vault read pki/issuer/$key \
    | tail -n 6
vault write pki/roles/2023-servers allow_any_name=true
vault write pki/config/urls \
     issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
     crl_distribution_points="$VAULT_ADDR/v1/pki/crl"
vault secrets enable -path=pki_int pki
vault secrets tune -max-lease-ttl=43800h pki_int
vault write -format=json pki_int/intermediate/generate/internal \
     common_name="example.com Intermediate Authority" \
     issuer_name="example-dot-com-intermediate" \
     | jq -r '.data.csr' > pki_intermediate.csr
vault write -format=json pki/root/sign-intermediate \
     issuer_ref="root-2023" \
     csr=@pki_intermediate.csr \
     format=pem_bundle ttl="43800h" \
     | jq -r '.data.certificate' > intermediate.cert.pem
vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
vault write pki_int/roles/example-dot-com \
     issuer_ref="$(vault read -field=default pki_int/config/issuers)" \
     allowed_domains="example.com" \
     allow_subdomains=true \
     max_ttl="720h"
vault write pki_int/issue/example-dot-com common_name="test.example.com" ttl="24h"
# this container is now healthy
touch /tmp/healthy

# keep container alive
tail -f /dev/null & trap 'kill %1' TERM ; wait
