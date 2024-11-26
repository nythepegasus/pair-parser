# pair-parser
A small Swift tool to extract certificates and other information from an iOS 17+ pairing file.

## Usage
```sh
USAGE: pairing-parser <pair-path> [<dev-cert-path>] [<root-cert-path>] [<host-cert-path>] [<host-priv-key-path>]

ARGUMENTS:
  <pair-path>             Path to the pairing file
  <dev-cert-path>         Path to save the Device Certificate (default: keys/server/cert.pem)
  <root-cert-path>        Path to save the Root Certificate (default: keys/ca/ca.crt)
  <host-cert-path>        Path to save the Host Certificate (default: keys/client/cert.pem)
  <host-priv-key-path>    Path to save the Host Private Key (default: keys/client/key.pem)

OPTIONS:
  -h, --help              Show help information.
```

### Example
```sh
pair-parse Nikki.plist # will create the files necessary for halfpipe
tree keys
# keys
# ├── ca
# │   └── ca.crt
# ├── client
# │   ├── cert.pem
# │   └── key.pem
# └── server
#     └── cert.pem
# 
# 4 directories, 4 files
```
