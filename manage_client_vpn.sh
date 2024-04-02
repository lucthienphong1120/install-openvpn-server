#!/bin/bash

# Kiểm tra xem script được chạy với quyền root hay không
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Help function
print_help() {
    echo "Usage: $0 {option} [username]"
    echo "Options:"
    echo "  -h, --help: Print help"
    echo "  -n, --new: Create new user"
    echo "  -l, --list: List all users"
    echo "  -d, --delete: Delete user"
    exit 1
}

# Get username argument
client_name=$2

new_user() {
# Define ca passphrase and client password
ca_passphrase="ps"
client_pass=$(/usr/bin/pwgen -sy 16 | awk {'print $0'})

# Get server ip
if [ ! -f "ip.txt" ]; then
    echo "Khong tim thay file ip.txt de cau hinh"
    echo "Hay tao file ip.txt chua thong tin ip server OpenVPN"
    exit 1
else
    server_ip=$(<"/root/ip.txt")
fi

# Get client name
if [[ $client_name == "" ]]; then
    read -p "Nhập tên người dùng: " client_name
fi

echo "Creating user: $client_name"

echo "----------"
cd /etc/easy-rsa

./easyrsa --batch --req-cn=$client_name --passout=pass:$client_pass gen-req $client_name -y

./easyrsa --batch --passin=pass:$ca_passphrase sign-req client $client_name

mkdir -p /etc/openvpn/client/$client_name
cp -rp /etc/easy-rsa/pki/{ca.crt,ta.key,issued/$client_name.crt,private/$client_name.key} /etc/openvpn/client/$client_name

tls_file="/etc/openvpn/client/$client_name/ta.key"
ca_file="/etc/openvpn/client/$client_name/ca.crt"
cert_file="/etc/openvpn/client/$client_name/$client_name.crt"
key_file="/etc/openvpn/client/$client_name/$client_name.key"

echo $client_pass > "/etc/openvpn/client/$client_name/$client_name.pwd"

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
echo "$client_pass" > /root/client_vpn/$client_name/$client_name.pwd

echo "----------"
echo "done"
}

list_user() {
    # Lấy danh sách các file trong thư mục reqs và hiển thị ra màn hình
    file_list=$(ls /root/client_vpn/*/*.ovpn 2>/dev/null)

    if [ -z "$file_list" ]; then
        echo "Không có user nào được tạo."
    else
        echo "Danh sách các user vpn được tạo:"
        count=1
        for file in $file_list; do
            client_name=$(basename "$file" .ovpn)
            password=$(cat /etc/openvpn/client/$client_name/$client_name.pwd)
            echo "$count. $client_name:$password"
            ((count++))
        done
    fi
}

delete_user() {
    # Get client name
    if [[ $client_name == "" ]]; then
        read -p "Nhập tên người dùng: " client_name
    fi

    # Kiểm tra xem cert của user đã tồn tại hay chưa?
    if [ ! -f "/root/client_vpn/$client_name/$client_name.ovpn" ]; then
        echo "Cert cho user $client_name khong ton tai"
        exit 1
    else
        echo "Bạn đã chọn xóa các tệp cho người dùng: $client_name"
    fi

    # Xóa các tệp cho người dùng
    rm -rf "/root/client_vpn/${client_name}"
    rm -rf "/etc/openvpn/client/${client_name}"
    rm -rf "/etc/easy-rsa/pki/private/${client_name}.key"
    rm -rf "/etc/easy-rsa/pki/issued/${client_name}.crt"
    rm -rf "/etc/easy-rsa/pki/reqs/${client_name}.req"

    echo "Đã xóa các tệp cho người dùng: $client_name"
}

# Check parse arguments
case "$1" in
    "-h" | "--help")
        print_help
    ;;
    "-n" | "--new")
        echo "Usage: $0 $1 [username]"
        new_user
    ;;
    "-l" | "--list")
        list_user
    ;;
    "-d" | "--delete")
        echo "Usage: $0 $1 [username]"
        delete_user
    ;;
    *)
        print_help
    ;;
esac
