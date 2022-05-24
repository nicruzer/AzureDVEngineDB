$tgtPath = "C:\Users\nicru\Downloads\DVDemoData\Data"
$srcPath = "C:\Users\nicru\OneDrive\Documents2\GitHub\Superhero-DataVault\Data"

$fileList = Get-ChildItem -Path $srcPath -Recurse -File

foreach($file in $fileList)
{
    $parentFolder = Split-Path $file.FullName -Parent | Split-Path -Leaf 
    $newTargetFolder = Join-Path -Path $tgtPath -ChildPath $parentFolder
    if (-not (Test-Path $newTargetFolder))
    {
        New-Item $newTargetFolder -ItemType Directory
    }
    $folderPath = Split-Path $file.FullName -Parent | Split-Path -Leaf | Join-Path -ChildPath $file.Name
    $outputPath = Join-Path -Path $tgtPath -ChildPath $folderPath
    $content = Get-Content $file.FullName
    $content |Out-File -FilePath $outputPath -Encoding ascii -Force
}