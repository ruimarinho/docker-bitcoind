# ruimarinho/bitcoin-core

A bitcoin-core docker image with support for the following platforms:

* `amd64` (x86_64)
* `arm32v7` (armv7)
* `arm64` (aarch64, armv8)

[![ruimarinho/bitcoin-core][docker-pulls-image]][docker-hub-url] [![ruimarinho/bitcoin-core][docker-stars-image]][docker-hub-url] [![ruimarinho/bitcoin-core][docker-size-image]][docker-hub-url]

## Tags

- `0.21.1`, `0.21`, `latest` ([0.21/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.21/Dockerfile)) [**multi-arch**]
- `0.21.1-alpine`, `0.21-alpine` ([0.21/alpine/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.21/alpine/Dockerfile))

- `0.20.1`, `0.20` ([0.20/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.20/Dockerfile)) [**multi-arch**]
- `0.20.1-alpine`, `0.20-alpine` ([0.20/alpine/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.20/alpine/Dockerfile))

- `0.19.1`, `0.19` ([0.19/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.19/Dockerfile)) [**multi-arch**]
- `0.19.1-alpine`, `0.19-alpine` ([0.19/alpine/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.19/alpine/Dockerfile))

- `0.18.1`, `0.18`, ([0.18/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.18/Dockerfile))
- `0.18.1-alpine`, `0.18-alpine` ([0.18/alpine/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.18/alpine/Dockerfile))

- `0.17.1`, `0.17` ([0.17/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.17/Dockerfile))
- `0.17.1-alpine`, `0.17-alpine` ([0.17/alpine/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.17/alpine/Dockerfile))

- `0.16.3`, `0.16` ([0.16/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.16/Dockerfile))
- `0.16.3-alpine`, `0.16-alpine` ([0.16/alpine/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.16/alpine/Dockerfile))

- `0.15.1`, `0.15` ([0.15/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.15/Dockerfile))
- `0.15.1-alpine`, `0.15-alpine` ([0.15/alpine/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.15/alpine/Dockerfile))

**Multi-architecture builds**

The newest images (Debian-based, *0.19+*) provide built-in support for multiple architectures. Running `docker pull` on any of the supported platforms will automatically choose the right image for you as all of the manifests and artifacts are pushed to the Docker registry.

**Picking the right tag**

- `ruimarinho/bitcoin-core:latest`: points to the latest stable release available of Bitcoin Core. Caution when using in production as blindly upgrading Bitcoin Core is a risky procedure.
- `ruimarinho/bitcoin-core:alpine`: same as above but using the Alpine Linux distribution (a resource efficient Linux distribution with security in mind, but not officially supported by the Bitcoin Core team — use at your own risk).
- `ruimarinho/bitcoin-core:<version>`: based on a slim Debian image, this tag format points to a specific version branch (e.g. `0.20`) or release of Bitcoin Core (e.g. `0.20.1`). Uses the pre-compiled binaries which are distributed by the Bitcoin Core team.
- `ruimarinho/bitcoin-core:<version>-alpine`: same as above but using the Alpine Linux distribution.

## What is Bitcoin Core?

Bitcoin Core is a reference client that implements the Bitcoin protocol for remote procedure call (RPC) use. It is also the second Bitcoin client in the network's history. Learn more about Bitcoin Core on the [Bitcoin Developer Reference docs](https://bitcoin.org/en/developer-reference).

## Usage

### How to use this image

This image contains the main binaries from the Bitcoin Core project - `bitcoind`, `bitcoin-cli` and `bitcoin-tx`. It behaves like a binary, so you can pass any arguments to the image and they will be forwarded to the `bitcoind` binary:

```sh
❯ docker run --rm -it ruimarinho/bitcoin-core \
  -printtoconsole \
  -regtest=1 \
  -rpcallowip=172.17.0.0/16 \
  -rpcauth='foo:7d9ba5ae63c3d4dc30583ff4fe65a67e$9e3634e81c11659e3de036d0bf88f89cd169c1039e6e09607562d54765c649cc'
```

