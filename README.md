# Desafio-Minsait
Repositório dedicado ao desafio proposto pela Minsait.

## Configuração do Projeto

### Pré-requisitos

- [Terraform](https://www.terraform.io/downloads.html) instalado
- [Azure CLI](https://learn.microsoft.com/pt-br/cli/azure/install-azure-cli) instalado
- Conta no Azure com as credenciais necessárias

### Configuração das Chaves SSH

1. Gere um par de chaves SSH (se ainda não tiver um). Dentro do repositório clonado, execute o seguinte comando no terminal:

    ssh-keygen -t rsa -b 2048 -f id_rsa

    Isso irá gerar dois arquivos:
    - `id_rsa` (chave privada)
    - `id_rsa.pub` (chave pública)

### Login na azure

1. Realize o login na azure com o seguinte comando comando no terminal:

    az login

Ao utilizar o comando será exibida uma tela para selecionar a sua conta.

### Configuração de Variáveis de Ambiente

1. Obtenha a lista de Subscriptions da sua conta azure com o seguinte comando:

    az account list --output table

Veja qual subscription deseja uitlizar e copie seu SubscriptionId

2. Crie um Service Principal no Azure AD e atribua um papel de Contribuitor com o seguinte comando:

    az ad sp create-for-rbac --name terraform-sp --role Contributor --scopes /subscriptions/seuSubscriptionId

Substitua o "seuSubscriptionId" pelo ID que copiou, como por exemplo: /subscription/12345678-1234-1234-1234-123456789abc

3. Ao utilizar o comando anterior, você receberá um JSON com o seguinte formato:

    {
        "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "displayName": "terraform-sp",
        "name": "http://terraform-sp",
        "password": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    }

4. Exporte as variáveis de ambiente no terminal com os seguintes comandos no repositório clonado:

    export TF_VAR_subscription_id="seu_subscriptionId"
    export TF_VAR_client_id="seu_appId"
    export TF_VAR_client_secret="seu_password"
    export TF_VAR_tenant_id="seu_tenant"

Substitua `seu_subscriptionId`, `seu_appId`, `seu_password` e `seu_tenant` pelos valores reais das suas credenciais do Azure, obtidos no passo anterior:

### Executando o Terraform

1. Com as variáveis de ambiente configuradas, execute os comandos do Terraform:

    terraform init
    terraform plan
    terraform apply

### Conexão com a vm

1. Obtenha o ip público da vm que foi criada com o comando:

    az vm show -d -g rg-minsait -n vm-minsait --query publicIps -o tsv

2. Para acessar a vm utilize o comando:

    ssh -i id_rsa minsait@<seu_ip_publico>

Substtitua o <seu_ip_publico> pelo ip obtido, como por exemplo ssh -i id_rsa minsait@40.112.187.10

### Limpeza

Para destruir os recursos provisionados, execute:

terraform destroy

az vm show -d -g rg-minsait -n vm-minsait --query publicIps -o tsv