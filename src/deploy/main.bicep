param nodeImage string
param nodePort int
param nodeIsExternalIngress bool

param containerRegistry string
param containerRegistryUsername string
@secure()
param containerRegistryPassword string

param tags object

@secure()
param APPSETTINGS_API_KEY string
/*param APPSETTINGS_DOMAIN string
param APPSETTINGS_FROM_EMAIL string
param APPSETTINGS_RECIPIENT_EMAIL string */

var location = resourceGroup().location
var environmentName = 'env-${uniqueString(resourceGroup().id)}'
var minReplicas = 0

var nodeServiceAppName = 'node-app'
var workspaceName = 'workspace-zureday2022WfgL'
var appInsightsName = '${nodeServiceAppName}-app-insights'

var containerRegistryPasswordRef = 'container-registry-password'
var mailgunApiKeyRef = 'mailgun-api-key'



//Log analitycs workspace
resource workspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
    name: workspaceName
    location: location
    tags: tags
    properties: {
      sku: {
        name: 'PerGB2018'
      }
      retentionInDays: 30
      workspaceCapping: {}
    }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
  }
}

resource environment 'Microsoft.App/managedEnvironments@2022-01-01-preview' = {
  name: environmentName
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: workspace.properties.customerId
        sharedKey: listKeys(workspace.id, workspace.apiVersion).primarySharedKey
      }
    }
  }
}

resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: nodeServiceAppName
  kind: 'containerapps'
  tags: tags
  location: location
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      secrets: [
        {
          name: containerRegistryPasswordRef
          value: containerRegistryPassword
        }
        {
          name: mailgunApiKeyRef
          value: APPSETTINGS_API_KEY
        }
      ]
      registries: [
        {
          server: containerRegistry
          username: containerRegistryUsername
          passwordSecretRef: containerRegistryPasswordRef
        }
      ]
      ingress: {
        'external': nodeIsExternalIngress
        'targetPort': nodePort
      }
    }
    template: {
      containers: [
        {
          image: nodeImage
          name: nodeServiceAppName
          transport: 'auto'
          env: [
            {
              name: 'APPSETTINGS_API_KEY'
              secretref: mailgunApiKeyRef
            }                    
          ]
        }
      ]
      scale: {
        minReplicas: minReplicas
      }
    }
  }
}
