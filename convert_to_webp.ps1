# requires libwebp in PATH or in the same directory as the script
# download here: https://developers.google.com/speed/webp/download

Param (
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$Directory = '.',

    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$DestinationPath = '.\Converted',

    [ValidateRange(1, 100)]
    [int]$Quality = 75,

    [ValidateSet('default', 'photo', 'picture', 'drawing', 'icon', 'text')]
    [string]$Preset = 'default'
)



if (-not (Test-Path $Directory -PathType Container)) {
    Write-Host "Directory not found."
    Exit
}


if (-not (Test-Path $DestinationPath -PathType Container)) {
    New-Item -Path $DestinationPath -ItemType Directory | Out-Null
    Write-Host "Destination directory created at $DestinationPath."
}

Get-ChildItem -Path $Directory -Include "*.png", "*.jpg" , "*.gif" -File | ForEach-Object {
    $sourceFile = $_.FullName
    $destinationFile = Join-Path -Path $DestinationPath -ChildPath ($_.BaseName + '.webp')
    $args = "-q $Quality -preset $Preset `"$sourceFile`" -o `"$destinationFile`""
    

}