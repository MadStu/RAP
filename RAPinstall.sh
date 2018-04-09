#!/bin/bash

clear
echo " "
echo "Install of the Rapture Daemon is about to begin..."
sleep 1
echo " "
echo "You may be asked for your password a few times during the install..."
echo " "
sleep 1

LOGFILE=/$HOME/RAPinstall.log
echo "Updating..."
echo "   #01" >> $LOGFILE 2>&1

#01
sudo apt-get update -y >> $LOGFILE 2>&1

echo "Upgrading..."
echo "   #02" >> $LOGFILE 2>&1

#02
sudo apt-get upgrade -y >> $LOGFILE 2>&1

echo "..."
echo "   #03" >> $LOGFILE 2>&1

#03
sudo apt-get dist-upgrade -y >> $LOGFILE 2>&1

echo "Installing..."
echo "   #04" >> $LOGFILE 2>&1

#04
sudo apt-get install nano htop git -y >> $LOGFILE 2>&1

echo "..."
echo "   #05" >> $LOGFILE 2>&1

#05
sudo apt-get install build-essential libtool autotools-dev pwgen automake pkg-config libssl-dev libevent-dev bsdmainutils software-properties-common libgmp3-dev -y >> $LOGFILE 2>&1
echo "Still Installing..."
echo "   #06" >> $LOGFILE 2>&1

#06
sudo apt-get install libboost-all-dev -y >> $LOGFILE 2>&1

echo "Adding new repository..."
echo "   #07" >> $LOGFILE 2>&1

#07
sudo add-apt-repository ppa:bitcoin/bitcoin -y >> $LOGFILE 2>&1

echo "..."
echo "   #08" >> $LOGFILE 2>&1

#08
sudo apt-get update -y >> $LOGFILE 2>&1

echo "Installing more stuff..."
echo "   #09" >> $LOGFILE 2>&1

#09
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y >> $LOGFILE 2>&1

echo "..."
echo "   #10" >> $LOGFILE 2>&1

#10
sudo apt-get install libminiupnpc-dev -y >> $LOGFILE 2>&1

echo "Downloading Rapture files..."
echo "   #11" >> $LOGFILE 2>&1

#11
sudo mkdir $HOME/tempRAPTURE >> $LOGFILE 2>&1
sudo chmod -R 777 $HOME/tempRAPTURE >> $LOGFILE 2>&1
sudo git clone https://github.com/RaptureCore/Rapture $HOME/tempRAPTURE >> $LOGFILE 2>&1

echo "Generating..."
echo "   #12" >> $LOGFILE 2>&1

#12
cd $HOME/tempRAPTURE >> $LOGFILE 2>&1
sudo chmod 777 autogen.sh >> $LOGFILE 2>&1
sudo ./autogen.sh >> $LOGFILE 2>&1

echo "Configuring..."
echo "   #13" >> $LOGFILE 2>&1

#13
#sudo ./configure >> $LOGFILE 2>&1
sudo ./configure --without-gui CXXFLAGS="--param ggc-min-expand=1 --param ggc-min-heapsize=32768" >> $LOGFILE 2>&1


echo "Now Making. This will take a VERY long time. Leave it running, don't close your SSH session..."
echo "   #14A  " >> $LOGFILE 2>&1

#14A
sudo chmod +x share/genbuild.sh >> $LOGFILE 2>&1
echo "   #14B  " >> $LOGFILE 2>&1

#14B
sudo make >> $LOGFILE 2>&1

echo "Installing..."
echo "   #15" >> $LOGFILE 2>&1

#15
sudo make install >> $LOGFILE 2>&1

echo "Copying files..."
echo "   #16" >> $LOGFILE 2>&1

#16
cd $HOME >> $LOGFILE 2>&1
sudo mkdir $HOME/rapturecoin >> $LOGFILE 2>&1
sudo mkdir $HOME/.rapturecore >> $LOGFILE 2>&1
cp $HOME/tempRAPTURE/src/raptured $HOME/rapturecoin >> $LOGFILE 2>&1
cp $HOME/tempRAPTURE/src/rapture-cli $HOME/rapturecoin >> $LOGFILE 2>&1
sudo chmod -R 777 $HOME/rapturecoin >> $LOGFILE 2>&1
sudo chmod -R 777 $HOME/.rapturecore >> $LOGFILE 2>&1

echo "Writing configuration file..."
echo "   #17" >> $LOGFILE 2>&1

#17
RPCU=$(pwgen -1 4 -n) >> $LOGFILE 2>&1
PASS=$(pwgen -1 14 -n) >> $LOGFILE 2>&1
EXIP=$(curl ipinfo.io/ip) >> $LOGFILE 2>&1
printf "rpcuser=rpc$RPCU\nrpcpassword=$PASS\nrpcport=14778\nrpcthreads=8\nrpcallowip=127.0.0.1\nbind=$EXIP:14777\nmaxconnections=128\ngen=0\nexternalip=$EXIP\ndaemon=1\n\naddnode=89.40.4.153:14777\naddnode=45.77.44.31:14777\naddnode=45.76.151.171:14777\naddnode=188.166.245.67:14777\naddnode=104.131.22.223:14777\naddnode=45.77.44.31\naddnode=188.166.245.67\naddnode=104.131.101.147\naddnode=165.227.26.4\n\n" > /$HOME/.rapturecore/rapture.conf

