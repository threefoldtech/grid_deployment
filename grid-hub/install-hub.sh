#/bin/bash
## prerequisites
mkdir -p /srv/0-db_data /srv/0-db_index /srv/0-hub_public/users /srv/0-hub_workdir /srv/0-bootstrap/ipxe-template /srv/0-bootstrap/ipxe-template-uefi /srv/0-bootstrap/kernels/net /srv/caddy/data /srv/caddy/config /srv/caddy/log 
apt update && apt install python3 python3-redis python3-requests python3-pip -y
pip3 install pynacl
pip3 install redis

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
#sed -i "s#__THREEBOT_SEED__#${config_threebot_seed}#" config.py ## FIXME

## Hub: set all required domains in config.py
. ./.env
sed -i "s#__DOMAIN__#${DOMAIN}#g" config.py


## Bootstrap: set domain in config-bootstrap.py
cp config-bootstrap.py-example config-bootstrap.py
sed -i "s#__DOMAIN__#${DOMAIN}#g" config-bootstrap.py

## Bootstrap: set kernel links
for target in prod test dev qa; do
    ln -s /srv/0-bootstrap/kernels/zero-os-development-zos-v3-generic-23ebebd9f6-signed.efi /srv/0-bootstrap/kernels/net/${target}.efi
done


### Start Grid backed services with docker-compose and scripts
docker compose --env-file .env up -d

## Populate the users
tmux new -d -s 0-hub_user_sync
tmux send-keys -t 0-hub_user_sync "python3 hub-clone.py https://hub.grid.tf /srv/0-hub_public/users" ENTER

## Sync with hub.grid.tf and keep in sync
tmux new -d -s 0-hub_sync
tmux send-keys -t 0-hub_sync "python3 incremental.py" ENTER

## Initial sync with bootstrap.grid.tf
tmux new -d -s 0-bootstrap_sync
tmux send-keys -t 0-bootstrap_sync "python3 bootstrap-kernel-sync.py https://bootstrap.grid.tf /srv/0-bootstrap/kernels/" ENTER
