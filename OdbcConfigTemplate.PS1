Configuration OdbcConfig
{
    Param(
        [Parameter(Mandatory=$true)][ValidateNotNullorEmpty()]$SQLServerName,
        [Parameter(Mandatory=$true)][ValidateNotNullorEmpty()]$DatabaseName,
        [Parameter(Mandatory=$true)][ValidateNotNullorEmpty()]$ODBCName,
        [Parameter(Mandatory=$true)][ValidateNotNullorEmpty()]$ComputerName
    )
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    
    Node $ComputerName
    {
    Script OdbcScript #Creates ODBC Connection
        {
            SetScript = { 
                Write-verbose "Create ODBC Connection for $($Using:SQLServerName)"
                $NewDsn = Add-OdbcDsn -Name "$($Using:ODBCName)" -DriverName "SQL Server" `
                    -DsnType "System" -SetPropertyValue @(
                        "Server=$($Using:SQLServerName)", 
                        "Database=$($Using:DatabaseName)", 
                        "Description=$($Using:DatabaseName)"
                    ) -PassThru
                if ($NewDsn) {
                    Write-verbose "ODBC connection $($Using:ODBCName) created"
                } else {
                    Write-verbose "Failed to create ODBC connection $($Using:ODBCName)"
                }
            }
            TestScript = { 
                if (Get-OdbcDsn | ? {$_.Name -eq "$($Using:ODBCName)"}) {
                    Write-verbose "$($Using:ODBCName) - ODBC connection exists"
                    $true
                } else {
                    Write-verbose "$($Using:ODBCName) - ODBC does not exist"
                    $false
                }
            }
            GetScript = { 
                @{ Result = ((Get-OdbcDsn | ? {$_.Name -eq "$($Using:ODBCName)"}).Attribute.Server) } 
            } 
        }
    }
}

OdbcConfig -OutputPath C:\DSC\ODBC
