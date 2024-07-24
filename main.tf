# Bloco de configuração do Terraform:
# - Define os provedores necessários e suas versões.
# - Especifica a versão mínima do Terraform necessária para este código.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75.0"
    }
  }

  required_version = ">= 1.1.0"
}

# Bloco de configuração do provedor AzureRM:
# - Configura as credenciais para se conectar à conta do Azure.
# - As credenciais são passadas como variáveis.inform
provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Blocos de variáveis:
# - Definem variáveis que serão usadas para armazenar as credenciais do Azure.
# - Estas variáveis devem ser passadas ao executar o Terraform ou definidas em arquivos de variáveis.
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

# Recurso Azure Resource Group:
# - Cria um grupo de recursos no Azure chamado "rg-minsait".
# - Especifica a localização como "West US".
resource "azurerm_resource_group" "main" {
  name     = "rg-minsait"
  location = "West US"
}

# Recurso Azure Virtual Network:
# - Cria uma rede virtual chamada "vnet-minsait".
# - Define o espaço de endereços IP como "10.0.0.0/16".
# - A rede virtual está localizada no grupo de recursos criado anteriormente.
resource "azurerm_virtual_network" "main" {
  name                = "vnet-minsait"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Recurso Azure Subnet:
# - Cria uma sub-rede chamada "subnet-minsait" dentro da rede virtual "vnet-minsait".
# - Define o prefixo de endereço IP como "10.0.1.0/24".
resource "azurerm_subnet" "main" {
  name                 = "subnet-minsait"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Recurso Azure Network Security Group (NSG):
# - Cria um grupo de segurança de rede chamado "nsg-minsait".
# - Adiciona uma regra de segurança para permitir conexões SSH (porta 22) de qualquer endereço IP.
resource "azurerm_network_security_group" "main" {
  name                = "nsg-minsait"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Recurso Azure Network Interface:
# - Cria uma interface de rede chamada "nic-minsait".
# - A interface está associada à sub-rede "subnet-minsait".
# - Configura um IP público dinâmico.
resource "azurerm_network_interface" "main" {
  name                = "nic-minsait"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# Associação de Grupo de Segurança de Rede:
# - Associa a interface de rede "nic-minsait" ao grupo de segurança de rede "nsg-minsait".
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Recurso Azure Public IP:
# - Cria um IP público dinâmico chamado "public-ip-minsait".
resource "azurerm_public_ip" "main" {
  name                = "public-ip-minsait"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
}

# Recurso Azure Linux Virtual Machine:
# - Cria uma VM Linux chamada "vm-minsait".
# - Especifica o tipo de máquina como "Standard_B1s".
# - Usa um par de chaves SSH para autenticação.
# - Está associada à interface de rede "nic-minsait".
# - O disco do SO é configurado com 30 GB de armazenamento padrão LRS.
# - Usa uma imagem Ubuntu 18.04 LTS.
# - Executa um script de inicialização para configurar a VM (instalação do Docker, etc.).
resource "azurerm_linux_virtual_machine" "main" {
  depends_on = [azurerm_network_interface.main]

  name                = "vm-minsait"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_B1s"
  admin_username      = "minsait"

  admin_ssh_key {
    username   = "minsait"
    public_key = file("${path.module}/id_rsa.pub")
  }

  network_interface_ids = [azurerm_network_interface.main.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(file("init-script.sh"))

  tags = {
    environment = "Testing"
  }
}

# Saída do IP privado:
# - Exibe o endereço IP privado da interface de rede.
output "private_ip_address" {
  value = azurerm_network_interface.main.private_ip_address
}

# Saída do IP público:
# - Exibe o endereço IP público associado à VM.
output "public_ip_address" {
  value = azurerm_public_ip.main.ip_address
}