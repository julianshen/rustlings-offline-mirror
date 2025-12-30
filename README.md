# Rustlings Offline Mirror

A Docker-based offline cargo registry mirror for [rustlings](https://github.com/rust-lang/rustlings), enabling Rust learning in air-gapped or offline environments.

## Overview

This project uses [panamax](https://github.com/panamax-rs/panamax) to create a minimal cargo registry mirror containing only the dependencies needed for rustlings. The mirror is automatically built and published to GitHub Container Registry.

## Quick Start

### Pull and run the pre-built image

```bash
docker pull ghcr.io/julianshen/rustlings-offline-mirror:latest
docker run -d -p 8080:8080 ghcr.io/julianshen/rustlings-offline-mirror:latest
```

### Install Rust toolchain using the mirror

If you need to install or update the Rust toolchain in an offline environment, configure rustup to use this mirror:

```bash
export RUSTUP_DIST_SERVER=http://localhost:8080/rustup
export RUSTUP_UPDATE_ROOT=http://localhost:8080/rustup

# Install rustup (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Or update an existing installation
rustup update stable
```

You can add these exports to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.) to make them persistent.

### Configure cargo to use the mirror

Add the following to your `~/.cargo/config.toml`:

```toml
[source.crates-io]
replace-with = "my-mirror"

[source.my-mirror]
registry = "sparse+http://localhost:8080/crates.io-index/"
```

### Install and run rustlings

```bash
cargo install rustlings
rustlings init
cd rustlings
rustlings
```

## Building Locally

```bash
docker build -t rustlings-offline-mirror .
docker run -d -p 8080:8080 rustlings-offline-mirror
```

## How It Works

1. **Builder stage**: Installs panamax, initializes a mirror, and uses a dummy `Cargo.toml` declaring rustlings as a dependency to generate a `Cargo.lock`
2. **Sync**: Panamax syncs only the crates listed in the lockfile, keeping the mirror size minimal
3. **Runtime stage**: Serves the mirror on port 8080 using panamax's built-in server

## Customization

To add additional crates to the mirror, edit `dummy/Cargo.toml` and add them as dependencies.

## License

MIT
