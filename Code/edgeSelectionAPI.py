# -*- coding: utf-8 -*-
"""
Implementation of the Cloud Edge CAMARA API 
- Edge Discovery: Based in network topology
https://github.com/camaraproject/EdgeCloud

Author: Ricardo Serrano 
"""

from flask import Flask, jsonify, request
import requests
import json
import ssl

app = Flask(__name__)

# Function to verify the token with the prototype Oauth Server
def verify_token(token, req_url):
    oauth_server_url = 'http://10.0.0.65:2000/checkToken'
    headers = {'Content-Type': 'application/json'}  # Specify the file type
    payload = {'access_token': token, 'requested_url': req_url}

    response = requests.post(oauth_server_url, json=payload, headers=headers)
    print(headers, payload, response)
    
    if response.status_code == 200:
        # If Token is valid return True and no error code
        return True, None
    else:
        error_message = response.json().get('error')
        return False, {'code': response.status_code, 'message': error_message}
    
# Function to create a response entry structure
def create_response_entry(entry):
    return {
        'Provider': 'Telefonica',
        'Ern': entry['EdgeNode'],
        'Ern IP': entry['EdgeNode IP'],
        'NAS-id': entry['NAS-id']        
    }

# Mapping status codes to error messages
ERROR_MESSAGES = {
    400: {'code': 'INVALID_ARGUMENT', 'error': 'Invalid Header Format'},
    401: {'code': 'UNAUTHENTICATED', 'error': 'Unauthorized'},
    403: {'code': 'PERMISSION_DENIED', 'error': 'Forbidden'},
    404: {'code': 'NOT_FOUND', 'error': 'Subscriber Not Found'},
    405: {'code': 'METHOD_NOT_ALLOWED', 'error': 'Method Not Allowed'},
    406: {'code': 'NOT_ACCEPTABLE', 'error': 'Not Acceptable'},
    429: {'code': 'TOO_MANY_REQUESTS', 'error': 'Too Many Requests'},
    500: {'code': 'INTERNAL', 'error': 'Internal Server Error'},
    502: {'code': 'BAD_GATEWAY', 'error': 'Bad Gateway'},
    503: {'code': 'UNAVAILABLE', 'error': 'Service Unavailable'},
    504: {'code': 'TIMEOUT', 'error': 'Gateway Timeout'},
}

@app.route('/TFM_ric', methods=['GET'])
def get_edge_node_ip():
    # Token obtained from the Headers
    token = request.headers.get('Authorization')

    # Parameters from the actual request
    req_url = request.url 
    msisdn = request.args.get('msisdn')
    ip_address = request.args.get('ip_address')

    # Verify if the token is valid and if the user has access to the requested URL
    is_valid_token, error_info = verify_token(token, req_url)

    # If the token is not valid return the error codes
    if not is_valid_token:
        if error_info:
            error_code = error_info.get('code')
            error_message = error_info.get('message')
            return jsonify({error_code: {'code': error_code, 'error': error_message}}), int(error_code)
        else:
            return jsonify({401: {'code': ERROR_MESSAGES[401]['code'], 'error': ERROR_MESSAGES[401]['error']}}), 401

    # If neither msisdn nor ip_address is provided
    if not msisdn and not ip_address:  
        with open('dataseed.json', 'r') as file:
            all_entries = json.load(file)['data']
            # Return all EdgeNode and EdgeNode IP entries
            all_edge_nodes = {entry['EdgeNode']: entry['EdgeNode IP'] for entry in all_entries}
            return jsonify(all_edge_nodes)

    if msisdn or ip_address:
        # Requesting data based on provided msisdn or ip_address
        if msisdn:
            url = f'https://10.0.0.92:8080/services/2SSL/REST/UserProfile/PerfilComercialExt?msisdn={msisdn}&attribute=NAS-id'
        else:
            url = f'https://10.0.0.92:8080/services/2SSL/REST/UserProfile/PerfilComercialExt?IpAddr={ip_address}&attribute=NAS-id'

        response = requests.get(url, verify=False)

        # Handling different response status codes
        if response.status_code == 200:
            dg_response_data = response.json()
            operation_result_code = dg_response_data.get('operationResultCode')

            if operation_result_code == "00":
                nas_id = dg_response_data['Attributes'][0]['NAS-id']

                with open('dataseed.json', 'r') as file:
                    dataseed_response_data = json.load(file)

                for entry in dataseed_response_data['data']:
                    if entry['NAS-id'] == nas_id:
                        # Create response entry with additional details
                        response_entry = create_response_entry(entry)
                        return jsonify(response_entry)

                return jsonify({'error': 'No device found for the specified parameters.'}), 404
                
            else:
                return jsonify({404: {'error': 'DATAGRID INTERNAL ERROR: Device not found', 'code': operation_result_code}}), 404

        elif response.status_code in ERROR_MESSAGES:
            error_info = ERROR_MESSAGES[response.status_code]
            return jsonify({'code': error_info['code'], 'status': response.status_code, 'error': error_info['error']}), response.status_code

        else:
            return jsonify({'code': 'UNKNOWN_ERROR', 'status': response.status_code, 'error': 'An unknown error occurred.'}), response.status_code

    return jsonify({'error': 'Provide either msisdn or ip_address.'}), 400

if __name__ == '__main__':
    context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    context.load_cert_chain('/home/testmec/SSL/intent3/cert.pem', '/home/testmec/SSL/intent3/cert-key.pem')
    context.load_verify_locations('/home/testmec/SSL/intent3/ca.pem')

    app.run(host='10.0.0.1', port=2023, ssl_context=context, debug=True)
