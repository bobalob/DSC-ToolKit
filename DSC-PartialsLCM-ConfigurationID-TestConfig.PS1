configuration ServerBuild
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        File ServerBuild
        {
            DestinationPath = "C:\ServerBuild-1.txt"
            Type = "File"
            Contents = "Testing"
            Ensure = 'Present'
        }
    }
}

configuration AppConfig
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        File AppConfig
        {
            DestinationPath = "C:\AppConfig-2.txt"
            Type = "File"
            Contents = "Testing"
            Ensure = 'Present'
        }
    }
}

$MyNodes = 
@{
    AllNodes = 
    @(
        @{
            NodeName = "pullclient.example.com"
            Guid = "***use New-Guid to generate***"
        }
    );
}

ServerBuild -OutPutPath C:\DSC\TestConfig\srv -ConfigurationData $MyNodes
AppConfig -OutPutPath C:\DSC\TestConfig\app -ConfigurationData $MyNodes

Foreach ($Node in $MyNodes.AllNodes) {
    $source = "C:\DSC\TestConfig\srv\$($Node.NodeName).mof"
    $dest = "C:\Program Files\WindowsPowerShell\DscService\Configuration\ServerBuild.$($Node.Guid).mof"
    Copy-Item -Path $source -Destination $dest -Force
    New-DSCChecksum $dest -Force

    $source = "C:\DSC\TestConfig\app\$($Node.NodeName).mof"
    $dest = "C:\Program Files\WindowsPowerShell\DscService\Configuration\AppConfig.$($Node.Guid).mof"
    Copy-Item -Path $source -Destination $dest -Force
    New-DSCChecksum $dest -Force
}
