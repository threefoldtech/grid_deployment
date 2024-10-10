#!/bin/bash

# Ask user to make system changes
while true; do
read -p "This script will make changes to your Linux installation. Do you want to proceed? (y/n) " yn
case $yn in
        [yY] ) echo "OK! We will proceed.";
                break;;
        [nN] ) echo "OK! Exiting the script.";
                exit;;
        * ) echo "Your answer is invalid.";;
esac
done

# Ask user to run prerequisites script
while true; do
read -p "Do you want to run the prerequisites script? This will prepare your environment to run the Grid backend. (y/n) " yn
case $yn in
        [yY] ) echo "OK! We will run the prerequisites script.";
                bash ../apps/prep-env-prereq.sh --skip-node-exporter
                break;;
        [nN] ) echo "OK! Moving to the next step...";
                break;;
        * ) echo "Your answer is invalid.";;
esac
done

## Service prerequisites
mkdir -p /srv/0-db_data /srv/0-db_index /srv/0-hub_public/users /srv/0-hub_workdir /srv/caddy/data /srv/caddy/config /srv/caddy/log
apt update && apt install python3 python3-requests python3-pip -y
pip3 install pynacl
pip3 install redis 


## Hub: set all required keys in config.py
set -e
cp config.py-example config.py

### zflist binary
config_zflist="/usr/bin/zflist"

### generate base64 private key
pkeyfile=$(mktemp)
openssl genpkey -algorithm x25519 -out ${pkeyfile}
config_threebot_pkey=$(openssl pkey -in ${pkeyfile} -text | xargs | sed -e 's/.*priv\:\(.*\)pub\:.*/\1/' | xxd -r -p | base64)
rm -f ${pkeyfile}

### threebot appid
config_threebot_appid="my.app.id"

### generate threebot seed
python3 <<EOF
import nacl.utils
seed = nacl.utils.random(32)
with open('config.py', 'r') as file:
    contents = file.read()
with open('config.py', 'w') as file:
    file.write(contents.replace('__THREEBOT_SEED__', str(seed)))
EOF

### apply to config.py
sed -i "s#__ZFLIST_BIN__#${config_zflist}#" config.py
sed -i "s#__THREEBOT_PRIVATEKEY__#${config_threebot_pkey}#" config.py
sed -i "s#__THREEBOT_APPID__#${config_threebot_appid}#" config.py
sed -i "s/'readonly': True,/'readonly': False,/g" config.py


# Check if .env file exists
if [[ -f ./.env ]]; then
	    source ./.env
    else
	      echo ".env file not found!"
	        exit 1
fi

# Check if DOMAIN variable is set
if [[ -z "$DOMAIN" ]]; then
	  echo "DOMAIN is not set in the .env file"
	    exit 1
fi

## Hub: set all required domains in config.py
sed -i "s#__DOMAIN__#${DOMAIN}#g" config.py

### Start Grid backed services with docker-compose and scripts
docker compose --env-file .env up -d
