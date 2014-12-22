<#
.Synopsis
   Create new volumes from Storage configuration.
.DESCRIPTION
   DESCRIPTION HERE
.EXAMPLE
   $config = Get-StorageConfig -CimSession (New-CimSession SourceNode)
   $session = New-CimSession DestinationNode
   $pool = Get-StoragePool -CimSession $session
   New-VolumeFromStorageConfig -CimSession $session -StoragePool $pool -StorageConfig $config
#>
function New-VolumeFromStorageConfig
{
    [CmdletBinding()]
    Param
    (
        # CimSession
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true)]
        $StoragePool,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true)]
        [hashtable[]]
        $StorageConfig

    )

    Begin
    {
        $session = $CimSession
        $pool = $StoragePool
        $config = $StorageConfig
    }
    Process
    {
        foreach($c in $config){
            $virtual_disk = Get-VirtualDisk -CimSession $session -FriendlyName $c.Name -ErrorAction SilentlyContinue
            if($virtual_disk){
                $volume = Get-Volume -CimSession $session -DriveLetter $c.DriveLetter
                if($volume){
                    continue
                }
            }
            $c.Name
            $virtual_disk = New-VirtualDisk -CimSession $session -FriendlyName $c.Name -StoragePoolUniqueId $pool.UniqueId -ProvisioningType Thin -Size $c.Size -ResiliencySettingName $c.Resiliency
            Initialize-Disk -CimSession $session -VirtualDisk $virtual_disk -PassThru |
            New-Partition -CimSession $session -DriveLetter $c.DriveLetter -UseMaximumSize |
            Format-Volume -CimSession $session -FileSystem NTFS -NewFileSystemLabel $c.Name -Confirm:$false
        }
    }
    End
    {
    }
}