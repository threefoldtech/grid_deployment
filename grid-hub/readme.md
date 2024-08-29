# Running the Hub and Bootstrap stack

Documentation on how to deploy an independent Hub and Bootstrap instance.
Up to date scripts & docker-compose versions will be maintained for dev, qa, test and mainnet.


### Requirements

To start a Hub and Bootstrap stack one needs the following:

-- Configuration
- a working Docker environment
- one static IPv4 and IPv6 ip
- one A and one AAAA record to expose all services on. This can be the root of a domain or a subdomain but both must be wildcard records like *.your.domain ([see table for more info](#setting-the-dns-records))

-- Hardware
- min of 2 modern CPU cores
- min of 4GB RAM
- min of 1TB SSD/HDD storage 


#### Setting the DNS Records

The following table explicitly shows how to set the A and AAAA records for your domain.

Wildcard example:
| Type | Host | Value          |
| ---- | ---- | -------------- |
| A    | \*   | <ipv4_address> |
| AAAA | \*   | <ipv6_address> |

Individual records example:
| Type | Host                     | Value          |
| ---- | ------------------------ | -------------- |
| A    | \hub.your.domain         | <ipv4_address> |
| AAAA | \hub.your.domain         | <ipv6_address> |
| A    | \bootstrap.your.domain   | <ipv4_address> |
| AAAA | \bootstrap.your.domain   | <ipv6_address> |


### Files

What each file does::
- `.env` - contains environment variables maintaned by Threefold Tech and **your domain environment variable**
- `.gitignore` - has a list of files to ignore once the repo has been cloned. This has the purpose to not have uncommited changes to files when working in this repo
- `Caddyfile` - contains a fully working Caddy config used to expose the services
- `docker-compose.yml` - has all the required docker-compose configuration to deploy a working Grid stack
- `install_hub.sh` - script to make deploying easy
- `bootstrap-kernel-sync.py` - script to sync the bootstarp kernel from the master bootstrap instance
- `hub-clone.py` - script to sync the hub users from the master hub instance
- `config-bootstrap.py-example` - example file for bootstrap config
- `config.py-example` - example file for hub config
- `open_logs_tmux.sh` - opens all the docker logs in tmux sessions


### Storage

We use docker to run the services and mount several directories for persistent data. These will all be mounted inside /srv.  
You can control how (software raid, bcachefs, ..) this data will be stored by mounting /srv to any redundant configuration of your choosing.


### Deploy a full stack

Clone the repo and cd into the hub stack dir
```sh
git clone https://github.com/threefoldtech/grid_deployment.git
cd grid_deployment/grid-hub
```

Open `.env` and save your domain. Example for `hub.your.domain` and `bootstrap.your.domain`
```sh
DOMAIN=your.domain
```

Start the deploy and all it's scripts with the install script:
```sh
sh install-hub.sh
```


### Post deploy follow up

If you use the `install-hub.sh` script, Tmux is used to start 3 script in the background for initial sync with the master hub.
- `0-hub_user_sync` - syncs all registerd Threebot users from the master hub (will exit after sync)
- `0-hub_sync` - syncs all flist data from the master hub: this is the only script that keeps running after sync, to keep this slave in sync with the master hub
- `0-bootstrap_sync` - syncs all available kernels from the master bootstrap (will exit after sync)

