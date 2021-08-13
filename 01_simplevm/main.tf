resource "azurerm_resource_group" "simplevm" {
  name     = "simplevm"
  location = "westeurope"
}


resource "azurerm_virtual_network" "simplevm" {
  name                = "virtualNetwork1"
  location            = "westeurope"
  resource_group_name = "simplevm"
  address_space       = ["10.66.0.0/16"]
    dns_servers         = ["10.66.0.4", "10.66.0.5"]
  


  subnet {
    name           = "subnet1"
    address_prefix = "10.66.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.66.2.0/24"
  }

}
resource "azurerm_public_ip" "simplevm" {
  name                         = "simplevmPublicIp"
  location                     = "westeurope"
  resource_group_name          = "simplevm"
  allocation_method            = "Static"

  tags = {
    environment = "simplevm"
  }
}

resource "azurerm_network_interface" "simplevm" {
  name                = "simplevmNic"
  location            = "westeurope"
  resource_group_name = "${azurerm_resource_group.simplevm.name}"

  ip_configuration {
    name                          = "simplevmIpConfiguration"
    subnet_id                     = azurerm_virtual_network.simplevm.subnet.*.id[0]
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.simplevm.id
  }
}

resource "azurerm_virtual_machine" "simplevm" {
  name                  = "simplevmVm"
  location              = "westeurope"
  resource_group_name   = "${azurerm_resource_group.simplevm.name}"
  network_interface_ids = ["${azurerm_network_interface.simplevm.id}"]
  vm_size               = "Standard_B1s"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "simplevmVmDisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "simplevmVm"
    admin_username = "vmadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "simplevm"
  }
}
