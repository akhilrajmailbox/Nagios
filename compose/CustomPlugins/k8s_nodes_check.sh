#!/bin/bash
type jq >/dev/null 2>&1 || { echo >&2 "CRITICAL: The jq utility is required for this script to run."; exit 2; }
type kubectl >/dev/null 2>&1 || { echo >&2 "CRITICAL: The kubectl utility is required for this script to run if no API endpoint is specified"; exit 2; }

EXITCODE=0
export KUBECONFIG=/home/nagios/.kube/config

if [ -z $K8STATUS ]; then
	# kubectl mode
	K8STATUS="$(kubectl  get nodes  -o json)"
	if [ $(echo "$K8STATUS" | wc -l) -le 30 ]; then echo "UNKNOWN - unable to connect to Kubernetes via kubectl!"; exit 3; fi
fi


export NODES=$(echo "$K8STATUS" | jq -r '.items[].metadata.name')

function returnResult () {
	CHECKSTATUS="$1"
	if [[ "$CHECKSTATUS" == "Critical" ]]; then 
		RESULT=$(echo -e "$CHECKSTATUS: $NODE has condition $CHECK - $STATUS\n$RESULT")
        EXITCODE=2
	elif [[ "$CHECKSTATUS" == "Warning" ]]; then
		RESULT=$(echo -e "$CHECKSTATUS: $NODE has condition $CHECK - $STATUS\n$RESULT")
        EXITCODE=1
	fi
}

for NODE in ${NODES[*]}; do
	CHECKS=$(echo "$K8STATUS" | jq -r '.items[] | select(.metadata.name=="'$NODE'") | .status.conditions[].type')
	# Itterate through each condition for each node
	for CHECK in ${CHECKS[*]}; do
		STATUS=$(echo "$K8STATUS" | jq '.items[] | select(.metadata.name=="'$NODE'") | .status.conditions[]'  | jq -r 'select(.type=="'$CHECK'") .status')
		case "$CHECK-$STATUS" in
			"OutOfDisk-True") returnResult Critical;;
			"MemoryPressure-True") returnResult Critical;;
            "PIDPressure-True") returnResult Critical;;
			"DiskPressure-True") returnResult Critical;;
			"Ready-False") returnResult Critical;;

			"OutOfDisk-Unknown") returnResult Critical;;
			"MemoryPressure-Unknown") returnResult Critical;;
            "PIDPressure-Unknown") returnResult Critical;;
			"DiskPressure-Unknown") returnResult Critical;;
			"Ready-Unknown") returnResult Critical;;
			# Note the API only checks these 4 conditions at present. Others can be added here.
			*) returnResult OK;;
		esac
	done
done


case $EXITCODE in
	0) printf "OK - Kubernetes nodes all OK\n" ;;
	2) printf "Critical - Kubernetes nodes are down. please fix it\n" ;;

esac

echo "$RESULT"
exit $EXITCODE