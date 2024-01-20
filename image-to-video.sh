#! /bin/sh
FILE_NAME=$1
FPS=$2
IMAGE_EXTENSION=jpg

./validation.sh $FILE_NAME

if [ -z "$FPS" ]
then
  FPS=$(ffmpeg -i "$FILE_NAME" 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p")
fi

PROGRESSIVE=$(ffmpeg -i $FILE_NAME 2>&1 | sed -n 's/.*(\([^,]*\), \([a-zA-Z0-9]*\)(\(.*\))/\2/p' | cut -d ',' -f1)
DIR_NAME=$FILE_NAME-$PROGRESSIVE-$FPS-frames/upscayl_RealESRGAN_General_x4_v3_x4


echo "==================="
echo "Target dir: $DIR_NAME"
echo "FPS: $FPS"
echo "progressive: $PROGRESSIVE"
echo "==================="

echo "Converting scalled images to video for $FILE_NAME..."
# if file already exists, skip
# if [ -f "./_output.mp4" ]; then
#   echo "File[_output.mp4] already exists, skipping..."
# fi
time ffmpeg -framerate $FPS -i $DIR_NAME/frame-%03d.$IMAGE_EXTENSION -c:v libx264 -pix_fmt $PROGRESSIVE ./_output.mp4

echo "Extacting origin video audio from $FILE_NAME..."
time ffmpeg -i $FILE_NAME -q:a 0 -map a ./_output-audio.aac

echo "Merging video and audio..."
time ffmpeg -i ./_output.mp4 -i ./_output-audio.aac -c copy -map 0:v:0 -map 1:a:0 ./scalled-$FILE_NAME

echo "Done!"
echo "Do you need to delete temporary files? (y/n)"
read ANSWER
if [ "$ANSWER" = "y" ]; then
  rm -rf ./_output.mp4
  rm -rf ./_output-audio.aac
fi
