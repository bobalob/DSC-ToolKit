configuration CreatePullServer
{
  param
  (
    [Parameter(Mandatory=$true)][string[]]$ComputerName,
    [Parameter(Mandatory=$true)][string]$CertThumbprint,
    [Parameter(Mandatory=$true)][string]$guid
  )
  Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
  Import-DSCResource -ModuleName 'xPSDesiredStateConfiguration'

  Node $ComputerName
  {
    WindowsFeature DSCServiceFeature
    {
      Ensure = "Present"
      Name  = "DSC-Service"
    }

    xDscWebService PSDSCPullServer
    {
        Ensure                   = "Present"
        EndpointName             = "PSDSCPullServer"
        Port                     = 8080
        PhysicalPath             = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer"
        CertificateThumbPrint    = $CertThumbprint
        ModulePath               = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
        ConfigurationPath        = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
        RegistrationKeyPath      = "$env:PROGRAMFILES\WindowsPowerShell\DscService\DscService"
        State                    = "Started"
        DependsOn                = "[WindowsFeature]DSCServiceFeature"
        UseSecurityBestPractices = $True
    }

    xDscWebService PSDSCComplianceServer
    {
        Ensure                   = "Present"
        EndpointName             = "PSDSCComplianceServer"
        Port                     = 9080
        PhysicalPath             = "$env:SystemDrive\inetpub\wwwroot\PSDSCComplianceServer"
        CertificateThumbPrint    = $CertThumbprint
        State                    = "Started"
        DependsOn                = ("[WindowsFeature]DSCServiceFeature","[xDSCWebService]PSDSCPullServer")
        UseSecurityBestPractices = $True
    }

    File RegistrationKeys
    {
      DestinationPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\RegistrationKeys.txt"
      DependsOn = "[xDscWebService]PSDSCPullServer"
      Ensure = 'Present'
      Type = 'File'
      Contents = $guid
    }

  }

}

$ComputerName = "pullserver.example.com"

$Cert = Invoke-Command -ComputerName $ComputerName -ScriptBlock { 
  dir cert:\LocalMachine\My | ? { $_.EnhancedKeyUsageList -match "Server Authentication"} 
}

if ($Cert) {
    Write-Host "Create PullServer Config for $($ComputerName) with Cert $($Cert.Thumbprint)"
    CreatePullServer -ComputerName $ComputerName `
        -CertThumbprint $Cert.Thumbprint `
        -OutputPath C:\DSC\HTTPS-PullServer

    Start-DscConfiguration -Path C:\DSC\HTTPS-PullServer `
        -ComputerName $ComputerName -Verbose -Wait -force
} else {
    Write-Warning "No Valid Server Authentication Certificate Found"
}
