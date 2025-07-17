resource "azurerm_resource_group" "terra" {
  name     = "terra"
  location = "East US"
}

resource "azurerm_resource_group" "storeterra" {
    name     = "storeterra"
    location = "East US"
}

resource "azurerm_storage_account" "saterra" {
    name                     = "terrastorage2510"
    resource_group_name      = azurerm_resource_group.storeterra.name
    location                 = azurerm_resource_group.storeterra.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_storage_container" "sacontainer" {
    name                  = "terra-container"
    storage_account_name  = azurerm_storage_account.saterra.name
    container_access_type = "private"
}

resource "azurerm_virtual_network" "terra_vnet" {
    name                = "terra-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.terra.location
    resource_group_name = azurerm_resource_group.terra.name
}

resource "azurerm_subnet" "subnet1" {
    name                 = "subnet1"
    resource_group_name  = azurerm_resource_group.terra.name
    virtual_network_name = azurerm_virtual_network.terra_vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet2" {
    name                 = "subnet2"
    resource_group_name  = azurerm_resource_group.terra.name
    virtual_network_name = azurerm_virtual_network.terra_vnet.name
    address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_network_interface" "nic" {
  name                = "example-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "example-win-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "Password1234!"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}