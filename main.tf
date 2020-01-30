# Configure the Azure Provider

provider "azurerm" {
  subscription_id  = "${var.azure_subscrption_id}"
  client_id        = "${var.azure_client_id}"
  client_secret    = "${var.azure_client_secret}"
  tenant_id        = "${var.azure_tenant_id}"

# whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
version = "=1.34.0"
}

resource "azurerm_resource_group" "main" {
  name     = "main-resource"
  location = "East US"
}

resource "azurerm_virtual_network" "main" {
  name                = "main-virtual"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"
  resource_group_name = "main-resource"
}



resource "azurerm_subnet" "main" {
  name                 = "first"
  resource_group_name  = "main-resource"
  virtual_network_name = "main-virtual"
  address_prefix       = "10.0.0.0/24"
}

resource "azurerm_network_interface" "main" {
  name                = "main-nic"
  location            = "East US"
  resource_group_name = "main-resource"



 ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.main.id}"
    private_ip_address_allocation = "Dynamic"
  
}

}
resource "azurerm_virtual_machine" "main" {
  name                  = "new-vm-1"
  location              = "East US"
  resource_group_name   = "main-resource"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "new-vm-1"
    admin_username = "steve"
    admin_password = "TheBigNest123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

