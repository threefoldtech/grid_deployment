#/bin/bash
WD=$(pwd)

# Upgrade and fully re-sync processor from block 0
# NOTE: make sure the snapshot server is upgraded and re-synced first!
mkdir /mnt/disk/grid_processor_tmp
cd /mnt/disk/grid_processor_tmp
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotsqa/processor-qanet-latest.tar.gz .
tar xvf processor-qanet-latest.tar.gz
rm processor-qanet-latest.tar.gz
docker stop processor
docker stop processor_query_node
docker stop processor_db
rm -r /mnt/disk/srv/processor/*
mv * /mnt/disk/srv/processor/
cd "$WD"
git pull -r
docker compose --env-file .secrets.env --env-file .env up --no-deps -d processor_db processor processor_query_node

# wait for processor and db to fully start
sleep 30

# Need to restart gridproxy when re-deploying processor
docker restart grid_proxy

# Clean up
rm -r /mnt/disk/grid_processor_tmp