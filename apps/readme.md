<h1>TFGrid Backend Apps</h1>

<h2>Table of Contents</h2>

- [Introduction](#introduction)
- [Prerequisites script](#prerequisites script)
- [Substrate - subkey](#substrate---subkey)
- [References](#references)

---

## Introduction

This directory contains third-party apps and scripts required to perform the TFGrid backend tasks.


## Prerequisites script

This script can be used on Debian based distributions. It can be used to install all required software that will be needed to run services on this repo.  
It can be used manually or triggered by other install scripts (like the Grid backend install script, it will ask to run it)

The script will install:
- cli tools: `sudo apt-transport-https curl git nmon tmux tcpdump iputils-ping net-tools nano rsync tar pigz pv`
- Python: `python3 python3-requests python3-pip`
- Docker with Docker-compose plugin: `docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`
- Prometheus node eporter


## Substrate - subkey

The subkey program is a key generation and management utility to perform the following tasks:
- Generate and inspect cryptographically-secure public and private key pairs.
- Restore keys from secret phrases and raw seeds.
- Sign and verify signatures on messages.
- Sign and verify signatures for encoded transactions.
- Derive hierarchical deterministic child key pairs.


## References

Repo: https://github.com/paritytech/polkadot-sdk  
Docs: https://docs.substrate.io/reference/command-line-tools/subkey/

