@sys.description('The Web App name.')
@minLength(3)
@maxLength(24)
param appServiceAppName string = 'vprohaska-app-bicep'
@sys.description('The App Service Plan name.')
@minLength(3)
@maxLength(24)
param appServicePlanName string = 'vprohaska-app-bicep'
@sys.description('The Storage Account name.')
@minLength(3)
@maxLength(24)
@allowed([
  'nonprod'
  'prod'
  ])
param environmentType string = 'nonprod'
param location string = resourceGroup().location

@secure()
param dbhost string
@secure()
param dbuser string
@secure()
param dbpass string
@secure()
param dbname string

param rgLocation string = resourceGroup().location
param storageNames array = [
  'verastorage1'
  'verastorage2'
]

resource appStorageName 'Microsoft.Storage/storageAccounts@2021-06-01' = [for (name, i) in storageNames: {
  name: '${i}${name}${uniqueString(resourceGroup().id)}'
  location: rgLocation
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
}]

  module appService 'modules/appStuff.bicep' = {
    name: 'appService'
    params: {
      location: location
      appServiceAppName: appServiceAppName
      appServicePlanName: appServicePlanName
      environmentType: environmentType
      dbhost: dbhost
      dbuser: dbuser
      dbpass: dbpass
      dbname: dbname
    }
  }

  output appServiceAppHostName string = appService.outputs.appServiceAppHostName
 