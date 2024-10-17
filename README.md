<h1>ThreeFold Grid Full Stack</h1> 

<h2>Table of Contents</h2>

- [Introduction](#introduction)
- [TFGrid Full Stack Components](#tfgrid-full-stack-components)
- [TFGrid Backend](#tfgrid-backend)
- [TFGrid Zero-OS Hub](#tfgrid-zero-os-hub)
- [TFGrid Zero-OS Bootstrap Generator](#tfgrid-zero-os-bootstrap-generator)
- [TFChain Validator](#tfchain-validator)
- [TFGrid Snapshots](#tfgrid-snapshots)

---

## Introduction

This repo provides all tools required to setup a Threefold Grid Full Stack. Such a stack will be completely standalone, is made up of several services and provide you with all available grid functionalities.  

## TFGrid Full Stack Components

The TFGrid Full Stack is composed of:

- TFGrid Backend
- TFGrid Zero-OS Hub
- TFGrid Zero-OS Bootstrap Generator
- TFChain Validator

## TFGrid Backend

For each of the Threefold Grid networks (Devnet, QAnet, Testnet & Mainnet), the respective grid backend can be deployed using docker compose.  
[Have a look at the documentation to get started.](https://github.com/threefoldtech/grid_deployment/tree/development/docker-compose)

## TFGrid Zero-OS Hub

The Zero-OS Hub is used to distribute Flist files. Users use Flists to deploy workloads on 3Nodes.

## TFGrid Zero-OS Bootstrap Generator

The bootstrap service is used to create ZOS bootstrap images. Farmers use such images to deploy 3Nodes on the Grid.

## TFChain Validator

The grid run on TFChain. We provide an easy installer to set up a validator.

## TFGrid Snapshots

Daily snapshots can be found [here](https://bknd.snapshot.grid.tf/).

To set up your own snapshot creation, read [this documentation](https://github.com/threefoldtech/grid_deployment/tree/development/grid-snapshots).

You can also use Rsync to download the snapshots. Check [this link](https://github.com/threefoldtech/grid_deployment/tree/development/grid-snapshots#public-rsync-provided-by-threefold).
