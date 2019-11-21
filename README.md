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
| NAGIOS_MAIL_SENDER | PagerDuty \< mymail@gmail.com > |   The receiver will see the lert mail comes from this sender  |
| LOCAL_MONITOR | N |    for adding the localhost to the monitoring list, variable Value must be "Y / y" for monitor the localhost(The container) by the nagios    |


**NOTE :**

 *	port 80		>>	for web_ui access
 *	port 5666	>>	for nrpe connection between nagios server and client machines which being monitoring

web_ui :: `http://host-ip:9999/nagios`


**Admin Credentials**
```
admin		=		NagiosAdmin
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
kubectl apply -f nagios-namespace.yaml
```

we have to update the configuration files also, this will come under `FromFiles` Folder. 

* contact.cfg   :   you have to update the user list and their mail address for receiving the alerts from nagios, don't update anything for `NagiosUser`.
* custom-commands.cfg   :   you can add any custom commands / plugins for monitoring with your needs here.
* jenkins.cfg   : this is an example config files for one server (monitoring jenkins server for most of its resources)
* server1.cfg   : like jenkins.cfg, you can add `n` number of config files for each servers. naming is not a matter but file extension `.cfg` is matter...
* ...
* ...

```
kubectl -n monitor create configmap nagios-monitor --from-file=FromFiles
```

### Deploy Nagios server
```
kubectl apply -f nagios-deployment.yaml
```

### Configure k8s service (loadbalancer)
```
kubectl apply -f nagios-service.yaml
```


## Client machine configurations for nagios

**In client machine, run this commands in order to configure nrpe and nagios client (tested with ubuntu 16.04 machines)**

```
curl -s https://raw.githubusercontent.com/akhilrajmailbox/nagios/master/compose/client.sh | bash
```

*IMPORTANT ::*

for using 'check_nrpe' you need to configure in remote machine also, do not configure with 'argument enable option in remote machine' (security issue)

