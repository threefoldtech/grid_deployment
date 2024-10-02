# Adding your Validator to an Existing TFChain Network

This guide provides a step-by-step process to add a validator to the TFChain network based on docker-compose. It is an extension from the [official tfchain repo documentation](https://github.com/threefoldtech/tfchain/blob/development/docs/misc/adding_validators.md)
It covers generating keys using `subkey` via Docker, starting the node, inserting keys using a script, and submitting the necessary proposals for validation.


## Prerequisites

- **Docker Installed**: Ensure Docker is installed and running on your machine.
- **Access to a Server or Machine**: Where you can run the TFChain node and `subkey` via Docker.
- **Polkadot.js Browser Extension**: For managing accounts and signing transactions.
- **Basic Knowledge**: Familiarity with command-line operations and blockchain concepts.


## Hardware

### Requirements

The most common way for a beginner to run a validator is on a cloud server running Linux. You may choose any VPS provider you prefer and any operating system you are comfortable with.
For this guide, we will be using Ubuntu 22.04, but the instructions should be similar for other platforms.

The transaction weights in TFChain were benchmarked on standard hardware.
It is recommended that validators run at least the standard hardware to ensure they can process all blocks in time.
The following are not minimum requirements, but if you decide to run with less than this, be aware that you might have performance issues.

#### Standard Hardware

- CPU
  - x86-64 compatible;
  - Intel Ice Lake, or newer (Xeon or Core series); AMD Zen3, or newer (EPYC or Ryzen);
  - 8 physical cores @ 3.4GHz;
  - Simultaneous multithreading disabled (Hyper-Threading on Intel, SMT on AMD);
  - Prefer single-threaded performance over higher core count. A comparison of single-threaded performance can be found here.
- Storage
  - An NVMe SSD. Should be reasonably sized to deal with blockchain growth. Minimum around 80GB but will need to be re-evaluated every six months.
- Memory
  - 64 GB DDR4 ECC.
- System
  - Linux Kernel 5.16 or newer.

The specs posted above are not a hard requirement to run a validator but are considered best practice. Running a validator is a responsible task, using professional hardware is a must in any case.


## 1. Deploy a TFchain validator

First of all, cd into the network directory for the network you are deploying a validator for. Example for mainnet:
```sh
cd ../grid_deployment/tfchain-validator/mainnet
```

￼
### 1.1 Generate the Validator Account Key

We'll use `subkey` via Docker to generate a new key pair for your validator account. Alternatively, the apps dir also contains a static binary for Linux

```bash
docker run --rm parity/subkey:latest generate --scheme sr25519
```

Take note of the following:
- **Secret Phrase (Mnemonic)**: Securely store this mnemonic; it's crucial for account recovery.
- **Secret Seed**
- **Public Key (hex)**
- **SS58 Address**: This is your validator's account address.

This key will serve as your validator controller account and session key for AURA (validator node/author account). It will also be used to derive the GRANDPA key. Please keep this information safe.


### 1.2 Generate the Node (aka Network) Key

Generate the node key file, which identifies your node in the P2P network.

```bash
docker run --rm parity/subkey:latest generate-node-key > "<node_private_key_file>"
```

This command outputs a public key and writes the secret seed (private key) to the <node_private_key_file> file. Keep the secret seed secure, you'll use it when starting the node.


### 1.3 Derive the GRANDPA Key

Using the same mnemonic from step 1.1, derive the GRANDPA key (Ed25519).

```bash
docker run --rm parity/subkey:latest inspect --scheme ed25519 "mnemonic phrase"
```

Replace `"mnemonic phrase"` with your actual mnemonic enclosed in quotes.

Note down the **Public Key (hex)** for GRANDPA. This key will serve as your session key for GRANDPA.


### 1.3 Prepare the .secrets.env file

First copy the example
```sh
cp .secrets.env-example .secrets.env
```

Add the following to the `.secrets.env` file
- `TFCHAIN_NODE_KEY=` - generated node key from step 1.2
- `NODE_NAME=` - identify your node by giving it an appropriate name
- `MNEMONIC=""` - generated mnemonic from step 1.1

As an example the file should look like this
```sh
#########################################
#     Unique Grid backend variables     #
#########################################
### Custom variables - this seciton must be provided by the entity running this backend stack. See documentation.

# Enter the TFchain node node-key
# NOTE: make sure this is an unique node-key for each instance !
TFCHAIN_NODE_KEY=12D3KooWMcAmUFBpgUXPscKXePG1L37vXcenTnoiC8Zp1V9x2A65

# Enter a name for your validator
# NOTE: this name will appear at https://telemetry.tfchain.grid.tf/ and serves no perpose, only for recognition
NODE_NAME=bob-validator

# !! Only required for validator initialization, not for running a validator !!
# Enter the mnemonic of your TFchain validator wallet
# NOTE: this variable should be removed once the validator keys have been inserted! Keep this mnemonic safe and don't forget to remove it here. Check the readme.
MNEMONIC="diary april breeze marble fit boss never solid next tooth must episode"
```


### 1.3 Insert Session Keys

Once the `.secrets.env` file has been completed, we run the init script to insert the AURA and GRANDPA keys into the correct location.

```sh
sh validator-init.sh
```


### 1.4 Deploy the validator

Once all prerequisites have been met, start the validator.

```sh
sh install-tfchain-validator.sh
```

Check the logs by starting the provided script
```sh
sh open_logs_tmux.sh
tmux a
```