echo "Starting Rapture daemon..."
echo "   #18" >> $LOGFILE 2>&1

#18
raptured -daemon >> $LOGFILE 2>&1
sleep 2
echo "Running for 60 seconds then stopping..."
echo "   #19" >> $LOGFILE 2>&1

#19
sleep 60
MKEY=$(rapture-cli masternode genkey) >> $LOGFILE 2>&1
rapture-cli stop >> $LOGFILE 2>&1

echo "Inserting masternodeprivkey into config file..."
echo "   #20" >> $LOGFILE 2>&1

#20
sleep 2
echo -e "masternode=1\nmasternodeprivkey=$MKEY\n\n" >> /$HOME/.rapturecore/rapture.conf
sleep 10

echo "Starting Rapture daemon again..."
echo "   #21" >> $LOGFILE 2>&1

#21
raptured -daemon >> $LOGFILE 2>&1
sleep 1

echo "Installing more dependencies..."
echo "   #22" >> $LOGFILE 2>&1

#22
sudo apt-get -y install virtualenv python-virtualenv >> $LOGFILE 2>&1

echo "Downloading Sentinel..."
echo "   #23" >> $LOGFILE 2>&1

#23
git clone https://github.com/RaptureCore/sentinel.git && cd sentinel >> $LOGFILE 2>&1
sleep 5

echo "Installing Sentinel..."
echo "   #24" >> $LOGFILE 2>&1

#24
virtualenv ./venv >> $LOGFILE 2>&1
sleep 2
./venv/bin/pip install -r requirements.txt >> $LOGFILE 2>&1
sleep 2

echo "Inserting cron entry..."
echo "   #25" >> $LOGFILE 2>&1

#25
crontab -l > mycron
echo "* * * * * cd /home/$USER/sentinel && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1" >> mycron
crontab mycron >> $LOGFILE 2>&1
rm mycron >> $LOGFILE 2>&1
sleep 10
cd ~/sentinel >> $LOGFILE 2>&1

echo "Testing Sentinel, all tests should pass..."
echo "   #26" >> $LOGFILE 2>&1

#26
./venv/bin/py.test ./test
sleep 1
./venv/bin/py.test ./test >> $LOGFILE 2>&1
sleep 2

echo "Stopping Rapture daemon..."
echo "   #27" >> $LOGFILE 2>&1

#27
sleep 1
rapture-cli stop >> $LOGFILE 2>&1

echo "Reindexing blockchain..."
echo "   #28" >> $LOGFILE 2>&1

#28
sleep 1
cd ~/.rapturecore >> $LOGFILE 2>&1
rm mncache.dat >> $LOGFILE 2>&1
rm mnpayments.dat >> $LOGFILE 2>&1
raptured -daemon -reindex >> $LOGFILE 2>&1
sleep 2
echo "Waiting for reindex to complete..."
sleep 10
echo "Keep waiting..."
sleep 20
echo "Just about there..."
sleep 30
rapture-cli getblockchaininfo >> $LOGFILE 2>&1
sleep 5

echo "Getting info..."
echo "   #29" >> $LOGFILE 2>&1

#29
rapture-cli getinfo >> $LOGFILE 2>&1
rapture-cli getinfo >> $LOGFILE 2>&1
cd ~/sentinel >> $LOGFILE 2>&1
venv/bin/python bin/sentinel.py >> $LOGFILE 2>&1

echo "Restarting Rapture daemon..."
echo "   #30" >> $LOGFILE 2>&1

#30
rapture-cli stop >> $LOGFILE 2>&1
sleep 60
raptured -daemon  >> $LOGFILE 2>&1
sleep 5

echo "Masternode sync status..."
echo "   #31" >> $LOGFILE 2>&1

#31
rapture-cli mnsync status >> $LOGFILE 2>&1
sleep 1
rapture-cli mnsync status
sleep 10
echo "Waiting again..."
sleep 4

echo "Deleting temp folder..."
echo "   #32" >> $LOGFILE 2>&1

#32
sudo rm -rf $HOME/tempRAPTURE >> $LOGFILE 2>&1
rapture-cli mnsync status >> $LOGFILE 2>&1
sleep 3 
echo "Keep checking the masternode sync status by typing: rapture-cli mnsync status"
sleep 3
echo "When you see AssetID: 999 then you can Start Alias on your windows wallet..."
sleep 3
echo "Now would be a good time to setup your Transaction ID and VOUT from your windows wallet"
sleep 3
echo "You'll need the Masternode Key which is:"
echo "$MKEY"
sleep 3
echo "You'll also need your server IP which is:"
echo "$EXIP"
sleep 3
echo "Good luck! You got this!!"
echo " --END--" >> $LOGFILE 2>&1
