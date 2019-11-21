FROM akhilrajmailbox/ubuntu:14.04
MAINTAINER Akhil Raj <akhilrajmailbox@gmail.com>


RUN bash -c 'debconf-set-selections <<< "postfix postfix/mailname string nagios.local"'
RUN bash -c 'debconf-set-selections <<< "postfix postfix/main_mailer_type string Internet Site"'
RUN apt-get update && apt-get upgrade -y && apt-get install -y apache2 sudo vim net-tools curl \
            dnsutils wget build-essential libgd2-xpm-dev openssl libssl-dev xinetd \
            apache2-utils unzip postfix php5 libapache2-mod-php5 php5-mcrypt php5-cli mailutils
RUN useradd nagios && groupadd nagcmd && usermod -a -G nagcmd nagios

# # Configure aws cli
# RUN apt-get install python-dev python-pip jq -y
# RUN pip install awscli
# RUN ln -fs /usr/bin/python3 /usr/bin/python
# RUN apt-get install python3-pip -y
# RUN pip3 install awscli --upgrade
# WORKDIR /tmp/
# RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
#     && curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator
# RUN chmod +x kubectl \
#     &&  chmod +x aws-iam-authenticator
# RUN mv kubectl aws-iam-authenticator /usr/local/bin/


## Installing and Configuring Nagios Server
WORKDIR /opt/
RUN curl -L -O https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.3.4.tar.gz
RUN tar xvf nagios-*.tar.gz && rm -rf nagios-*.tar.gz && mv /opt/nagios-* /opt/nagios
WORKDIR /opt/nagios
RUN ./configure --with-nagios-group=nagios --with-command-group=nagcmd
RUN make all
RUN make install
RUN make install-commandmode
RUN make install-init
RUN make install-config
RUN /usr/bin/install -c -m 644 sample-config/httpd.conf /etc/apache2/sites-available/nagios.conf
RUN usermod -G nagcmd www-data

# COPY resources/nagios-4.3.2.tar.gz /opt/
# WORKDIR /opt/
# RUN tar xvf nagios-4.3.2.tar.gz && mv /opt/nagios-4.3.2 /opt/nagios
# WORKDIR /opt/nagios
# RUN ./configure --with-nagios-group=nagios --with-command-group=nagcmd
# RUN make all
# RUN make install
# RUN make install-commandmode
# RUN make install-init
# RUN make install-config
# RUN ls -l /etc/apache2/
# RUN /usr/bin/install -c -m 644 sample-config/httpd.conf /etc/apache2/sites-available/nagios.conf
# RUN usermod -G nagcmd www-data



## Installing all nagios plugins
WORKDIR /opt/
RUN curl -L -O http://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz
RUN tar xvf /opt/nagios-plugins-*.tar.gz && rm -rf nagios-plugins-*.tar.gz && mv /opt/nagios-plugins-* /opt/nagios-plugins
WORKDIR /opt/nagios-plugins
RUN ./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
RUN make
RUN make install

# COPY resources/nagios-plugins-2.2.1.tar.gz /opt/
# WORKDIR /opt/
# RUN tar xvf /opt/nagios-plugins-2.2.1.tar.gz && mv /opt/nagios-plugins-2.2.1 /opt/nagios-plugins
# WORKDIR /opt/nagios-plugins
# RUN ./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
# RUN make
# RUN make install



## Configuring nrpe plugin for nagios
WORKDIR /opt/
RUN curl -L -O http://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz
RUN tar xvf /opt/nrpe-*.tar.gz && rm -rf nrpe-*.tar.gz && mv /opt/nrpe-* /opt/nrpe
WORKDIR /opt/nrpe
RUN ./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
RUN make all
RUN make install
RUN make install-xinetd
RUN make install-daemon-config

# COPY resources/nrpe-2.15.tar.gz /opt/
# WORKDIR /opt/
# RUN tar xvf /opt/nrpe-2.15.tar.gz && mv /opt/nrpe-2.15 /opt/nrpe
# WORKDIR /opt/nrpe
# RUN ./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
# RUN make all
# RUN make install
# RUN make install-xinetd
# RUN make install-daemon-config


## Customisation of nagios server
WORKDIR /opt/ 
RUN wget http://sourceforge.net/projects/arana-nagios/files/arana_style-1.0for-Nagios3x-ENG.zip
RUN unzip arana_style-*.zip && cp -r arana_style/* /usr/local/nagios/share/ && rm -rf arana_style*
COPY nath_status.php /usr/local/nagios/share/nath_status.php

EXPOSE 25 465 587 80 5666


## Customising the nagios configuration location
RUN sed -i "s|#cfg_dir=/usr/local/nagios/etc/servers|cfg_dir=/usr/local/nagios/etc/servers|g" /usr/local/nagios/etc/nagios.cfg
RUN mkdir /usr/local/nagios/etc/servers
RUN mv /etc/xinetd.d/nrpe /etc/xinetd.d/nrpe-org
RUN mv /usr/local/nagios/etc/objects/commands.cfg /usr/local/nagios/etc/objects/commands.cfg-org


## nagios configurations
COPY ConfigTemplates/template.cfg /usr/local/nagios/etc/servers/template.cfg
COPY ConfigTemplates/commands.cfg /usr/local/nagios/etc/objects/commands.cfg


## Reference
WORKDIR /opt/NagiosReference
COPY ConfigTemplates/Reference/monitor.cfg-reference /opt/NagiosReference/monitor.cfg-reference
COPY ConfigTemplates/Reference/specific-monitor.cfg-reference /opt/NagiosReference/specific-monitor.cfg-reference
COPY ConfigTemplates/Reference/specific-template.cfg-reference /opt/NagiosReference/specific-template.cfg-reference


## Configuring custom templates and plugins for nagios plugins
COPY ConfigTemplates/contacts.cfg /usr/local/nagios/etc/servers/monitor/contacts.cfg
COPY ConfigTemplates/custom-commands.cfg /usr/local/nagios/etc/servers/monitor/custom-commands.cfg
COPY CustomPlugins/k8s_nodes_check.sh /usr/local/nagios/libexec/k8s_nodes_check.sh
COPY CustomPlugins/k8s_pods_check.sh /usr/local/nagios/libexec/k8s_pods_check.sh
COPY CustomPlugins/check_mem /usr/local/nagios/libexec/check_mem
RUN chmod a+x /usr/local/nagios/libexec/*

ENV USER_PASSWORD "MyroUserCreds"
ENV SMTP_SERVER "smtp.gmail.com"
ENV SMTP_PORT "465"
ENV SMTP_USERNAME ""
ENV SMTP_PASSWORD ""
ENV NAGIOS_MAIL_SENDER "PagerDuty <mymail@gmail.com>"
ENV LOCAL_MONITOR "N"

COPY docker_entrypoint.sh /docker_entrypoint.sh
RUN chmod a+x /docker_entrypoint.sh
ENTRYPOINT [ "/docker_entrypoint.sh" ]
