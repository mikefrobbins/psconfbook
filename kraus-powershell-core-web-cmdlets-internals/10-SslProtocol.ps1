# Endpoint that only supports TLS 1.0
$Uri = 'https://tls-v1-0.badssl.com:1010'
# Make TLS 1.2 the only acceptable protocol so the command fails
Invoke-WebRequest -Uri $Uri -SslProtocol 'Tls12'