#!/bin/sh
set -e

slskd_username="${SLSKD_USERNAME:-admin}"
slskd_password="${SLSKD_PASSWORD:-adminadmin}"
slskd_addr="${SLSKD_ADDR:-http://localhost:5030}" # ex. http://10.0.1.48:8080
gtn_addr="${GTN_ADDR:-http://localhost:8000}" # ex. http://10.0.1.48:8000

if [[ -n "$GTN_USERNAME" && -n "$GTN_PASSWORD" ]]; then
    echo "Attempting to retrieve port from Gluetun via username and password..."
    port_number=$(curl --fail --silent --show-error --user "$GTN_USERNAME:$GTN_PASSWORD" $gtn_addr/v1/openvpn/portforwarded | jq '.port')
elif [ -n "$GTN_APIKEY" ]; then
    echo "Attempting to retrieve port from Gluetun via api key..."
    port_number=$(curl --fail --silent --show-error --header "X-API-Key: $GTN_APIKEY" $gtn_addr/v1/openvpn/portforwarded | jq '.port')
else
    echo "Attempting to retrieve port from Gluetun without authentication..."
    port_number=$(curl --fail --silent --show-error  $gtn_addr/v1/openvpn/portforwarded | jq '.port')
fi

if [ ! "$port_number" ] || [ "$port_number" = "0" ]; then
    echo "Could not get current forwarded port from gluetun, exiting..."
    exit 1
else
    echo "Port number succesfully retrieved from Gluetun: $port_number"
fi

token=$(curl -X POST --fail --silent --show-error \
  -H "Content-Type: application/json" --data \
  "{\"username\": \"$slskd_username\", \"password\": \"$slskd_password\"}" \
  $slskd_addr/api/v0/session | jq -r '.token')

auth_header="Authorization: Bearer $token"

config=$(curl -X GET --fail --silent --show-error \
  -H "$auth_header" \
  $slskd_addr/api/v0/options/yaml)

if [ ! "$config" ]; then
    echo "Could not get current slskd config, exiting..."
    exit 1
fi

echo "Updating port to $port_number"

config=$(sed -n "s/listen_port:\s[0-9]*/listen_port: $port_number/")

curl -X POST --fail --silent --show-error \
  -H "$auth_header" \
  -H "Content-Type: application/json" \
  --data "$config" \
  $slskd_addr/api/v0/options/yaml


echo "Successfully updated port"
