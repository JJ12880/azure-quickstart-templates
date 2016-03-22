#!/bin/bash

set -e 
date
ps axjf
NPROC=$(nproc)
echo "nproc: $NPROC"


#################################################################
# Build config file                                             #
#################################################################

file=$HOME/.Radium
if [ ! -e "$file" ]
then
sudo mkdir $HOME/.Radium
fi

sudo printf 'rpcuser=%s\n' $3  >> $HOME/.Radium/Radium.conf
sudo printf 'rpcpassword=%s\n' $4 >> $HOME/.Radium/Radium.conf
sudo printf 'rpcport=%s\n' $5 >> $HOME/.Radium/Radium.conf
sudo printf 'rpcallowip=%s\n' $6 >> $HOME/.Radium/Radium.conf
sudo printf 'server=1' >> $HOME/.Radium/Radium.conf



time apt-get update
#################################################################
# Update Ubuntu and install prerequisites for running Radium #
#################################################################

if [ $1 = 'From_Source' ]; then
time apt-get install -y ntp wget git miniupnpc build-essential libssl-dev libdb++-dev libboost-all-dev libqrencode-dev libtool autotools-dev autoconf pkg-config


#################################################################
# Git Clone Radium Source                                       #
#################################################################

cd /usr/local
time git clone https://github.com/tm2013/Radium.git
chmod -R 777 /usr/local/Radium/

#################################################################
# Build Radium from source                                      #
#################################################################

cd /usr/local/Radium/src 
make -f makefile.unix USE_UPNP=-
cp /usr/local/Radium/src/Radiumd /usr/bin/Radiumd
else
#################################################################
# Install Radium from Binary                                    #
#################################################################

cd $HOME/.Radium
DOWNLOADFILE=$(curl -s https://api.github.com/repos/JJ12880/Radium/releases | grep browser_download_url | grep linux64 | head -n 1 | cut -d '"' -f 4)
DOWNLOADNAME=$(curl -s https://api.github.com/repos/JJ12880/Radium/releases | grep name | grep linux64 | head -n 1 | cut -d '"' -f 4)
DIRNAME=$(echo $DOWNLOADNAME | sed 's/.tgz//')
sudo wget $DOWNLOADFILE
sudo tar zxf $DOWNLOADNAME

sudo cp Radiumd /usr/bin/Radiumd
fi

if [ $2 = 'From_Git' ]; then
#################################################################
# Download Blockchain from Github                               #
#################################################################

cd $HOME/.Radium
DOWNLOADFILE=$(curl -s https://api.github.com/repos/JJ12880/Radium/releases | grep browser_download_url | grep linuxblockchain | head -n 1 | cut -d '"' -f 4)
DOWNLOADNAME=$(curl -s https://api.github.com/repos/JJ12880/Radium/releases | grep name | grep linuxblockchain | head -n 1 | cut -d '"' -f 4)
DIRNAME=$(echo $DOWNLOADNAME | sed 's/.tgz//')
sudo wget $DOWNLOADFILE
sudo tar zxf $DOWNLOADNAME
sudo rm $DOWNLOADNAME
fi


################################################################
# Configure Radium node to auto start at boot       #
#################################################################

printf '%s\n%s\n' '#!/bin/sh' '/usr/bin/Radiumd --rpc-endpoint=127.0.0.1:8090 -d /usr/local/Radium/programs/radiumd/'>> /etc/init.d/radium
chmod +x /etc/init.d/radium
update-rc.d radium defaults
/usr/bin/Radiumd --rpc-endpoint=127.0.0.1:8090  & exit 0
