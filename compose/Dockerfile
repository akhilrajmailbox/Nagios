from akhilrajmailbox/ubuntu:14.04
maintainer Akhil Raj <akhilrajmailbox@gmail.com>


run bash -c 'debconf-set-selections <<< "postfix postfix/mailname string nagios.local"'
run bash -c 'debconf-set-selections <<< "postfix postfix/main_mailer_type string Internet Site"'
run apt-get update && apt-get upgrade -y && apt-get install -y apache2 sudo nano net-tools \
            dnsutils wget build-essential libgd2-xpm-dev openssl libssl-dev xinetd \
            apache2-utils unzip postfix php5 libapache2-mod-php5 php5-mcrypt php5-cli mailutils


run useradd nagios && groupadd nagcmd && usermod -a -G nagcmd nagios

copy nagios-4.3.2.tar.gz /opt/
workdir /opt/
run tar xvf nagios-4.3.2.tar.gz && mv /opt/nagios-4.3.2 /opt/nagios
workdir /opt/nagios
run ./configure --with-nagios-group=nagios --with-command-group=nagcmd
run make all
run make install
run make install-commandmode
run make install-init
run make install-config
run ls -l /etc/apache2/
run /usr/bin/install -c -m 644 sample-config/httpd.conf /etc/apache2/sites-available/nagios.conf
run usermod -G nagcmd www-data

copy nagios-plugins-2.2.1.tar.gz /opt/
workdir /opt/
run tar xvf /opt/nagios-plugins-2.2.1.tar.gz && mv /opt/nagios-plugins-2.2.1 /opt/nagios-plugins
workdir /opt/nagios-plugins
run ./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
run make
run make install

copy nrpe-2.15.tar.gz /opt/
workdir /opt/
run tar xvf /opt/nrpe-2.15.tar.gz && mv /opt/nrpe-2.15 /opt/nrpe
workdir /opt/nrpe
run ./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
run make all
run make install
run make install-xinetd
run make install-daemon-config

expose 25 465 587 80 5666

run sed -i "s|#cfg_dir=/usr/local/nagios/etc/servers|cfg_dir=/usr/local/nagios/etc/servers|g" /usr/local/nagios/etc/nagios.cfg
run mkdir /usr/local/nagios/etc/servers
run mv /etc/xinetd.d/nrpe /etc/xinetd.d/nrpe-org
run mv /usr/local/nagios/etc/objects/commands.cfg /usr/local/nagios/etc/objects/commands.cfg-org

copy commands.cfg /usr/local/nagios/etc/objects/commands.cfg
copy monitor.cfg-reference /root/monitor.cfg-reference
copy specific-monitor.cfg-reference /root/specific-monitor.cfg-reference
copy specific-template.cfg-reference /root/specific-template.cfg-reference

add start.sh /root/start.sh
run chmod 777 /root/start.sh
entrypoint "/root/start.sh"
