
echo "downloading zip"
cd /home/container/series
axel -n 10 {{ZIP_URL}}
echo "extracting zip"
FILENAME=$(basename "$ZIP_URL")
if [[ -f "$FILENAME" && "$FILENAME" == *.zip ]]; then
    unzip "$FILENAME"
else
    echo "Downloaded file is not a ZIP or doesn't exist: $FILENAME"
fi
echo "done"
