# Threefold Grid backend

This repo provides all tools required to setup a Threefold Guardian stack. Such a stack will be completely standalone, is made up of several services and provide you with all available grid functionality.  


## Grid backend services with docker compose

One can deploy a full grid backend stack with docker compose for each of the Threefold Grid networks (Devnet, QAnet, Testnet & Mainnet).  
[Have a look at the documentation to get started.](https://github.com/threefoldtech/grid_deployment/tree/development/docker-compose)


## Grid Hub

The hub is used to distribute flist files for ZOS to boot a users workload.


## Grid Bootstrap

The bootstrap services has to task to provide files to boot from over the internet.


## TFchain Validator

The grid run on TFchain, here you can find an easy installer to setup a validator.


## Grid snapshots

Daily snapshots can be found here: https://bknd.snapshot.grid.tf/  
[Have a look at the docs to setup your own snapshot creation](https://github.com/threefoldtech/grid_deployment/tree/development/grid-snapshots)

[One can also use `RSYNC` to download the snapshots](https://github.com/threefoldtech/grid_deployment/tree/development/grid-snapshots#public-rsync-provided-by-threefold)
