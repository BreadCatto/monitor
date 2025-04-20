echo "installing packages"
apt update
apt install unzip
apt install axel
echo "downloading zip"
axel -n 10 {{ZIP_URL}}
echo "done"
