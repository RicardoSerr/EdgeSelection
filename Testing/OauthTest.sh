#!/bin/bash

# Function to test a valid request
printf "==============================\n"
echo "TEST CASE: CORRECT REQUEST"
## Function to send a POST request to generate a token
echo "Generating token..."
curl_output=$(curl -s -X POST -H "Content-Type: application/json" -d '{"client_id":"ricardoSerrano","client_secret":"Telefonica123"}' http://192.168.1.65:2000/generateToken)
echo "Response:"
echo "$curl_output"
Token=$(echo "$curl_output" | jq -r '.access_token')  # Extracting the access_token from the response using 'jq'
## Function to send a POST request to check the token
echo "Checking token..."
echo "Using Token: $Token"
curl_output=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"access_token\": \"$Token\", \"requested_url\": \"https://192.168.1.92:2023/SimpleEdge\"}" http://192.168.1.65:2000/checkToken)
echo "Response:"
echo "$curl_output"

# Function to test if the token can be reused
printf "==============================\n"
echo "TEST CASE: REUSING TOKEN"
## Function to send a POST request to check the token
echo "Checking token..."
echo "Using Token: $Token"
curl_output=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"access_token\": \"$Token\", \"requested_url\": \"https://192.168.1.92:2023/SimpleEdge\"}" http://192.168.1.65:2000/checkToken)
echo "Response:"
echo "$curl_output"

# Function to test trying a forbiden URL
printf "==============================\n"
echo "TEST CASE: Forbidden URL"
## Function to send a POST request to generate a token
echo "Generating token..."
curl_output=$(curl -s -X POST -H "Content-Type: application/json" -d '{"client_id":"user1","client_secret":"Password123"}' http://192.168.1.65:2000/generateToken)
echo "Response:"
echo "$curl_output"
Token=$(echo "$curl_output" | jq -r '.access_token')
## Function to send a POST request to check the token
echo "Checking token..."
echo "Using Token: $Token"
curl_output=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"access_token\": \"$Token\", \"requested_url\": \"https://192.168.1.92:2023/adminEdgeSites\"}" http://192.168.1.65:2000/checkToken)
echo "Response:"
echo "$curl_output"
