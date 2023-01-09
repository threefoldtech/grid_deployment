# Snapshots for Grid backend services

To facilitate deploying Grid backend services we provide snapshots to significantly reduce sync time.


## Services

- TFchain public node
- Graphql - Indexer
- Graphql - Processor


## Deploy services

Deploy the 3 individual services using known methods (docker-compose).


## Script

Add the script to cron.


## Public rsync

We use rsync to distribute the snapshots.

Create: /etc/rsyncd.conf

```sh
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
log file = /var/log/rsync.log
port = 873
max connections = 20
exclude = lost+found/
transfer logging = yes
use chroot = yes

[gridsnapshots]
path = /storage/rsync-public/
comment = THREEFOLD GRID SNAPSHOTS
read only = true
timeout = 300
```

If Ubuntu, start and enable via systemd:

```sh
systemctl start rsync
systemctl enable rsync
systemctl status rsync
```
