<#
.Synopsis
   Get simple json form storage config
.DESCRIPTION
   DESCRIPTION HERE
.EXAMPLE
   Get-StorageConfig -CimSession (New-CimSession -ComputerName StorageHost)
#>
function Get-StorageConfig
{
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    Param
    (
        # CimSession
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0,
                   ParameterSetName = "ByCimSession")]
        [Microsoft.Management.Infrastructure.CimSession[]]
        $CimSession
    )

    Begin
    {
        $Storages = @()
    }
    Process
    {
        foreach($session in $CimSession){
            $virtual_disk = Get-VirtualDisk -CimSession $session
            foreach($vdisk in $virtual_disk){
                $volume = $vdisk|Get-Disk|Get-Partition|Get-Volume
                $Storages += @{
                    Name = $vdisk.FriendlyName
                    DriveLetter = $volume.DriveLetter
                    Size = $volume.Size
                    Resiliency = $vdisk.ResiliencySettingName
                }
            }
        }
    }
    End
    {
        $json = $Storages|ConvertTo-Json
        return $json
    }
}
