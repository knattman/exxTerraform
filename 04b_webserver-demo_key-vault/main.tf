resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_group}-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.address_space]
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.resource_group}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = var.subnet_prefix
}

resource "azurerm_public_ip" "pip" {
  name                         = "${var.hostname}-publicIp"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.rg.name
  allocation_method            = "Static"
}

resource "azurerm_network_security_group" "webserver-nsg" {
  name                = "${var.resource_group}-webserver-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "in-http80" {
  name                        = "in-http80"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.webserver-nsg.name
}

resource "azurerm_network_security_rule" "in-ssh22" {
  name                        = "in-ssh22"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.webserver-nsg.name
}

resource "azurerm_network_interface" "nic" {
  name                      = "${var.hostname}-nic"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name
  #network_security_group_id = azurerm_network_security_group.webserver-nsg.id

  ip_configuration {
    name                          = "${var.resource_group}-ipConfiguration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_storage_account" "stor" {
  name                     = var.storage_account_name
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
}

resource "azurerm_managed_disk" "datadisk" {
  name                 = "${var.hostname}-datadisk"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"
}


resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.hostname}-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = data.azurerm_key_vault_secret.demoadmin.value
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
  depends_on            = [azurerm_network_interface.nic]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.image_sku
    version   = "latest"
  }
}

output "Public_IP_Web" {
  value = azurerm_public_ip.pip.ip_address
}
