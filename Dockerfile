Attach to specific wifi network (set with designated username and password to automatically hook in)
Upgrade to latest packages
Set hostname
sudo raspi-config nonint do_hostname hammy
Enable SSH
sudo raspi-config nonint do_ssh 0
Create /data

Enable VNC
sudo raspi-config nonint do_vnc 0
Set resolution so VNC will work
sudo raspi-config 

Set Static IP or use DHCP for interface
Switch sound interface to analog on top right
Test if analog microphone works for HF Comms

#Basic dependencies
sudo apt install vim
sudo apt install code
Install code python and C++ extensions
sudo apt install docker
sudo apt install portainer

sudo apt install rtl-sdr
sudo apt install gqrx-sdr
sudo apt install cubicsdr
Set cubicsdr recording directory to /data/recording

sudo apt install socat
sudo apt -y install gpsd gpsd-clients python-gps chrony python-gi-cairo
sudo cp config/gps /etc/default/gpsd
sudo cp config/chrony.conf /etc/chrony/chrony.conf


sudo apt install dump1090-mutable

Install rticonnextdds

#Make python3 requirements.txt file
pip3 install rticonnextdds-connector
