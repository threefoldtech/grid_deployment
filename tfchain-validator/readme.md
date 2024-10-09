# Adding your Validator to an Existing TFChain Network

This guide provides a step-by-step process to add a validator to the TFChain network based on docker-compose. It is an extension from the [official tfchain repo documentation](https://github.com/threefoldtech/tfchain/blob/development/docs/misc/adding_validators.md)
It covers generating keys using `subkey` via Docker, starting the node, inserting keys using a script, and submitting the necessary proposals for validation.


## Prerequisites

- **Docker Installed**: Ensure Docker is installed and running on your machine
- **Access to a Server or Machine**: Where you can run the TFChain node and `subkey` via Docker
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


## 1. Deploy a TFchain validator

Cd into the network directory for the network you are deploying a validator for. Example for mainnet:
```sh
git clone https://github.com/threefoldtech/grid_deployment.git
cd grid_deployment/tfchain-validator/mainnet
```


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

This key will serve as your validator controller account and session key for AURA (validator node/author account). It will also be used to derive the GRANDPA key.
**Please keep this information safe and stored in an encrypted form, not plain text.**


### 1.2 Generate the Node (aka Network) Key

Generate the node key file, which identifies your node in the P2P network.

```bash
docker run --rm parity/subkey:latest generate-node-key > "<node_private_key_file>"
```

This command outputs a public key and writes the secret seed (private key) to the <node_private_key_file> file. Keep the secret seed secure, you'll use it when starting the node.
**Please keep this information safe and stored in an encrypted form, not plain text.**


### 1.3 Derive the GRANDPA Key

Using the same mnemonic from step 1.1, derive the GRANDPA key (Ed25519).

```bash
docker run --rm parity/subkey:latest inspect --scheme ed25519 "mnemonic phrase"
```

Replace `"mnemonic phrase"` with your actual mnemonic enclosed in quotes.

Note down the **Public Key (hex)** for GRANDPA. This key will serve as your session key for GRANDPA.
**Please keep this information safe and stored in an encrypted form, not plain text.**


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
TFCHAIN_NODE_KEY=771e3b9f58b98c49cd604dd0c24c50dff1f4b8c2c20cba2b6ef57ad23255be56

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


## 2. Set Session Keys On-Chain

To have your node recognized as a validator, you need to set your session keys on-chain.

### 2.1 Add Validator Account to Polkadot.js Extension

- Open the Polkadot.js browser extension.
- Import your validator controller account using the mnemonic from step 1.1.
- Ensure you have some TFT tokens in this account (0.1 TFT should suffice for transaction fees).

### 2.2 Set Session Keys via PolkadotJS Apps

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


## 3. Submit a Council Motion to Add Validator

The TFChain network requires a governance proposal to add a validator node.

1. Navigate to **Governance → Council**.
2. Click on **Propose Motion**.
3. Select `validatorSet` → `addValidator(validatorId)`.
4. Input your validator controller account's SS58 address (generated in step 1.1).
5. Submit the proposal.

After submission, inform other council members and request them to vote on the proposal.


## 4. Finalize and Start Validating

Once your session keys are set and the council approves your validator, your node will start participating in block production after 2 sessions.


### Ensure Node Health

- Keep your node online and synchronized.
- Monitor logs for any errors or warnings.

---

## References

- **Subkey Utility via Docker**: [Parity Subkey Docker Image](https://hub.docker.com/r/parity/subkey)
- **TFChain Docker Images**: [TFChain Docker Packages](https://github.com/threefoldtech/tfchain/pkgs/container/tfchain)
- **PolkadotJS Apps**: [PolkadotJS Interface](https://polkadot.js.org/apps/)
- **PolkadotJS Extension**: [Browser Extension](https://polkadot.js.org/extension/)
- **Validator Set Pallet**: [Substrate Validator Set Module](https://github.com/gautamdhameja/substrate-validator-set)
- **Council Integration Guide**: [Council Integration](https://github.com/gautamdhameja/substrate-validator-set/blob/master/docs/council-integration.md)
- **Polkadot Validator Guide**: [How to Validate on Polkadot](https://wiki.polkadot.network/docs/maintain-guides-how-to-validate-polkadot)
