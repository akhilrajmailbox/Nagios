# Nagios Server

Nagios, now known as Nagios Core, is a free and open-source computer-software application that monitors systems, networks and infrastructure. Nagios offers monitoring and alerting services for servers, switches, applications and services.

## Environment variables

This image can be configured by means of environment variables, that one can set on a `Deployment`.

| Variable Name | Default Value |   Description |
|---------------|---------------|---------------|
| USER_PASSWORD | MyroUserCreds |   Readonly user for Nagios webUI  |
| SMTP_SERVER | smtp.gmail.com |    smpt server for sending Alert mail  | 
| SMTP_PORT | 465 | smtp port number for the "SMTP_SERVER"  |
| SMTP_USERNAME | -- |  Your smtp username (mail address)   |
| SMTP_PASSWORD | -- |  Password for the "SMTP_USERNAME"    |
| NAGIOS_MAIL_SENDER | PagerDuty < mymail@gmail.com > |   The receiver will see the lert mail comes from this sender  |
| LOCAL_MONITOR | N |    for adding the localhost to the monitoring list, variable Value must be "Y / y" for monitor the localhost(The container) by the nagios    |


**NOTE :**

 *	port 80		>>	for web_ui access
 *	port 5666	>>	for nrpe connection between nagios server and client machines which being monitoring

web_ui :: `http://host-ip:9999/nagios`


**Admin Credentials**
```
admin		=		nagiosadmin
password	=		you have to run the command "AdminPass" in the nagios container to get the admin password. This passowrd will change if the container get redeployed, so no need to save this password anywhere.
```

**Readonly User Credentials**
```
user		=		NagiosUser
password	=		USER_PASSWORD
```

## Kubernetes Deployment

**Run these commands from `Kubernetes` Folder**


### Create Namespace caled "monitor" for Nagios Deployment
```
kubectl apply -f nagios-namespace.yaml
```

### Configure Configmap
**Note : update the configmap "nagios-configmap.yaml" then run this command. Don't push this file to any cloud storage or to your repo after update the sensitive information**
```
kubectl apply -f nagios-configmap.yaml
```

we have to update the configuration files also, this will come under `FromFiles` Folder. 

* contact.cfg   :   you have to update the user list and their mail address for receiving the alerts from nagios, don't update anything for `NagiosUser`.
* custom-commands.cfg   :   you can add any custom commands / plugins for monitoring with your needs here.
* jenkins.cfg   : this is an example config files for one server (monitoring jenkins server for most of its resources)
* server1.cfg   : like jenkins.cfg, you can add `n` number of config files for each servers. naming is not a matter but file extension `.cfg` is matter...
* ...
* ...

```
kubectl -n monitor create configmap nagios-monitor-cm --from-file=FromFiles
```

### Deploy Nagios server
```
kubectl apply -f nagios-deployment.yaml
```

### Configure k8s service (loadbalancer)
```
kubectl apply -f nagios-service.yaml
```

## take the admin password from the nagios pod
```
kubectl -n monitor exec -it nagios-f856cc9cc-sthsj AdminPass
```



## Client machine configurations for nagios
**In client machine, run this commands in order to configure nrpe and nagios client (tested with ubuntu 16.04 machines)**
```
curl -s https://raw.githubusercontent.com/akhilrajmailbox/nagios/master/compose/client.sh | bash
```

*IMPORTANT ::*

for using 'check_nrpe' you need to configure in remote machine also, do not configure with 'argument enable option in remote machine' (security issue)



## nrpe Plugin configurations with an example

`Example Plugin name :  check_vpn`

### Nagios client side configurations

* create a shell script with name `check_vpn`
```
#!/bin/bash
VPN_IPAddress=$1
if ping -c1 $VPN_IPAddress > /dev/null; then
                echo "OK - VPN is up"
                exit 0
        else
                echo "CRITICAL - VPN is down"
                exit 2
fi
```

* update the nrpe.cfg
```
dont_blame_nrpe=1
command[my_vpn]=/usr/lib/nagios/plugins/check_vpn $ARG1$
```

* add the scripts to `plugins` folder
```
cd /usr/lib/nagios/plugins/
chmod a+x check_vpn/usr/lib/nagios/plugins/check_vpn
service nagios-nrpe-server restart
```

* test the plugin
```
/usr/lib/nagios/plugins/check_vpn 159.232.1.1
```

### Nagios server side configurations

* configure a custom command entry to use check_vpn script / plugin in the remote machine

```
define command{
        command_name    check_vpn_server
        command_line    $USER1$/check_nrpe -H $ARG1$ -c $ARG2$ -a $ARG3$
        }
```

* example :

```
 -H $ARG1$     >>  host where need to run
 -c $ARG2$     >>  command, here (my_vpn)
 -a $ARG3$     >>  argument for my_vpn
 example       >>  check_command                   check_vpn_server!192.168.0.125!my_vpn!159.232.1.1
```



## Reference Docs

[ServerAlarms apps for ios and android](https://exchange.nagios.org/directory/Addons/Frontends-%28GUIs-and-CLIs%29/Mobile-Device-Interfaces/Nagios-Client--2D-Status-Monitor/details)

[Read only secondary user 1](https://serverfault.com/questions/436886/nagios-is-it-possible-to-create-view-only-users-and-let-them-view-only-speci)

[Read only secondary user 2](https://github.com/asuknath/Nagios-Status-JSON)

[Nagios Object Definitions 1](https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/3/en/objectdefinitions.html?_ga=2.92039834.146004542.1532584157-1578007940.1531140260)

[Nagios Object Definitions 2](https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/3/en/cgis.html#extinfo_cgi)

[Themes and Skin 1](https://www.techietown.info/2017/03/installchange-nagios-theme/)

[Themes and Skin 2](https://exchange.nagios.org/directory/Addons/Frontends-(GUIs-and-CLIs)/Web-Interfaces/Themes-and-Skins)

[plugin creation 1](http://www.yourownlinux.com/2014/06/how-to-create-nagios-plugin-using-bash-script.html)

[plugin creation 2](https://www.howtoforge.com/tutorial/write-a-custom-nagios-check-plugin/)