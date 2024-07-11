#/bin/bash
## prerequisites
mkdir -p /srv/0-db_data /srv/0-db_index /srv/0-hub_public/users /srv/0-hub_workdir /srv/caddy/data /srv/caddy/config /srv/caddy/log 
apt update && apt install python3 python3-redis python3-requests -y

## Disable COW on BTRFS (optional in case of btrfs at /srv)
#chattr +C /srv/0-db_data
#chattr +C /srv/0-db_index

## Start Grid backed services with docker-compose
docker compose --env-file .env up -d

## Populate the users
tmux new -d -s 0-hub_user_sync
tmux send-keys -t 0-hub_user_sync "python3 hub-clone.py https://hub.grid.tf /srv/0-hub_public/users" ENTER

## Sync with hub.grid.tf and keep in sync
tmux new -d -s 0-hub_sync
tmux send-keys -t 0-hub_sync "python3 incremental.py" ENTER
