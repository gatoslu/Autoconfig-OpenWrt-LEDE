# Autoinstall-OpenWrt/LEDE    Install shadowsocks in OpenWrt/LEDE by automation

# 此脚本用于自动安装shadowsocks相关包，免去手动安装的繁琐，

# 以及不会在openwrt中安装科学上网服务的同学。可能不适用所有情况，请自行检查确认能否使用。

# 其中脚本：autoconfig_openwrt.sh和autoconfig_lede.sh为一键方案，个人自用脚本，公开代码

  
  # 配置为：
  
  # 1、配置shadowsocks，Chinadns，shadowvpn，会是否询问安装
  
  # 2、配置shadowsocks看门狗功能
  
  # 3、配置国内路由表自动升级功能
  
  # 4、配置路由软件自动检测升级功能
  
  # 5、增加aa65535配置的SourceForge源
  
    # src/gz openwrt_dist http://openwrt-dist.sourceforge.net/packages/OpenWrt/base/{architecture}
    
    # src/gz openwrt_dist_luci http://openwrt-dist.sourceforge.net/packages/OpenWrt/luci

# 更新日志
#2017.4.20 添加ngrok安装选项

#2017.4.11 添加中文语言包安装选项

#2017.4.10 更新软件名称，增加脚本中的下载结果检查以及root权限检查和wget组件检查，添加LEDE自动配置方案

#2017.3.8 更新openwrt路由的一件下载shadowsocks及配置方案


# 脚本中的软件均来自aa65535同学，感谢贡献。
