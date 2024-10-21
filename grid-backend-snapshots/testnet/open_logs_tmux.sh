#/bin/bash
tmux new -d -s tfchain_public_rpc
tmux send-keys -t tfchain_public_rpc "docker logs tfchain-public-node -f --tail 500" ENTER
tmux new -d -s graphql_indexer
tmux send-keys -t graphql_indexer "docker logs indexer_ingest -f --tail 500" ENTER
tmux new -d -s graphql_processor
tmux send-keys -t graphql_processor "docker logs processor -f --tail 500" ENTER
