[DSCLocalConfigurationManager()]
configuration PullClientConfigNames
{
    Param(
      [Parameter(Mandatory=$true)]
      [ValidateNotNullorEmpty()]
      $Guid
    )
    Node $AllNodes.NodeName
    {
        Settings
        {
            RefreshMode = 'Pull'
            RefreshFrequencyMins = 30
            RebootNodeIfNeeded = $true
            CertificateId = $node.Thumbprint
        }
        ConfigurationRepositoryWeb Core-PullSrv
        {
            ServerURL = 'https://pullserver.example.com:8080/PSDSCPullServer.svc'
            RegistrationKey = $guid
            ConfigurationNames = @("ServerBuild-$($node.NodeName)")
        }
    }
}
PullClientConfigNames -OutPutPath C:\DSC\PullClient -ConfigurationData .\ConfigDataPullClient.psd1
Set-DscLocalConfigurationManager -Path C:\DSC\PullClient -verbose

#Update-DscConfiguration -ComputerName dscclient.example.com -wait -verbose
