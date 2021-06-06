#This is the closest thing to an official raspbian image on dockerhub.
FROM balenalib/raspberry-pi-debian:latest

#Update the Pi to the latest version
RUN apt update && \
    apt upgrade

#Attach to specific wifi network (set with designated username and password to automatically hook in)
#Upgrade to latest packages
#Set hostname
#sudo raspi-config nonint do_hostname hammy
#Enable SSH
#sudo raspi-config nonint do_ssh 0

#Generate an ssh key
ssh-keygen

#Setup the Raspberry Pi to function as a wireless hotspot
RUN apt install -y  hostapd \
                    dnsmasq

#Thanks to raspberryconnect for this simplified installer
curl "https://www.raspberryconnect.com/images/hsinstaller/AutoHotspot-Setup.tar.gz" -o AutoHotspot-Setup.tar.gz
tar -xzvf AutoHotspot-Setup.tar.gz
cd Autohotspot
sudo ./autohotspot-setup.sh

#Select option 1
#Then select option 7 and enter the preferred SSID and password
#Test using option 6 to force the pi to enter hotspot mode

#The address of the pi when in hotspot mode is 192.168.50.5 by default.
#You can use this to SSH and VNC into the pi even when no internet is present.
#Just connect to the pi's wifi SSD to communicate with the device.

#Create /data
RUN mkdir -p /data/recording

#Enable VNC
#sudo raspi-config nonint do_vnc 0
#Set resolution so VNC will work
#sudo raspi-config 

#Set Static IP or use DHCP for interface
#Switch sound interface to analog on top right
#Test if analog microphone works for HF Comms

#Basic dependencies
RUN apt install -y vim \
                    code \
                    docker \
                    portainer \
                    socat

#SDR components
RUN apt install -y  rtl-sdr \
                    gqrx-sdr \
                    cubicsdr

#Set cubicsdr recording directory to /data/recording

#Install rpitx for transmitting from the GPIO pins
RUN git clone https://github.com/F5OEO/rpitx && \
                                    cd rpitx && \
                                    ./install.sh

#External GPS Synchronization
RUN apt -y install  gpsd \
                    gpsd-clients \ 
                    python-gps \ 
                    chrony \ 
                    python-gi-cairo \
                    xgps \
                    gegps \
                    viking \
                    foxtrotgps \
                    gpsbabel

#Currently requires /usr/sbin/gpsd /dev/ttyACM0 -n -F /var/run/gpsd.sock

#Capture GPS data using sudo gpspipe -r
#Record GPS data to a time-tagged file
#sudo gpspipe -r -d -l -o /data/data.`date +"%Y%m%d%h%m%s"`.nmea
#Convert GPS track to KML
#sudo gpsbabel -i nmea -f data.160902Sep091472862456.nmea -o kml -F trackdata1.kml

RUN cp config/gps /etc/default/gpsd && \
    cp config/chrony.conf /etc/chrony/chrony.conf

#Used for ADS-B 1090 reception (Flightaware)
RUN apt install -y dump1090-mutable

#Install VS Code python and C++ extensions

#Set up the Pi to send data over DDS
#Install rticonnextdds

#Make python3 requirements.txt file
#pip3 install rticonnextdds-connector
