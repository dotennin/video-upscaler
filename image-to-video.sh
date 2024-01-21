FILE_NAME=$1
FPS=$2
IMAGE_EXTENSION=$3

if [ -z "$FPS" ]
then
  FPS=$(ffmpeg -i "$FILE_NAME" 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p")
fi

if [ -z "$IMAGE_EXTENSION" ]
then
  IMAGE_EXTENSION=jpg
fi

PROGRESSIVE=$(ffmpeg -i $FILE_NAME 2>&1 | sed -n 's/.*(\([^,]*\), \([a-zA-Z0-9]*\)(\(.*\))/\2/p' | cut -d ',' -f1)
DIR_NAME=scalled-$FILE_NAME-$PROGRESSIVE-$FPS-frames


echo "==================="
echo "Target dir: $DIR_NAME"
echo "FPS: $FPS"
echo "progressive: $PROGRESSIVE"
echo "==================="

echo "Converting scalled images to video for $FILE_NAME..."
time ffmpeg -framerate $FPS -i $DIR_NAME/frame-%03d.$IMAGE_EXTENSION -c:v libx264 -pix_fmt $PROGRESSIVE ./_output.mp4

ffmpeg_output=$(ffmpeg -i $FILE_NAME 2>&1)
if echo "$ffmpeg_output" | grep -q "Stream #[0-9]*:[0-9]*.*Audio"; then
    echo "The video file has audio content."
    echo "Extacting origin video audio from $FILE_NAME..."
    time ffmpeg -i $FILE_NAME -q:a 0 -map a ./_output-audio.aac
    echo "Merging video and audio..."
    ffmpeg -i ./_output.mp4 -i ./_output-audio.aac -c copy -map 0:v:0 -map 1:a:0 ./scalled-$FILE_NAME
else
    echo "The video file does not have audio content. Skipped merging video and audio."
    mv ./_output.mp4 ./scalled-$FILE_NAME
fi

echo "Done!"
echo "Do you need to delete temporary files? (y/n)"
read ANSWER
if [ "$ANSWER" = "y" ]; then
  rm -rf ./_output.mp4
  rm -rf ./_output-audio.aac
fi
