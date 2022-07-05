param containerAppName string
param location string
param environmentName string 
param containerImage string = 'azureday.azurecr.io/samplecontainerapp/containerappbusiness:v1'
param containerPort int
param isExternalIngress bool
param containerRegistry string = 'azureday.azurecr.io'
param containerRegistryUsername string
param isPrivateRegistry bool
param enableIngress bool 
param registryPassword string
param minReplicas int 
param secrets array = []
param env array = []

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' existing= {
  name: environmentName
}

// container apps business
resource containerAppBusiness 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      secrets: secrets
      registries: isPrivateRegistry ? [
        {
          server: containerRegistry
          username: containerRegistryUsername
          passwordSecretRef: registryPassword
        }
      ] : null
      ingress: enableIngress ? {
        external: isExternalIngress
        targetPort: containerPort
        transport: 'auto'
      } : null
      dapr: {
        enabled: true
        appPort: containerPort
        appId: containerAppName
      }
    }
    template: {
      containers: [
        {
          image: containerImage
          name: containerAppName
          env: env
         
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: 1
      }
    }
  }
}

output fqdn string = enableIngress ? containerAppBusiness.properties.configuration.ingress.fqdn : 'Ingress not enabled'
