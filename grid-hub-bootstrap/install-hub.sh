#/bin/bash

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
                sh ../apps/prep-env-prereq.sh
                break;;
        [nN] ) echo "OK! Moving to the next step...";
                break;;
        * ) echo "Your answer is invalid.";;
esac
done

## Service prerequisites
mkdir -p /srv/0-db_data /srv/0-db_index /srv/0-hub_public/users /srv/0-hub_workdir /srv/0-bootstrap/kernels/net /srv/caddy/data /srv/caddy/config /srv/caddy/log 
apt update && apt install python3 python3-requests python3-pip -y
pip3 install pynacl --break-system-packages
pip3 install redis --break-system-packages

## Disable COW on BTRFS (optional in case of btrfs at /srv)
#chattr +C /srv/0-db_data
#chattr +C /srv/0-db_index


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
#config_threebot_seed=$(python3 -c "import nacl; from nacl import utils; print(nacl.utils.random(32))")
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
#sed -i "s#__THREEBOT_SEED__#${config_threebot_seed}#" config.py

## Hub: set all required domains in config.py
. ./.env
sed -i "s#__DOMAIN__#${DOMAIN}#g" config.py


## Bootstrap: set domain in config-bootstrap.py
cp config-bootstrap.py-example config-bootstrap.py
sed -i "s#__DOMAIN__#${DOMAIN}#g" config-bootstrap.py


### Start Grid backed services with docker-compose and scripts
docker compose --env-file .env up -d

## Populate the users
tmux new -d -s 0-hub_user_sync
tmux send-keys -t 0-hub_user_sync "while true; do python3 hub-clone.py https://hub.grid.tf /srv/0-hub_public/users; sleep 10m; done" ENTER

## Sync with hub.grid.tf and keep in sync
tmux new -d -s 0-hub_sync
tmux send-keys -t 0-hub_sync "python3 incremental.py" ENTER

## Initial sync with bootstrap.grid.tf
tmux new -d -s 0-bootstrap_sync
tmux send-keys -t 0-bootstrap_sync "python3 bootstrap-kernel-sync.py https://bootstrap.grid.tf /srv/0-bootstrap/kernels/" ENTER

## Bootstrap: set kernel links
docker exec -i 0-bootstrap /bin/bash <<EOF
cd /opt/kernels/net
ln -s ../zero-os-development-zos-v3-generic-23ebebd9f6-signed.efi prod.efi
ln -s ../zero-os-development-zos-v3-generic-23ebebd9f6-signed.efi test.efi
ln -s ../zero-os-development-zos-v3-generic-23ebebd9f6-signed.efi dev.efi
ln -s ../zero-os-development-zos-v3-generic-23ebebd9f6-signed.efi qa.efi
EOF
