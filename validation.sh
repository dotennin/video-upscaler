#! /bin/sh
FILE_NAME=$1

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
