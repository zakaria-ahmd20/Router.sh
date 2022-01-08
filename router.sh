!/bin/bash
cp /etc/network/interfaces /etc/network/interfaces.bak
cp /etc/resolv.conf /etc/resolv.conf.bak
cp /etc/nftables.conf /etc/nftables.conf.bak
cp /etc/sysctl.conf /etc/sysctl.conf.bak


# first create all backups ^^
# if vm uses NAT then we will use dhcp if not then we will have to configure a GW
echo " Does this GW use NAT, if yes , type yes"
read Var
if [[  $Var == 'yes'  ]]
then

    echo 'enter your ip address'

    read ip

    echo "auto ens33
    iface enp0s3 inet dhcp

    auto ens37
    iface ens37 inet static
      address $ip' " > /etc/network/interfaces

    echo 'nameserver 8.8.8.8' > /etc/resolv.conf

    #set up name server
    touch filex.nft

    # set up ip forwarding
    nft flush ruleset
    echo 'table inet router {
            chain route {
                    type nat hook postrouting priority filter; policy accept;
                    oifname "ens33" counter masquerade
            }
    }' > /root/filex

    nft -f filex
    nft list ruleset > /etc/nftables.conf
    systemctl enable nftables
    #enable ip forwarding
    sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf


    reboot
else

    echo 'enter your first  ip address'

    read ip
    echo 'enter your second ip address'
    read ip2
    echo 'enter your gateway ip'
    read gw

    echo "auto ens33
    iface ens33 inet static
      address $ip
      gateway $gw
    auto ens37
    iface ens37 inet static
      address $ip2' " > /etc/network/interfaces

    echo 'nameserver 8.8.8.8' > /etc/resolv.conf

    #set up name server
    touch filex.nft

    # set up ip forwarding
    nft flush ruleset
    echo 'table inet router {
            chain route {
                    type nat hook postrouting priority filter; policy accept;
                    oifname "ens33" counter masquerade
            }
    }' > /root/filex

    nft -f filex
    nft list ruleset > /etc/nftables.conf
    systemctl enable nftables
    #enable ip forwarding
    sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf


    reboot

    fi
