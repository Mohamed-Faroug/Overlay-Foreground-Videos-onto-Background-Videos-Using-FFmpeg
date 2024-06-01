#!/bin/bash

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg could not be found. Please install it and try again."
    exit 1
fi

# Add logging for debugging
LOG_FILE="video_processing.log"
exec > >(tee -i $LOG_FILE)
exec 2>&1

# Define key values
COLOR_KEY="black"
COLOR_SENSITIVITY="0.3"
COLOR_BLEND="0.2"

# Loop over all video files in the directory
for foreground_video in *.MP4 *.mp4 *.MOV *.mov; do
    # Check if the foreground video file exists
    if [ -f "$foreground_video" ]; then
        # Get the base name of the foreground video file without extension
        file_name=$(basename "$foreground_video" .MP4)
        file_name=$(basename "$file_name" .mp4)
        file_name=$(basename "$file_name" .MOV)
        file_name=$(basename "$file_name" .mov)

        # Check if there's a corresponding background video file
        background_video="background_$file_name.mp4"
        if [ -f "$background_video" ]; then
            # Get the duration of the foreground video
            duration=$(ffprobe -i "$foreground_video" -show_entries format=duration -v quiet -of csv="p=0") || { echo "Failed to get duration for $foreground_video"; continue; }

            # Get background video dimensions
            bg_width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$background_video") || { echo "Failed to get width for $background_video"; continue; }
            bg_height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$background_video") || { echo "Failed to get height for $background_video"; continue; }

            # Remove black background from the foreground video and overlay it onto the background video directly
            ffmpeg -stream_loop -1 -i "$background_video" -i "$foreground_video" -filter_complex "[1]scale=$bg_width:$bg_height:force_original_aspect_ratio=decrease,pad=$bg_width:$bg_height:(ow-iw)/2:(oh-ih)/2,format=rgba,colorkey=$COLOR_KEY:$COLOR_SENSITIVITY:$COLOR_BLEND[fg];[0][fg]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2:shortest=1" -t "$duration" -c:v libx264 -pix_fmt yuv420p -y "output_video_$file_name.mp4"
            if [ $? -ne 0 ]; then
                echo "Failed to create final video for $file_name"
                continue
            fi

            echo "Created video for $file_name"
        else
            echo "Background video file not found for $foreground_video"
        fi
    fi
done

echo "All videos created!"
