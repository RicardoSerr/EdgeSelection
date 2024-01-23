#!/bin/bash
# Ruta al archivo de certificado de CA
CACERT_PATH="ca.pem"
###
token1=$(curl -s -X POST -H "Content-Type: application/json" -d '{"client_id":"ricardoSerrano","client_secret":"Telefonica123"}' http://192.168.1.65:2000/generateToken | jq -r '.access_token')
echo "For ricardoSerrano making API request with token:: $token1"
response_all=$(curl -s -X GET 'https://192.168.1.92:2023/TFM_ric' -H "Authorization: $token1" --cacert "ca.pem")
echo "API Response:"
echo "$response_all"
###
token2=$(curl -s -X POST -H "Content-Type: application/json" -d '{"client_id":"user1","client_secret":"Password123"}' http://192.168.1.65:2000/generateToken | jq -r '.access_token')
echo "For user1 Making API request with token:: $token2"
response_ipas=$(curl -s -X GET "https://192.168.1.92:2023/TFM_ric?ip_address=192.168.1.5:8088" -H "Authorization: $token2" --cacert "ca.pem")
echo "API Response:"
echo "$response_ipas"
###
token3=$(curl -s -X POST -H "Content-Type: application/json" -d '{"client_id":"user2","client_secret":"Password123"}' http://192.168.1.65:2000/generateToken | jq -r '.access_token')
echo "For user2 making API request with token:: $token3"
response_msisdn=$(curl -s -X GET "https://192.168.1.92:2023/TFM_ric?ip_address=192.168.1.5:8088" -H "Authorization: $token3" --cacert "ca.pem")
echo "API Response:"
echo "$response_msisdn"