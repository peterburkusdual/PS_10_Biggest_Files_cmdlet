
$Path = "C:\Users"
$Computer = "WIN-FS-001"
$DisplayAsTable = $true

$Data = Invoke-Command -ComputerName $Computer -ArgumentList $Path -ScriptBlock {
    Param($Path)

    $Object = Get-ChildItem -Recurse -File -Path $Path | Select-Object -Property Length, Name, CreationTime, Directory | Sort-Object -Descending -Property Length | Select-Object -First 10
    $Object | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $(HOSTNAME.EXE)

    $Lengths = $Object | Select-Object -ExpandProperty Length

    $Info = @()
    for (($i = 0); $i -lt $Object.Length; $i++)
    {
        # Define our custom, ordered properties for each computer.
        $Properties = [ordered] @{
            "ComputerName" = $Object.ComputerName[$i]
            "Length"       = $Lengths[$i]
            "Name"         = $Object.Name[$i]
            "CreationTime" = $Object.CreationTime[$i]
            "Driectory"    = $Object.Directory[$i]
        }
        # Create our custom PSObject.
        $CustomObject = New-Object -TypeName PSObject -Property $Properties

        $Info += , $CustomObject
    }

    return ($Info | Format-Table | Out-String).Trim()
}

Write-Host "END" -ForegroundColor Green
$Data