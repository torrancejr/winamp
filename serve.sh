#!/bin/bash
cd "$(dirname "$0")"

# Generate self-signed cert if not present
if [ ! -f cert.pem ]; then
  echo "Generating self-signed SSL certificate..."
  openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes \
    -subj "/CN=localhost" 2>/dev/null
  echo "Certificate generated."
fi

echo ""
echo "WinampEQ running at https://localhost:8888"
echo "Press Ctrl+C to stop"
echo ""

python3 -c "
import http.server, ssl, os
os.chdir('$(pwd)')
ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ctx.load_cert_chain('cert.pem', 'key.pem')
server = http.server.HTTPServer(('localhost', 8888), http.server.SimpleHTTPRequestHandler)
server.socket = ctx.wrap_socket(server.socket, server_side=True)
server.serve_forever()
"
