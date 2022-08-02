terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.14.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

provider "local" {}

provider "tls" {}

provider "azurerm" {
  features {}
}

##################################
# SSH Keys
##################################
# Below we are creating a public/private key pair that is stored within state.
# For ease of use, we are then saving the private key locally.
# Please note - this is not good practice from a security point of view - 
# its just a simple demo to demonstrate linting/testing.

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "example" {
  content  = tls_private_key.example.private_key_pem
  filename = "./key.pem"
}


##################################
# Resource Group
##################################

resource "azurerm_resource_group" "example" {
  name     = "rg-testing-demo"
  location = "uksouth"
}

##################################
# VNet and Subnet
##################################

resource "azurerm_virtual_network" "example" {
  name                = "vnet-testing-demo"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "snet-testing-demo"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

##################################
# VM NIC and PIP
##################################

resource "azurerm_public_ip" "example" {
  name                = "pip-testing-demo"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "example" {
  name                = "nic-testing-demo"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "vm-testing-demo"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B1ls" # Trying changing this to an invalid example and running tflint
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.example.public_key_openssh
  }

  user_data = base64encode(file("./files/install_httpd.sh")) # Using a simple bash script to provision initialise the server. Check out cloud init - https://cloudinit.readthedocs.io/en/latest/
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # Note, this connection block is used by all provisioners. Alternatively, it could be defined
  # under each provisioner individually.
  connection {
    type        = "ssh"
    user        = self.admin_username
    private_key = tls_private_key.example.private_key_pem
    host        = self.public_ip_address
  }

  # Here we use a provisioner to load a file, replace the relevant value and upload to the server.
  # In real life, a better option would be to use a tool like Packer to immutably build a VM image
  # with the required application files baked in!
  provisioner "file" {
    content = templatefile(
      "./files/index.html.tmpl",
      {
        server_name = self.name
        server_ip   = self.private_ip_address
      }
    )
    destination = "/home/adminuser/index.html"
  }

  # This provisioner is doing two things:
  # 1. Waiting for the "boot-finished" file to appear 
  # 2. Moving the files to a path that requires sudo (I don't believe the "file" provisioner can use sudo to achieve this directly)
  #
  # We wait for the boot-finished file to ensure that the user_data script has finished running. Else you'll
  # likely get an error that Apache is not installed. Provisioners start as soon as the server is reachable, they do not wait
  # for user_data to finish.
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo mv /home/adminuser/index.html /var/www/html/index.html",
      "sudo systemctl restart apache2"
    ]
  }
}
