#!/bin/bash

path=$(dirname "$0")

# Accept multiple IPs as arguments
IEM_IPS=("$@")

mkdir -p "${path}/out"

# Generate the CA key and certificate
openssl genrsa -out "${path}/out/myCA.key" 4096
openssl req -x509 -new -nodes -key "${path}/out/myCA.key" -sha256 -days 825 -out "${path}/out/myCA.crt" -config "${path}/ca.conf"

# Generate the certificate key
openssl genrsa -out "${path}/out/myCert.key" 4096

# Create a SAN configuration with multiple IPs
san_config="[alt_names]"
for i in "${!IEM_IPS[@]}"; do
  san_config+="\nIP.$((i + 1))=${IEM_IPS[i]}"
done

# Generate the CSR
openssl req -new -key "${path}/out/myCert.key" -out "${path}/out/myCert.csr" \
  -subj "/C=DE/ST=Dummy/L=Dummy/O=Dummy/CN=${IEM_IPS[0]}" \
  -config <(cat "${path}/cert.conf" <(printf "\\n%s" "$san_config"))

# Sign the certificate with the CA
openssl x509 -req -in "${path}/out/myCert.csr" -CA "${path}/out/myCA.crt" -CAkey "${path}/out/myCA.key" \
  -CAcreateserial -out "${path}/out/myCert.crt" -days 825 -sha256 \
  -extfile <(cat "${path}/cert-ext.conf" <(printf "\\n%s" "$san_config"))

# Combine the certificate and CA chain
cat "${path}/out/myCert.crt" "${path}/out/myCA.crt" > "${path}/out/certChain.crt"

# Cleanup and copy the certificate
rm "${path}/out/myCert.csr"
cp "${path}/out/myCert.crt" "${path}/out/certChain.crt" "$(pwd)/"
