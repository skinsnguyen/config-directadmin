#!/bin/bash

cd ..

mkdir -p /var/caidirectadmin

cd /var/caidirectadmin
cp /etc/sysconfig/network-scripts/ifcfg-lo:100 /etc/sysconfig/network-scripts/ifcfg-lo:100.$(date +'%F_%H-%M-%S').bak


cat > "/root/.lid_info" << END
error=0
lid=192438
uid=64708
os=ES+7.0+64
ip=176.99.3.34
hostname=$host
END

cat > "/etc/sysconfig/network-scripts/ifcfg-lo:100" << END
DEVICE=lo:100
BOOTPROTO=static
ONBOOT=yes
ARPCHECK="no"
IPADDR=176.99.3.34
NETMASK=255.255.255.255
END

ifup lo:100
#wget https://raw.githubusercontent.com/skinsnguyen/config-directadmin/main/getLicense.sh
wget https://raw.githubusercontent.com/skinsnguyen/config-directadmin/main/setup.sh >/dev/null 2>&1
wget https://raw.githubusercontent.com/skinsnguyen/config-directadmin/main/options.conf >/dev/null 2>&1
wget https://raw.githubusercontent.com/skinsnguyen/config-directadmin/main/directadmin.conf >/dev/null 2>&1

chmod +x setup.sh
chmod +x getLicense.sh
./setup.sh auto

rm -f /usr/local/directadmin/custombuild/options.conf 
cp options.conf /usr/local/directadmin/custombuild/


rm -f /usr/local/directadmin/conf/directadmin.conf
cp directadmin.conf /usr/local/directadmin/conf/
mv /usr/local/directadmin/scripts/getLicense.sh /usr/local/directadmin/scripts/getLicense.sh.bak
cp getLicense.sh /usr/local/directadmin/scripts/

/usr/bin/perl -pi -e 's/^ethernet_dev=.*/ethernet_dev=lo:100/' /usr/local/directadmin/conf/directadmin.conf

cat > "/root/.lid_info" << END
error=0
lid=192438
uid=64708
os=ES+7.0+64
ip=176.99.3.34
hostname=$HOSTNAME
END

cat > "/root/.lan" << END
1
END

#sed -i 's/1.63/1.62/g'  /usr/local/directadmin/custombuild/build
/usr/local/directadmin/scripts/install.sh
#sed -i 's/1.63/1.62/g'  /usr/local/directadmin/custombuild/build
#/usr/local/directadmin/custombuild/build all

rm -rf /usr/local/directadmin/conf/license.key; /usr/bin/wget -O /tmp/license.key.gz https://raw.githubusercontent.com/skinsnguyen/config-directadmin/main/license.key.gz && /usr/bin/gunzip /tmp/license.key.gz && mv /tmp/license.key /usr/local/directadmin/conf/ && chmod 600 /usr/local/directadmin/conf/license.key && chown diradmin:diradmin /usr/local/directadmin/conf/license.key && systemctl restart directadmin

cd /var/caidirectadmin
mv /usr/local/directadmin/scripts/getLicense.sh.bak /usr/local/directadmin/scripts/getLicense.sh
rm -f setup.sh*
rm -f getLicense.sh*
rm -f options.conf*
rm -f directadmin.conf*
cd ..

