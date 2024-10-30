<h1>TFGrid Backend Snapshots</h1>

<h2>Table of Contents</h2>

- [Introduction](#introduction)
- [ThreeFold Public Rsync](#threefold-public-rsync)
- [Services](#services)
- [Requirements](#requirements)
  - [Configuration](#configuration)
  - [Hardware](#hardware)
  - [Files for Each Net](#files-for-each-net)
- [Deployment](#deployment)
- [Script](#script)
- [Rsync](#rsync)

---

## Introduction

To facilitate the deployment of TFchain validators, we provide snapshots to significantly reduce sync time. This can be setup anywhere from scratch. Once all services are synced, one can use the scripts to create snapshots automatically.

## ThreeFold Public Rsync

Threefold hosts all available snapshots at: [https://bknd.snapshot.grid.tf/](https://bknd.snapshot.grid.tf/), which can be downloaded with rsync as shown below:

- Mainnet:
    ```
    rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshots/tfchain-mainnet-validator-latest.tar.gz .  
    ```
- Testnet:
    ```
    rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotstest/tfchain-testnet-validator-latest.tar.gz .  
    ```
- Devnet:
    ```
    rsync -Lv --progress --partial rsync://bknd.snapshot.grid.tf:34873/gridsnapshotsdev/tfchain-devnet-validator-latest.tar.gz .  
    ```

## Requirements

To run your own snapshot backend one needs the following

### Configuration

- A working docker environment
- 'node key' for the TFchain public RPC node, generated with `subkey generate-node-key`

### Hardware

- Min of 8 modern CPU cores
- Min of 32GB RAM
- Min of 1TB SSD storage (high preference for NVMe based storage) preferably more (as the chain keeps growing in size)
- Min of 2TB HDD storage (to store and share the snapshots)

Dev, QA and Testnet can do with a Sata SSD setup. Mainnet requires NVMe based SSDs due to the data size.


### Files for Each Net

Each folder contains the required deployment files for it's net, work in the folder that has the name of the network you want to create snapshots for.

What does each file do:
- `.env` - contains environment files maintaned by Threefold Tech
- `.secrets.env-examples` - is where you have to add all your unique environment variables
- `create_snapshot.sh` - script to create a snapshot (used by cron)
- `docker-compose.yml` - has all the required docker-compose configuration to deploy a working Grid stack
- `open_logs_tmux.sh` - opens all the docker logs in tmux sessions

## Deployment

`cd` into the correct folder for the network your deploying for, our example uses mainnet.

```sh
cd mainnet
cp .secrets.env-example .secrets.env
```

Create a unique TFchain node key with `docker run --rm parity/subkey:latest generate-node-key > "validator_private_node_key"`. Your node key will be in the file `validator_private_node_key`, you will need to add this key into the `.secrets.env` file below.

Open `.secrets.env` and add your generated subkey node-key

Check if all environment variables are correct.
```
docker compose --env-file .secrets.env --env-file .env config
```

Deploy the tfchain node. Depending on the disk iops available, it can take up until a week to sync from block 0.

```sh
docker compose --env-file .secrets.env --env-file .env up -d
```

## Script

Add the appropriate script to cron with an interval you want the snapshots to be created

```sh
mkdir /var/log/snapshots
touch /var/log/snapshots/snapshots-cron.log
crontab -e
```

```sh
0 1 * * * sh /root/code/grid_deployment/tfchain-validator-snapshots/mainnet/create_snapshot.sh > /var/log/snapshots/snapshots-cron.log 2>&1
```

This example will execute the script every day at 1 AM and send the logs to /var/log/snapshots/snapshots-cron.log


## Rsync

We use rsync to expose the snapshots to the community. To setup a public rsync server create and edit the following file:

- File `/etc/rsyncd.conf`:

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

Start and enable the service with systemd:

```sh
systemctl start rsync
systemctl enable rsync
systemctl status rsync
```
