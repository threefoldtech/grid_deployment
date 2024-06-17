#/bin/bash
# Script to initiate two compose based container that will insert aura and grandpa key based on the provided TFchain mnemonic

# Ask user to make system changes
while true; do
read -p "This script requires you to have created a .secrets.env file that contains your TFchain validator wallet mnemonic. Proceed? (y/n) " yn
case $yn in 
        [yY] ) echo "OK! We will proceed.";
                break;;
        [nN] ) echo "OK! Exiting the script.";
                exit;;
        * ) echo "Your answer is invalid.";;
esac
done

## Create directories
mkdir -p /srv/tfchain/

## Start Grid backed services with docker-compose
docker compose --env-file .secrets.env --env-file .env -f validator-init.yml up -d
