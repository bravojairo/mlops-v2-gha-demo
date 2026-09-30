# Azure MLOps (v2) solution accelerator

[Main README file](https://github.com/Azure/mlops-v2/blob/main/README.md)

## Terraform state access

The infrastructure workflow authenticates to Azure using the service principal
identified by the repository's `ARM_CLIENT_ID` secret. Terraform uses Azure AD
to read and write blobs in the storage account specified by
`terraform_st_storage_account` in `config-infra-prod.yml`. That service principal
needs **Storage Blob Data Contributor** on the state storage account. An Azure
administrator with permission to create role assignments (such as User Access
Administrator) must grant it; a Contributor deployment identity cannot grant
itself access. From an administrator's Azure CLI session:

```bash
STATE_SCOPE=$(az storage account show \
  --resource-group rg-mlopslite-jbc4prod-tf \
  --name stmlopslitejbc4prodtf --query id -o tsv)
SP_OBJECT_ID=$(az ad sp show --id "<ARM_CLIENT_ID>" --query id -o tsv)
az role assignment create --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" --scope "$STATE_SCOPE"
```

Use the actual state resource group and storage account if the configuration
changes. On a first deployment, run the workflow once to create the state
storage account, then grant access and rerun it. Allow time for Azure RBAC to
propagate. The workflow checks blob-list access before invoking Terraform for
an existing account, rather than reporting the resulting 403 as an installation
failure.
