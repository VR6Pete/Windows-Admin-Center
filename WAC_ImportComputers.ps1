$outputfile = "C:\temp\ExportedComputers.csv"
Import-Module ActiveDirectory

function GetEnabledComputers {

Get-ADComputer -Filter {Enabled -eq $true} -Properties * |
 Select DNSHostName |


Export-CSV "$outputfile" -NoTypeInformation -Encoding utf8


}

function RenameDNSName {

 $filedata = Import-Csv $outputfile | Select-Object @{ expression={$_.DNSHostName}; label='name'  }
 $filedata | Export-Csv $outputfile -NoTypeInformation -Encoding utf8

         }

function PopulateColumnData{ 

$filedata = Import-CSV $outputfile |
ForEach-Object {

  $data1 = 'msft.sme.connection-type.server'
  $data2 = ''
  $data3 = 'global'

  $_ | 
  Add-Member -MemberType NoteProperty -Name type -Value $data1 -PassThru |
  Add-Member -MemberType NoteProperty -Name tags -Value $data2 -PassThru |
  Add-Member -MemberType NoteProperty -Name groupId -Value $data3 -PassThru

} 
$filedata | Export-CSV $outputfile -NoTypeInformation -Encoding utf8
}


Function ConvertToLower {

$objects = Import-Csv -Path $outputfile


$objects | 
ConvertTo-Csv -NoTypeInformation  |

ForEach-Object { $_.ToLower() } |
Out-File -FilePath $outputfile -Encoding utf8

}

Function ImportWAC {

# Load the module
Import-Module "$env:ProgramFiles\windows admin center\PowerShell\Modules\ConnectionTools"
# Available cmdlets: Export-Connection, Import-Connection

Import-Connection "https://localhost" -fileName $outputfile 


}

Function LaunchWAC {

$Command = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
$Parms = "https://localhost"

$Prms = $Parms.Split(" ")
& "$Command" $Prms

}

GetEnabledComputers
ConvertToLower
RenameDNSName
PopulateColumnData
ImportWAC
LaunchWAC