#!/bin/bash

# Lấy danh sách các file trong thư mục reqs và hiển thị ra màn hình
file_list=$(ls /root/client_vpn/*/*.ovpn 2>/dev/null)

if [ -z "$file_list" ]; then
    echo "Không có user nào được tạo."
else
    echo "Danh sách các user vpn được tạo:"
    count=1
    for file in $file_list; do
        client_name=$(basename "$file" .ovpn)
        echo "$count. $client_name"
        ((count++))
    done
fi
