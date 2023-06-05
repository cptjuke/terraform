#Version and Providers
terraform {
required_providers {
	azurerm = {
		source = "hashicorp/azurerm"
		version = "3.0.0"
		}
	}
}

#Azure configuration
provider "azurerm" {
features {}
}

#Create a resource group
resource "azurerm_resource_group" "gruporecursos" {
name = "gruporecursos"
location = "West Europe"
}


#Create a virtual network
resource "azurerm_virtual_network" "redvirtual" {
name = "redvirtual"
address_space = ["10.0.0.0/16"]
location = "West Europe"
resource_group_name = azurerm_resource_group.gruporecursos.name
}

#Create a subnet
resource "azurerm_subnet" "subred" {
name = "redinterna"
resource_group_name = azurerm_resource_group.gruporecursos.name
virtual_network_name = azurerm_virtual_network.redvirtual.name
address_prefixes = ["10.0.0.0/24"]
}

#Create public IPs
resource "azurerm_public_ip" "ip_publica" {
	name = "ippublica"
	location = "West Europe"
	resource_group_name = azurerm_resource_group.gruporecursos.name
	allocation_method = "Static"
}


#Create network security group and access rules
resource "azurerm_network_security_group" "gruposeg" {
	name = "grupodeseguridad"
	location = "West Europe"
	resource_group_name = azurerm_resource_group.gruporecursos.name

#Access rule	
	security_rule {
		name = "SSH"
		priority = 1001
		direction = "Inbound"
		access = "Allow"
		protocol = "Tcp"
		source_port_range = "*"
		destination_port_range = "22"
		source_address_prefix = "*"
		destination_address_prefix = "*"
	}
}


#Create network interface
resource "azurerm_network_interface" "nic" {
name = "network-nic"
location = "West Europe"
resource_group_name = azurerm_resource_group.gruporecursos.name

#IP configuration of the network interface
ip_configuration {
name = "internal"
subnet_id = azurerm_subnet.subred.id
private_ip_address_allocation = "Dynamic"
public_ip_address_id = azurerm_public_ip.ip_publica.id
}
}

#Create virtual machine
resource "azurerm_linux_virtual_machine" "maquinalinux" {
name = "maquinalinux"
resource_group_name = azurerm_resource_group.gruporecursos.name
location = "West Europe"
size = "Standard_B1ls"
admin_username = "jccalvo"
network_interface_ids = [
azurerm_network_interface.nic.id
]


#Generate ssh key with key autogen and be careful with the path to the key, username and admin_username from the virtual machine has to match
admin_ssh_key {
  username = "jccalvo"
  public_key = file("C:/terraform-first-fresh-try/id_rsa.pub")
}

os_disk {
	caching = "ReadWrite"
	storage_account_type = "Standard_LRS"

}


#Test with another authentication method (Doesnt work)
#os_profile {
#computer_name  = "maquinalinux"
#admin_username = "intermark"
#admin_password = "Intermark96"
#}

#os_profile_linux_config {
#disable_password_authentication = false
#}


#Operative System ISO Specifications
source_image_reference {
	publisher = "Canonical"
	offer = "0001-com-ubuntu-server-focal"
	sku = "20_04-lts-gen2"
	version = "latest"
}
}
