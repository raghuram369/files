uci set network.vpn0="interface"
uci set network.vpn0.ifname="tun0"
uci set network.vpn0.proto="none"
uci set network.vpn0.auto="1"
uci commit network

uci delete firewall.allow_openVPN_inbound
uci delete firewall.vpn
uci delete firewall.vpn_lan
uci delete firewall.vpn_wan

uci commit firewall

uci set firewall.allow_openVPN_inbound=rule
uci set firewall.allow_openVPN_inbound.target='ACCEPT'
uci set firewall.allow_openVPN_inbound.src='wan'
uci set firewall.allow_openVPN_inbound.proto='udp'
uci set firewall.allow_openVPN_inbound.dest_port='1194'
uci set firewall.allow_openVPN_inbound.family='ipv4'
uci set firewall.allow_openVPN_inbound.name='Allow OpenVPN'

uci set firewall.vpn=zone
uci set firewall.vpn.input='ACCEPT'
uci set firewall.vpn.forward='ACCEPT'
uci set firewall.vpn.output='ACCEPT'
uci set firewall.vpn.masq='1'
uci set firewall.vpn.network='vpn0'

uci set firewall.vpn_wan=forwarding
uci set firewall.vpn_wan.src='vpn'
uci set firewall.vpn_wan.dest='wan'

uci set firewall.vpn_lan=forwarding
uci set firewall.vpn_lan.src='vpn'
uci set firewall.vpn_lan.dest='lan'
uci commit firewall

echo "deleting openvpn config"

uci delete openvpn.vcpe

echo "adding openvpn config"
uci set openvpn.vcpe=openvpn

uci set openvpn.vcpe.enabled='1'
uci set openvpn.vcpe.dev='tun'
uci set openvpn.vcpe.port='1194'
uci set openvpn.vcpe.proto='udp'
uci set openvpn.vcpe.status='/var/log/openvpn_status.log'
uci set openvpn.vcpe.log='/tmp/openvpn.log'
uci set openvpn.vcpe.verb='3'
uci set openvpn.vcpe.mute='5'
uci set openvpn.vcpe.mssfix='1200'
uci set openvpn.vcpe.keepalive='10 120'
uci set openvpn.vcpe.persist_key='1'
uci set openvpn.vcpe.persist_tun='1'
uci set openvpn.vcpe.user='nobody'
uci set openvpn.vcpe.group='nogroup'
uci set openvpn.vcpe.ca='/etc/openvpn/ca.crt'
uci set openvpn.vcpe.cert='/etc/openvpn/vcpe.crt'
uci set openvpn.vcpe.key='/etc/openvpn/vcpe.key'
uci set openvpn.vcpe.dh='/etc/openvpn/dh2048.pem'
uci set openvpn.vcpe.mode='server'
uci set openvpn.vcpe.tls_server='1'
uci set openvpn.vcpe.server='10.8.0.0 255.255.255.0'
uci set openvpn.vcpe.topology='subnet'
uci set openvpn.vcpe.client_to_client='1'
#uci set openvpn.vcpe.tls_auth='/etc/openvpn/ta.key 0'
uci add_list openvpn.vcpe.push='redirect-gateway def1'
uci add_list openvpn.vcpe.push='persist-key'
uci add_list openvpn.vcpe.push='persist-tun'
uci set openvpn.vcpe.comp_lzo='no'
uci set openvpn.vcpe.ccd_exclusive='1'
uci set openvpn.vcpe.client_config_dir='/etc/openvpn/clients/'

uci commit openvpn
rm /etc/openvpn/clients/*
mkdir -p /etc/openvpn/clients
cat > /etc/openvpn/clients/chetan.gopal@verizon.com <<- "EOF"
iroute "192.168.10.0 255.255.255.0"
EOF


cat > /etc/openvpn/clients/ravi.chunduru@verizon.com <<- "EOF"
iroute "192.168.20.0 255.255.255.0"
EOF

/etc/init.d/openvpn reload
