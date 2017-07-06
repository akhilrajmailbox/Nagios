

docker run command ::

```

docker run -e MAIL_ADDRESS=<<<mail-address>>> -e HTPASSWORD=<<<password>>> -e HOST_IP=<<<docker-host-ip>>> -p 9999:80 -p 9998:5666 --hostname nagios.local --name nagios.local -v /path/to/folder:/usr/local/nagios/etc/servers -it akhilrajmailbox/nagios:latest /bin/bash

```

environment variable ::

```
MAIL_ADDRESS		=	The mail address for getting the notifications
HTPASSWORD		=	The password for web user (the web user is 'nagiosadmin')
HOST_IP			=	The docker-running host ip address 
LOCAL_MONITOR		=	The value should be 'Y' ; for adding the localhost to monitoring list,
				If this environment variable is not provided, then localhost(The container) will not monitor by the nagios

```

NOTE :::

 *	The 'HOST_IP' is optional, if you don't provide, then the server will configure with container ip address.
 *	'hostname' need to provide, if you want a proper name for mail sender
 *	port 80		>>	for web_ui access
 *	port 5666	>>	for nrpe connection between nagios server and client machines which being monitoring

web_ui ::

http://host-ip:9999/nagios


```
admin		=		nagiosadmin
password	=		HTPASSWORD (you need to provide with docker run command)

```

commands ::
	for adding another user other than nagiosadmin, use this command inside the docker container 
```
nagios-user <<username>> <<password>>
```

IMPORTANT ::

for using 'check_nrpe' you need to configure in remote machine also, and do not configure with 'argument enable option in remote machine' (security issue)

