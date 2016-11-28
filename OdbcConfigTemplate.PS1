Configuration OdbcConfig
{
    Param(
        [Parameter(Mandatory=$true)][ValidateNotNullorEmpty()]$SQLServerName,
        [Parameter(Mandatory=$true)][ValidateNotNullorEmpty()]$DatabaseName,
        [Parameter(Mandatory=$true)][ValidateNotNullorEmpty()]$ODBCName
    )
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    
    Node $AllNodes.NodeName
    {
    Script OdbcScript #Creates ODBC Connection
        {
            SetScript = { 
                Write-verbose "Create ODBC Connection for $($SQLServerName)"
                $NewDsn = Add-OdbcDsn -Name "$($ODBCName)" -DriverName "SQL Server" `
                    -DsnType "System" -SetPropertyValue @(
                        "Server=$($SQLServerName)", 
                        "Database=$($DatabaseName)", 
                        "Description=$($DatabaseName)"
                    ) -PassThru
                if ($NewDsn) {
                    Write-verbose "ODBC connection $($ODBCName) created"
                } else {
                    Write-verbose "Failed to create ODBC connection $($ODBCName)"
                }
            }
            TestScript = { 
                if (Get-OdbcDsn | ? {$_.Name -eq "$($ODBCName)"}) {
                    Write-verbose "$($ODBCName) - ODBC connection exists"
                    $true
                } else {
                    Write-verbose "$($ODBCName) - ODBC does not exist"
                    $false
                }
            }
            GetScript = { 
                @{ Result = ((Get-OdbcDsn | ? {$_.Name -eq "$($ODBCName)"}).Attribute.Server) } 
            } 
        }
    }
}
