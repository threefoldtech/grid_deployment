#/bin/bash
WD=$(pwd)

# Upgrade and fully re-sync indexer from block 0
# NOTE: make sure the snapshot server is upgraded and re-synced first!
mkdir ~/grid_indexer_tmp
cd ~/grid_indexer_tmp
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotstest/indexer-testnet-latest.tar.gz .
#tar xvf indexer-testnet-latest.tar.gz
tar -I pigz -xf indexer-testnet-latest.tar.gz
rm indexer-testnet-latest.tar.gz
docker stop indexer_db
rm -r /srv/indexer/*
mv * /srv/indexer/
cd "$WD"
docker compose --env-file .secrets.env --env-file .env up --no-deps -d indexer_db
