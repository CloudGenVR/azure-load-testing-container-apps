param location string = resourceGroup().location
param environmentName string = 'env-${uniqueString(resourceGroup().id)}'
param isPrivateRegistry bool = true
param containerRegistry string
param containerRegistryUsername string = 'testUser'
@secure()
param containerRegistryPassword string = ''
param registryPassword string = 'registry-password'

//ingress app
param appIngressImage string = ''
param appIngressPort int
param appIngressisExternalIngress bool = true
var appIngressServiceName = 'appingress-app'


//business app
param appBusinessImage string = ''
param appBusinessPort int
param appBusinessExternalIngress bool = true
var appBusinessServiceName = 'appbusiness-app'
//@secure()
//param APPSETTINGS_Clients_BusinessLogic string //"http://business-logic"

module environment 'environment.bicep' = {
  name: '${deployment().name}--environment'
  params: {
    environmentName: environmentName
    location: location
    appInsightsName: '${environmentName}-ai'
    logAnalyticsWorkspaceName: '${environmentName}-la'
  }
}

module appingress 'appingress.bicep' = {
  name: '${deployment().name}--${appIngressServiceName}'
  dependsOn: [
    environment
  ]
  params: {
    minReplicas: 0 
    containerAppName: appIngressServiceName
    containerImage: appIngressImage
    containerPort: appIngressPort
    containerRegistry: containerRegistry
    containerRegistryUsername: containerRegistryUsername
    enableIngress: true
    environmentName: environmentName
    isExternalIngress: appIngressisExternalIngress
    isPrivateRegistry: isPrivateRegistry
    location: location
    registryPassword: registryPassword
    secrets: [
      {
        name: registryPassword
        value: containerRegistryPassword
      }
    ]
  }
}

module appbusiness 'appbusiness.bicep' = {
  name: '${deployment().name}--${appBusinessServiceName}'
  dependsOn: [
    environment
  ]
  params: {
    minReplicas: 0 
    containerAppName: appBusinessServiceName
    containerImage: appBusinessImage
    containerPort: appBusinessPort
    containerRegistry: containerRegistry
    containerRegistryUsername: containerRegistryUsername
    enableIngress: true
    environmentName: environmentName
    isExternalIngress: appBusinessExternalIngress
    isPrivateRegistry: isPrivateRegistry
    location: location
    registryPassword: registryPassword
    secrets: [
      {
        name: registryPassword
        value: containerRegistryPassword
      }
    ]
  }
}


output appingressFqdn string = appingress.outputs.fqdn
output appbusinessFqdn string = appbusiness.outputs.fqdn



