#!/bin/sh
 
opkg update
for ipk in $(opkg list-upgradable | awk '$1!~/^kmod|^Multiple/{print $1}'); do
	opkg upgrade $ipk
done
