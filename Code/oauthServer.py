from flask import Flask, jsonify, request
import json
import secrets
import re
import atexit
import os

app = Flask(__name__)

# URL Patterns for resource access segmentation
allEdges_pattern = r'https://192\.168\.1\.92:2023/SimpleEdge'
admin_pattern = r'https://192\.168\.1\.92:2023/adminEdgeSites'
msisdn_pattern = r'https://192\.168\.1\.92:2023/SimpleEdge\?msisdn=\d{11}'
ipadr_pattern = r'https://192\.168\.1\.92:2023/SimpleEdge\?ip_address=\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d{1,4}'

# Tokens file path
TOKENS_FILE = 'tokens.json'

# User List examples
users_credentials = [
    {
        'client_id': 'ricardoSerrano',
        'client_secret': 'Telefonica123',
        'allowed_urls': [allEdges_pattern, msisdn_pattern, ipadr_pattern, admin_pattern]
    },
    {
        'client_id': 'user1',
        'client_secret': 'Password123',
        'allowed_urls': [msisdn_pattern, allEdges_pattern]
    },
    {
        'client_id': 'user2',
        'client_secret': 'Password123',
        'allowed_urls': [ipadr_pattern, allEdges_pattern]
    }
]

# Load existing tokens from the JSON file if file does not exists, creates it
def load_tokens():
    try:
        with open(TOKENS_FILE, 'r') as file:
            return json.load(file)
    except FileNotFoundError:
        return {}

# Save tokens to the JSON file
def save_tokens(tokens):
    with open(TOKENS_FILE, 'w') as file:
        json.dump(tokens, file, indent=4)

@app.route('/checkToken', methods=['POST'])
def check_token():
    access_token = request.json.get('access_token')
    url_to_access = request.json.get('requested_url')
    print("Readed URL:", url_to_access)

    # Load existing tokens from the JSON file
    tokens = load_tokens()

    # Check if the token exists in the tokens dictionary
    if access_token in tokens:
        client_id = tokens[access_token]

        # Check if the user is authorized to access the requested URL
        for user in users_credentials:
            if user['client_id'] == client_id:
                for allowed_url_pattern in user['allowed_urls']:
                    if re.match(allowed_url_pattern, url_to_access):
                        # Remove the used token from the tokens dictionary
                        del tokens[access_token]
                        save_tokens(tokens)  # Save the updated tokens to the JSON file
                        return jsonify({'message': f'Access granted to {url_to_access}'}), 200

        # If the URL doesn't match any allowed URL pattern for the user
        return jsonify({'error': 'Access denied. Insufficient priviledges or invalid URL parameters.'}), 403
    else:
        return jsonify({'error': 'Invalid token'}), 401

@app.route('/generateToken', methods=['POST'])
def generate_token():
    data = request.json
    client_id = data.get('client_id')
    client_secret = data.get('client_secret')

    # Check if the provided credentials match any user in the list
    if any(user['client_id'] == client_id and user['client_secret'] == client_secret for user in users_credentials):
        # Load existing tokens or create an empty dictionary
        tokens = load_tokens()

        # Remove any existing token associated with the user
        existing_tokens = [token for token, user_id in tokens.items() if user_id == client_id]
        for existing_token in existing_tokens:
            del tokens[existing_token]

        # Generate access token
        access_token = secrets.token_hex(16)

        # Store the generated token
        tokens[access_token] = client_id

        # Save the updated tokens to the JSON file
        save_tokens(tokens)

        return jsonify({'access_token': access_token}), 200
    else:
        return jsonify({'error': 'Invalid client credentials'}), 401


# Delete Tokens file when the program ends
@atexit.register
def delete_tokens_file():
    try:
        os.remove(TOKENS_FILE)
    except FileNotFoundError:
        pass

if __name__ == '__main__':
    app.run(host='192.168.1.65', port=2000)
