## OpenVPN User Guide

Liên hệ với admin để được cấp file client config
+ username.ovpn
+ private key password

### OpenVPN Client trên Windows

Download OpenVPN Connect tại trang chủ: https://openvpn.net/client/client-connect-vpn-for-windows/

Sau khi cài xong màn hình sẽ hiển thị như sau, bấm Import và chọn tệp username.ovpn thả vào đây

![](https://openvpn.net/wp-content/uploads/connect-02.png)

Sau đó server sẽ yêu cầu nhập private key password (được cung cấp từ admin)
+ Nếu đúng sẽ connect thành công vào VPN
+ Nếu sai sẽ báo *Client Authentication Failed* -> liên hệ admin để giải quyết

![](https://openvpn.net/wp-content/uploads/connect-04.png)

### OpenVPN Client trên Linux

Tham khảo hướng dẫn tại trang chủ: https://openvpn.net/openvpn-client-for-linux/

```
apt install apt-transport-https curl
```

Retrieve the OpenVPN Inc package signing key

```
mkdir -p /etc/apt/keyrings && curl -fsSL https://swupdate.openvpn.net/repos/repo-public.gpg | gpg --dearmor > /etc/apt/keyrings/openvpn-repo-public.gpg
```

Set up the apt source

```
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/openvpn-repo-public.gpg] http://build.openvpn.net/debian/openvpn/release/2.5 focal main" > /etc/apt/sources.list.d/openvpn-aptrepo.list
```

Install OpenVPN

```
apt-get update && apt-get install openvpn=2.5.7-focal0
```

Connect using client config file

```
openvpn username.ovpn
```

### OpenVPN Client trên MacOSS

Download OpenVPN Connect tại trang chủ: https://openvpn.net/client-connect-vpn-for-mac-os/

Các bước thực hiện tương tự trên Windows

![](https://openvpn.net/wp-content/uploads/connect-04.png)
