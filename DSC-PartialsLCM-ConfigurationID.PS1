[DSCLocalConfigurationManager()]
configuration PullClientConfigNames
{
    Node $AllNodes.NodeName
    {
        Settings
        {
            RefreshMode = 'Pull'
            RefreshFrequencyMins = 30
            RebootNodeIfNeeded = $true
            ConfigurationID = $Node.ConfigurationID
        }
        ConfigurationRepositoryWeb Master-PullSrv
        {
            ServerURL = 'https://pullserver.example.com:8080/PSDSCPullServer.svc'
            CertificateID = 'SERVER-CERT-THUMBPRINT'
            AllowUnsecureConnection = $False
        }
        
        PartialConfiguration "ServerBuild"
        {
            Description = "Server Build"
            ConfigurationSource = @("[ConfigurationRepositoryWeb]Master-PullSrv")
        }

        PartialConfiguration "AppConfig"
        {
            Description = "Server Build"
            ConfigurationSource = @("[ConfigurationRepositoryWeb]Master-PullSrv")
            DependsOn = "[PartialConfiguration]ServerBuild"
        }
    }
}

$MyNodes = 
@{
    AllNodes = 
    @(
        @{
            NodeName = "pullclient.example.com"
            ConfigurationID = "***use New-Guid to generate***"
        }
    );
}

PullClientConfigNames -OutPutPath C:\DSC\PullClient -ConfigurationData $MyNodes
Set-DscLocalConfigurationManager -Path C:\DSC\PullClient -verbose

Update-DscConfiguration -wait -verbose
