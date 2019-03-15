#!/bin/bash
type jq >/dev/null 2>&1 || { echo >&2 "CRITICAL: The jq utility is required for this script to run."; exit 2; }
type kubectl >/dev/null 2>&1 || { echo >&2 "CRITICAL: The kubectl utility is required for this script to run if no API endpoint is specified"; exit 2; }


function usage {
cat <<EOF
Usage: 
  ./check_kube_pods.sh [-n <NAMESPACE> -w <WARN_THRESHOLD> -c <CRIT_THRESHOLD>]
Options:
  -w <WARN_THRESHOLD>	# Warning threshold for number of container restarts [default: 10]
  -c <CRIT_THRESHOLD>	# Critical threshold for number of container restarts [default: 15]
  -n <NAMESPACE>	    # Namespace to check, for example, "kube-system".
  -h			        # Show usage / help
EOF
exit 2
}


WARN_THRESHOLD=10
CRIT_THRESHOLD=15
export KUBECONFIG=/home/nagios/.kube/config

EXITCODE=0
PODS_READY=0

while getopts ":c:w:n:h:v:" OPTIONS; do
    case "${OPTIONS}" in
		w) WARN_THRESHOLD=${OPTARG} ;;
		c) CRIT_THRESHOLD=${OPTARG} ;;
		n) NAMESPACE=${OPTARG} ;;
        h) usage ;;
        *) usage ;;
    esac
done


WARN_THRESHOLD=$(($WARN_THRESHOLD + 0))
CRIT_THRESHOLD=$(($CRIT_THRESHOLD + 0))

function returnResult () {
        RESULT=$(echo -e "$1: $2\n$RESULT")
        if [[ "$1" == "Critical" ]] && [ $EXITCODE -le 2 ]; then EXITCODE=2; fi
        if [[ "$1" == "Warning" ]] && [ $EXITCODE -eq 0 ]; then EXITCODE=1; fi
        if [[ "$1" == "Unknown" ]] && [ $EXITCODE -eq 0 ]; then EXITCODE=3; fi
}


if [[ ! -z $NAMESPACE ]]; then
    PODS_STATUS=$(kubectl get pods --namespace $NAMESPACE -o json)
    if [ $(echo "$PODS_STATUS" | wc -l) -le 10 ]; then echo "UNKNOWN - unable to connect to kubernetes cluster!"; exit 3; fi
    PODS=$(echo "$PODS_STATUS" | jq -r '.items[].metadata.name')


    for POD in ${PODS[*]}; do
            POD_STATUS=$(echo "$PODS_STATUS" | jq -r '.items[] | select(.metadata.name | contains("'$POD'"))')
            POD_CONDITION_TYPES=$(echo "$POD_STATUS" | jq -r '.status.conditions[] | .type')
            for TYPE in ${POD_CONDITION_TYPES[*]}; do
                TYPE_STATUS=$(echo "$POD_STATUS" | jq -r '.status.conditions[] | select(.type=="'$TYPE'") | .status')
                if [[ "${TYPE_STATUS}" != "True" ]]; then
                    returnResult OK "Pod: $POD  $TYPE: $TYPE_STATUS"
                else
                    if [[ "${TYPE}" == "Ready" ]]; then PODS_READY=$((PODS_READY+1)); fi
                fi
            done

    CONTAINERS=$(echo "$POD_STATUS" | jq -r '.status.containerStatuses[].name')
            for CONTAINER in ${CONTAINERS[*]}; do
                CONTAINER_READY=$(echo "$POD_STATUS" | jq -r '.status.containerStatuses[] | select(.name=="'$CONTAINER'") | .ready')
                CONTAINER_RESTARTS=$(echo "$POD_STATUS" | jq -r '.status.containerStatuses[] | select(.name=="'$CONTAINER'") | .restartCount')
                if (( $CONTAINER_RESTARTS > $WARN_THRESHOLD && $CONTAINER_RESTARTS < $CRIT_THRESHOLD )); then 
                    returnResult Warning "Pod: $POD   Container: $CONTAINER    Ready: $CONTAINER_READY   Restarts: $CONTAINER_RESTARTS"
                elif (( $CONTAINER_RESTARTS > $CRIT_THRESHOLD )); then
                    returnResult Critical "Pod: $POD   Container: $CONTAINER    Ready: $CONTAINER_READY   Restarts: $CONTAINER_RESTARTS"
                fi
            done
    done

else
echo "Namespace need to provide"
exit 3
fi


case $EXITCODE in
	0) printf "OK - pods are all OK, found $PODS_READY in ready state.\n" ;;
	# 1) printf "Warning - pods show warning status, $PODS_READY in ready state.\n" ;;
	# 2) printf "Critical - pods show critical status, $PODS_READY in ready state.\n" ;;
esac

echo "$RESULT"
exit $EXITCODE