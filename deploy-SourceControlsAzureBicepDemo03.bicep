/**
   Begin common prolog commands
   write-output "Begin common prolog"
   $name='SourceControlsAzureBicepDemo03'
   $rg="rg_$name"
   $loc='westus2'
   write-output "End common prolog"
   End common prolog commands

   emacs 1
   Begin commands to deploy this file using Azure CLI with PowerShell
   echo WaitForBuildComplete
   WaitForBuildComplete
   write-output "Previous build is complete. Begin deployment build."
   az.cmd deployment group create --name $name --resource-group $rg   --template-file  deploy-SourceControlsAzureBicepDemo03.bicep 
   write-output "end deploy"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs 2
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   echo CreateBuildEvent.exe
   CreateBuildEvent.exe&
   write-output "begin shutdown"
   az.cmd deployment group create --mode complete --template-file ./clear-resources.json --resource-group $rg
   BuildIsComplete.exe
   Get-AzResource -ResourceGroupName $rg | ft
   write-output "showdown is complete"
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs 3
   Begin commands for one time initializations using Azure CLI with PowerShell
   az.cmd group create -l $loc -n $rg
   $id=(az.cmd group show --name $rg --query 'id' --output tsv)
   write-output "id=$id"
   $sp="spad_$name"
   az.cmd ad sp create-for-rbac --name $sp --sdk-auth --role contributor --scopes $id
   write-output "go to github settings->secrets and create a secret called AZURE_CREDENTIALS with the above output"
   write-output "{`n`"`$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",`n `"contentVersion`": `"1.0.0.0`",`n `"resources`": [] `n}" | Out-File -FilePath clear-resources.json
   End commands for one time initializations using Azure CLI with PowerShell

 */

param name string= uniqueString(resourceGroup().name)
param appplanName string = '${name}-app-plan'
param appname string = '${name}-web-site'
param location string = resourceGroup().location

resource appPlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appplanName
  location: location
  sku: {
    name: 'F1'
    capacity: 1
  }
  tags: {
    displayName: appplanName
  }
  properties: {
    name: appplanName
  }
}

resource website 'Microsoft.Web/sites@2021-03-01' = {
  name: appname
  location: location
  properties: {
    serverFarmId: appPlan.id
    siteConfig: {
      webSocketsEnabled: true
      netFrameworkVersion: 'v6.0'
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ]
    }
    httpsOnly: true
  }
  dependsOn: [
    appPlan
  ]
}

resource appname_web 'Microsoft.Web/sites/sourcecontrols@2021-03-01' = {
  parent: website
  name: 'web'
  properties: {
    repoUrl: 'https://github.com/siegfried01/SourceControlsAzureBicepDemo03.git'
    branch: 'main'
    gitHubActionConfiguration: {
      codeConfiguration: {
        runtimeVersion: '6.0'
        runtimeStack: 'DOTNET'
      }
      generateWorkflowFile: true
    }
    isGitHubAction: true
  }
}
