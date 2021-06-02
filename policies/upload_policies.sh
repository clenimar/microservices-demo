#!/bin/bash

set -euo pipefail

# ================ Parse CAS address ==============

# If provided SCONE_CAS_ADDR is an IPv4 address,
# create an entry for "cas" in /etc/hosts with
# such address. This is needed because SCONE CLI
# does not support IP addresses when attesting a CAS.
# If the provided SCONE_CAS_ADDR is a name, just use it.
if [[ -z "$SCONE_CAS_ADDR" ]]; then
    CAS_ADDR="cas"
elif [[ $SCONE_CAS_ADDR =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    # NOTE: checking only for a generic IPv4 format (with no octet validation).
    CAS_ADDR="cas"
    echo "$SCONE_CAS_ADDR $CAS_ADDR" >> /etc/hosts
else
    CAS_ADDR=$SCONE_CAS_ADDR
fi

# ================ Attest CAS ================

# attest CAS before uploading the session file, accept CAS running in debug
# mode (--only_for_testing-debug) and outdated TCB (-GSC)
echo "Attesting CAS ..."
scone cas attest "$CAS_ADDR" "$CAS_MRENCLAVE" -GCS --only_for_testing-ignore-signer --only_for_testing-debug
echo "Done attesting CAS ..."

# ================ Workflow Session ================

echo "Uploading namespace.yml ..."
#--use-env  Use the environment variables for variable substitution
scone session create --use-env "${BASH_SOURCE%/*}/namespace.yml"

echo "Cartservice is written in C#, which is not yet supported by sconify-image."
echo "Uploading cartservice.yml..."
#--use-env  Use the environment variables for variable substitution
scone session create --use-env "${BASH_SOURCE%/*}/cartservice.yml"

echo "redis-cart is based on our Redis curated image."
echo "Uploading redis-cart.yml..."
#--use-env  Use the environment variables for variable substitution
scone session create --use-env "${BASH_SOURCE%/*}/redis-cart.yml"
