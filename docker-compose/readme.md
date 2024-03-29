# Running a Grid backend stack

Up to date scripts & docker-compose versions will be maintained for dev, qa, test and mainnet.


### Requirements

To start a full Grid backend stack one needs the following:

-- Configuration
- one static IPv4 and IPv6 ip
- one A and one AAAA record to expose all services on. This can be the root of a domain or a subdomain but both must be wildcard records like *.your.domain ([see table for more info](#setting-the-dns-records))
- 'node key' for the TFchain public RPC node, generated with `subkey generate-node-key`
- mnemonic for a wallet on TFchain for the activation service, **this wallet needs funds** and does not need a Twin ID
- mnemonic for a wallet on TFchain for the Grid proxy service, **this wallet needs funds AND a registered Twin ID**

-- Hardware
- min of 8 modern CPU cores
- min of 32GB RAM
- min of 1TB SSD storage (high preference for NVMe based storage) preferably more (as the chain keeps growing in size)

Dev, QA and Testnet can do with a Sata SSD setup. Mainnet requires NVMe based SSDs due to the data size.

**Note**: If a deployment does not have enough disk iops available one can see the processor container restarting regulary alongside grid_proxy errors regarding processor database timeouts.


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

Check if all environment variables are correct.

```
docker compose --env-file .secrets.env --env-file .env config
```

Deploy by executing the script. This can take a few hours since large snapshot data needs to be downloaded and extracted.

```sh
sh install_grid_bknd.sh
```

Or manually without snapshots. Depending on the available disk iops available, it can take up until a week to sync from block 0.

```sh
docker compose --env-file .secrets.env --env-file .env up -d
```

### DNS

The .secrets.env file contains a DOMAIN environment variable which is used in docker compose itself and inside several containers. After you deploy caddy will request several certificates for subdomains of your provided DOMAIN environment variable.
Make sure the above DNS requirements are met, IPv6 is optional but we strongly encourage to configure it by default.

These subdomains wille be generated and for which Caddy will request a certificate for , *.your.domain as example:
- dashboard.your.domain
- metrics.your.domain
- tfchain.your.domain
- indexer.your.domain (Devnet only)
- graphql.your.domain
- relay.your.domain
- gridproxy.your.domain
- activation.your.domain
- stats.your.domain


### Firewall

A correct firewall config is essential! We use NFTables by default: https://wiki.nftables.org/wiki-nftables/index.php/Main_Page
We want the following ports to be publicly exposed for the stack to function correctly:
- 80/TCP -> redirect to 443
- 443/TCP -> Grid services over HTTPS
- 30333/TCP -> libp2p for TFchain communication
- 22/TCP -> SSH: preferably use a none standard port (other then 22)

Example config for
- `eno1` as internal subnet
- `eno2` as external subnet

```sh
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
  chain input {
    type filter hook input priority filter; policy accept;
    ct state { established, related } accept
    ct state invalid drop
    iifname "lo" accept
    iifname "eno1" accept
    iifname "docker0" accept
    ip protocol icmp accept
    ip6 nexthdr ipv6-icmp accept
    iifname "eno2" jump public
  }

  chain forward {
    type filter hook forward priority filter; policy accept;
  }

  chain output {
    type filter hook output priority filter; policy accept;
  }

  chain public {
    # otherwise expose ports we want to expose
    tcp dport { 80, 443, 30333 } counter packets 0 bytes 0 accept
    # public ssh
    tcp dport 22 counter accept
    # separate counter to monitor default ssh port
    tcp dport 22 counter drop
    counter drop
  }
}

table inet nat {
  chain prerouting {
    type nat hook prerouting priority dstnat; policy accept;
  }

  chain input {
    type nat hook input priority 100; policy accept;
  }

  chain output {
    type nat hook output priority -100; policy accept;
  }

  chain postrouting {
    type nat hook postrouting priority srcnat; policy accept;
    ip saddr 172.16.0.0/12 masquerade
  }
}
```

**Note**: In case you use nftables, disable iptables for docker in `/lib/systemd/system/docker.service` by adding `--iptables=false` at the end of `ExecStart=`


For iptables one can use UFW

```sh
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 30333/tcp
ufw allow 22/tcp
ufw enable
ufw status
```


### Update

`cd` into the correct folder for the network your deploying for, our example uses mainnet.

**Note**: Only list services at the end of this command of which you know there is an update for, example for the `grid_relay`.

```sh
git pull -r
docker compose --env-file .secrets.env --env-file .env up --no-deps -d grid_relay
```

Example for `grid_relay` and `grid_dashboard`.

```sh
git pull -r
docker compose --env-file .secrets.env --env-file .env up --no-deps -d grid_relay grid_dashboard
```


### Metrics

Quite a bunch of Prometheus based metrics are exposed by default.

- Caddy: https://metrics.your.domain/caddy
- TFchain: https://metrics.your.domain/metrics
- Grid Relay: https://relay.your.domain/metrics
- Graphql Indexer: https://metrics.your.domain/indexer/_status/vars
- Graphql Processor: https://metrics.your.domain/graphql/metrics

Note: some metrics are global metrics from the grid, some are regarding the local stack deployment

Example Prometheus server configuration, replace `your.domain` by your domain configured in .secrets.env:

```sh
# Threefold Grid backend - example Prometheus config
global:
  scrape_interval: 15s
  evaluation_interval: 15s

# Caddy (proxy) - Mainnet
  - job_name: 'caddy-mainnet'
    metrics_path: /caddy
    scheme: https
    tls_config:
       insecure_skip_verify: true
    static_configs:
      - targets:
        - metrics.your.domain:443
        labels:
          backend: 'grid-caddy-mainnet'
          
# TFchain public RPC node - Mainnet
  - job_name: 'substrate_mainnet'
    metrics_path: /metrics
    scrape_interval: 5s
    static_configs:
      - targets:
        - metrics.your.domain
        labels:
          backend: 'grid-substrate-mainnet'

## Relay (RMB) - Mainnet
  - job_name: 'relay-mainnet'
    static_configs:
      - targets: 
        - relay.your.domain
        labels:
          backend: 'grid-relay-mainnet'

## GraphQL Indexer - Mainnet
  - job_name: 'indexer-mainnet'
    metrics_path: /indexer/_status/vars
    static_configs:
      - targets:
        - metrics.your.domain
        labels:
          backend: 'grid-indexer-mainnet'

## GraphQL Processor - Mainnet
  - job_name: 'graphql-mainnet'
    metrics_path: /graphql/metrics
    static_configs:
      - targets:
        - metrics.your.domain
        labels:
          backend: 'grid-graphql-mainnet'
```
