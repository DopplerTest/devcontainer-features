# Doppler Dev Container Features

A collection of [Dev Container Features](https://containers.dev/implementors/features/) for integrating [Doppler](https://doppler.com) into your development containers.

> This repo follows the [dev container feature distribution specification](https://containers.dev/implementors/features-distribution/).

## Features

| Feature | Description |
| ------- | ----------- |
| [doppler-cli](src/doppler-cli/README.md) | Installs the [Doppler CLI](https://docs.doppler.com/docs/cli) for secrets management |

## Usage

Add the desired feature to your `devcontainer.json`:

```jsonc
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/dopplerhq/devcontainer-features/doppler-cli": {}
  }
}
```

See the [doppler-cli feature README](src/doppler-cli/README.md) for supported options.

### Options

| Option | Type | Default | Description |
| ------ | ---- | ------- | ----------- |
| `version` | `string` | `latest` | Version of the Doppler CLI to install (e.g., `3.67.0` or `latest`) |

### OS Support

This feature supports Debian/Ubuntu-based distributions, Red Hat/Fedora-based distributions, and Alpine Linux.

## Development

To test locally, install the [devcontainer CLI](https://code.visualstudio.com/docs/devcontainers/devcontainer-cli):

```shell
npm install -g @devcontainers/cli
```

### Running Tests

```shell
devcontainer features test --features doppler-cli --base-image mcr.microsoft.com/devcontainers/base:ubuntu .
```

## License

Licensed under the [Apache License 2.0](LICENSE).
