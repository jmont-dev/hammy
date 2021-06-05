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
                    cubicsdr \

#Set cubicsdr recording directory to /data/recording

#External GPS Synchronization
RUN apt -y install  gpsd \
                    gpsd-clients \ 
                    python-gps \ 
                    chrony \ 
                    python-gi-cairo

RUN cp config/gps /etc/default/gpsd && \
    cp config/chrony.conf /etc/chrony/chrony.conf

#Used for ADS-B 1090 reception (Flightaware)
RUN apt install -y dump1090-mutable

#Install VS Code python and C++ extensions

#Set up the Pi to send data over DDS
#Install rticonnextdds

#Make python3 requirements.txt file
#pip3 install rticonnextdds-connector
