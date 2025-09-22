# Azure Infrastructure as Code

This repository contains Terraform configurations for deploying Azure infrastructure components for the Tyrant project within a hub-spoke architecture of IXM.

## Project Structure

The infrastructure has been organized into logical modules for better maintainability and readability:

### Core Configuration Files

* `main.tf` - Overview and documentation of the project structure
* `providers.tf` - Terraform configuration and provider blocks (AzureRM, Kubernetes; Helm temporarily commented out)
* `variables.tf` - Input variables and their default values
* `output.tf` - Output values for use by other modules or external systems
* `backend.tf` - Terraform backend configuration for state management

### Infrastructure Components

* `resource-groups.tf` - Resource group logic and local variables
* `networking.tf` - Virtual network, subnets, and DNS zones (using pre-provisioned spoke resources)
* `container-registry.tf` - Azure Container Registry (ACR) configuration (using hub ACR)
* `kubernetes.tf` - Azure Kubernetes Service (AKS) cluster, namespaces, and Helm releases
* `databases.tf` - PostgreSQL Flexible Server and all databases (dev/test/prod environments)
* `storage.tf` - Azure Storage Account resources
* `key-vault.tf` - Azure Key Vault and access policies
* `monitoring.tf` - Log Analytics Workspace and Application Insights
* `ai-services.tf` - Azure OpenAI Service and other AI services
* `api-management.tf` - Azure API Management Service for API gateway and management
* `roles.tf` - Role assignments and permissions

## Infrastructure Overview

This configuration deploys a complete Azure infrastructure within a spoke, integrated with a hub, including:

- **Networking**: Utilizes pre-provisioned spoke virtual network with dedicated subnets for AKS, PostgreSQL, and API Management, peered with the hub.
- **Container Platform**: AKS cluster with NGINX ingress controller (Helm deployment pending provider fix).
- **Databases**: PostgreSQL Flexible Server with databases for dev, test, and prod environments, using private endpoints.
- **Storage**: Azure Storage Account for data persistence with private endpoints.
- **Security**: Key Vault for secrets management, linked to hub for certificates.
- **Monitoring**: Log Analytics and Application Insights, linked to hub workspace.
- **AI Services**: Azure OpenAI Service with private endpoints.
- **API Management**: Azure API Management Service integrated with spoke subnets.

## Getting Started

1. Ensure you have Terraform installed (version >= 1.0).
2. Configure your Azure credentials using a service principal with appropriate roles (see below).
3. Update variables in `variables.tf` or set them via pipeline variables as needed.
4. Run `terraform init` to initialize the backend (using hub storage).
5. Run `terraform plan` to review the deployment plan.
6. Run `terraform apply` to deploy the infrastructure.

## Terraform Service Principal Requirements

The Terraform service principal used for deploying this infrastructure requires specific Azure AD permissions to successfully create and manage all resources. The following permissions are required:

### Required Azure AD Roles

1. **Contributor Role (Subscription level)**
   - Allows the service principal to create, update, and delete Azure resources.
   - Required for managing all infrastructure components (AKS, databases, storage, etc.).
2. **User Administrator Role (Azure AD level)**
   - Allows the service principal to manage users and groups in Azure AD.
   - Required for creating and managing service principals, managed identities, and role assignments.
3. **Application Administrator Role (Azure AD level)**
   - Allows the service principal to manage application registrations and service principals.
   - Required for creating and configuring managed identities and application registrations.
