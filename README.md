# Terraform Azure Basic Deployment Guide

This guide explains the key Terraform concepts demonstrated in your Azure basic deployment project. It covers infrastructure as code principles, Azure resource management, and best practices for deploying cloud infrastructure.

## Table of Contents
1. [Terraform Fundamentals](#terraform-fundamentals)
2. [Azure Provider Configuration](#azure-provider-configuration)
3. [Variables and Outputs](#variables-and-outputs)
4. [Resource Management](#resource-management)
5. [Data Sources](#data-sources)
6. [State Management](#state-management)
7. [Modules](#modules)
8. [Identity and Access Management](#identity-and-access-management)
9. [Best Practices](#best-practices)

## Terraform Fundamentals

### What is Terraform?
Terraform is an infrastructure as code (IaC) tool that allows you to define and provision infrastructure using a declarative configuration language. Instead of manually creating resources through a cloud console, you write code that describes your desired infrastructure state.

### Core Components
- **Providers**: Plugins that allow Terraform to interact with cloud platforms (like Azure, AWS, GCP)
- **Resources**: Individual infrastructure components (VMs, networks, databases, etc.)
- **Data Sources**: Read existing infrastructure information
- **Variables**: Parameterize your configurations for reusability
- **Outputs**: Expose information about your infrastructure after deployment

## Azure Provider Configuration

### Provider Block
```hcl
provider "azurerm" {
  features {}
}
```
The `azurerm` provider enables Terraform to manage Azure resources. The `features` block is required and allows you to enable/disable specific provider features.

### Required Providers
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}
```
This block specifies which providers your configuration needs and their version constraints. The `~> 3.0` means "any version 3.x but not 4.0".

## Variables and Outputs

### Input Variables
```hcl
variable "project_name" {
  default = "tf-project"
}

variable "location" {
  default = "northeurope"
}

variable "environment" {
  default = "prod"
}
```
Variables make your configuration reusable and configurable. You can override defaults via:
- Command line: `terraform plan -var="project_name=myproject"`
- Environment variables: `TF_VAR_project_name=myproject`
- Variable files: `terraform plan -var-file="production.tfvars"`

### Output Values
```hcl
output "app_url" {
  value = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "key_vault_uri" {
  value = azurerm_key_vault.main.vault_uri
}
```
Outputs expose information about your infrastructure. After `terraform apply`, you can query outputs with `terraform output <name>`.

## Resource Management

### Resource Declaration
```hcl
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-rg"
  location = var.location
}
```
Resources are the core of Terraform configurations. Each resource block creates exactly one infrastructure object.

### Resource Types
Your project demonstrates several Azure resource types:

#### Resource Group
```hcl
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-rg"
  location = var.location
}
```
Resource groups are containers that hold related Azure resources. They're fundamental to Azure's resource management.

#### App Service Plan
```hcl
resource "azurerm_service_plan" "main" {
  name                = "${var.project_name}-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "B1"
  os_type             = "Linux"
}
```
App Service Plans define the compute resources for your web apps. The SKU "B1" is a basic tier plan.

#### Linux Web App
```hcl
resource "azurerm_linux_web_app" "main" {
  name                = "${var.project_name}-app"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id
  site_config {}
  identity {
    type = "SystemAssigned"
  }
}
```
Web Apps host your application code. The `identity` block enables managed identity for secure authentication.

#### Key Vault
```hcl
resource "azurerm_key_vault" "main" {
  name                = "${var.project_name}-kv"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}
```
Key Vault securely stores secrets, keys, and certificates.

#### Log Analytics Workspace
```hcl
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.project_name}-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
```
Log Analytics collects and analyzes telemetry data from your Azure resources.

## Data Sources

### Client Configuration
```hcl
data "azurerm_client_config" "current" {}
```
Data sources fetch information from existing infrastructure. `azurerm_client_config` provides details about the current Azure context, including tenant ID and subscription ID.

## State Management

### Remote Backend
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tf-rg"
    storage_account_name = "tfstorage552026"
    container_name       = "tf-container"
    key                  = "prod.terraform.tfstate"
  }
}
```
The backend configuration tells Terraform where to store its state file. Using Azure Storage ensures:
- State persistence across machines
- Collaboration safety
- State locking to prevent concurrent modifications

## Modules

### Module Structure
Your project includes module directories:
```
modules/
  monitoring/
  network/
```
Modules allow you to organize and reuse Terraform configurations. Even though they're empty in your project, they would contain:
- `main.tf`: Module resources
- `variables.tf`: Module inputs
- `outputs.tf`: Module outputs

### Using Modules
```hcl
module "network" {
  source = "./modules/network"
  # variables...
}
```

## Identity and Access Management

### System-Assigned Managed Identity
```hcl
resource "azurerm_linux_web_app" "main" {
  # ...
  identity {
    type = "SystemAssigned"
  }
}
```
Managed identities allow Azure resources to authenticate to other Azure services without storing credentials.

### Key Vault Access Policy
```hcl
resource "azurerm_key_vault" "main" {
  # ...
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_linux_web_app.main.identity[0].principal_id

    secret_permissions = [
      "Get",
      "List"
    ]
  }
}
```
Access policies control who can access Key Vault secrets. Here, the web app's managed identity gets read permissions.

## Best Practices

### 1. Use Variables for Configurability
- Avoid hardcoding values
- Use variables for environment-specific settings

### 2. Leverage Resource References
- Use `resource.name.attribute` instead of hardcoded values
- Ensures dependencies are properly tracked

### 3. Implement Remote State
- Store state remotely for collaboration
- Enable state locking

### 4. Use Managed Identities
- Avoid storing credentials in code
- Leverage Azure's built-in authentication

### 5. Organize with Modules
- Break complex configurations into reusable modules
- Improve maintainability and testing

### 6. Validate and Format Code
- Run `terraform validate` to check syntax
- Use `terraform fmt` for consistent formatting

### 7. Plan Before Apply
- Always review `terraform plan` output
- Understand what changes will be made

## Common Commands

```bash
# Initialize working directory
terraform init

# Format configuration files
terraform fmt

# Validate configuration
terraform validate

# Create execution plan
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy

# Show state
terraform show

# List resources
terraform state list
```

## Next Steps

1. **Add Application Deployment**: Configure your web app to deploy actual application code
2. **Implement Monitoring**: Use the monitoring module to add Application Insights
3. **Network Security**: Add virtual networks, subnets, and NSGs in the network module
4. **CI/CD Integration**: Use the bash script to automate deployments
5. **Environment Management**: Create separate configurations for dev/staging/prod

This guide covers the foundational concepts in your Terraform project. As you expand your infrastructure, refer back to these principles for consistent and maintainable code.</content>
<parameter name="filePath">c:\Users\TelvinCaesarVarfley\dev\2026\azure-tee\terraform-basica\basic deployment\guide.md