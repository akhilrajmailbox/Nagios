

docker run command ::

```

docker run -e MAIL_ADDRESS=<<<mail-address>>> -e HTPASSWORD=<<<password>>> -e HOST_IP=<<<docker-host-ip>>> -p 9999:80 -p 9998:5666 --hostname nagios.local --name nagios.local -it akhilrajmailbox/nagios:latest /bin/bash

```

environment variable ::

```
MAIL_ADDRESS		=	The mail address for getting the notifications
HTPASSWORD		=	The password for web user (the web user is 'nagiosadmin')
HOST_IP			=	The docker-running host ip address 

```

NOTE :::

 *	The 'HOST_IP' is optional, if you don't provide, then the server will configure with container ip address.
 *	'hostname' need to provide, if you want a proper name for mail sender


web_ui ::

```
admin		=		nagiosadmin
password	=		HTPASSWORD (you need to provide with docker run command)

```

IMPORTANT ::

for using 'check_nrpe' you need to configure in remote machine also, and do not configure with 'argument enable option in remote machine' (security issue)
