#!/bin/bash
A=$(tput sgr0)
export TERM=xterm
echo ""
echo ""
echo -e '\E[33m'"----------------------------------- $A"
echo -e '\E[33m'"|   optional docker variable      | $A"
echo -e '\E[33m'"----------------------------------- $A"
echo -e '\E[33m'"----------------------------------- $A"
echo -e '\E[33m'"|    1)  MAIL_ADDRESS             | $A"
echo -e '\E[33m'"----------------------------------- $A"
echo -e '\E[33m'"|    2)  HOST_IP                  | $A"
echo -e '\E[33m'"----------------------------------- $A"
echo ""
echo -e '\E[32m'"###################################### $A"
echo -e '\E[32m'"###          MAIL_ADDRESS          ### $A"
echo -e '\E[32m'"###################################### $A"
echo -e '\E[33m'"You can provide mail address for getting notification from nagios server $A"
echo ""
echo ""
echo -e '\E[32m'"###################################### $A"
echo -e '\E[32m'"###             HOST_IP            ### $A"
echo -e '\E[32m'"###################################### $A"
echo -e '\E[33m'"You can provide the ip-address of the docker machine if you wish, $A"
echo -e '\E[33m'"so that you can connect the remote machines with nagios server by using the 'docker machine ip' and 'port no' $A"
echo ""
echo -e '\E[33m'"If you don't provide 'HOST_IP' then It choose 'container ip' as default ip address for nrpe configuration, $A"
echo -e '\E[33m'"so communication between 'remote machine' and 'nagios server (this container)' is not possible $A"
echo ""
echo "Configuring........"

if [[ ! -f /usr/local/nagios/etc/htpasswd.users ]];then
if [[ "$HTPASSWORD" = "" ]];then
echo ""
echo -e '\E[32m'"Please provide all environment variable while run the 'docker run command' with -e option $A"
echo ""
echo ""
echo -e '\E[33m'"----------------------------------- $A"
echo -e '\E[33m'"|    indeeded docker variable     | $A"
echo -e '\E[33m'"----------------------------------- $A"
echo -e '\E[33m'"----------------------------------- $A"
echo -e '\E[33m'"|    1)  HTPASSWORD               | $A"
echo -e '\E[33m'"----------------------------------- $A"
echo ""
echo "USERNAME : nagiosadmin"
echo "PASSWORD : The password you are providing with 'HTPASSWORD' environment variable"
echo ""
exit 0
else
sleep 1
fi
htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin $HTPASSWORD
fi

echo ""
if [[ "$HOST_IP" = "" ]]; then
HOST_IP=`ifconfig | grep -A 1 eth0 | tail -1 | cut -d ":" -f 2 | cut -d " " -f 1`
fi

cat <<EOF > /etc/xinetd.d/nrpe
# default: on
# description: NRPE (Nagios Remote Plugin Executor)
service nrpe
{
        flags           = REUSE
        socket_type     = stream
        port            = 5666
        wait            = no
        user            = nagios
        group           = nagios
        server          = /usr/local/nagios/bin/nrpe
        server_args     = -c /usr/local/nagios/etc/nrpe.cfg --inetd
        log_on_failure  += USERID
        disable         = no
        only_from       = 127.0.0.1 $HOST_IP
}
EOF

sed -i "s|NOTIFY_MAIL_ADDRESS|$MAIL_ADDRESS|g" /usr/local/nagios/etc/objects/commands.cfg

postconf -e myhostname="`hostname -f`"
postconf -e mydestination="`hostname -f`, localhost.localdomain, localhost"
echo "`hostname -f`" > /etc/mailname

service xinetd restart & wait
service apache2 restart & wait
a2enmod rewrite
a2enmod cgi

ln -s /etc/apache2/sites-available/nagios.conf /etc/apache2/sites-enabled/
service xinetd restart & wait
service nagios restart & wait
service apache2 restart & wait
service postfix restart & wait

echo "##################################"
echo ""
echo -e '\E[32m'"The config file should be under '/usr/local/nagios/etc/servers/' with '.cfg' extension $A"
echo -e '\E[32m'"You can find a reference file 'monitor.cfg-reference' under '/usr/local/nagios/etc/servers/' $A"
echo -e '\E[32m'"Configure your config file and reload the server with 'service nagios reload' $A"
echo ""
echo "##################################"
echo "##################################"
tailf /usr/local/nagios/var/nagios.log

fi
