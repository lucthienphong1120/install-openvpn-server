#!/bin/bash

# Kiểm tra xem script được chạy với quyền root hay không
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Nhập tên người dùng
read -p "Nhập tên người dùng: " username

# Kiểm tra xem cert của user đã tồn tại hay chưa?

if [ ! -f "/root/client_vpn/$username/$username.ovpn" ]; then
	echo "Cert cho user $username khong ton tai"
	exit 1
fi
echo "Bạn đã chọn xóa các tệp cho người dùng: $username"

# Xóa các tệp cho người dùng
rm -rf "/root/client_vpn/${username}"
rm -rf "/etc/openvpn/client/${username}"
rm -rf "/etc/easy-rsa/pki/private/${username}.key"
rm -rf "/etc/easy-rsa/pki/issued/${username}.crt"
rm -rf "/etc/easy-rsa/pki/reqs/${username}.req"

echo "Đã xóa các tệp cho người dùng: $username"

