param location string = resourceGroup().location
param envName string = 'blog-sample'

param containerImage string
param containerPort int
param registry string
param registryUsername string

@secure()
param registryPassword string

module law 'law.bicep' = {
    name: 'log-analytics-workspace'
    params: {
      location: location
      name: 'law-${envName}'
    }
}

module containerAppEnvironment 'environment.bicep' = {
  name: 'container-app-environment'
  params: {
    name: envName
    location: location
    lawClientId:law.outputs.clientId
    lawClientSecret: law.outputs.clientSecret
  }
}

module containerAppIngress 'containerappIngress.bicep' = {
  name: 'containerAppIngress'
  params: {
    name: 'containerAppIngress'
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: containerImage
    containerPort: containerPort
    envVars: [
        {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Production'
        }
    ]
    useExternalIngress: true
    registry: registry
    registryUsername: registryUsername
    registryPassword: registryPassword

  }
}

module containerAppBusiness 'containerappIngress.bicep' = {
  name: 'containerAppBusiness'
  params: {
    name: 'containerAppBusiness'
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: containerImage
    containerPort: containerPort
    envVars: [
        {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Production'
        }
    ]
    useExternalIngress: true
    registry: registry
    registryUsername: registryUsername
    registryPassword: registryPassword

  }
}

output fqdnIngress string = containerAppIngress.outputs.fqdn
output fqdnBusiness string = containerAppBusiness.outputs.fqdn
