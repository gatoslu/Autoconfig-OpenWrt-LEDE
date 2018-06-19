## Autoinstall-OpenWrt/LEDE    Install shadowsocks in OpenWrt/LEDE by automation

-  此脚本用于OpenWrt/LEDE中自动安装Shadowsocks相关包，免去手动安装的繁琐步骤

- 以及不会在OpenWrt/LEDE中安装科学上网服务的同学。可能不适用所有情况，请自行检查确认能否使用。

- 其中脚本：autoconfig_openwrt.sh和autoconfig_lede.sh为一键自动化配置方案，适用于MT7620系列路由器，请在对应的系统中使用相关脚本！

  
## 相关功能配置简介：
  
  
 - 1、配置shadowsocks，Chinadns，shadowvpn，自动询问是否安装相应服务
 
 - 2、配置shadowsocks看门狗功能
  
 - 3、配置国内路由表自动升级功能
  
 - 4、配置路由软件自动检测升级功能
  
 - 5、增加aa65535配置的SourceForge源
  
    # src/gz openwrt_dist http://openwrt-dist.sourceforge.net/packages/base/{architecture}
    
    # src/gz openwrt_dist_luci http://openwrt-dist.sourceforge.net/packages/luci
    
## 使用方法

- LEDE 执行命令：

wget --no-check-certificate https://raw.githubusercontent.com/gatoslu/Autoconfig-OpenWrt-LEDE/master/autoconfig_lede.sh

chmod +x autoconfig_lede.sh

./autoconfig.sh

- OpenWrt 执行命令：

wget --no-check-certificate https://raw.githubusercontent.com/gatoslu/Autoconfig-OpenWrt-LEDE/master/autoconfig_openwrt.sh

chmod +x autoconfig_openwrt.sh

./auconfig_openwrt.sh







## 更新日志

- 2017.4.22 添加kms安装选项，更新相关编译文件

- 2017.4.20 添加ngrok安装选项

- 2017.4.11 添加中文语言包安装选项

- 2017.4.10 更新软件名称，增加脚本中的下载结果检查以及root权限检查和wget组件检查，添加LEDE自动配置方案

- 2017.3.8 更新openwrt路由的一件下载shadowsocks及配置方案


## 致敬
- OpenWrt/LEDE
- clowwindy
- aa65535
- dosgo
- madeye

