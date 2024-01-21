#! /bin/sh
FILE_NAME=$1
FPS=$2
SUFFIX=webp

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


OS_TYPE=""

if [ $(uname -s) == "Linux" ]; then
  OS_TYPE="-linux"
elif [ $(uname -s) == "Darwin" ]; then
  OS_TYPE="-mac"
elif [ $(uname -s) == "CYGWIN"* ] || [ $(uname -s) == "MINGW"* ]; then
  OS_TYPE=".exe"
else
    echo "unknown OS type: $os_type"
    exit 1;
fi

if [ -z "$FPS" ]
then
  FPS=$(ffmpeg -i "$FILE_NAME" 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p")
fi

PROGRESSIVE=$(ffmpeg -i $FILE_NAME 2>&1 | sed -n 's/.*(\([^,]*\), \([a-zA-Z0-9]*\)(\(.*\))/\2/p' | cut -d ',' -f1)
DIR_NAME=$FILE_NAME-$PROGRESSIVE-$FPS-frames

# export frames function
function export_frames() {
  echo "==================="
  echo "Exporting frames for $FILE_NAME..."
  echo "FPS: $FPS"
  echo "progressive: $PROGRESSIVE"
  echo "==================="
  mkdir -p $DIR_NAME
  time ffmpeg -i "$FILE_NAME" -vf fps=$FPS $DIR_NAME/frame-%03d.png
}

function upscale_frames() {
  echo "==================="
  echo "Upscaling for $FILE_NAME..."
  echo "==================="
  mkdir -p scalled-$DIR_NAME
  time ./realesrgan-ncnn-vulkan${OS_TYPE} \
          -i $DIR_NAME/ \
          -o scalled-$DIR_NAME/ \
          -n RealESRGAN_General_x4_v3 \
          -f $SUFFIX \
          -v \
          -j 8:12:12
}

# check if the directory exists then ask user whether to overwrite
if [ -d "$DIR_NAME" ]; then
  echo "Directory $DIR_NAME already exists. Do you want to overwrite it? (y/n)"
  read ANSWER
  if [ "$ANSWER" = "y" ]
  then
    export_frames
  fi
else
  export_frames
fi

if [ -d "scalled-$DIR_NAME" ]; then
  echo "Directory scalled-$DIR_NAME already exists. Do you want to overwrite it? (y/n)"
  read ANSWER
  if [ "$ANSWER" = "y" ]
  then
    upscale_frames
  fi
else
  upscale_frames
fi


# copy frame-001 - frame-010 for testing
# cp $DIR_NAME/frame-001.png _$DIR_NAME/frame-001.png

# echo "Testing -j default options for $FILE_NAME..."
# time ./realesrgan-ncnn-vulkan${OS_TYPE} \
#         -i $DIR_NAME/frame-001.png \
#         -o scalled-$DIR_NAME/frame-001.$SUFFIX \
#         -n RealESRGAN_General_x4_v3 \
#         -f $SUFFIX \
#         -v
#
# echo "Testing -j 2:2:2 options for $FILE_NAME..."
# time ./realesrgan-ncnn-vulkan${OS_TYPE} \
#         -i $DIR_NAME/frame-001.png \
#         -o scalled-$DIR_NAME/frame-001.$SUFFIX \
#         -n RealESRGAN_General_x4_v3 \
#         -f $SUFFIX \
#         -v \
#         -j 2:2:2
#
# echo "Testing -j 4:4:4 options for $FILE_NAME..."
# time ./realesrgan-ncnn-vulkan${OS_TYPE} \
#         -i $DIR_NAME/frame-001.png \
#         -o scalled-$DIR_NAME/frame-001.$SUFFIX \
#         -n RealESRGAN_General_x4_v3 \
#         -f $SUFFIX \
#         -v \
#         -j 4:4:4
# echo "Testing -j 4:8:8 options for $FILE_NAME..."
# time ./realesrgan-ncnn-vulkan${OS_TYPE} \
#         -i $DIR_NAME/frame-001.png \
#         -o scalled-$DIR_NAME/frame-001.$SUFFIX \
#         -n RealESRGAN_General_x4_v3 \
#         -f $SUFFIX \
#         -v \
#         -j 4:8:8
#
# echo "Testing -j 8:12:12 options for $FILE_NAME..."
# time ./realesrgan-ncnn-vulkan${OS_TYPE} \
#         -i $DIR_NAME/frame-001.png \
#         -o scalled-$DIR_NAME/frame-001.$SUFFIX \
#         -n RealESRGAN_General_x4_v3 \
#         -f $SUFFIX \
#         -v \
# 	      -j 8:12:12

./image-to-video.sh $FILE_NAME $FPS $SUFFIX
