#/bin/bash
tmux new -d -s tfchain_public_rpc 'docker logs tfchain-public-node -f --tail 500'
tmux new -d -s graphql_indexer 'docker logs indexer_ingest -f --tail 500'
tmux new -d -s graphql_processor 'docker logs processor -f --tail 500'
tmux new -d -s grid_relay 'docker logs grid_relay -f --tail 500'
tmux new -d -s grid_proxy 'docker logs grid_proxy -f --tail 500'
tmux new -d -s grid_dashboard 'docker logs grid_dashboard -f --tail 500'
tmux new -d -s caddy 'docker logs caddy -f --tail 500'
