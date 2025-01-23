# Running the Hub and Bootstrap stack

Documentation on how to deploy an independent Hub.

These deployments will act as slave instances and sync some flist from https://hub.grid.tf.


### Requirements

To start a Hub needs the following:

-- Configuration
- a working Docker environment
- one static IPv4 and IPv6 ip
- one A and one AAAA record to expose all services on. This can be the root of a domain or a subdomain but both must be wildcard records like *.your.domain ([see table for more info](#setting-the-dns-records))

-- Hardware
- min of 2 modern CPU cores
- min of 4GB RAM
- min of 100 SSD/HDD storage


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
| A    | hub.your.domain         | <ipv4_address> |
| AAAA | hub.your.domain         | <ipv6_address> |



### Files

- `.env` - contains environment variables maintaned by Threefold Tech and **your domain environment variable**
- `.gitignore` - has a list of files to ignore once the repo has been cloned. This has the purpose to not have uncommited changes to files when working in this repo
- `Caddyfile` - contains a fully working Caddy config used to expose the services
- `docker-compose.yml` - docker-compose file to deploy a Hub, Bootstrap and Caddy
- `install_hub.sh` - script to install prerequisites, docker-compose and post-install scripts for Ubuntu
- `config.py-example` - example file for hub config
- `flist_manager.py` - Python script to manage and sync FLists.
- `flists.txt` - A text file containing a list of FList URLs to be processed by `flist_manager.py`.


### Storage

We use docker to run the services and mount several directories for persistent data. **These will all be mounted inside** `/srv`.
You can control how (software raid, bcachefs, ..) this data will be stored by mounting `/srv` to any redundant storage configuration of your choosing.


### Deploy a Hub

Clone the repo and cd into the hub stack dir
```sh
git clone https://github.com/threefoldtech/grid_deployment.git
cd grid_deployment/grid-hub_standalone
```

Open `.env` and save your domain. Example for `hub.your.domain`
```sh
DOMAIN=your.domain
```

Start the deploy and all its scripts with the install script:
This script also runs the `flist_manager.py` to process FList URLs specified in the `flists.txt` file, ensuring proper synchronization and directory management.
```sh
sh install-hub.sh
```

### Running the `flist_manager.py`

#### Requirements
Ensure that:
- `flists.txt` file is updated with all required FList URLs.

#### Steps to Execute
1. Run the script inside the container without logging in:
   ```sh
   docker exec -it 0-hub python3 /hub/src/flist_manager.py /hub/src/flists.txt
   ```

This will process all FList URLs specified in the `flists.txt` file and save them to their appropriate directories.
