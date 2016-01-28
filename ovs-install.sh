#!/bin/bash
#EDIT THIS BEFORE USE!!!!
CONTROLLER_IP=130.127.38.2
CONTROLLER_PORT=6011
DESIRED_IP=192.168.1.1/24
#Go To line 56 change the perl command as needed
#####################################################################
#Should be Automatic From this point on  more or less               #
#####################################################################
echo 'Checking and installing necessary dependencies...'
sudo apt-get update
cg=$(sudo apt --installed list | grep "clang")
uu=$(sudo apt --installed list | grep "uuid-dev")
lx=$(sudo apt --installed list | grep "libxml2-dev")
if [ -z $cg ] || [ -z $uu ] || [-z $lx ];
then
	sudo apt-get install clang -y
	sudo apt-get install uuid-dev -y
	sudo apt-get install libxml2-dev -y
else
	echo 'Dependency install complete, 5 second rest to exit should errors occur.'
	sleep 5
fi

echo 'Building Bridge...'
sudo ovs-vsctl add-br br0
sudo ovs-vsctl add-port br0 $(ifconfig | awk '{print $1}' | grep "vlan")
sudo ifconfig $(ifconfig | awk '{print $1}' | grep "vlan") 0 up
sudo ifconfig br0 $DESIRED_IP up
sudo ovs-vsctl set-controller br0 tcp:$CONTROLLER_IP:$CONTROLLER_PORT
sudo ovs-vsctl show
ifconfig br0 

echo 'Installing SoS Agents now...'
sudo git clone http://github.com/cbarrin/sos-agent 
cd ./sos-agent
#uncomment if common.h is not correct.
#sudo perl -p -i -e 's/10.0.255/192.168.2/g' ./common.h
sudo make 
echo 'Instillation complete.'
echo 'To run the SoS agent run ./run.sh.'
echo 'Recommended that you do so from a screen session.'
