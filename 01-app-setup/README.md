# Application Infrastructure Setup

This deploys the set of infrastructure required to run the application

The main components of the application are:

* Azure SQL for storing data
* Azure Storage for storing binary blob uploads
* Azure Application for enabling single sign on

No secret credentials are stored or created during deployment as all authentication is handled by Azure AD, including access to the database and storage.

## 1. Database and Storage

1. Determine who will be the **database administrator**
2. Find the **Object ID** in Azure AD that corresponds to their identity

```bash
# The Azure AD Object ID of the SQL Server Database Administrator
az ad signed-in-user show --query 'objectId' -o tsv # aad_admin_objectid
```

> Note: You would ideally use a group identity here rather than a single user, for example a group called "Azure Arc SQL Server Admins" however creating an Azure AD group is a privileged operation that you may not have access to

## 2. User Authentication

To allow users to sign-in to your deployment of the application you will need to register a new application with Azure AD and take note of it's **Application ID**

You can re-use the same Application ID in multiple regions, runs and deployments. The same application can be shared for all running instances of the Reviewer application.

The only reason you must create a new application is so that you have control over the **Reply URLs** and can add your own values to redirect to **your** applications after signing in with Azure AD.

```
# Register Application
SUFFIX=$RANDOM
APP=$(az ad app create --display-name="Item Reviewer $SUFFIX" --available-to-other-tenants=true)
APP_ID=$(echo $APP | jq -r .appId)
OBJECT_ID=$(echo $APP | jq -r .objectId)

# Update requestedAccessTokenVersion to v2, add SPA reply urls and set application URI
# you should add on more hosts into the `redirectUris` array that correspond to your hosts
REDIRECT_URIS=$(az network public-ip list --query "[?name=='Arc-K3s-Demo-PIP'].join('', ['https://', dnsSettings.fqdn])" -o json)
az rest \
    --method PATCH \
    --headers "Content-Type=application/json" \
    --uri "https://graph.microsoft.com/v1.0/applications/${OBJECT_ID}" \
    --body "{\"api\":{\"requestedAccessTokenVersion\":2}, \"identifierUris\":[\"api://${APP_ID}\"], \"spa\":{\"redirectUris\":$REDIRECT_URIS}}"

# You will need this when running the Infrastructure deployment
echo "Application ID: ${APP_ID}"

```

## 3. Generate Kubernetes Manifests

1. Run the **Deploy Infrastructure** workflow from [GitHub Actions](../../../actions/workflows/01-app-infra.yml) specifying the secret name you added previously e.g. `AZURE_CREDENTIALS_WESTEUROPE` and the values above
2. Download the generated manifest bundle from the run artifacts

> Note: This doesn't actually deploy the application to your cluster as we are controlling that with GitOps. It does however generate the set of manifests that you can directly commit to an Application Developer owned repository.

## 4. Create SQL Schema

All infrastructure will now be provisioned so it's time to create the DB schema. The SQL Server we deployed has [Azure AD Authentication Only](https://docs.microsoft.com/azure/azure-sql/database/authentication-azure-ad-only-authentication?tabs=azure-cli) so without allowing admin access to a group that the GitHub Action also has access to we can't yet deploy changes automatically. This means you will need to log in to your server manually and deploy a few resources to allow the application to work.

1. Download [Azure Data Studio](https://azure.microsoft.com/services/developer-tools/data-studio/)
2. Find the **connection details** in the output of your GitHub Action run

![connect to your database](https://user-images.githubusercontent.com/51163690/127883966-cbba4e5a-4239-4e76-a71e-41685cb4fe67.png)

3. Connect to SQL Server as the **database administrator** (Azure AD Admin specified earlier)

![use Azure AD Auth](https://user-images.githubusercontent.com/51163690/127884156-c19f1f00-f90b-4e44-a1d2-9f217cd9fc3b.png)

4. Create [contained users](https://docs.microsoft.com/azure/active-directory/managed-identities-azure-resources/tutorial-windows-vm-access-sql#create-contained-user) by executing the code written to the log of the GitHub Action under **Next Steps**

> Note: The exact SQL to execute will look something like this

```sql
# Replace ... with the output from the GitHub Action
CREATE USER [...] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [...];
ALTER ROLE db_datawriter ADD MEMBER [...];
```

5. If you haven't already, then also deploy the [Application Schema](../scripts/schema.sql). It is included in the **Next Steps** output above

# Troubleshooting

* Can't create an Azure AD group for the DB Admin. This can happen if you aren't an Admin of your Azure AD tenant or have otherwise been restricted from creating groups. As a workaround you can set just one person as the DB administrator by finding their Azure AD Object ID.
