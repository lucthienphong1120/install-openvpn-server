server_ip=$(<"/root/ip.txt")
read -p "Nhập tên người dùng: " client_name

cd /etc/easy-rsa

# ./easyrsa gen-req $client_name nopass
./easyrsa gen-req $client_name
# -> enter client private key password

./easyrsa sign-req client $client_name
# -> enter CA passphrase

mkdir -p /etc/openvpn/client/$client_name
cp -rp /etc/easy-rsa/pki/{ca.crt,ta.key,issued/$client_name.crt,private/$client_name.key} /etc/openvpn/client/$client_name

tls_file="/etc/openvpn/client/$client_name/ta.key"
ca_file="/etc/openvpn/client/$client_name/ca.crt"
cert_file="/etc/openvpn/client/$client_name/$client_name.crt"
key_file="/etc/openvpn/client/$client_name/$client_name.key"

ovpn_content=$(cat <<EOF
# Specify that we are a client
client
# Use the same setting as you are using
dev tun
proto udp
# The hostname/IP and port of the server.
remote $server_ip 1194
# Keep trying indefinitely to resolve
resolv-retry infinite
# Most clients don't need to bind
nobind
# Downgrade privileges after initialization (non-Windows only)
user nobody
group nobody
# Try to preserve some state across restarts
persist-key
persist-tun
# Verify server certificate
remote-cert-tls server
key-direction 1
cipher AES-256-CBC
verb 3
<ca>
$(cat "$ca_file")
</ca>
<cert>
$(cat "$cert_file")
</cert>
<key>
$(cat "$key_file")
</key>
<tls-crypt>
$(cat "$tls_file")
</tls-crypt>
EOF
)

mkdir -p /root/client_vpn/$client_name
echo "$ovpn_content" > /root/client_vpn/$client_name/$client_name.ovpn
