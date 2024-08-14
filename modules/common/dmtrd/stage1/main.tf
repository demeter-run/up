module "utxorpc_crd" {
  # The repo is not yet public
  # source = "git::https://github.com/demeter-run/ext-cardano-utxorpc.git//bootstrap/crds"
  source = "../../../../../ext-cardano-utxorpc/bootstrap/crds"
}

module "dbsyncports_crds" {
  source = "git::https://github.com/demeter-run/ext-cardano-dbsync-serverless//bootstrap/crds"
}

module "ogmiosports_crds" {
  source = "git::https://github.com/demeter-run/ext-cardano-ogmios//bootstrap/crds"
}

module "cardanonodeports_crds" {
  source = "git::https://github.com/demeter-run/ext-cardano-node//bootstrap/crds"
}

module "blockfrostports_crds" {
  # source = "git::https://github.com/demeter-run/ext-cardano-blockfrost//bootstrap/crds"
  source = "../../../../../ext-cardano-blockfrost/bootstrap/crds"
}

module "submitapiports_crds" {
  # source = "git::https://github.com/demeter-run/ext-cardano-submitapi//bootstrap/crds"
  source = "../../../../../ext-cardano-submitapi/bootstrap/crds"
}

module "marloweports_crds" {
  # source = "git::https://github.com/demeter-run/ext-cardano-marlowe//bootstrap/crds"
  source = "../../../../../ext-cardano-marlowe/bootstrap/crds"
}

module "mumakports_crds" {
  # source = "git::https://github.com/demeter-run/ext-mumak//bootstrap/crds"
  source = "../../../../../ext-mumak/bootstrap/crds"
}
