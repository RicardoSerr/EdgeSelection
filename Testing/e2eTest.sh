#!/bin/bash

CACERT_PATH="ca.pem"
API_SERVER="192.168.1.92:2023"
AUTH_SERVER="192.168.1.65:2000"

CLIENT_IP_ADDR="X.X.X.X:Y"
CLIENT_MSISDN="34XXXXXXXXX"
get_token() {
    local client_id=$1
    local client_secret=$2
    curl -s -X POST -H "Content-Type: application/json" -d '{"client_id":"'$client_id'","client_secret":"'$client_secret'"}' "http://$AUTH_SERVER/generateToken" | jq -r '.access_token'
}

make_get_request() {
    local url=$1
    local token=$2
    curl -s -X GET "$url" -H "Authorization: $token" --cacert "$CACERT_PATH"
}

make_put_request() {
    local url=$1
    local token=$2
    local data=$3
    curl -s -X PUT "$url" -H "Authorization: $token" -H "Content-Type: application/json" -d "$data" --cacert "$CACERT_PATH"
}

# Retreive all possible EdgeSites
printf "==============================\n"
token1=$(get_token "ricardoSerrano" "Telefonica123")
echo "For ricardoSerrano making API request with token:: $token1"
response_all=$(make_get_request "https://$API_SERVER/SimpleEdge" "$token1")
echo "API Response:"
echo "$response_all"
printf "==============================\n"

# Request using the IP
token2=$(get_token "user1" "Password123")
echo "For user1 Making API request (IP ADDR) with token:: $token2"
response_ipas=$(make_get_request "https://$API_SERVER/SimpleEdge?ip_address=$CLIENT_IP_ADDR" "$token2")
echo "API Response:"
echo "$response_ipas"
printf "==============================\n"

# Request using the MSISDN
token3=$(get_token "user2" "Password123")
echo "For user2 making API request (MSISDN) with token:: $token3"
response_msisdn=$(make_get_request "https://$API_SERVER/SimpleEdge?msisdn=$CLIENT_MSISDN" "$token3")
echo "API Response:"
echo "$response_msisdn"
printf "==============================\n"

# Forbidden access
token3=$(get_token "user2" "Password123")
echo "For user2 making a forbiden request with token:: $token3"
response_msisdn=$(make_get_request "https://$API_SERVER/adminEdgeSites" "$token3")
echo "API Response:"
echo "$response_msisdn"
printf "==============================\n"

# Bad Request
token3=$(get_token "user2" "Password123")
echo "For user2 making a bad request with token:: $token3"
response_msisdn=$(make_get_request "https://$API_SERVER/SimpleEdge?msisdn=1234" "$token3")
echo "API Response:"
echo "$response_msisdn"
printf "==============================\n"

# Example PUT request for admin
token1=$(get_token "ricardoSerrano" "Telefonica123")
echo "For ricardoSerrano making API request with token:: $token1"
updated_data='{"data": [
    {
      "NAS-id": "DCBESP2_vUGW01",
      "NAS-Group IP": "10.0.0.1",
      "EdgeNode": "TE_sev_675",
      "EdgeNode IP": "23.127.0.4"
    },
    {
      "NAS-id": "DCBTYB2_vUGW01",
      "NAS-Group IP": "10.0.0.2",
      "EdgeNode": "TE_alco_231",
      "EdgeNode IP": "23.127.0.1"
    },
    {
      "NAS-id": "DCVCAR2_vUGW01",
      "NAS-Group IP": "10.0.0.3",
      "EdgeNode": "TE_bcn_129",
      "EdgeNode IP": "23.127.0.3"
    }]}'
response_put_admin=$(make_put_request "https://$API_SERVER/adminEdgeSites" "$token1" "$updated_data")
echo "PUT Admin API Response:"
echo "$response_put_admin"
printf "==============================\n"

# Example GET request for admin
token1=$(get_token "ricardoSerrano" "Telefonica123")
echo "For ricardoSerrano making API request with token:: $token1"
response_get_admin=$(make_get_request "https://$API_SERVER/adminEdgeSites" "$token1")
echo "GET Admin API Response:"
echo "$response_get_admin"
