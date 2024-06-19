<#
.SYNOPSIS
    Re-encodes videos in a format that might be better for sharing and allows automatic cropping.

.DESCRIPTION
    This script provides a function to re-encode videos in a format that is optimized for sharing. It also allows users to automatically crop their videos. The script utilizes the FFmpeg library for video encoding and cropping.

.LINK
    For more information about FFmpeg, visit: https://ffmpeg.org/
    For more PowerShell scripts by me, visit: https://github.com/jtnorr/scripts
#>

# Prompt the user to enter a directory path
$directory = Read-Host "Enter the directory path:"

# Check if the directory exists
if (Test-Path $directory -PathType Container) {
    # Prompt the user to enter the video codec
    $videoCodec = Read-Host "Enter the video codec (e.g., libx264):"

    # Prompt the user to enter the audio codec
    $audioCodec = Read-Host "Enter the audio codec (e.g., aac):"

    # Prompt the user automatically crop videos
    $autoCrop = Read-Host "Automatically crop videos? (y/n):"

    # Get all video files in the directory
    $videoFiles = Get-ChildItem -Path $directory -Filter "*.mp4" -File

    # Loop through each video file and re-encode using ffmpeg
    foreach ($file in $videoFiles) {
        if ($autoCrop -eq "y") {
            # $videoParams to get parameters of the video for easier handling
            $videoParams = & ffmpeg -i $file -vf "cropdetect=24:16:0" - f null - 2>&1 | Select-String -Pattern "crop=[0-9]+:[0-9]+:[0-9]+:[0-9]+" | ForEach-Object
            $cropValues = $videoParams -replace "crop=(\d+):(\d+):(\d+):(\d+)", '$1,$2,$3,$4'
            $outputFile = Join-Path -Path $directory -ChildPath ($file.BaseName + "_cropped_encoded.mp4")
            ffmpeg -i $file.FullName -vf "crop=$cropValues" -c:v $videoCodec -crf 23 -c:a $audioCodec $outputFile
            # Progress bar for cool aesthetics (shouldn't have performance issues)
            Write-Progress -Activity "Cropping and re-encoding videos..." -Status "Processing file $($videoFiles.IndexOf($file) + 1) of $($videoFiles.Count)" -PercentComplete (($videoFiles.IndexOf($file) + 1) / $videoFiles.Count * 100)
        } else {
            # Simple re-encoding without cropping
            $outputFile = Join-Path -Path $directory -ChildPath ($file.BaseName + "_encoded.mp4")
            ffmpeg -i $file.FullName -c:v $videoCodec -crf 23 -c:a $audioCodec $outputFile
            Write-Progress -Activity "Re-encoding videos..." -Status "Processing file $($videoFiles.IndexOf($file) + 1) of $($videoFiles.Count)" -PercentComplete (($videoFiles.IndexOf($file) + 1) / $videoFiles.Count * 100)
        }
    }

    Write-Host "Re-encoding complete."
} else {
    Write-Host "Directory not found."
}