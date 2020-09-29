#!/bin/sh
##### SCRIPT PARAMETERS #####
USR=`find /home/*/.local/share/nucypher/ -type f -name ursula.json | awk -F "/" '{print $3}'`
if [ -z "$USR" ]; then
   USR1="root"
   HOME1="/root"
else
   USR1=$USR
   HOME1="/home/$USR"
fi
IPC="$HOME1/.ethereum/geth.ipc"
STAKERADDRESS=`cat $HOME1/.local/share/nucypher/ursula.json | jq .checksum_address| tr -d '"'`
crontab -l | { cat; echo "*/5 * * * * su $USR1 -c 'cd ~ nucypher status stakers --provider ~/.ethereum/geth.ipc > /tmp/nucypher.tmp && cp /tmp/nucypher.tmp /tmp/nucypher.txt'"; } | crontab -
crontab -l | { cat; echo "*/5 * * * * su $USR1 -c 'cd ~ nucypher worklock status --provider ~/.ethereum/geth.ipc --bidder-address $STAKERADDRESS > /tmp/worklock.tmp && cp /tmp/worklock.tmp /tmp/worklock.txt'"; } | crontab -
mkdir -p /etc/zabbix/scripts
curl -s https://raw.githubusercontent.com/dmirgaleev/nucypher_zabbix/master/geth.sh > /etc/zabbix/scripts/geth.sh
curl -s https://raw.githubusercontent.com/dmirgaleev/nucypher_zabbix/master/nucypher-stats.sh > /etc/zabbix/scripts/nucypher-stats.sh
curl -s https://raw.githubusercontent.com/dmirgaleev/nucypher_zabbix/master/nucypher-version.sh > /etc/zabbix/scripts/nucypher-version.sh
curl -s https://raw.githubusercontent.com/dmirgaleev/nucypher_zabbix/master/worklock.sh > /etc/zabbix/scripts/worklock.sh
curl -s https://raw.githubusercontent.com/dmirgaleev/nucypher_zabbix/master/nucypher.conf > /etc/zabbix/zabbix_agentd.d/nucypher.conf
chmod 700 /etc/zabbix/scripts/*.sh
service zabbix-agent restart
service zabbix-agent status
exit 0
