# requires libwebp in PATH or in the same directory as the script
# download here: https://developers.google.com/speed/webp/download

Param (
    [string]$Directory = 'C:\Users\janin\OneDrive\Desktop',
    [string]$DestinationPath = 'C:\Users\janin\OneDrive\Desktop\converted',
    [string]$Quality = '75',
    [string]$Preset
)

if ([string]::IsNullOrEmpty($Preset)) {
    $Preset = Read-Host "Enter the Preset type (default, photo, picture, drawing, icon, text)"
}

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