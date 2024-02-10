# Running a Grid backend stack

Up to date scripts & docker-compose versions will be maintained for dev, test and mainnet.

Under development - documentation to be written.

### Requirements

To start a full Grid backend stack one needs the following:

-- Configuration
- one static IPv4 and IPv6 ip
- one A and one AAAA record to expose all services on. This can be the root of a domain or a subdomain but both must be wildcard records like *.your.domain ([see table for more info](#setting-the-dns-records))
- 'node key' for the TFchain public RPC node, generated with `subkey`
- mnemonic for a wallet on TFchain for the activation service, **this wallet needs funds** and does not need a Twin ID
- mnemonic for a wallet on TFchain for the Grid proxy service, **this wallet needs funds AND a registered Twin ID*

-- Hardware
- min of 8 modern CPU cores
- min of 32GB RAM
- min of 1TB SSD storage (high preference for NVMe based storage)

#### Setting the DNS Records

The following table explicitly shows how to set the A and AAAA records for your domain.

| Type | Host | Value          |
| ---- | ---- | -------------- |
| A    | \*   | <ipv4_address> |
| AAAA | \*   | <ipv6_address> |


### Files for each net

Each folder contains the required deployment files for it's net, work in the folder that has the name of the network you want to deploy on.

What does each file do:
- `.env` - contains environment files maintaned by Threefold Tech
- `.gitignore` - has a list of files to ignore once the repo has been cloned. This has the purpose to not have uncommited changes to files when working in this repo
- `.secrets.env-examples` - is where you have to add all your unique environment variables
- `Caddyfile-example` - contains a full working Caddy config. It is copied by the `install_grid_bknd.sh` script to `Caddyfile`. If you don't use this script, copy the file yourself
- `docker-compose.yml` - has all the required docker-compose configuration to deploy a working Grid stack
- `install_grid_bknd.sh` - is a script to make deploying from 0 easy
- `re-sync_processor.sh` - is a script to re-sync the Graphql processor with the hand of a online snapshot
- `typesBundle.json` - contains data for the Graphql indexer and is not to be touched


### Deploy a full stack

`cd` into the correct folder for the network your deploying for, our example uses mainnet.

```sh
cd mainnet
cp .secrets.env-example .secrets.env
cp Caddyfile-example Caddyfile
```

Open `.secrets.env` and add your unique variables

Deploy by executing the script.

```sh
sh install_grid_bknd.sh
```

Or manually.

```sh
docker compose --env-file .secrets.env --env-file .env up -d
```

Check if all environment variables are correct.

```
docker compose --env-file .secrets.env --env-file .env config
```


DNS records that Caddy will request certificates for, with *.your.domain as example:
- dashboard.your.domain
- metrics.your.domain
- tfchain.your.domain
- graphql.your.domain
- relay.your.domain
- gridproxy.your.domain
- activation.your.domain
- stats.your.domain


### Update

`cd` into the correct folder for the network your deploying for, our example uses mainnet.

```sh
git pull -r
docker compose --env-file .secrets.env --env-file .env up -d
```

