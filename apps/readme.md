# Grid backend apps

Third party apps required to perform Grid backend tasks.

#### How to use the script:
- To run the script normally and install everything (including the node exporter):

```bash
./prep-env-prereq.sh
```
- To skip the installation of the node exporter:

```bash
./prep-env-prereq.sh --skip-node-exporter
```

### Substrate - subkey

The subkey program is a key generation and management utility to perform the following tasks:
- Generate and inspect cryptographically-secure public and private key pairs.
- Restore keys from secret phrases and raw seeds.
- Sign and verify signatures on messages.
- Sign and verify signatures for encoded transactions.
- Derive hierarchical deterministic child key pairs.

Repo: https://github.com/paritytech/polkadot-sdk  
Docs: https://docs.substrate.io/reference/command-line-tools/subkey/