_Note: [learn more](#using-rpcauth-for-remote-authentication) about how `-rpcauth` works for remote authentication._

By default, `bitcoind` will run as user `bitcoin` for security reasons and with its default data dir (`~/.bitcoin`). If you'd like to customize where `bitcoin-core` stores its data, you must use the `BITCOIN_DATA` environment variable. The directory will be automatically created with the correct permissions for the `bitcoin` user and `bitcoin-core` automatically configured to use it.

```sh
❯ docker run --env BITCOIN_DATA=/var/lib/bitcoin-core --rm -it ruimarinho/bitcoin-core \
  -printtoconsole \
  -regtest=1
```

You can also mount a directory in a volume under `/home/bitcoin/.bitcoin` in case you want to access it on the host:

```sh
❯ docker run -v ${PWD}/data:/home/bitcoin/.bitcoin -it --rm ruimarinho/bitcoin-core \
  -printtoconsole \
  -regtest=1
```

You can optionally create a service using `docker-compose`:

```yml
bitcoin-core:
  image: ruimarinho/bitcoin-core
  command:
    -printtoconsole
    -regtest=1
```

### Using a custom user

By default, this image creates the `bitcoin` user as a system user, which translates into `100:101` on Debian and `999:999` on Alpine. You customize the user and group ids using the environment variables `$UID` and `$GID` as follows:

```sh
❯ docker run -e UID=120 -e GID=120 -it --rm ruimarinho/bitcoin-core \
  -printtoconsole \
  -regtest=1
```

This will chown the `$BITCOIN_DATA` directory with uid and gid `120:120`.

### Using RPC to interact with the daemon

There are two communications methods to interact with a running Bitcoin Core daemon.

The first one is using a cookie-based local authentication. It doesn't require any special authentication information as running a process locally under the same user that was used to launch the Bitcoin Core daemon allows it to read the cookie file previously generated by the daemon for clients. The downside of this method is that it requires local machine access.

The second option is making a remote procedure call using a username and password combination. This has the advantage of not requiring local machine access, but in order to keep your credentials safe you should use the newer `rpcauth` authentication mechanism.

#### Using cookie-based local authentication

Start by launch the Bitcoin Core daemon:

```sh
❯ docker run --rm --name bitcoin-server -it ruimarinho/bitcoin-core \
  -printtoconsole \
  -regtest=1
```

Then, inside the running `bitcoin-server` container, locally execute the query to the daemon using `bitcoin-cli`:

```sh
❯ docker exec --user bitcoin bitcoin-server bitcoin-cli -regtest getmininginfo

{
  "blocks": 0,
  "currentblocksize": 0,
  "currentblockweight": 0,
  "currentblocktx": 0,
  "difficulty": 4.656542373906925e-10,
  "errors": "",
  "networkhashps": 0,
  "pooledtx": 0,
  "chain": "regtest"
}
```

In the background, `bitcoin-cli` read the information automatically from `/home/bitcoin/.bitcoin/regtest/.cookie`. In production, the path would not contain the regtest part.

#### Using rpcauth for remote authentication

Before setting up remote authentication, you will need to generate the `rpcauth` line that will hold the credentials for the Bitcoind Core daemon. You can either do this yourself by constructing the line with the format `<user>:<salt>$<hash>` or use the official [`rpcauth.py`](https://github.com/bitcoin/bitcoin/blob/master/share/rpcauth/rpcauth.py)  script to generate this line for you, including a random password that is printed to the console.

_Note: This is a Python 3 script. use `[...] | python3 - <username>` when executing on macOS._

Example:

```sh
❯ curl -sSL https://raw.githubusercontent.com/bitcoin/bitcoin/master/share/rpcauth/rpcauth.py | python - <username>

String to be appended to bitcoin.conf:
rpcauth=foo:7d9ba5ae63c3d4dc30583ff4fe65a67e$9e3634e81c11659e3de036d0bf88f89cd169c1039e6e09607562d54765c649cc
Your password:
qDDZdeQ5vw9XXFeVnXT4PZ--tGN2xNjjR4nrtyszZx0=
```

Note that for each run, even if the username remains the same, the output will be always different as a new salt and password are generated.

Now that you have your credentials, you need to start the Bitcoin Core daemon with the `-rpcauth` option. Alternatively, you could append the line to a `bitcoin.conf` file and mount it on the container.

Let's opt for the Docker way:

```sh
❯ docker run --rm --name bitcoin-server -it ruimarinho/bitcoin-core \
  -printtoconsole \
  -regtest=1 \
  -rpcallowip=172.17.0.0/16 \
  -rpcauth='foo:7d9ba5ae63c3d4dc30583ff4fe65a67e$9e3634e81c11659e3de036d0bf88f89cd169c1039e6e09607562d54765c649cc'
```

Two important notes:

1. Some shells require escaping the rpcauth line (e.g. zsh), as shown above.
2. It is now perfectly fine to pass the rpcauth line as a command line argument. Unlike `-rpcpassword`, the content is hashed so even if the arguments would be exposed, they would not allow the attacker to get the actual password.

You can now connect via `bitcoin-cli` or any other [compatible client](https://github.com/ruimarinho/bitcoin-core). You will still have to define a username and password when connecting to the Bitcoin Core RPC server.

To avoid any confusion about whether or not a remote call is being made, let's spin up another container to execute `bitcoin-cli` and connect it via the Docker network using the password generated above:

```sh
❯ docker run -it --link bitcoin-server --rm ruimarinho/bitcoin-core \
  bitcoin-cli \
  -rpcconnect=bitcoin-server \
  -regtest \
  -rpcuser=foo\
  -stdinrpcpass \
  getbalance
```

Enter the password `qDDZdeQ5vw9XXFeVnXT4PZ--tGN2xNjjR4nrtyszZx0=` and hit enter:

```
0.00000000
```

Note: under Bitcoin Core < 0.16, use `-rpcpassword="qDDZdeQ5vw9XXFeVnXT4PZ--tGN2xNjjR4nrtyszZx0="` instead of `-stdinrpcpass`.

Done!

### Exposing Ports

Depending on the network (mode) the Bitcoin Core daemon is running as well as the chosen runtime flags, several default ports may be available for mapping.

Ports can be exposed by mapping all of the available ones (using `-P` and based on what `EXPOSE` documents) or individually by adding `-p`. This mode allows assigning a dynamic port on the host (`-p <port>`) or assigning a fixed port `-p <hostPort>:<containerPort>`.

Example for running a node in `regtest` mode mapping JSON-RPC/REST (18443) and P2P (18444) ports:

```sh
docker run --rm -it \
  -p 18443:18443 \
  -p 18444:18444 \
  ruimarinho/bitcoin-core \
  -printtoconsole \
  -regtest=1 \
  -rpcallowip=172.17.0.0/16 \
  -rpcbind=0.0.0.0 \
  -rpcauth='foo:7d9ba5ae63c3d4dc30583ff4fe65a67e$9e3634e81c11659e3de036d0bf88f89cd169c1039e6e09607562d54765c649cc'
```

To test that mapping worked, you can send a JSON-RPC curl request to the host port:

```
curl --data-binary '{"jsonrpc":"1.0","id":"1","method":"getnetworkinfo","params":[]}' http://foo:qDDZdeQ5vw9XXFeVnXT4PZ--tGN2xNjjR4nrtyszZx0=@127.0.0.1:18443/
```

#### Mainnet

- JSON-RPC/REST: 8332
- P2P: 8333

#### Testnet

- Testnet JSON-RPC: 18332
- P2P: 18333

#### Regtest

- JSON-RPC/REST: 18443 (_since 0.16+_, otherwise _18332_)
- P2P: 18444

#### Signet

- JSON-RPC/REST: 38332
- P2P: 38333

## Archived tags

_Please note that due to [CVE-2018-17144](https://nvd.nist.gov/vuln/detail/CVE-2018-17144), the following tags are unavailable: 0.14.0, 0.14.1, 0.14.2, 0.15.0, 0.15.0.1, 0.15.1, 0.16.0, 0.16.1 and 0.16.2._

For historical reasons, the following tags are still available and automatically updated when the underlying base image (_Alpine Linux_ or _Debian stable_) is updated as well:

- `0.13.2`, `0.13` ([0.13/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.13/Dockerfile))
- `0.13.2-alpine`, `0.13-alpine` ([0.13/alpine/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.13/alpine/Dockerfile))

- `0.12.1`, `0.12` ([0.12/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.12/Dockerfile))
- `0.12.1-alpine`, `0.12-alpine` ([0.12/alpine/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.12/alpine/Dockerfile))

- `0.11.2`, `0.11` ([0.11/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.11/Dockerfile))
- `0.11.2-alpine`, `0.11-alpine` ([0.11/alpine/Dockerfile](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/0.11/alpine/Dockerfile))

## Docker

This image is officially supported on Docker version 17.09, with support for older versions provided on a best-effort basis.

## License

[License information](https://github.com/bitcoin/bitcoin/blob/master/COPYING) for the software contained in this image.

[License information](https://github.com/ruimarinho/docker-bitcoin-core/blob/master/LICENSE) for the [ruimarinho/docker-bitcoin-core][docker-hub-url] docker project.

[docker-hub-url]: https://hub.docker.com/r/ruimarinho/bitcoin-core
[docker-pulls-image]: https://img.shields.io/docker/pulls/ruimarinho/bitcoin-core.svg?style=flat-square
[docker-size-image]: https://img.shields.io/docker/image-size/ruimarinho/bitcoin-core?style=flat-square
[docker-stars-image]: https://img.shields.io/docker/stars/ruimarinho/bitcoin-core.svg?style=flat-square
