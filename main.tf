terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "avm-rg" {
  name     = "avm-resources"
  location = "west europe"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "avm-vn" {
  name                = "avm-network"
  resource_group_name = azurerm_resource_group.avm-rg.name
  location            = azurerm_resource_group.avm-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "avm-subnet" {
  name                 = "avm-subnet"
  resource_group_name  = azurerm_resource_group.avm-rg.name
  virtual_network_name = azurerm_virtual_network.avm-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "avm-sg" {
  name                = "avm-sg"
  resource_group_name = azurerm_resource_group.avm-rg.name
  location            = azurerm_resource_group.avm-rg.location

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "avm-dev-rule" {
  name                        = "avm-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.avm-rg.name
  network_security_group_name = azurerm_network_security_group.avm-sg.name

}

resource "azurerm_subnet_network_security_group_association" "avm-sga" {
  subnet_id                 = azurerm_subnet.avm-subnet.id
  network_security_group_id = azurerm_network_security_group.avm-sg.id

}

resource "azurerm_public_ip" "avm-ip" {
  name                = "avm-ip"
  resource_group_name = azurerm_resource_group.avm-rg.name
  location            = azurerm_resource_group.avm-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}



resource "azurerm_network_interface" "avm-ni" {
  name                = "example-nic"
  resource_group_name = azurerm_resource_group.avm-rg.name
  location            = azurerm_resource_group.avm-rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.avm-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.avm-ip.id
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "avm-lvm" {
  name                  = "avm-lvm"
  resource_group_name   = azurerm_resource_group.avm-rg.name
  location              = azurerm_resource_group.avm-rg.location
  size                  = "Standard_F2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.avm-ni.id]

  custom_data = filebase64("customdata.tpl")

  # admin_ssh_key {
  #   username   = "adminuser"
  #   public_key = file("~/.ssh/avmazurekey.pub")
  # }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
