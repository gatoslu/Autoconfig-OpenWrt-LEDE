#!/bin/sh
#自动安装openwrt版shadowsocks脚本和用户配置脚本

check_result() {
  if [ $1 -ne 0 ]; then
    echo "Error: $2" >&2
    exit $1
  fi
}

if [ "x$(id -u)" != 'x0' ]; then
  echo 'Error: This script can only be executed by root'
  exit 1
fi

if [ -f '/ss_watchdog' ]; then
  echo 'Autoconfig for OpenWrt has been installed.'
  exit 1
fi

if [ ! -f '/usr/bin/wget' ]; then
  echo 'Installing wget ...'
  opkg update
  opkg install wget
  check_result $? "Can't install wget."
  echo 'Install wget succeed.'
fi

 
INSTALLED=$(opkg list-installed)

for a in $(opkg print-architecture | awk '{print $2}'); do
	case "$a" in
		all|noarch)
			;;
		ar71xx|bcm53xx|bcm2708|brcm47xx|brcm63xx|kirkwood|mvebu|oxnas|ramips_24kec|sunxi|x86|x86_64)
			ARCH=${a}
			;;
		*)
			echo "Architectures not support."
			exit 0
			;;
	esac
done

echo -e "\nTarget Arch:\033[32m $ARCH \033[0m\n"

sed -i "s/^\(option check_signature\)/#\1/" /etc/opkg.conf

if !(grep -q "openwrt_dist" /etc/opkg.conf); then
	echo "src/gz openwrt_dist http://openwrt-dist.sourceforge.net/packages/OpenWrt/base/$ARCH" >>/etc/opkg.conf
	echo "src/gz openwrt_dist_luci http://openwrt-dist.sourceforge.net/packages/OpenWrt/luci" >>/etc/opkg.conf
fi

opkg update

if echo "$INSTALLED" | grep -q "luci"; then
	LuCI=yes
fi


read -p "Install the Language zh_cn [Y/n]?" INS_ZH_CN
read -p "Install the ChinaDNS [Y/n]?" INS_CD
read -p "Install the DNS-Forwarder [Y/n]?" INS_DF
read -p "Install the shadowsocks-libev [Y/n]?" INS_SS
read -p "Install the ShadowVPN [Y/n]?" INS_SV

#询问自动安装看门狗脚本
read -p "Created the shadowsocks_watchdog [Y/n]?" INS_SSDOG
#询问安装自动升级国内路由表脚本
read -p "Created the update_ignorelist [Y/n]?" INS_IGNORE
#询问安装自动程序升级模块脚本
read -p "Created the autoupgrade.sh [Y/n]?" INS_AUTOUP


if echo ${INS_ZH_CN} | grep -qi "^y"; then
	opkg install luci-i18n-base-zh-cn luci-i18n-commands-zh-cn luci-i18n-diag-core-zh-cn luci-i18n-firewall-zh-cn
fi

if echo ${INS_CD} | grep -qi "^y"; then
	opkg install ChinaDNS
	if [ "$LuCI" = "yes" ]; then
		opkg install luci-app-chinadns
		/etc/init.d/chinadns enable
	fi
fi

if echo ${INS_DF} | grep -qi "^y"; then
	opkg install dns-forwarder
	if [ "$LuCI" = "yes" ]; then
		opkg install luci-app-dns-forwarder
		/etc/init.d/dns-forwarder enable
	fi
fi

if echo ${INS_SS} | grep -qi "^y"; then
	if echo "$INSTALLED" | grep -q "libmbedtls"; then
		opkg install shadowsocks-libev-mbedtls
	else
		opkg install shadowsocks-libev
	fi
	if [ "$LuCI" = "yes" ]; then
		opkg install luci-app-shadowsocks
		/etc/init.d/shadowsocks enable
	fi
fi

if echo ${INS_SV} | grep -qi "^y"; then
	opkg install ShadowVPN
	if [ "$LuCI" = "yes" ]; then
		opkg install luci-app-shadowvpn
		/etc/init.d/shadowvpn enable
	fi
fi

TMP_DIR=`mktemp -d`
cd ${TMP_DIR}


#创建shadowsocks看门狗脚本
if echo ${INS_SSDOG} | grep -qi "^y"; then
	echo 'Downloading ss_watchdog script ...'
	wget --no-check-certificate https://raw.githubusercontent.com/gatoslu/Autoinstall-OpenWrt/master/shadowsocks_watchdog -O ss_watchdog
	check_result $? 'Download shadowsocks_watchdog failed.'
	
	echo 'Extract shadowsocks_watchdog ...'
	cp ss_watchdog /ss_watchdog
	#配置ssl环境
   #chmod 755 /ss_watchdog
		if !(grep -q "ss_watchdog" /etc/crontabs/root); then
			echo "*/10 * * * * /ss_watchdog >> /var/log/ss_watchdog.log 2>&1" >>/etc/crontabs/root
			echo "0 1 * * 6 echo "" > /var/log/ss_watchdog.log" >>/etc/crontabs/root
		fi
fi
#创建国内路由表升级脚本
if echo ${INS_IGNORE} | grep -qi "^y"; then
	echo "#!/bin/sh">/update_ignorelist
	wget --no-check-certificate https://raw.githubusercontent.com/gatoslu/Autoinstall-OpenWrt/master/update_ignorelist -O update_ignorelist
	check_result $? 'Download update_ignorelist failed.'
	
	echo 'Extract update_ignorelist ...'
	cp update_ignorelist /update_ignorelist
	
	#chmod 755 /update_ignorelist
		if !(grep -q "update_ignorelist" /etc/crontabs/root); then
			echo "30 4 * * * /update_ignorelist>/dev/null 2>&1" >>/etc/crontabs/root
			fi
fi

#创建自动程序升级脚本
if echo ${INS_AUTOUP} | grep -qi "^y"; then
	wget --no-check-certificate https://raw.githubusercontent.com/gatoslu/Autoinstall-OpenWrt/master/auto_upgrade.sh -O autoupgrade.sh
	
	check_result $? 'Download autoupgrade.sh failed.'
	
	echo 'Extract autoupgrade.sh ...'
	cp autoupgrade.sh /autoupgrade.sh
	#chmod 755 /autoupgrade.sh
		if !(grep -q "autoupgrade.sh" /etc/crontabs/root); then
			echo "0 3 * * 6 /root/autoupgrade.sh" >>/etc/crontabs/root
		fi
fi

echo 'Fix Permissions ...'
chmod 755 /ss_watchdog
chown root.root /ss_watchdog
chmod 755 /update_ignorelist
chown root.root /update_ignorelist
chmod 755 /autoupgrade.sh
chown root.root /autoupgrade.sh

echo 'Cleaning ...'
rm -rf ${TMP_DIR}

echo "openssl config...!"

mkdir -p /etc/ssl/certs
	export SSL_CERT_DIR=/etc/ssl/certs
    source /etc/profile
	opkg install ca-certificates wget


	
echo "Instal compelt,enjot it!"
