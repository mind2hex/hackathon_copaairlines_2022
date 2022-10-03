# creacion del resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group[1]}"
  location = "${var.resource_group[0]}"
}

# creacion de la red virtual
resource "azurerm_virtual_network" "virtualnetwork" {
  name                = "${var.virtual_network[0]}"
  address_space       = ["${var.virtual_network[1]}"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# creacion de la subnet
resource "azurerm_subnet" "virtualnetwork_subnet" {
  name                 = "${var.subnet[0]}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.virtualnetwork.name
  address_prefixes     = ["${var.subnet[1]}"]
}

# creacion PIP Windows
resource "azurerm_public_ip" "windowsPIP" {
  name                = "${var.public_ip_names[0]}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# creacion PIP Linux
resource "azurerm_public_ip" "LinuxPIP" {
  name                = "${var.public_ip_names[1]}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# creacion del Network Security Group y la regla para permitir
# conexiones en el puerto 80 del servicio web
resource "azurerm_network_security_group" "nsg" {
  name                = "myNetworkSecurityGroup"   # no hay referencia en variables.tf por que solo se usa una vez
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # regla del firewall para admitir conexiones en el puerto 80
  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # regla del firewall para admitir conexiones en el puerto 22 SSH
  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

}

# Creacion de la NIC de Windows
resource "azurerm_network_interface" "WindowsNIC" {
  name                = "WindowsNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "WindowsNIC_configuration"
    subnet_id                     = azurerm_subnet.virtualnetwork_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windowsPIP.id
  }
}

# Creacion de la NIC de Linux
resource "azurerm_network_interface" "LinuxNIC" {
  name                = "LinuxNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "LinuxNIC_configuration"
    subnet_id                     = azurerm_subnet.virtualnetwork_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.LinuxPIP.id
  }
}

# Conectando el security group a la NIC de Linux
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.LinuxNIC.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Creando WindowsVM
resource "azurerm_windows_virtual_machine" "WindowsVM" {
  name                  = "${var.virtual_machine_names[0]}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.WindowsNIC.id]
  size                  = "Standard_B2s"

  os_disk {
    name                 = "WindowsDISK"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "128"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-DataCenter"
    version   = "latest"
  }

  computer_name                   = "WindowsVM"
  admin_username                  = "windows_user"
  admin_password                  = "Windows_p4ss"  # se cumplen requerimientos de contrasena
}

# Creando LinuxVM
resource "azurerm_linux_virtual_machine" "LinuxVM" {
  name                  = "${var.virtual_machine_names[1]}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.LinuxNIC.id]
  size                  = "Standard_B2s"

  os_disk {
    name                 = "LinuxDisc"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "60"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-LTS"
    version   = "latest"
  }

  computer_name                   = "LinuxVM"
  admin_username                  = "linux_user"
  admin_password                  = "Linux_p4ss"
  disable_password_authentication = false
}

