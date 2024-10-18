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

This repo provides all tools required for a Threefold Grid full stack deployment. A TFGrid full stack is completely stand-alone and made up of several services. It provides all available grid functionalities.  

## TFGrid Full Stack Components

The TFGrid full stack is composed of:

- TFGrid Backend
- TFGrid Zero-OS Hub
- TFGrid Zero-OS Bootstrap Generator
- TFChain Validator

## TFGrid Backend

For each of the Threefold Grid networks (Devnet, QAnet, Testnet & Mainnet), the respective grid backend can be deployed using docker compose.

Have a look at the [documentation](./grid-backend/readme.md) to get started.

## TFGrid Zero-OS Hub

The Zero-OS Hub is used to distribute Flist files. Users use Flists to deploy workloads on 3Nodes.

Have a look at the [documentation](./grid-hub-bootstrap/readme.md) to get started.

## TFGrid Zero-OS Bootstrap Generator

The bootstrap service is used to create ZOS bootstrap images. Farmers use bootstrap images to set up 3Nodes on the TFGrid.

Have a look at the [documentation](./grid-hub-bootstrap/readme.md) to get started.

## TFChain Validator

The TFGrid runs on TFChain. An easy-to-use installer is provided to set up a validator.

Have a look at the [documentation](./tfchain-validator/readme.md) to get started.

## TFGrid and TFChain Validator Snapshots

Daily TFGrid and TFChain validator snapshots can be found at [https://bknd.snapshot.grid.tf/](https://bknd.snapshot.grid.tf/). 

To set up your own TFGrid snapshot creation, read [this documentation](./grid-snapshots/readme.md).

To set up your own TFChain validator snapshot creation, read [this documentation](./tfchain-validator-snapshots/readme.md).

> Note: You can also use Rsync to download the snapshots. Read [this section](./grid-snapshots/readme.md#threefold-public-rsync) for more information.