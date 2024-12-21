<#
.SYNOPSIS
    Re-encodes videos in a format that might be better for sharing and allows automatic cropping.

.DESCRIPTION
    This script provides a function to re-encode videos in a format that is optimized for sharing. It also allows users to automatically crop their videos. The script utilizes the FFmpeg library for video encoding and cropping.

.LINK
    For more information about FFmpeg, visit: https://ffmpeg.org/
    For more PowerShell scripts by me, visit: https://github.com/jtnorr/scripts
#>

# Check if FFmpeg is installed
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "FFmpeg is not installed. Please install FFmpeg before running this script.
    You can install FFmpeg by visiting https://ffmpeg.org/download.html.
    On Windows devices you might be able to get the binaries through Winget or Chocolatey.
    On Linux devices you might be able to get the binaries through your package manager."
    Return
}

# Get current working directory
$scriptDirectory = (Get-Item .).FullName

# Prompt the user to enter a directory path for input and output
$directory = ($directory = Read-Host "Enter the directory path for input (leave empty for the current directory: $scriptDirectory)") ? $directory : $scriptDirectory
$OutputDirectory = ($OutputDirectory = Read-Host "Enter the directory path for output (leave empty for the current directory: $scriptDirectory)") ? $OutputDirectory : $scriptDirectory

# Check if the directory exists
if (-Not (Test-Path $OutputDirectory -PathType Container)) {
    Write-Host "Output directory does not exist."
    $createDir = Read-Host "Do you wish to create the directory? (y/n - default: y)"
    if (($createDir -eq "y" -or $createDir -eq "")) {
        New-Item -Path $OutputDirectory -ItemType Directory | Out-Null
        Write-Host "Directory created at $OutputDirectory."
    } else {
        Return
    }
}


Write-Host "The following settings are the default, leave the prompts empty if you wish to use them:
Video codec: libx264
Audio codec: aac
Automatically crop videos: yes
Normalise audio: yes"

# Prompt the user to enter the video codec
$videoCodec = ($vcodec = Read-Host "Enter the video codec (e.g., libx264)") ? $vcodec : "libx264"

# Prompt the user to enter the audio codec
$audioCodec = ($acodec = Read-Host "Enter the audio codec (e.g., aac)") ? $acodec : "aac"

# Prompt the user automatically crop videos
$autoCrop = ($crop = Read-Host "Automatically crop videos? (y/n)") ? $crop : "y"

#Prompt the user for normalising audio
$normaliseAudio = ($normalise = Read-Host "Normalise audio? (y/n)") ? $normalise : "y"

# Get all video files in the directory
$videoFiles = Get-ChildItem -Path $directory -Filter "*.mp4" -File



# Loop through each video file and re-encode using ffmpeg
foreach ($file in $videoFiles) {
    if ($autoCrop -eq "y") {
        # Progress bar for cool aesthetics (shouldn't have performance issues)
        Write-Progress -Activity "Cropping and re-encoding videos..." -Status "Processing file $($videoFiles.IndexOf($file) + 1) of $($videoFiles.Count)" -PercentComplete (($videoFiles.IndexOf($file) + 1) / $videoFiles.Count * 100)


        # $videoParams to get parameters of the video for easier handling
        $videoParams = & ffmpeg -i $file.FullName -vf cropdetect -f null - 2>&1 | Select-String -Pattern "crop=[0-9]+:[0-9]+:[0-9]+:[0-9]+" | Select-Object -Last 1 | ForEach-Object {
            $_.Matches.Value
        }
        $outputFile = Join-Path -Path $OutputDirectory -ChildPath ($file.BaseName + "_cropped_encoded.mp4")
        $commandLineOperation = "ffmpeg -hide_banner -loglevel warning -i", "`"$($file.FullName)`"", "-vf $videoParams -c:v $videoCodec -crf 23 -c:a $audioCodec" -join " "
        if ($normaliseAudio -eq "y") {
            $commandLineOperation += " -af loudnorm=I=-16:LRA=11:TP=-1.5"
        }
        $commandLineOperation += " `"$outputFile`""
        Invoke-Expression $commandLineOperation
    
        
    } else {
        # Progress bar for cool aesthetics (shouldn't have performance issues)
        Write-Progress -Activity "Re-encoding videos..." -Status "Processing file $($videoFiles.IndexOf($file) + 1) of $($videoFiles.Count)" -PercentComplete (($videoFiles.IndexOf($file) + 1) / $videoFiles.Count * 100)
        
        
        # Simple re-encoding without cropping
        $outputFile = Join-Path -Path $OutputDirectory -ChildPath ($file.BaseName + "_encoded.mp4")
        $commandLineOperation = "ffmpeg -hide_banner -loglevel warning -i", "`"$($file.FullName)`"", "-vf $videoParams -c:v $videoCodec -crf 23 -c:a $audioCodec" -join " "
        if ($normaliseAudio -eq "y") {
            $commandLineOperation += " -af loudnorm=I=-16:LRA=11:TP=-1.5"
        }
        $commandLineOperation += " `"$outputFile`""
        Invoke-Expression $commandLineOperation
        
    }
}

Write-Host "Re-encoding complete."
