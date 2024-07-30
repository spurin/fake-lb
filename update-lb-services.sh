#!/bin/bash

# This script sets externalIPs for LoadBalancer services to the numerically sorted internal IPs of all nodes.
SLEEP_INTERVAL=5

while true; do
    # Get all nodes' internal IPs
    node_ips=$(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}')

    # Convert node IPs into an array and sort numerically
    IFS=' ' read -r -a ip_array <<< "$node_ips"
    IFS=$'\n' sorted_ips=($(sort -V <<<"${ip_array[*]}"))
    unset IFS

    # JSON array of IPs
    json_ips=$(printf ',"%s"' "${sorted_ips[@]}")
    json_ips="[${json_ips:1}]"

    # Get all services across all namespaces
    services=$(kubectl get svc --all-namespaces -o json)

    # Loop through each service
    echo "$services" | jq -c '.items[]' | while read -r svc; do
        type=$(echo "$svc" | jq -r '.spec.type')

        if [[ "$type" == "LoadBalancer" ]]; then
            namespace=$(echo "$svc" | jq -r '.metadata.namespace')
            name=$(echo "$svc" | jq -r '.metadata.name')
            externalIPs=$(echo "$svc" | jq -r '.spec.externalIPs | length')

            if [[ "$externalIPs" == "0" ]]; then
                # Construct the patch command
                patch="{\"spec\":{\"externalIPs\":$json_ips}}"
                kubectl patch svc "$name" -n "$namespace" --type=merge -p "$patch"
                echo "Set externalIPs to node IPs (sorted numerically) for service:$name in namespace:$namespace."
            fi
        fi
    done

    sleep $SLEEP_INTERVAL
done
