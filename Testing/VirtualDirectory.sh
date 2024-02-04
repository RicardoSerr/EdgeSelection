#!/bin/bash

VIRTUAL_DIRECTORY_IPPORT="0.0.0.0:10" # To be replaced by the Virtual Directory IP 
AVAILABLE_MSISDN="34XXXXXX" # To be replaced by a valid MSISDN
AVAILABLE_IPADDR="X.X.X.X:Y" # To be replaced by a valid IP Addr
UNAVAILABLE_MSISDN="1234"

printf "==============================\n"
echo "TEST CASE: No Parameters"
url_no_parameters="https://$VIRTUAL_DIRECTORY_IPPORT/services/2SSL/REST/UserProfile/PerfilComercialExt"
curl_output_no_parameters=$(curl -s -X GET "$url_no_parameters" --cacert 'ca.pem')
echo "Response:"
echo "$curl_output_no_parameters"
printf "==============================\n"

echo "TEST CASE: Request NAS-ID using MSISDN"
url_msisdn="https://$VIRTUAL_DIRECTORY_IPPORT/services/2SSL/REST/UserProfile/PerfilComercialExt?msisdn=$AVAILABLE_MSISDN&attribute=NAS-id"
curl_output_msisdn=$(curl -s -X GET "$url_msisdn" --cacert 'ca.pem')
echo "Response:"
echo "$curl_output_msisdn"
printf "==============================\n"

echo "TEST CASE: Request NAS-ID using IP"
url_ip="https://$VIRTUAL_DIRECTORY_IPPORT/services/2SSL/REST/UserProfile/PerfilComercialExt?IpBAM=$AVAILABLE_IPADDR&attribute=NAS-id"
curl_output_ip=$(curl -s -X GET "$url_ip" --cacert 'ca.pem')
echo "Response:"
echo "$curl_output_ip"
printf "==============================\n"

echo "TEST CASE: Request NAS-ID using wrong MSISDN"
url_wrong_msisdn="https://$VIRTUAL_DIRECTORY_IPPORT/services/2SSL/REST/UserProfile/PerfilComercialExt?msisdn=$UNAVAILABLE_MSISDN&attribute=NAS-id"
curl_output_wrong_msisdn=$(curl -s -X GET "$url_wrong_msisdn" --cacert 'ca.pem')
echo "Response:"
echo "$curl_output_wrong_msisdn"
printf "==============================\n"

echo "TEST CASE: Unavailable attributes"
url_unavailable_attributes="https://$VIRTUAL_DIRECTORY_IPPORT/services/2SSL/REST/UserProfile/PerfilComercialExt?msisdn=$AVAILABLE_MSISDN&attribute=random"
curl_output_unavailable_attributes=$(curl -s -X GET "$url_unavailable_attributes" --cacert 'ca.pem')
echo "Response:"
echo "$curl_output_unavailable_attributes"
printf "==============================\n"
