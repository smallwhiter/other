#!/bin/bash
 
while [[ $# -ge 1 ]]; do
  case $1 in
    -L|-l|--url)
      shift
      tmpMyLink="$1"
      shift
      ;;
    -U|-u|--UserName)
      shift
      tmpMyUserName="$1"
      shift
      ;;
    -P|-p|--PassWord)
      shift
      tmpMyPassWord="$1"
      shift
      ;;
    *|--help)
      echo -ne " Usage:\n\tbash $0\t-L/--url \033[33m'\033[04mhttp://moeclub.org\033[0m\033[33m'\033[0m\n\t\t\t\t-U/--UserName \033[33m'\033[04mMoeClub.org\033[0m\033[33m'\033[0m\n\t\t\t\t-P/--PassWord \033[33m'\033[04mVicer\033[0m\033[33m'\033[0m\n"
      exit 1;
      ;;
    esac
  done
 
function CHECK()
{
MyLink=$tmpMyLink
MyUserName=$tmpMyUserName
MyPassWord=$tmpMyPassWord
[ -z $MyLink ] && echo "Please input your URL! " && exit 1;
MyDomian="$(echo -n "$MyLink" |awk -F '//' '{print $2}')"
[ -z $MyDomian ] && echo -e "URL Error! ( exp:\033[33m'\033[04mhttp://moeclub.org\033[0m\033[33m'\033[0m )" && exit 1;
CHECKIP="$(echo "$MyDomian" | grep -o '\(\([0-9]\|[1-9][0-9]\|1[0-9]\{2\}\|2[0-4][0-9]\|25[0-5]\)\.\)\{3\}\([0-9]\|[1-9][0-9]\|1[0-9]\{2\}\|2[0-4][0-9]\|25[0-5]\)')"
[ "$MyDomian" == "$CHECKIP" ] && [ "$(echo "$MyDomian" |awk -F '.' '{print NF}')" -eq '4' ] && ISIP='1' || ISIP='0'
}
 
function UPDATE_SRC()
{
[ ! -f /etc/os-release ] && echo "Not Found Version! " && exit 1;
[ -f /etc/os-release ] && DEB_VER="$(awk -F'[= "]' '/VERSION_ID/{print $3}' /etc/os-release)"
[ -z $DEB_VER ] && echo "Error, Found Version! " && exit 1;
sed -i '/debian wheezy main/'d /etc/apt/sources.list
sed -i '/debian wheezy-backports main/'d /etc/apt/sources.list
sed -i '/debian wheezy-updates main/'d /etc/apt/sources.list
sed -i '/debian jessie main/'d /etc/apt/sources.list
sed -i '/debian jessie-backports main/'d /etc/apt/sources.list
sed -i '/debian jessie-updates main/'d /etc/apt/sources.list
sed -i '/multimedia/'d /etc/apt/sources.list
echo "deb http://httpredir.debian.org/debian wheezy main" >>/etc/apt/sources.list
echo "deb-src http://httpredir.debian.org/debian wheezy main" >>/etc/apt/sources.list
[ "$DEB_VER" == '7' ] && echo "deb http://httpredir.debian.org/debian wheezy-backports main" >> /etc/apt/sources.list
[ "$DEB_VER" == '7' ] && echo "deb-src http://httpredir.debian.org/debian wheezy-backports main" >> /etc/apt/sources.list
[ "$DEB_VER" == '7' ] && echo "deb http://httpredir.debian.org/debian wheezy-updates main" >> /etc/apt/sources.list
[ "$DEB_VER" == '7' ] && echo "deb-src http://httpredir.debian.org/debian wheezy-updates main" >> /etc/apt/sources.list
echo "deb http://httpredir.debian.org/debian jessie main" >>/etc/apt/sources.list
echo "deb-src http://httpredir.debian.org/debian jessie main" >>/etc/apt/sources.list
[ "$DEB_VER" == '8' ] && echo "deb http://httpredir.debian.org/debian jessie-backports main" >> /etc/apt/sources.list
[ "$DEB_VER" == '8' ] && echo "deb-src http://httpredir.debian.org/debian jessie-backports main" >> /etc/apt/sources.list
[ "$DEB_VER" == '8' ] && echo "deb http://httpredir.debian.org/debian jessie-updates main" >> /etc/apt/sources.list
[ "$DEB_VER" == '8' ] && echo "deb-src http://httpredir.debian.org/debian jessie-updates main" >> /etc/apt/sources.list
echo "deb http://www.deb-multimedia.org wheezy main non-free" >>/etc/apt/sources.list
sed -i '/deb cdrom/'d /etc/apt/sources.list
sed -i '/^$/'d /etc/apt/sources.list
[ "$DEB_VER" == '7' ] && {
[ -f /etc/apt/preferences ] && mv -f /etc/apt/preferences /etc/apt/preferences.bak
cat >/etc/apt/preferences<<EOFSRC
Package: *
Pin: release wheezy-backports
Pin-Priority: 70
 
Package: *
Pin: release jessie
Pin-Priority: 60
 
Package: *
Pin: release jessie-backports
Pin-Priority: 50
EOFSRC
}
[ "$DEB_VER" == '8' ] && {
[ -f /etc/apt/preferences ] && mv -f /etc/apt/preferences /etc/apt/preferences.bak
cat >/etc/apt/preferences<<EOFSRC
Package: *
Pin: release jessie-backports
Pin-Priority: 70
 
Package: *
Pin: release wheezy
Pin-Priority: 60
EOFSRC
}
}
 
