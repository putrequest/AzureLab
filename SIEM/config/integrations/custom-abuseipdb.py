#!/var/ossec/framework/python/bin/python3
import sys
import json
import requests
from socket import socket, AF_UNIX, SOCK_DGRAM

alert_file = open(sys.argv[1])
api_key = sys.argv[2]
alert = json.loads(alert_file.read())
alert_file.close()

srcip = alert.get("data", {}).get("srcip")
if not srcip:
    sys.exit(0)

url = "https://api.abuseipdb.com/api/v2/check"
headers = {"Accept": "application/json", "Key": api_key}
params = {"ipAddress": srcip, "maxAgeInDays": "90"}

response = requests.get(url, headers=headers, params=params)
if response.status_code == 200:
    data = response.json().get("data", {})
    score = data.get("abuseConfidenceScore", 0)
    if score > 25:
        msg = json.dumps({
            "integration": "abuseipdb",
            "abuseipdb": {
                "found": 1,
                "source_ip": srcip,
                "abuse_confidence_score": score,
                "country": data.get("countryCode"),
                "isp": data.get("isp")
            }
        })
        sock = socket(AF_UNIX, SOCK_DGRAM)
        sock.connect("/var/ossec/queue/sockets/queue")
        sock.send(f"1:abuseipdb:{msg}".encode())
        sock.close()