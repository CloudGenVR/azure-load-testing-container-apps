param location string = resourceGroup().location
param name string 

resource symbolicname 'Microsoft.LoadTestService/loadTests@2022-04-15-preview' = {
  name: name
  location: location
  tags: {
    DemoPerformance: 'Azure Load Testing'
  }
  identity: {
    type: 'SystemAssigned'
  }
}
