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
  echo 'Autoconfig for lede has been installed.'
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
		aarch64_armv8-a|arm_arm1176jzf-s_vfp|arm_arm926ej-s|arm_cortex-a15_neon-vfpv4|arm_cortex-a5|arm_cortex-a53_neon-vfpv4|arm_cortex-a7_neon-vfpv4|arm_cortex-a8_vfpv3|arm_cortex-a9|arm_cortex-a9_neon|arm_cortex-a9_vfpv3|arm_fa526|arm_mpcore|arm_mpcore_vfp|arm_xscale|armeb_xscale|i386_pentium|i386_pentium4|mips_24kc|mips_mips32|mips64_octeon|mipsel_24kc|mipsel_74kc|mipsel_mips32|powerpc_464fp|powerpc_8540|x86_64)
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
	echo "src/gz openwrt_dist http://openwrt-dist.sourceforge.net/packages/base/$ARCH" >>/etc/opkg.conf
	echo "src/gz openwrt_dist_luci http://openwrt-dist.sourceforge.net/packages/luci" >>/etc/opkg.conf
fi

opkg update

if echo "$INSTALLED" | grep -q "luci"; then
	LuCI=yes
fi

#询问安装中文语言包
read -p "Install Language zh-cn [Y/n]?" INS_ZH_CN
read -p "Install ngrok [Y/n]?" INS_NGROK
read -p "Install vlmcsd [Y/n]?" INS_KMS

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





#安装NGROK模块
if echo ${INS_NGROK} | grep -qi "^y"; then
	echo 'Installing ngrok ...'
	wget --no-check-certificate https://raw.githubusercontent.com/gatoslu/Autoconfig-OpenWrt-LEDE/master/ngrokc/lede_ngrokc/ngrokc_20160829-1_mipsel_24kc.ipk -O ngrokc.ipk
	check_result $? 'Download ngrokc failed.'
	opkg install ngrokc.ipk
	
	echo 'Installing luci-app-ngrok ... '
	wget --no-check-certificate https://raw.githubusercontent.com/gatoslu/Autoconfig-OpenWrt-LEDE/master/ngrokc/luci-app-ngrokc_allv1.1.ipk -O luci-app-ngrokc_allv1.1.ipk
	check_result $? 'Download luci-app-ngrok failed.'
	opkg install luci-app-ngrokc_allv1.1.ipk
	
fi

#安装KMS
if echo ${INS_KMS} | grep -qi "^y"; then
	echo 'Installing vlmcsd ...'
	wget --no-check-certificate https://raw.githubusercontent.com/gatoslu/Autoconfig-OpenWrt-LEDE/master/KMS/LEDE/vlmcsd_svn1108-1_mipsel_24kc.ipk -O vlmcsd.ipk
	check_result $? 'Download vlmcsd failed.'
	opkg install vlmcsd.ipk	
	
	echo 'Installing luci-app-vlmcsd ... '
	wget --no-check-certificate https://raw.githubusercontent.com/gatoslu/Autoconfig-OpenWrt-LEDE/master/KMS/LEDE/luci-app-vlmcsd_1.0.1-2_all.ipk -O luci-app-vlmcsd.ipk
	check_result $? 'Download luci-app-vlmcsd failed.'
	opkg install luci-app-vlmcsd.ipk	
	
fi



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
	check_result $? 'Download ss_watchdog failed.'
	
	echo 'Extract ss_watchdog ...'
	cp ss_watchdog /ss_watchdog
	#配置ssl环境
   #chmod 755 /ss_watchdog
		if !(grep -q "ss_watchdog" /etc/crontabs/root); then
			echo "*/30 * * * * /ss_watchdog >> /var/log/ss_watchdog.log 2>&1" >>/etc/crontabs/root
			echo "0 3 * * 6 echo "" > /var/log/ss_watchdog.log" >>/etc/crontabs/root
		fi
fi
#创建国内路由表升级脚本
if echo ${INS_IGNORE} | grep -qi "^y"; then
	echo 'Downloading update_ignorelist script ...'
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
	echo 'Downloading autoupgrade.sh script ...'
	wget --no-check-certificate https://raw.githubusercontent.com/gatoslu/Autoinstall-OpenWrt/master/auto_upgrade.sh -O autoupgrade.sh
	
	check_result $? 'Download autoupgrade.sh failed.'
	
	echo 'Extract autoupgrade.sh ...'
	cp autoupgrade.sh /autoupgrade.sh
	#chmod 755 /autoupgrade.sh
		if !(grep -q "autoupgrade.sh" /etc/crontabs/root); then
			echo "5 5 * * 6 /root/autoupgrade.sh" >>/etc/crontabs/root
		fi
fi

echo 'Fix Permissions ...'
chmod 755 /ss_watchdog
chown root.root /ss_watchdog
chmod 755 /update_ignorelist
chown root.root /update_ignorelist
chmod 755 /autoupgrade.sh
chown root.root /autoupgrade.sh
chmod 755 /usr/bin/ngrokc
chown root.root /usr/bin/ngrokc

echo 'Cleaning ...'
rm -rf ${TMP_DIR}

echo "openssl config...!"

mkdir -p /etc/ssl/certs
	export SSL_CERT_DIR=/etc/ssl/certs
    source /etc/profile
	opkg install ca-certificates wget ca-bundle


	
echo "Instal compelt,enjot it!"
