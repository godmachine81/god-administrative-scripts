
#!/bin/bash
#Clear old iptables and nat rules  (flush)
 iptables -F
 iptables -t nat -F

#Create Input, Output, and Forward Chains
 iptables -P INPUT ACCEPT
 iptables -P OUTPUT ACCEPT
 iptables -P FORWARD DROP

#Set variables for the local interfaces
 export LAN=eth0
 export WAN=wlan0

#Accept traffic from the LAN and Loopback interface
 iptables -I INPUT 1 -i ${LAN} -j ACCEPT
 iptables -I INPUT 1 -i lo -j ACCEPT
# iptables -A INPUT -p UDP --dport bootps ! -i ${LAN} -j REJECT
# iptables -A INPUT -p UDP --dport domain ! -i ${LAN} -j REJECT

#Drop TCP / UDP packets to privileged ports
# iptables -A INPUT -p TCP ! -i ${LAN} -d 0/0 --dport 0:1023 -j DROP
# iptables -A INPUT -p UDP ! -i ${LAN} -d 0/0 --dport 0:1023 -j DROP

#NAT RULES
 iptables -I FORWARD -i ${LAN} -d 192.168.0.0/255.255.0.0 -j DROP
 iptables -A FORWARD -i ${LAN} -s 192.168.0.0/255.255.0.0 -j ACCEPT
 iptables -A FORWARD -i ${WAN} -d 192.168.0.0/255.255.0.0 -j ACCEPT
 iptables -t nat -A POSTROUTING -o ${WAN} -j MASQUERADE

#Add Ports to open for Chad's Torrents
#First his Desktop (port 12345)
iptables -t nat -A PREROUTING -p tcp --dport 12345 -i ${WAN} -j DNAT --to 192.168.0.21
iptables -t nat -A PREROUTING -p udp --dport 12345 -i ${WAN} -j DNAT --to 192.168.0.21

#Second his Laptop (port 23456)
iptables -t nat -A PREROUTING -p tcp --dport 23456 -i ${WAN} -j DNAT --to 192.168.0.22
iptables -t nat -A PREROUTING -p udp --dport 23456 -i ${WAN} -j DNAT --to 192.168.0.22

#Enable Forwarding
 echo 1 > /proc/sys/net/ipv4/ip_forward
 for f in /proc/sys/net/ipv4/conf/*/rp_filter ; do echo 1 > $f ; done

#Save the rules so this script doesn't have to be ran each time 
 /etc/init.d/iptables save
