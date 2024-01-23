#!/bin/bash

# Function to send a POST request to generate a token
printf "==============================\n"
echo "Generating token..."
curl_output=$(curl -s -X POST -H "Content-Type: application/json" -d '{"client_id":"ricardoSerrano","client_secret":"Telefonica123"}' http://192.168.1.65:2000/generateToken)
echo "Response:"
echo "$curl_output"
Token=$(echo "$curl_output" | jq -r '.access_token')  # Extracting the access_token from the response using 'jq' (assuming it's a JSON response)
echo "$Token"
# Function to send a POST request to check the token
printf "==============================\n"
echo "Checking token..."
echo "Using Token: $Token"
curl_output=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"access_token\": \"$Token\"}" http://192.168.1.65:2000/checkToken)
echo "Response:"
echo "$curl_output"
