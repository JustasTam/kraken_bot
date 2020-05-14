# Import required Python libraries
import sys
import time
import base64
import hashlib
import hmac

# Decode API private key from base64 format displayed in account management
api_secret = base64.b64decode(sys.argv[1])

# Variables (API method, nonce, and POST data)
api_path = sys.argv[2]
api_nonce = str(int(time.time()*1000))
api_post = "nonce=" + api_nonce + "&asset=xbt"

# Cryptographic hash algorithms
api_sha256 = hashlib.sha256(api_nonce + api_post).digest()
api_hmac = hmac.new(api_secret, api_path + api_sha256, hashlib.sha512)

# Encode signature into base64 format used in API-Sign value
api_signature = base64.b64encode(api_hmac.digest())

# API authentication signature for use in API-Sign HTTP header
print api_signature