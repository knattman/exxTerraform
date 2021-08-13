data "azurerm_virtual_network" "my_network" {
  name                = "virtualNetwork1"
  resource_group_name = "simplevm"
}

data "azurerm_virtual_machine" "my_vm" {
  name                = "simplevmVm"
  resource_group_name = "simplevm"
  
}


output "my_network_id" {
  value = "${data.azurerm_virtual_network.my_network.id}"
}

output "my_vm" {
  value = "${data.azurerm_virtual_machine.my_vm.id}"
}
