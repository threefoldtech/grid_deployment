#!/bin/bash
sleep 2
echo "Set sql.conn.max_read_buffer_message_size to 32 MiB"

HOSTPARAMS="--host indexer_db --insecure"
SQL="/cockroach/cockroach.sh sql $HOSTPARAMS"

# https://github.com/threefoldtech/tfchain_graphql/issues/130#issuecomment-1689987550
$SQL -e "SET CLUSTER SETTING sql.conn.max_read_buffer_message_size = '32MiB';"
