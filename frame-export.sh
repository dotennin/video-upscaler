#! /bin/sh
FILE_NAME=$1
FPS=$2

./validation.sh $FILE_NAME

if [ -z "$FPS" ]
then
  FPS=$(ffmpeg -i "$FILE_NAME" 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p")
fi

PROGRESSIVE=$(ffmpeg -i $FILE_NAME 2>&1 | sed -n 's/.*(\([^,]*\), \([a-zA-Z0-9]*\)(\(.*\))/\2/p' | cut -d ',' -f1)
DIR_NAME=$FILE_NAME-$PROGRESSIVE-$FPS-frames
mkdir $DIR_NAME


echo "==================="
echo "Exporting frames for $FILE_NAME..."
echo "FPS: $FPS"
echo "progressive: $PROGRESSIVE"
echo "==================="
time ffmpeg -i "$FILE_NAME" -vf fps=$FPS $DIR_NAME/frame-%03d.png
