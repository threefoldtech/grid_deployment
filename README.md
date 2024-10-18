<h1>ThreeFold Grid Full Stack</h1> 

<h2>Table of Contents</h2>

- [Introduction](#introduction)
- [TFGrid Full Stack Components](#tfgrid-full-stack-components)
- [TFGrid Backend](#tfgrid-backend)
- [TFGrid Zero-OS Hub](#tfgrid-zero-os-hub)
- [TFGrid Zero-OS Bootstrap Generator](#tfgrid-zero-os-bootstrap-generator)
- [TFChain Validator](#tfchain-validator)
- [TFGrid and TFChain Validator Snapshots](#tfgrid-and-tfchain-validator-snapshots)

---

## Introduction

This repo provides all tools required for a Threefold Grid Full Stack deployment. A TFGrid Full Stack is completely stand-alone and made up of several services. It provides all available grid functionalities.  

## TFGrid Full Stack Components

The TFGrid Full Stack is composed of:

- TFGrid Backend
- TFGrid Zero-OS Hub
- TFGrid Zero-OS Bootstrap Generator
- TFChain Validator

## TFGrid Backend

For each of the Threefold Grid networks (Devnet, QAnet, Testnet & Mainnet), the respective grid backend can be deployed using docker compose.

Have a look at the [documentation](https://github.com/threefoldtech/grid_deployment/tree/development/grid-backend) to get started.

## TFGrid Zero-OS Hub

The Zero-OS Hub is used to distribute Flist files. Users use Flists to deploy workloads on 3Nodes.

Have a look at the [documentation](https://github.com/threefoldtech/grid_deployment/tree/development/grid-hub-bootstrap) to get started.

## TFGrid Zero-OS Bootstrap Generator

The bootstrap service is used to create ZOS bootstrap images. Farmers use bootstrap images to set up 3Nodes on the TFGrid.

Have a look at the [documentation](https://github.com/threefoldtech/grid_deployment/tree/development/grid-hub-bootstrap) to get started.

## TFChain Validator

The TFGrid runs on TFChain. An easy-to-use installer is provided to set up a validator.

Have a look at the [documentation](https://github.com/threefoldtech/grid_deployment/tree/development/tfchain-validator) to get started.

## TFGrid and TFChain Validator Snapshots

Daily TFGrid and TFChain validator snapshots can be found at [https://bknd.snapshot.grid.tf/](https://bknd.snapshot.grid.tf/). 

To set up your own TFGrid snapshot creation, read [this documentation](https://github.com/threefoldtech/grid_deployment/tree/development/grid-snapshots). 

To set up your own TFChain validator snapshot creation, read [this documentation](https://github.com/threefoldtech/grid_deployment/tree/development/tfchain-validator-snapshots).

> Note: You can also use Rsync to download the snapshots. Read [this section](https://github.com/threefoldtech/grid_deployment/tree/development/grid-snapshots#public-rsync-provided-by-threefold) for more information.
