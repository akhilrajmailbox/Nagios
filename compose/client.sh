#!/bin/bash
# this script was written for ubuntu 16.04 servers

function depen_on() {
VPC_RANGE=""
    until [[ ! -z "$VPC_RANGE" ]] ; do
	read -r -p "Enter VPC Range for your project, ie) 10.1.0.0/16 :: " VPC_RANGE </dev/tty
	echo "VPC_RANGE can not be empty"
    done
    echo "Configuring nrpe with VPC Range :: $VPC_RANGE, If you want to change it, run this script again"
}


function package_install() {
    depen_on
    Required_Packages=(
        "nagios-plugins"
        "nagios-nrpe-server"
        "sed"
        "net-tools")

    apt-get update -y
    for my_Package in ${Required_Packages[@]}; do
        if dpkg -l | grep $my_Package  >/dev/null ; then
            echo "$my_Package is already installed in your system"
        else
            echo "$my_Package is being installing...."
            apt-get install -y $my_Package
        fi
    done
}


function nrpe_config() {
    package_install
    sed -i "s|^server_address=.*|#server_address=|g" /etc/nagios/nrpe.cfg
    sed -i "s|^allowed_hosts=.*|allowed_hosts=127.0.0.1,$VPC_RANGE|g" /etc/nagios/nrpe.cfg

    Remote_Commands=(
        "command[my_disk]=/usr/lib/nagios/plugins/check_disk -w 60% -c 40% -p /"
        "command[my_load]=/usr/lib/nagios/plugins/check_load -w 5.0,4.0,3.0 -c 10.0,6.0,4.0"
        "command[my_procs]=/usr/lib/nagios/plugins/check_procs -w 300 -c 450 -s RSZDT"
        "command[my_users]=/usr/lib/nagios/plugins/check_users -w 5 -c 10"
        "command[my_swap]=/usr/lib/nagios/plugins/check_swap -w 30% -c 20%"
        "command[my_mem]=/usr/lib/nagios/plugins/check_mem -w 70 -c 80")


Number_Of_Array=${#Remote_Commands[@]}
Initial_Number_Of_Array=0

while [ $Initial_Number_Of_Array -lt $Number_Of_Array ]
do
	nrpe_commands_name=`echo ${Remote_Commands[$Initial_Number_Of_Array]} | cut -d"[" -f2 | cut -d"]" -f1`
    if cat /etc/nagios/nrpe.cfg | grep "$nrpe_commands_name" >/dev/null; then
        echo "The nrpe command : $nrpe_commands_name, already available in this machines"
    else
        echo "Configuring the nrpe command : $nrpe_commands_name"
        echo ${Remote_Commands[$Initial_Number_Of_Array]} >> /etc/nagios/nrpe.cfg
    fi
    Initial_Number_Of_Array=`expr $Initial_Number_Of_Array + 1`
done

curl -s https://raw.githubusercontent.com/akhilrajmailbox/nagios/master/custom-plugin/check_mem -o /usr/lib/nagios/plugins/check_mem
    if [[ $? -ne 0 ]] ; then
      echo "issue while downloading check_mem plugin...."
      exit 1
    fi
chmod a+x /usr/lib/nagios/plugins/check_mem
}

function start_nrpe() {
    nrpe_config
    /etc/init.d/nagios-nrpe-server stop
    sleep 5
    /etc/init.d/nagios-nrpe-server start
    sleep 5
    netstat -tulpn | grep LISTEN
}

start_nrpe
