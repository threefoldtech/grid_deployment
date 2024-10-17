<h1>TFGrid ZOS Hub and Bootstrap Generator</h1>

<h2>Table of Contents</h2>

- [Introduction](#introduction)
- [Requirements](#requirements)
  - [Configuration](#configuration)
  - [Hardware](#hardware)
  - [Setting the DNS Records](#setting-the-dns-records)
- [Files](#files)
- [Storage](#storage)
- [Deployment](#deployment)
- [Post-Deployment Follow-up](#post-deployment-follow-up)
- [Open Service Logs](#open-service-logs)

---

## Introduction

We document the procedures to deploy an independent TFGrid ZOS Hub and Bootstrap Generator instance.

These deployments will act as slave instances and sync all the data from [https://hub.grid.tf](https://hub.grid.tf) and [https://bootstrap.grid.tf](https://bootstrap.grid.tf).

By default, a deployment will be master-slave from the Threefold hosted instances and will keep itself in sync. A master-master relation is not possible.

However we are working on two more scenarios where one can deploy a synced instance and be stand alone once the sync is done, and empty standalone deployments.

## Requirements

To start a Hub and Bootstrap stack one needs the following:

### Configuration

- A working Docker environment
- One static IPv4 and IPv6 ip
- One A and one AAAA record to expose all services on. This can be the root of a domain or a subdomain but both must be wildcard records like *.your.domain ([see table for more info](#setting-the-dns-records))

### Hardware

- Min of 2 modern CPU cores
- Min of 4GB RAM
- Min of 1TB SSD/HDD storage 


### Setting the DNS Records

The following table explicitly shows how to set the A and AAAA records for your domain.

Wildcard example:
| Type | Host | Value          |
| ---- | ---- | -------------- |
| A    | \*   | <ipv4_address> |
| AAAA | \*   | <ipv6_address> |

Individual records example:
| Type | Host                     | Value          |
| ---- | ------------------------ | -------------- |
| A    | hub.your.domain         | <ipv4_address> |
| AAAA | hub.your.domain         | <ipv6_address> |
| A    | bootstrap.your.domain   | <ipv4_address> |
| AAAA | bootstrap.your.domain   | <ipv6_address> |


## Files

- `.env` - contains environment variables maintaned by Threefold Tech and **your domain environment variable**
- `.gitignore` - has a list of files to ignore once the repo has been cloned. This has the purpose to not have uncommited changes to files when working in this repo
- `Caddyfile` - contains a fully working Caddy config used to expose the services
- `docker-compose.yml` - docker-compose file to deploy a Hub, Bootstrap and Caddy
- `install_hub.sh` - script to install prerequisites, docker-compose and post-install scripts for Ubuntu
- `bootstrap-kernel-sync.py` - script to sync the bootstarp kernel from the master bootstrap instance
- `hub-clone.py` - script to sync the hub users from the master hub instance
- `config-bootstrap.py-example` - example file for bootstrap config
- `config.py-example` - example file for hub config
- `open_logs_tmux.sh` - opens all the docker logs in tmux sessions


## Storage

We use docker to run the services and mount several directories for persistent data. **These will all be mounted inside** `/srv`.  
You can control how (software raid, bcachefs, ..) this data will be stored by mounting `/srv` to any redundant storage configuration of your choosing.


## Deployment

Clone the repo and cd into the hub stack dir:

```sh
git clone https://github.com/threefoldtech/grid_deployment.git
cd grid_deployment/grid-hub
```

Open `.env` and save your domain. Here is an example for `hub.your.domain` and `bootstrap.your.domain`:
```sh
DOMAIN=your.domain
```

Start the deployment and all its scripts with the install script:
```sh
sh install-hub.sh
```


## Post-Deployment Follow-up

If you use the `install-hub.sh` script, Tmux is used to start 3 script in the background for initial sync with the master hub.
- `0-hub_user_sync` - syncs all registerd Threebot users from the master hub, this can take a few hours (will exit after sync)
- `0-hub_sync` - syncs all flist data from the master hub: this is the only script that keeps running after sync, to keep this slave in sync with the master hub. Do not stop this script. Note: initial sync could take a few days, this is a known issue and will be improved in the future
- `0-bootstrap_sync` - syncs all available kernels from the master bootstrap (will exit after sync)


## Open Service Logs

This script opens all Docker container logs in separate tmux sessions:
```sh
sh open_logs_tmux.sh
```
