<h1>TFGrid Validator</h1>

<h2>Table of Contents</h2>

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Hardware](#hardware)
  - [Requirements](#requirements)
    - [Standard Hardware](#standard-hardware)
- [1. Generate keys](#1-generate-keys)
  - [1.1 Generate the Validator Account Key](#11-generate-the-validator-account-key)
  - [1.2 Generate the Node (aka Network) Key](#12-generate-the-node-aka-network-key)
  - [1.3 Derive the GRANDPA Key](#13-derive-the-grandpa-key)
  - [1.4 Store all generated keys](#14-store-all-generated-keys)
- [2. Deploy the TFchain validator](#2-deploy-the-tfchain-validator)
  - [2.1 Prepare the .secrets.env file](#21-prepare-the-secretsenv-file)
  - [2.2 Insert Session Keys](#22-insert-session-keys)
  - [2.3 Deploy the validator](#23-deploy-the-validator)
- [3. Set Session Keys On-Chain](#3-set-session-keys-on-chain)
  - [3.1 Add Validator Account to Polkadot.js Extension](#31-add-validator-account-to-polkadotjs-extension)
  - [3.2 Set Session Keys via PolkadotJS Apps](#32-set-session-keys-via-polkadotjs-apps)
- [4. Submit a Council Motion to Add Validator](#4-submit-a-council-motion-to-add-validator)
- [5. Finalize and Start Validating](#5-finalize-and-start-validating)
  - [Ensure Node Health](#ensure-node-health)
- [References](#references)

---

## Introduction

We document the procedures to add a validator to an existing TFChain network. We provide a step-by-step process to add a validator to the TFChain network based on docker-compose. It is an extension from the [official tfchain repo documentation](https://github.com/threefoldtech/tfchain/blob/development/docs/misc/adding_validators.md).

This documentation covers the following stes: generating keys using `subkey` via Docker, starting the node, inserting keys using a script, and submitting the necessary proposals for validation.

## Prerequisites

- **Docker Installed**: Ensure Docker is installed and running on your machine (installation is included in the prerequisites script)
- **Access to a Server or Machine**: Where you will run the TFChain node and `subkey` via Docker
- **Polkadot.js Browser Extension**: For managing accounts and signing transactions on your client device / browser
- **Basic Knowledge**: Familiarity with command-line operations and blockchain concepts


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


## 1. Generate keys

Go into the network directory for the network you are deploying a validator for. The following example is for mainnet:

```sh
git clone https://github.com/threefoldtech/grid_deployment.git
cd grid_deployment/tfchain-validator/mainnet
sh ../../apps/prep-env-prereq.sh
```

Next three steps will generate the keys required to run your validator. Keep this information secure: don't store them as plain text, but encrypted in some password manager (like Keepass).
Not all keys generated will be used to run your validator, this is normal. It's important to keep these keys for specific situations in the future. For example to redeploy in case your validator got lost, to do some required chain calls like setting your public keys, in case of a change after runtime upgrade.


### 1.1 Generate the Validator Account Key

We'll use `subkey` via Docker to generate a new key pair for your validator account. Alternatively, the apps dir also contains a static binary for Linux.

```bash
docker run --rm parity/subkey:latest generate --scheme sr25519
```

Take note of the following:
- **Secret Phrase (Mnemonic)**: Securely store this mnemonic; it's crucial for account recovery.
- **Secret Seed**
- **Public Key (hex)**
- **SS58 Address**: This is your validator's account address.

This key will serve as your validator controller account and session key for AURA (validator node/author account). The Mnemonic will be used to initialize your validator (by adding it to the .secrets.env file), it will also be used to derive the GRANDPA key later on.

> Note: Please keep this information safe and stored in an encrypted form, not in plain text.


### 1.2 Generate the Node (aka Network) Key

Generate the node key file, which identifies your node in the P2P network.

```bash
docker run --rm parity/subkey:latest generate-node-key > "validator_private_node_key"
```

This command outputs a public key and writes the secret seed (private key) to the <node_private_key_file> file. You'll use the private key when starting the node (by adding it to the .secrets.env file).

> Note: Please keep this information safe and stored in an encrypted form, not in plain text. Store both the private and the public keys.


### 1.3 Derive the GRANDPA Key

Using the same mnemonic from step 1.1, derive the GRANDPA key (Ed25519).

```bash
docker run --rm parity/subkey:latest inspect --scheme ed25519 "mnemonic phrase"
```

Replace `"mnemonic phrase"` with your actual mnemonic enclosed in quotes.

Note down the **Public Key (hex)** for GRANDPA. This key will serve as your session key for GRANDPA and will be used later on to insert your session keys on the chain.

> Note: Please keep this information safe and stored in an encrypted form, not plain text.


### 1.4 Store all generated keys

Stora all your keys safely behind a password and preferably encrypted in a password manager (like Keepass). Below is an example of all the generated keys that should be stored for each validator:
```sh
# SR25519 key (also called the AURA key)
➜ docker run --rm parity/subkey:latest generate --scheme sr25519
Secret phrase:       birth illness item heavy embark bacon force shield reason normal walnut appear
  Network ID:        substrate
  Secret seed:       0xab2815226af6e96b498f2859254154396122160544dfe035d07c7e673c0511ca
  Public key (hex):  0x1eaafb158306e56b0a49c96903cbd180aebbf46ddd787dbe2e34fa652474ca58
  Account ID:        0x1eaafb158306e56b0a49c96903cbd180aebbf46ddd787dbe2e34fa652474ca58
  Public key (SS58): 5Ckv5vEiHT6piWLHKR26P4StaeFkSvN895tpZg6ptVkAerB4
  SS58 Address:      5Ckv5vEiHT6piWLHKR26P4StaeFkSvN895tpZg6ptVkAerB4

# Node key
➜  docker run --rm parity/subkey:latest generate-node-key > "validator_private_node_key"
12D3KooWBh1KZREg9sxpMpD9aACtuEq9DZeNhqYjcLhR7ZMSPG3B
➜  ls                             
validator_private_node_key

# ED25519 (also called the GRANDPA key)
➜  docker run --rm parity/subkey:latest inspect --scheme ed25519 "birth illness item heavy embark bacon force shield reason normal walnut appear"
Secret phrase:       birth illness item heavy embark bacon force shield reason normal walnut appear
  Network ID:        substrate
  Secret seed:       0xab2815226af6e96b498f2859254154396122160544dfe035d07c7e673c0511ca
  Public key (hex):  0xc08fc5e91f5691791e2454baf6f0719fd881e6619950538cf7c3f90ddda01ebc
  Account ID:        0xc08fc5e91f5691791e2454baf6f0719fd881e6619950538cf7c3f90ddda01ebc
  Public key (SS58): 5GRBm4kUeKE7cKZMhZhRF1nEBAg4MHTAVmzxo2KAbh3TQyLQ
  SS58 Address:      5GRBm4kUeKE7cKZMhZhRF1nEBAg4MHTAVmzxo2KAbh3TQyLQ
```

## 2. Deploy the TFchain validator

### 2.1 Prepare the .secrets.env file

First copy the example:

```sh
cd grid_deployment/tfchain-validator/mainnet
cp .secrets.env-example .secrets.env
```

Add the following to the `.secrets.env` file
- `TFCHAIN_NODE_KEY=` - generated node key from step 1.2
- `NODE_NAME=` - identify your node by giving it an appropriate name (without spaces or special characters)
- `MNEMONIC=""` - generated mnemonic from step 1.1 (place it in between the brackets)

As an example the file should look like this
```sh
#########################################
#     Unique Grid backend variables     #
#########################################
### Custom variables - this seciton must be provided by the entity running this backend stack. See documentation.

# Enter the TFchain node node-key
# NOTE: make sure this is an unique node-key for each instance !
TFCHAIN_NODE_KEY=a45ae624585f300d42170b052ed8a859aea38202f48805faf246db0e2d3c6e3e

# Enter a name for your validator
# NOTE: this name will appear at https://telemetry.tfchain.grid.tf/ and serves no perpose, only for recognition
NODE_NAME=bob-validator

# !! Only required for validator initialization, not for running a validator !!
# Enter the mnemonic of your TFchain validator wallet
# NOTE: this variable should be removed once the validator keys have been inserted! Keep this mnemonic safe and don't forget to remove it here. Check the readme.
MNEMONIC="birth illness item heavy embark bacon force shield reason normal walnut appear"
```


### 2.2 Insert Session Keys

Once the `.secrets.env` file has been completed, we run the init script to insert the AURA and GRANDPA keys into the correct location.

```sh
sh validator-init.sh
```


### 2.3 Deploy the validator

Once all prerequisites have been met, start the validator.

```sh
sh install-tfchain-validator.sh
```

Check the logs by starting the provided script.
```sh
sh open_logs_tmux.sh
tmux a
```

Or check the logs manually by:
```sh
docker logs tfchain-validator -f --tail 500
```


## 3. Set Session Keys On-Chain

To have your node recognized as a validator, you need to set your session keys on-chain.

### 3.1 Add Validator Account to Polkadot.js Extension

- Open the Polkadot.js browser extension.
- Import your validator controller account using the mnemonic from step 1.1.
- Ensure you have some TFT tokens in this account (0.1 TFT should suffice for transaction fees).

### 3.2 Set Session Keys via PolkadotJS Apps

1. Navigate to [PolkadotJS Apps](https://polkadot.js.org/apps/).
2. Connect to the TFChain network (e.g., wss://tfchain.dev.grid.tf).
3. Go to **Developer → Extrinsics**.
4. Select your validator controller account as the signer.
5. Choose `session` → `setKeys(keys, proof)`.
6. Input your session keys:

   - **keys**: Use previously generated aura and gran hex public keys
     - **aura**: Manually enter the hex public key of the sr25519 key
     - **gran**: Manually enter the hex public key of the ed25519 key

   - **proof**: Set to `0x00`

7. Submit the transaction. Once the session keys are set on-chain, your validator will be recognized by the network.


## 4. Submit a Council Motion to Add Validator

The TFChain network requires a governance proposal to add a validator node.

1. Navigate to **Governance → Council**.
2. Click on **Propose Motion**.
3. Select `validatorSet` → `addValidator(validatorId)`.
4. Input your validator controller account's SS58 address (generated in step 1.1).
5. Submit the proposal.

After submission, inform other council members and request them to vote on the proposal.


## 5. Finalize and Start Validating

Once your session keys are set and the council approves your validator, your node will start participating in block production after 2 sessions.


### Ensure Node Health

- Keep your node online and synchronized.
- Monitor logs for any errors or warnings.

## References

- **Subkey Utility via Docker**: [Parity Subkey Docker Image](https://hub.docker.com/r/parity/subkey)
- **TFChain Docker Images**: [TFChain Docker Packages](https://github.com/threefoldtech/tfchain/pkgs/container/tfchain)
- **PolkadotJS Apps**: [PolkadotJS Interface](https://polkadot.js.org/apps/)
- **PolkadotJS Extension**: [Browser Extension](https://polkadot.js.org/extension/)
- **Validator Set Pallet**: [Substrate Validator Set Module](https://github.com/gautamdhameja/substrate-validator-set)
- **Council Integration Guide**: [Council Integration](https://github.com/gautamdhameja/substrate-validator-set/blob/master/docs/council-integration.md)
- **Polkadot Validator Guide**: [How to Validate on Polkadot](https://wiki.polkadot.network/docs/maintain-guides-how-to-validate-polkadot)
