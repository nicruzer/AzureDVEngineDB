Push-Location

cd "$($env:OneDrive)\AzureDV\Resources"
$tbl = Import-Csv -Path ".\INSERT_dbo_Tables.csv"

$statement = foreach ($r in $tbl)
{
    Write-Output ("('{0}')" -f ($r.PsObject.Properties.ForEach({$_.Value}) -join "', '"))
}

$statement -join ",`n" |Set-Clipboard

Pop-Location