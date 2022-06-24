param ContainerAppIngressImage string
param ContainerAppIngressPort int
param ContainerAppIngressIsExternalIngress bool

param ContainerAppBusinessPort string
param ContainerAppBusinessIsExternalIngress bool
param ContainerAppBusinessImage string



param containerRegistry string
param containerRegistryUsername string
@secure()
param containerRegistryPassword string

param tags object


//@secure()
param APPSETTINGS_Clients_BusinessLogic string //"http://business-logic"

var location = resourceGroup().location
var environmentName = 'env-${uniqueString(resourceGroup().id)}'
var minReplicas = 0

var workspaceName = 'container-app-log-analytics'
var appInsightsName = 'container-app-insights'

//var containerAppBusinessServiceAppName = 'container-app-business'
var containerAppIngressServiceAppName = 'sampleingress'
var containerAppBusinessServiceAppName = 'sampleingress'



var containerRegistryPasswordRef = 'container-registry-password'


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

resource containerAppIngress 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: containerAppIngressServiceAppName
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
      ]
      registries: [
        {
          server: containerRegistry
          username: containerRegistryUsername
          passwordSecretRef: containerRegistryPasswordRef
        }
      ]
      ingress: {
        'external': ContainerAppIngressIsExternalIngress
        'targetPort': ContainerAppIngressPort
      }
    }
    template: {
      containers: [
        {
          image: ContainerAppIngressImage
          name: containerAppIngressServiceAppName
          transport: 'auto'         
        }
      ]
      scale: {
        minReplicas: minReplicas
      }
    }
  }
}


resource containerAppBusiness 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: containerAppBusinessServiceAppName
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
      ]
      registries: [
        {
          server: containerRegistry
          username: containerRegistryUsername
          passwordSecretRef: containerRegistryPasswordRef
        }
      ]
      ingress: {
        'external': ContainerAppBusinessIsExternalIngress
        'targetPort': ContainerAppBusinessPort
      }
    }
    template: {
      containers: [
        {
          image: ContainerAppBusinessImage
          name: containerAppBusinessServiceAppName
          transport: 'auto'
          env: [
            {
              name: 'APPSETTINGS_CLIENTS_BUSINESSLOGIC'
              secretref: APPSETTINGS_Clients_BusinessLogic
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
*/
