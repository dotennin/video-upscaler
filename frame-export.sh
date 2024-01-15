#! /bin/sh
FILE_NAME=$1
FPS=$2

# check if ffmpeg exists
if ! command -v ffmpeg &> /dev/null
then
  echo "ffmpeg could not be found"
  exit 1
fi

# check if the file exists
if [ ! -f "$FILE_NAME" ]
then
  echo "Usage: $0 <file_name> [fps]"
  exit 1
fi

if [ -z "$FPS" ]
then
  FPS=$(ffmpeg -i "$FILE_NAME" 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p")
fi

PROGRESSIVE=$(ffmpeg -i Toyomaru.Akira.Fubuki.ts 2>&1 | sed -n 's/.*(\([^,]*\), \([a-zA-Z0-9]*\)(\(.*\))/\2/p' | cut -d ',' -f1)
DIR_NAME=$FILE_NAME-$PROGRESSIVE-$FPS-frames
mkdir $DIR_NAME


echo "==================="
echo "Exporting frames for $FILE_NAME..."
echo "FPS: $FPS"
echo "progressive: $PROGRESSIVE"
echo "==================="
time ffmpeg -i "$FILE_NAME" -vf fps=$FPS $DIR_NAME/frame-%03d.png
