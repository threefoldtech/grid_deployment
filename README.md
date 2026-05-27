# Grid Deployment

Docker Compose configurations, deployment scripts, and snapshot management for running a full grid backend stack.

## What this is

Grid Deployment provides the automation needed to deploy a complete grid infrastructure locally or on remote servers with minimal configuration. It orchestrates chain nodes, GraphQL indexers, a flist hub, a bootstrap generator, and supporting services into a stand-alone, fully functional stack.

A full stack deployment includes all grid functionalities and can be run independently for development, testing, or production operations.

## What this repository contains

- `docker-compose/` — Docker Compose configurations for the grid backend (Devnet, QAnet, Testnet, Mainnet)
- `grid-hub/` — deployment configuration for the Zero-OS Hub
- `grid-bootstrap/` — deployment configuration for the bootstrap generator
- `tfchain-validator/` — installer and configuration for TFChain validators
- `grid-snapshots/` — scripts and documentation for snapshot creation and download

## Role in the stack

Grid Deployment ties together multiple backend services into a single operational unit. It handles:

- Blockchain node operation via ledger_chain
- Grid indexing and query APIs via GraphQL
- Workload image distribution via the hub
- Node bootstrapping via the bootstrap generator

This repository is the operational entry point for anyone running grid backend infrastructure, whether for a public network or a private deployment.

## Relation to ThreeFold

This technology is used within the ThreeFold ecosystem and was first deployed on the ThreeFold Grid. The component itself is designed as reusable infrastructure technology and should be understood by its technical function first, independent of any specific deployment.

## Ownership

This repository is owned and maintained by TF-Tech NV, a Belgian company responsible for the development and maintenance of this technology.

## Components

### Grid Backend

For each network (Devnet, QAnet, Testnet, Mainnet), the respective grid backend can be deployed using Docker Compose.

See [docker-compose/readme.md](./docker-compose/readme.md) for details.

### Grid Hub

The hub distributes flist files. Users reference flists when deploying workloads on nodes.

See [grid-hub/readme.md](./grid-hub/readme.md) for details.

### Grid Bootstrap Generator

The bootstrap service creates Zero-OS bootstrap images. Farmers use bootstrap images to set up nodes.

See [grid-bootstrap/readme.md](./grid-bootstrap/readme.md) for details.

### Ledger Chain Validator

The grid runs on ledger_chain. An easy-to-use installer is provided to set up a validator.

See [tfchain-validator/readme.md](./tfchain-validator/readme.md) for details.

### Snapshots

Daily backend and validator snapshots are available at [https://bknd.snapshot.grid.tf/](https://bknd.snapshot.grid.tf/).

To set up your own snapshot creation, see [grid-snapshots/readme.md](./grid-snapshots/readme.md).

You can also use Rsync to download snapshots. See the [ThreeFold public Rsync section](./grid-snapshots/readme.md#threefold-public-rsync) for more information.

## License

This project is licensed under the Apache License 2.0 — see the [LICENSE](LICENSE) file for details.