function INSTALL_SRC()
{
apt-get update;
DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes deb-multimedia-keyring;
apt-get -qq update;
DEBIAN_FRONTEND=noninteractive apt-get install -y lsb-release curl sed gawk openssl autogen autoconf automake gettext pkg-config make gcc m4 libtool zlib1g-dev libpcre3 libpcre3-dev insserv e2fslibs;
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx nginx-common spawn-fcgi libfcgi0ldbl fcgiwrap p7zip-full unzip vnstat ffmpeg;
apt-get -qq update;
DEBIAN_FRONTEND=noninteractive apt-get install -y -q -t wheezy transmission transmission-common transmission-daemon
apt-get -qq update;
DEBIAN_FRONTEND=noninteractive apt-get install -y -q -t jessie libcurl3-gnutls
DEBIAN_FRONTEND=noninteractive apt-get install -y -q -t jessie php5 php5-cgi php5-gd php-apc;
}
 
function REMOVE_SRC()
{
apt-get -y -qq --force-yes remove --purge apache* bind9* >/dev/null 2>&1
apt-get -y -qq autoremove >/dev/null 2>&1
}
 
function TRANSMISSION_CONFIG()
{
bash /etc/init.d/transmission-daemon stop
mkdir -p /tmp
mkdir -p /etc/transmission-daemon
mkdir -p /usr/share/transmission
rm -rf /usr/share/transmission/*
wget --no-check-certificate -q -O '/tmp/Transmission.zip' 'https://moeclub.org/attachment/LinuxSoftware/transmission/Transmission.zip.deb'
7z x /tmp/Transmission.zip -o/usr/share/transmission
rm -rf /etc/transmission-daemon/settings.json
wget --no-check-certificate -q -O '/etc/transmission-daemon/settings.json' 'https://moeclub.org/attachment/LinuxSoftware/transmission/settings.json'
[ -f '/etc/init.d/transmission-daemon' ] && sed -i s'/^USER=.*/USER=root/g' /etc/init.d/transmission-daemon
mkdir -p /data/www;
mkdir -p /etc/transmission-daemon;
mkdir -p /usr/share/transmission;
mkdir -p /var/lib/transmission-daemon;
sed -i 's|http://moeclub.org|'$MyLink'|g' /usr/share/transmission/web/index.html
sed -i 's|http://moeclub.org|'$MyLink'|g' /usr/share/transmission/web/index.mobile.html
[ -n "$MyUserName" ] && sed -i 's|MoeClub.org|'$MyUserName'|g' /etc/transmission-daemon/settings.json
[ -n "$MyPassWord" ] && sed -i 's|Vicer|'$MyPassWord'|g' /etc/transmission-daemon/settings.json
bash /etc/init.d/transmission-daemon restart
}
 
function H5AI_CONFIG()
{
mkdir -p /data/www
rm -rf /data/www/*
mkdir -p /data/www/download
mkdir -p /tmp
wget --no-check-certificate -qO /tmp/h5ai.zip 'https://moeclub.org/attachment/LinuxSoftware/directory/h5ai.zip.deb'
[ -f /tmp/h5ai.zip ] && 7z x /tmp/h5ai.zip -o/data/www;
[ -f /data/www/_h5ai/public/js/scripts.js ] && sed -i 's|http://moeclub.org|'$MyLink'/dl|' /data/www/_h5ai/public/js/scripts.js
chown -R www-data:www-data /data/www;
chmod -R a+x /data/www;
}
 
function NGINX_CONFIG()
{
mkdir -p /etc/nginx
rm -rf /etc/nginx/*
rm -rf /usr/share/nginx/www
mkdir -p /etc/nginx/sites-available
wget --no-check-certificate -qO '/etc/nginx/example' 'https://moeclub.org/attachment/LinuxSoftware/nginx/config/example'
wget --no-check-certificate -qO '/etc/nginx/fcgiwrap' 'https://moeclub.org/attachment/LinuxSoftware/nginx/config/fcgiwrap'
wget --no-check-certificate -qO '/etc/nginx/fcgiwrap-php' 'https://moeclub.org/attachment/LinuxSoftware/nginx/config/fcgiwrap-php'
wget --no-check-certificate -qO '/etc/nginx/fastcgi_params' 'https://moeclub.org/attachment/LinuxSoftware/nginx/config/fastcgi_params'
wget --no-check-certificate -qO '/etc/nginx/fcgiwrap.conf' 'https://moeclub.org/attachment/LinuxSoftware/nginx/config/fcgiwrap.conf'
wget --no-check-certificate -qO '/etc/nginx/nginx.conf' 'https://moeclub.org/attachment/LinuxSoftware/nginx/config/nginx.conf'
cp -f /etc/nginx/example /etc/nginx/sites-available/h5ai
sed -i 's|stie.moeclub.org|'$MyDomian'|' /etc/nginx/sites-available/h5ai
[ "$ISIP" -eq '1' ] && sed -i '/server_name/d' /etc/nginx/sites-available/h5ai
chmod -R a+x /etc/nginx;
ln -sf /etc/nginx/fcgiwrap /etc/init.d/fcgiwrap;
ln -sf /etc/nginx/fcgiwrap-php /etc/init.d/fcgiwrap-php;
update-rc.d -f fcgiwrap remove
update-rc.d fcgiwrap defaults
update-rc.d -f fcgiwrap-php remove
update-rc.d fcgiwrap-php defaults
bash /etc/init.d/fcgiwrap-php restart
bash /etc/init.d/nginx restart
}
 
CHECK;
REMOVE_SRC;
UPDATE_SRC;
INSTALL_SRC;
TRANSMISSION_CONFIG;
H5AI_CONFIG;
NGINX_CONFIG;
