module "rg" {
  source = "../../Modules/RG"
  var-rg = var.rg
}

module "stgacc" {
    depends_on = [ module.rg ]
  source = "../../Modules/STORAGE_ACC"
  var-stg = var.stgacc
}

module "vnet" {
  depends_on = [ module.rg ]
  source = "../../Modules/VNET"
  var-vnet = var.vnet
}

module "subnet" {
  depends_on = [ module.rg, module.vnet ]
  source = "../../Modules/SUBNET"
  var-subnet = var.subnet
}

module "nsg" {
  depends_on = [module.rg]
  source = "../../Modules/NSG"
  var-nsg = var.nsg
}

module "pubip" {
  depends_on = [ module.rg ]
  source = "../../Modules/PUBLIC_IP"
  var-pubip = var.pubip
}

module "vm" {
  depends_on = [ module.rg, module.vnet, module.subnet ]
  source = "../../Modules/VM"
  var-vm = var.vm
}

module "bastion" {
  depends_on = [ module.rg , module.subnet , module.pubip ]
  source = "../../Modules/BASTION"
  var-bastion = var.bastion
}