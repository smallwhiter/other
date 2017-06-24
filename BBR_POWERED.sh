#!/bin/bash
 
[ "$EUID" -ne '0' ] && echo "Error,This script must be run as root! " && exit 1
[ -z "$(dpkg -l |grep 'grub-')" ] && echo "Not found grub." && exit 1
which make >/dev/null 2>&1
[ $? -ne '0' ] && {
echo "Install make..."
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq make >/dev/null 2>&1
which make >/dev/null 2>&1
[ $? -ne '0' ] && {
echo "Error! Install make. "
exit 1
}
}
which gcc-4.9 >/dev/null 2>&1
[ $? -ne '0' ] && {
echo "Install gcc-4.9..."
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq gcc-4.9 >/dev/null 2>&1
which gcc-4.9 >/dev/null 2>&1
[ $? -ne '0' ] && {
echo "Error! Install gcc-4.9. "
exit 1
}
}
MainURL='http://kernel.ubuntu.com/~kernel-ppa/mainline'
KernelVer="$(wget -qO- "$MainURL" |awk -F '/">|href="' '{print $2}' |sed '/rc/d;/^$/d' |tail -n1)"
[ -n "$KernelVer" ] && ReleaseURL="$(echo -n "$MainURL/$KernelVer")"
KernelBit="$(getconf LONG_BIT)"
KernelBitVer=''
[ "$KernelBit" == '32' ] && KernelBitVer='i386'
[ "$KernelBit" == '64' ] && KernelBitVer='amd64'
[ -z "$KernelBitVer" ] && echo "Error! " && exit 1
HeadersFile="$(wget -qO- "$ReleaseURL" |awk -F '">|href="' '/generic.*.deb/{print $2}' |grep 'headers' |grep "$KernelBitVer" |head -n1)"
[ -n "$HeadersFile" ] && HeadersAll="$(echo "$HeadersFile" |sed 's/-generic//g;s/_'${KernelBitVer}'.deb/_all.deb/g')"
[ -z "$HeadersAll" ] && echo "Error! Get Linux Headers for All." && exit 1
echo "$HeadersFile" | grep -q "$(uname -r)"
[ $? -ne '0' ] && echo "Error! Header not be matched by Linux Kernel." && exit 1
echo -ne "Download Kernel Headers for All\n\t$HeadersAll\n"
wget -qO "$HeadersAll" "$ReleaseURL/$HeadersAll"
echo -ne "Install Kernel Headers for All\n\t$HeadersAll\n"
dpkg -i "$HeadersAll" >/dev/null 2>&1
echo -ne "Download Kernel Headers\n\t$HeadersFile\n"
wget -qO "$HeadersFile" "$ReleaseURL/$HeadersFile"
echo -ne "Install Kernel Headers\n\t$HeadersFile\n"
dpkg -i "$HeadersFile" >/dev/null 2>&1
echo -ne "Download BBR POWERED Source code\n"
[ -e ./tmp ] && rm -rf ./tmp
mkdir -p ./tmp && cd ./tmp
[ $? -eq '0' ] && {
wget --no-check-certificate -qO- 'https://moeclub.org/attachment/LinuxSoftware/bbr/tcp_bbr_powered.c.deb' >./tcp_bbr_powered.c
echo 'obj-m:=tcp_bbr_powered.o' >./Makefile
make -s -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=`which gcc-4.9`
echo "Loading TCP BBR POWERED..."
[ -f ./tcp_bbr_powered.ko ] && [ -f /lib/modules/$(uname -r)/modules.dep ] && {
cp -rf ./tcp_bbr_powered.ko /lib/modules/$(uname -r)/kernel/net/ipv4
depmod -a >/dev/null 2>&1
}
modprobe tcp_bbr_powered
[ ! -f /etc/sysctl.conf ] && touch /etc/sysctl.conf
sed -i '/net.core.default_qdisc.*/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control.*/d' /etc/sysctl.conf
echo "net.core.default_qdisc = fq" >>/etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = bbr_powered" >>/etc/sysctl.conf
}
lsmod |grep -q 'bbr_powered'
[ $? -eq '0' ] && {
sysctl -p >/dev/null 2>&1
echo "Finish! "
exit 0
} || {
echo "Error, Loading BBR POWERED."
exit 1
}
