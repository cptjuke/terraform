#Proveedor y version
terraform {
required_providers {
	azurerm = {
		source = "hashicorp/azurerm"
		version = "3.0.0"
		}
	}
}

#Configuracion de Azure
provider "azurerm" {
features {}
}

#Crear un grupo de recursos
resource "azurerm_resource_group" "gruporecursos" {
name = "gruporecursos"
location = "West Europe"
}


#Crear una red virtual
resource "azurerm_virtual_network" "redvirtual" {
name = "redvirtual"
address_space = ["10.0.0.0/16"]
location = "West Europe"
resource_group_name = azurerm_resource_group.gruporecursos.name
}

#Crear una subred virtual
resource "azurerm_subnet" "subred" {
name = "redinterna"
resource_group_name = azurerm_resource_group.gruporecursos.name
virtual_network_name = azurerm_virtual_network.redvirtual.name
address_prefixes = ["10.0.0.0/24"]
}

#Crear IPs publicas
resource "azurerm_public_ip" "ip_publica" {
	name = "ippublica"
	location = "West Europe"
	resource_group_name = azurerm_resource_group.gruporecursos.name
	allocation_method = "Static"
}


#Crear grupo de seguridad de la red y reglas de acceso
resource "azurerm_network_security_group" "gruposeg" {
	name = "grupodeseguridad"
	location = "West Europe"
	resource_group_name = azurerm_resource_group.gruporecursos.name

#Regla de acceso	
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


#Crear una tarjeta de red
resource "azurerm_network_interface" "nic" {
name = "network-nic"
location = "West Europe"
resource_group_name = azurerm_resource_group.gruporecursos.name

ip_configuration {
name = "internal"
subnet_id = azurerm_subnet.subred.id
private_ip_address_allocation = "Dynamic"
public_ip_address_id = azurerm_public_ip.ip_publica.id
}
}

#Crear maquina virtual
resource "azurerm_linux_virtual_machine" "maquinalinux" {
name = "maquinalinux"
resource_group_name = azurerm_resource_group.gruporecursos.name
location = "West Europe"
size = "Standard_B1ls"
admin_username = "jccalvo"
network_interface_ids = [
azurerm_network_interface.nic.id
]


#Llave ssh generarla con key autogen y fijarse bien en el archivo que colocamos, el admin_username de la maquina virtual y el username deben coincidir
admin_ssh_key {
  username = "jccalvo"
  public_key = file("C:/terraform-first-fresh-try/id_rsa.pub")
}

os_disk {
	caching = "ReadWrite"
	storage_account_type = "Standard_LRS"

}


#Experimento para otro metodo de conexión (no sale bien)	
#os_profile {
#computer_name  = "maquinalinux"
#admin_username = "intermark"
#admin_password = "Intermark96"
#}

#os_profile_linux_config {
#disable_password_authentication = false
#}


#Imagen del sistema operativo
source_image_reference {
	publisher = "Canonical"
	offer = "0001-com-ubuntu-server-focal"
	sku = "20_04-lts-gen2"
	version = "latest"
}
}
