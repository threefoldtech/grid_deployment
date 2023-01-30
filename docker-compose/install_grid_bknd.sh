#/bin/bash

## Create directories
mkdir /srv/tfchain /srv/tfchain/chains /srv/tfchain/chains/tfchain_devnet /srv/tfchain/chains/tfchain_devnet/db /srv/indexer /srv/processor ~/grid_snapshots_tmp


## Download snapshots, extract and remove archives
cd ~/grid_snapshots_tmp
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotsdev/tfchain-devnet-latest.tar.gz .
tar xvf tfchain-devnet-latest.tar.gz -C /srv/tfchain/chains/tfchain_devnet/db/
rm tfchain-devnet-latest.tar.gz
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotsdev/indexer-devnet-latest.tar.gz .
tar xvf indexer-devnet-latest.tar.gz -C /srv/indexer/
rm indexer-devnet-latest.tar.gz
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotsdev/processor-devnet-latest.tar.gz .
tar xvf processor-devnet-latest.tar.gz -C /srv/processor/
rm processor-devnet-latest.tar.gz


## Start Grid backed services with docker-compose
cd ~
docker-compose -f docker-compose.yml up -d
