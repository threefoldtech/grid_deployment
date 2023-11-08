# Snapshots for Grid backend services

To facilitate deploying Grid backend services we provide snapshots to significantly reduce sync time. This can be setup anywhere from scratch. Once all services are synced, one can use the scripts to create snapshots automatically.


## Public rsync provided by Threefold

Threefold hosts all available snapshots at: https://bknd.snapshot.grid.tf/

Which can be downloaded with rsync:

- Mainnet:

rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshots/tfchain-mainnet-latest.tar.gz .  
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshots/indexer-mainnet-latest.tar.gz .  
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshots/processor-mainnet-latest.tar.gz .  

- Testnet:

rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotstest/tfchain-testnet-latest.tar.gz .  
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotstest/indexer-testnet-latest.tar.gz .  
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotstest/processor-testnet-latest.tar.gz .  

- Devnet:

rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotsdev/tfchain-devnet-latest.tar.gz .  
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotsdev/indexer-devnet-latest.tar.gz .  
rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotsdev/processor-devnet-latest.tar.gz .   

## Services

There are 3 Grid backend services that collect enough data to justify creating snapshots:

- Threefold blockchain - TFchain
- Graphql - Indexer
- Graphql - Processor


## Deploy services

Deploy the 3 individual services using known methods (docker-compose).


## Script

Add the appropriate script to cron with an interval you want the snapshots to be created

`crontab -e`

```sh
0 1 * * * sh /opt/snapshots/create-snapshot.sh > /var/log/snapshots/snapshots-cron.log 2>&1
```

This example will execute the script every day at 1 AM and send the logs to /var/log/snapshots/snapshots-cron.log


## Rsync

We use rsync to expose the snapshots to the community. To setup a public rsync server create and edit the following file:

/etc/rsyncd.conf

```sh
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
log file = /var/log/rsync.log
port = 34873
max connections = 20
exclude = lost+found/
transfer logging = yes
use chroot = yes
reverse lookup = no

[gridsnapshots]
path = /storage/rsync-public/mainnet
comment = THREEFOLD GRID MAINNET SNAPSHOTS
read only = true
timeout = 300
list = false

[gridsnapshotstest]
path = /storage/rsync-public/testnet
comment = THREEFOLD GRID TESTNET SNAPSHOTS
read only = true
timeout = 300
list = false

[gridsnapshotsdev]
path = /storage/rsync-public/devnet
comment = THREEFOLD GRID DEVNET SNAPSHOTS
read only = true
timeout = 300
list = false
```

Start and enable via systemd:

```sh
systemctl start rsync
systemctl enable rsync
systemctl status rsync
```
