# Overlay-Foreground-Videos-onto-Background-Videos-Using-FFmpeg
This bash script is designed to overlay a series of foreground videos onto corresponding background videos using ffmpeg. It ensures ffmpeg is installed, iterates through all video files in the current directory, and processes each pair of foreground and background videos by scaling and overlaying them.
Features:

    Check for ffmpeg installation: Ensures ffmpeg is installed on the system before proceeding.
    Iterate over video files: Loops through all .MP4, .mp4, .MOV, and .mov files in the directory.
    Match corresponding background videos: Searches for a background video file matching each foreground video.
    Retrieve video properties: Uses ffprobe to get the duration and dimensions of the videos.
    Overlay videos: Scales the foreground video to fit the background video dimensions, removes the black background, and overlays it onto the background video.
    Error handling: Logs errors and continues processing the next video file if an error occurs.

Usage:

    Ensure ffmpeg is installed: sudo apt-get install ffmpeg or download from ffmpeg.org.
    Place the script in the directory with your videos.
    Run the script: ./overlay_videos.sh
