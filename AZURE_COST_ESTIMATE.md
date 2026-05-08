# Azure Cost Estimation - Resource Inventory

This document lists all Azure resources configured in this Terraform deployment that you can use with the [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/).

## Overview
**Location**: North Europe  
**Project Name**: tf-project (default)  
**Environment**: prod (default)

---

## Resource List for Azure Calculator

### 1. **App Service**
- **Service Name**: App Service
- **Plan Tier**: Basic (B1)
- **Operating System**: Linux
- **Instance Count**: 1 (default)
- **Approximate Spec**: 
  - 1 vCPU
  - 1.75 GB RAM
  - 10 GB Storage
- **Resource Name**: `${project_name}-app`
- **Region**: North Europe
- **Additional Features**:
  - System-Assigned Managed Identity: Yes
  - Key Vault Integration: Yes

> Note: Azure Pricing Calculator does not expose a separate "App Service Plan" item for this scenario. The App Service estimate already includes the underlying App Service Plan pricing.

### 2. **Key Vault**
- **Service Name**: Azure Key Vault
- **SKU**: Standard
- **Operations Estimated**:
  - Secret Get operations: ~1,000/month (estimate)
  - Secret List operations: ~100/month (estimate)
- **Resource Name**: `${project_name}-kv`
- **Region**: North Europe
- **Additional Info**: 
  - Stores secrets for the web app
  - Access policy for web app managed identity

### 3. **Log Analytics Workspace**
- **Service Name**: Log Analytics Workspace
- **SKU**: Per GB 2018
- **Data Retention**: 30 days
- **Estimated Ingestion**: (Varies based on logging level)
  - Minimum: ~0.5 GB/day (conservative estimate)
  - Medium: ~2 GB/day
  - High: ~5+ GB/day
- **Resource Name**: `${project_name}-logs`
- **Region**: North Europe
- **Note**: Log volume depends on:
  - Web app activity
  - Application Insights integration
  - Diagnostic settings enabled

> Note: If the calculator does not show a direct "Log Analytics Workspace" card, search for "Log Analytics" or use the Azure Monitor section and select Log Analytics Workspace from there.

### 4. **Resource Group**
- **Service Name**: Resource Group (No charge)
- **Name**: `${project_name}-rg`
- **Region**: North Europe
- **Purpose**: Container for all resources above

---

## Cost Calculation Steps

### Using Azure Pricing Calculator:

1. **Add App Service**
   - Search for "App Service"
   - Choose "Linux" OS
   - Select "B1" tier
   - Set instance count to 1
   - Set region to "North Europe"

2. **Add Key Vault**
   - Search for "Azure Key Vault"
   - Choose "Standard" tier
   - Enter estimated operations per month
   - Set region to "North Europe"

3. **Add Log Analytics Workspace**
   - Search for "Log Analytics" or open the Azure Monitor section
   - Select "Log Analytics Workspace"
   - Choose "Per GB 2018" pricing model
   - Enter estimated GB/day ingestion
   - Set retention to 30 days
   - Set region to "North Europe"

> Note: App Service pricing includes the App Service Plan. There is no separate App Service Plan entry to add in the calculator for this deployment.

---

## Estimated Monthly Cost Breakdown (Rough Estimates)

| Resource | Tier/Size | Estimated Monthly Cost |
|----------|-----------|----------------------|
| App Service Plan (B1) | 1 vCPU, 1.75GB RAM | $10-15 |
| Key Vault | Standard + Operations | $0.50-2.00 |
| Log Analytics | Per GB 2018 | $2-15* |
| **Total** | | **$12.50-32** |

*Log Analytics is highly variable based on data ingestion volume.

---

## Variables to Configure for Accurate Pricing

1. **Expected Daily Users/Traffic**
   - Affects compute requirements and logging volume

2. **Application Runtime Stack**
   - Different runtimes may have different licensing costs

3. **Data Ingestion Volume**
   - Log Analytics costs scale with data ingestion
   - Estimate based on expected logs/metrics

4. **Backup & Disaster Recovery**
   - Not configured yet but add to estimate if needed

5. **SSL Certificate**
   - Not configured yet; HTTPS access uses managed certificate

---

## Cost Optimization Tips

1. **App Service Plan**: Consider shared tier or consumption-based options if traffic is low
2. **Log Analytics**: Adjust retention policy or sampling to reduce ingestion costs
3. **Key Vault**: Monitor transaction volume; consolidate operations where possible
4. **Auto-scaling**: Add auto-scale rules to handle traffic spikes efficiently
5. **Reserved Instances**: If workload is stable, purchase 1-year or 3-year reserved capacity

---

## Next Steps

1. Visit [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
2. Add each resource from the list above
3. Adjust quantities/sizes based on your actual needs
4. Export the estimate for budget planning
5. Review monthly charges in Azure Cost Management after deployment

---

## Additional Considerations

- **Data Transfer**: Outbound data transfer costs apply (not included in plan pricing)
- **Backup Storage**: If enabling backups, add storage costs
- **Custom Domain**: Using custom domain requires DNS hosting (not included)
- **Application Insights**: If enabled, adds additional monitoring costs
- **Managed Identity**: No direct charge but requires RBAC configuration
