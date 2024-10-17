<h1>ThreeFold Grid Full Stack</h1> 

<h2>Table of Contents</h2>

- [Introduction](#introduction)
- [Full Stack Components](#full-stack-components)
- [Grid Backend](#grid-backend)
- [Grid Hub](#grid-hub)
- [Grid Bootstrap](#grid-bootstrap)
- [TFChain Validator](#tfchain-validator)
- [Grid Snapshots](#grid-snapshots)

---

## Introduction

This repo provides all tools required to setup a Threefold Grid Full Stack. Such a stack will be completely standalone, is made up of several services and provide you with all available grid functionalities.  

## Full Stack Components

The TFGrid Full Stack is composed of:

- Grid Backend
- Grid Hub
- Grid Bootstrap
- TFChain Validator

## Grid Backend

One can deploy a grid backend with docker compose for each of the Threefold Grid networks (Devnet, QAnet, Testnet & Mainnet).  
[Have a look at the documentation to get started.](https://github.com/threefoldtech/grid_deployment/tree/development/docker-compose)

## Grid Hub

The ZOS Hub is used to distribute Flist files. Users use Flists to deploy workloads on 3Nodes.

## Grid Bootstrap

The bootstrap services is used to create ZOS bootstrap images. Farmers use such images to deploy 3Nodes on the Grid.

## TFChain Validator

The grid run on TFChain. We provide an easy installer to setup a validator.

## Grid Snapshots

Daily snapshots can be found [here](https://bknd.snapshot.grid.tf/).

To set up your own snapshot creation, read [this documentation](https://github.com/threefoldtech/grid_deployment/tree/development/grid-snapshots).

You can also use Rsync to download the snapshots. Check [this link](https://github.com/threefoldtech/grid_deployment/tree/development/grid-snapshots#public-rsync-provided-by-threefold).
