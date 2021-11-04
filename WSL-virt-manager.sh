#!/bin/bash

# QEMU over SSH enabled virt-manager
#
# Tested with Ubuntu 20.04 because in Debian some dbus stuff just won't work [maybe you can]
#
# MAKE SURE TO HAVE YOUR XSERVER ALREADY RUNNING!!
#
# dependencies: qemu, ssh server, libvirt and virtlog/lock daemons, and virt-manager of course. also enable password authentication in your ssh server or copy your keys prior to this script.
# 
# This is just a dirty way to get your virt-manager running with [hopefully] no errors and to provide a way that 'just works'. Thank MS for not helping in all of this. Maybe you can set up a bridged connection, if you have enough ethernet ports on your PC.
#
# logs are saved in home/.vmlogs by default since libvirt and virtlog daemons cannot be started directly by systemctl/service, so we start them manually and keep them in background with logs enabled. I don't even know if it logs anything this way, but I don't have time right now.

if [ -d ~/.vmlogs ]; then
echo "Daemon logs are saved in .vmlogs/ folder."
else mkdir ~/.vmlogs && echo "Daemon logs are saved in .vmlogs/ folder."
fi

CURRENT_WSL_IP=$(ip a show eth0 | grep global | cut -c 10-20)
WSL_USER=$(whoami)
WSL_HOME=$HOME

echo "Starting up..."
echo "Ip is $CURRENT_WSL_IP"
echo "Starting ssh server and libvirtd+virtlogd, please insert password: "
sudo echo "SUDO OK"

function start_services {
service ssh restart
libvirtd | tee -a $WSL_HOME/.vmlogs/libvirtd.log &
virtlogd | tee -a $WSL_HOME/.vmlogs/virtlogd.log &
}
SV=$(declare -f start_services)
sudo bash -c "$SV; start_services"

printf "Services started. Warming up"
printf "." && sleep 1 && printf "." && sleep 1 && printf "." && sleep 1 && printf "." && sleep 1 && printf "." && sleep 1 && printf ".\n"
echo "Ready. Starting virt-manager on $CURRENT_WSL_IP..."

virt-manager -c qemu+ssh://${WSL_USER}@${CURRENT_SWL_IP}/system

read -p "Press ENTER to clean up this page, or Ctrl+C to exit the script."
clear