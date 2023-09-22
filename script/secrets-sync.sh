export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root

## To run this script you need to have manually added access_key and secret_key 
##  to vault
## vault secrets enable -path=kva kv-v2
## vault kv put kva/aws-creds access_key="$AWS_ACCESS_KEY_ID" secret_key="$AWS_SECRET_ACCESS_KEY"

export AWS_ACCESS_KEY_ID=$(vault kv get --field access_key kva/aws-creds)
export AWS_SECRET_ACCESS_KEY=$(vault kv get --field secret_key kva/aws-creds)
export AWS_REGION=us-east-1

echo "$AWS_ACCESS_KEY_ID, $AWS_SECRET_ACCESS_KEY, $AWS_REGION"

vault secrets enable -path=kv1 kv-v2

vault kv put kv1/database/dev api_key="abc" key_id="123"

vault write sys/sync/destinations/aws-sm/aws-sm1 \
   access_key_id="${AWS_ACCESS_KEY_ID}" \
   secret_access_key="${AWS_SECRET_ACCESS_KEY}" \
   region="${AWS_REGION}"

vault write sys/sync/destinations/aws-sm/aws-sm1/associations/set \
   mount="kv1" \
   secret_name="database/dev"

vault kv put kv1/database/dev api_key="abc" key_id="updated"

vault kv patch -mount=kv1 database/dev last_key=new_one

vault write sys/sync/destinations/aws-sm/aws-sm1/associations/remove \
   mount="kv1" \
   secret_name="database/dev"