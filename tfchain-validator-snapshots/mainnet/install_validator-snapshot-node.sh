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
read -p "Do you want to run the prerequisites script? This will prepare your environment to run the TFChain validator snapshot node. (y/n) " yn
case $yn in 
        [yY] ) echo "OK! We will run the prerequisites script.";
                sh ../../apps/prep-env-prereq.sh
                break;;
        [nN] ) echo "OK! Moving to the next step...";
                break;;
        * ) echo "Your answer is invalid.";;
esac
done

## Create directories
mkdir -p /srv/tfchain/

## Start Grid backed services with docker-compose
docker compose --env-file .secrets.env --env-file .env up -d