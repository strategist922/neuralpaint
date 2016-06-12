#!/usr/bin/env bash
#RUN THIS AS SUDO
#INSTALLATION FOR UBUNTU

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
apt-get update
apt-get upgrade
apt-get -y install ruby
apt-get -y install libcurl4-openssl-dev
apt-get -y r-base
apt-get -y r-base-dev
echo "options(repos=structure(c(CRAN='https://cloud.r-project.org')))" > ~/.Rprofile
R -e "install.packages('httr')"
R -e "install.packages('httpuv')"
R -e "install.packages('twitteR')"
R -e "install.packages('magrittr')"
apt-get -y install git
apt-get -y install lua5.2
apt-get -y install luarocks
apt-get -y install luajit
curl -s https://raw.githubusercontent.com/torch/ezinstall/master/install-all | bash
apt-get -y install libprotobuf-dev protobuf-compiler
luarocks install loadcaffe
luarocks install image
luarocks install nn
git clone https://github.com/jcjohnson/neural-style.git
chmod +w neural-style/
cd neural-style/
sh ./models/download_models.sh
apt-get -y install chromium-browser
apt-get -y install libexif-dev

#To authenticate, ssh VM -X on host, xhost + on host, and export DISPLAY="127.0.0.1:10.0" on host

