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
        $outputFile = Join-Path -Path $directory -ChildPath ($file.BaseName + "_encoded.mp4")
        ffmpeg -i $file.FullName -c:v $videoCodec -crf 23 -c:a $audioCodec -b:a 128k $outputFile
    }

    Write-Host "Re-encoding complete."
} else {
    Write-Host "Directory not found."
}