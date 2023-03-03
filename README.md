# Features

This project **Features** is a set of reusable 'features'. Quickly add a tool/cli to a development container.

_Features_ are self-contained units of installation code and development container configuration. Features are designed to install atop a wide-range of base container images (this repo focuses on **debian based images**).

> This repo follows the [**proposed** dev container feature distribution specification](https://containers.dev/implementors/features-distribution/).

**List of features:**

- [doppler-cli](src/doppler-cli/README.md): Install the Doppler CLI

## Usage

To reference a feature from this repository, add the desired features to a devcontainer.json. Each feature has a README.md that shows how to reference the feature and which options are available for that feature.

The example below installs the _doppler-cli_ declared in the `./src` directory of this repository.

See the relevant feature's README for supported options.

```jsonc
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/dopplerhq/devcontainer-features/doppler-cli": {}
  }
}
```

After starting a devcontainer with this feature enabled, you'll need to run
`doppler login` once. The config file is stored in a file located at `/doppler`
which is a mount of a docker volume called `doppler-cli-user-config`. When
starting subsequent devcontainers, your config should be retained so logging
in won't be necessary. If you don't want your session to persist, be sure to
explicitly run `doppler logout` before ending your session.

# Development

To test this locally, you'll need to install the [devcontainer CLI](https://code.visualstudio.com/docs/devcontainers/devcontainer-cli):

```shell
npm install -g @devcontainers/cli
```

## Running Tests

To run the test suite, execute the following command:

```shell
devcontainer features test --features doppler-cli --base-image mcr.microsoft.com/devcontainers/base:ubuntu .
```

## Executing Locally

You can fire up a devcontainer using the `devcontainer` CLI. To start, grab a
sample project like Microsoft's [vscode-remote-try-node](https://github.com/microsoft/vscode-remote-try-node). Clone that locally and then copy the feature
directory to the `.devcontainer` directory in that project. To do that, run this command from the root devcontainer-feature project directory:

```shell
cp -r src/doppler-cli/ /path/to/vscode-remote-try-node/.devcontainer/doppler-cli
```

Now, edit the `devcontainer.json` file in the `vscode-remote-try-node` project
by uncommenting the `"features": {},` line and changing it to:

```jsonc
"features": {
  "./doppler-cli": {}
},
```

Finally, up one directory from the `vscode-remote-try-node` project, run
this command:

```shell
devcontainer up --workspace-folder vscode-remote-try-node/
```

From there, you can connect to the container, switch to the `vscode` user and
run `doppler login`.