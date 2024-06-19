# Path to the input video file
$inputVideo = "path/to/input/video.mp4"

# Run cropdetect to get video parameters
$videoParams = & ffmpeg -i $inputVideo -vf "cropdetect=24:16:0" -f null - 2>&1 | Select-String -Pattern "crop=[0-9]+:[0-9]+:[0-9]+:[0-9]+" | ForEach-Object {
    $_.Matches.Value
}

# Extract crop values from the video parameters
$cropValues = $videoParams -replace "crop=(\d+):(\d+):(\d+):(\d+)", '$1,$2,$3,$4'

# Crop the video using ffmpeg
$outputVideo = "path/to/output/video.mp4"
& ffmpeg -i $inputVideo -vf "crop=$cropValues" $outputVideo