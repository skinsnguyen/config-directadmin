#!/bin/sh

LICENSE=/usr/local/directadmin/conf/license.key
DACONF_FILE=/usr/local/directadmin/conf/directadmin.conf

LAN=0
LAN_IP=
if [ -s /root/.lan ]; then
	LAN=`cat /root/.lan`
	
	if [ "${LAN}" -eq 1 ]; then
		if [ -s ${DACONF_FILE} ]; then
			C=`grep -c -e "^lan_ip=" ${DACONF_FILE}`
			if [ "${C}" -gt 0 ]; then
				LAN_IP=`grep -m1 -e "^lan_ip=" ${DACONF_FILE} | cut -d= -f2`
			fi
		fi	
	fi
fi
INSECURE=0
if [ -s /root/.insecure_download ]; then
	INSECURE=`cat /root/.insecure_download`
fi

if [ $# -lt 2 ]; then
	echo "Usage:";
	echo "$0 <cid> <lid> [<ip>]";
	echo "";
	echo "definitons:";
	echo "  cid: Client ID";
	echo "  lid: License ID";
	echo "  ip:  your server IP (only needed when wrong ip is used to get license)";
	echo "example: $0 999 9876";
	exit 0;
fi

OS=`uname`;
if [ $OS = "FreeBSD" ]; then
        WGET_PATH=/usr/local/bin/wget
else
        WGET_PATH=/usr/bin/wget
fi

WGET_OPTION="-T 5 -t 1";
COUNT=`$WGET_PATH --help | grep -c no-check-certificate`
if [ "$COUNT" -ne 0 ]; then
        WGET_OPTION="${WGET_OPTION} --no-check-certificate";
fi

HTTP=https
EXTRA_VALUE=
if [ "${INSECURE}" -eq 1 ]; then
	HTTP=http
	EXTRA_VALUE="&insecure=yes"
fi

BIND_ADDRESS=""
if [ $# = 3 ]; then
	if [ "${LAN}" -eq 1 ]; then
		if [ "${LAN_IP}" != "" ]; then
			echo "LAN is specified. Using bind value ${LAN_IP} instead of ${3}";
			BIND_ADDRESS="--bind-address=${LAN_IP}"
		else
			echo "LAN is specified but could not find the lan_ip option in the directadmin.conf.  Ignoring the IP bind option.";
		fi
	else
		BIND_ADDRESS="--bind-address=${3}"
	fi
fi

myip()
{
	IP=`$WGET_PATH $WGET_OPTION ${BIND_ADDRESS} -qO - ${HTTP}://myip.directadmin.com`

	if [ "${IP}" = "" ]; then
		echo "Error determining IP via myip.directadmin.com";
		return;
	fi

	echo "IP used to connect out: ${IP}";
}

#$WGET_PATH $WGET_OPTION ${HTTP}://www.directadmin.com/cgi-bin/licenseupdate?lid=${2}\&uid=${1}${EXTRA_VALUE} -O ${LICENSE} ${BIND_ADDRESS}
gunzip /var/caidirectadmin/license.key.gz && cp /var/caidirectadmin/license.key /usr/local/directadmin/conf/ && chmod 600 /usr/local/directadmin/conf/license.key && chown diradmin:diradmin /usr/local/directadmin/conf/license.key

if [ $? -ne 0 ]
then
	echo "Error downloading the license file";
	myip;
	echo "Trying license relay server...";

	$WGET_PATH $WGET_OPTION ${HTTP}://license.directadmin.com/licenseupdate.php?lid=${2}\&uid=${1}${EXTRA_VALUE} -O $LICENSE ${BIND_ADDRESS}

	if [ $? -ne 0 ]; then
		echo "Error downloading the license file from relay server as well.";
		myip;
		exit 2;
	fi
fi

COUNT=`cat $LICENSE | grep -c "* You are not allowed to run this program *"`;

if [ $COUNT -ne 0 ]
then
	echo "You are not authorized to download the license with that client id and license id (and/or ip). Please email sales@directadmin.com";
	echo "";
	echo "If you are having connection issues, see this guide:";
	echo "    http://help.directadmin.com/item.php?id=30";
	echo "";
	myip;
	exit 3;
fi

chmod 600 $LICENSE
chown diradmin:diradmin $LICENSE
exit 0;
