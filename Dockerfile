#This is the closest thing to an official raspbian image on dockerhub.
FROM balenalib/raspberry-pi-debian:latest

#Update the Pi to the latest version
RUN apt update && \
    apt upgrade

#Attach to specific wifi network (set with designated username and password to automatically hook in)

#Set hostname
sudo raspi-config nonint do_hostname hammy
#Enable SSH
sudo raspi-config nonint do_ssh 0
#Enable remote GPIO
sudo raspi-config nonint remote_gpio 0


Set rapsberry pi timezone to zulu (UTC)
Set digital clock display to %T (HH:MM:SS)

#Generate an ssh key
ssh-keygen

#Create /data
RUN mkdir -p /data/recording

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
                    librtlsdr-dev \
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

#Relevant files:
/etc/chrony/chrony.conf #Time Server Settings
/lib/systemd/system/gpsd.service
/lib/systemd/system/gpsd.socket
/etc/default/gpsd


#Capture GPS data using sudo gpspipe -r
#Record GPS data to a time-tagged file
#sudo gpspipe -r -d -l -o /data/data.`date +"%Y%m%d%h%m%s"`.nmea
#Convert GPS track to KML
#sudo gpsbabel -i nmea -f data.160902Sep091472862456.nmea -o kml -F trackdata1.kml

RUN cp config/gps /etc/default/gpsd && \
    cp config/chrony.conf /etc/chrony/chrony.conf

#/lib/systemd/system/gpsd.service

#Used for ADS-B 1090 reception (Flightaware)
#No longer maintained, build from source
#RUN apt install -y dump1090-mutable

RUN wget https://uk.flightaware.com/adsb/piaware/files/packages/pool/piaware/p/piaware-support/piaware-repository_5.0_all.deb
sudo dpkg -i piaware-repository_5.0_all.deb

sudo apt-get update

#Optional: Install piaware to automatically upload data to Flightaware
#sudo apt-get install piaware
#sudo piaware-config allow-auto-updates yes
#sudo piaware-config allow-manual-updates yes

sudo apt-get install dump1090-fa
sudo apt-get install dump978-fa

RUN mkdir -p /data/flight/1090 && \
    sudo chmod -R 777 /data/flight/1090
#Or add dump1090 user to appropriate group
sudo adduser dump1090 pi
sudo deluser dump1090 pi

#Do this if you want to invoke dump1090 manually, otherwise it will run on boot.
#systemctl disable dump1090-fa

#Can use view1090-fa --no-interactive to view output from command line

#Change startup options
/etc/default/dump1090-fa

#Where dump1090 is invoked from
/usr/share/dump1090-fa/start-dump1090-fa
./etc/systemd/system/default.target.wants/dump1090-fa.service
./usr/lib/systemd/system/dump1090-fa.service
./var/lib/systemd/deb-systemd-helper-enabled/default.target.wants/dump1090-fa.service
#/etc/systemd/system

/usr/bin/dump1090-fa --device-index 0 --gain -10 --ppm 0 --max-range 360 --fix --net --net-heartbeat 60 --net-ro-size 1300 --net-ro-interval 0.2 --net-ri-port 0 --net-ro-port 30002 --net-sbs-port 30003 --net-bi-port 30004,30104 --net-bo-port 30005 --json-location-accuracy 1 --write-json /run/dump1090-fa --quiet

%t/dump1090-fa

#Record ADS-B data from dump1090 into a file.
nc myreceiver 30003 > /data/flight/1090/file.txt
/usr/bin/dump1090-fa --raw >> /data/

#Actively updated JSON files are in /run/dump1090-fa
#View web map of ADS-B signals at http://localhost/skyaware

#Install VS Code python and C++ extensions

#Set up the Pi to send data over DDS
#Install rticonnextdds

#Make python3 requirements.txt file
#pip3 install rticonnextdds-connector
