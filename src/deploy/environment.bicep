param name string
param location string
param lawClientId string
param lawClientSecret string

resource env 'Microsoft.Web/kubeEnvironments@2021-03-01' = {
  name: name
  location: location
  properties: {
    environmentType: 'managed' //take a look
    internalLoadBalancerEnabled: false
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration:{
        customerId: lawClientId
        sharedKey: lawClientSecret
      }
    }
  }
}

output id string = env.id
