#Script to prepare the moudles installed on the pull server.
#Zips up any installed 'x' type modules installed with correct names and in the correct location

$mods = gci "C:\Program Files\WindowsPowerShell\Modules\" | ? {$_.name -match "^x"}


foreach ($mod in $Mods) {
  $subFolder = gci $mod.FullName 
  $subFolderName = ($subFolder).name
  $zipName = "$($mod.name)_$($subFolderName).zip"
  Write-Host $zipName
  Compress-Archive -Path "$($subFolder.FullName)\*" `
    -DestinationPath "C:\Program Files\WindowsPowerShell\DscService\Modules\$($zipName)" `
    -Force
  New-DscChecksum `
    -Path "C:\Program Files\WindowsPowerShell\DscService\Modules\$($zipName)" `
    -Force
}
