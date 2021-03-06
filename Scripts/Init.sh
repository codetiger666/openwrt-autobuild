#!/usr/bin/env bash

Core_X86_64(){
    Author=CodeTiger
    INCLUDE_SSR_Plus=true
    INCLUDE_Passwall=true
    INCLUDE_VSSR=true
    # INCLUDE_OpenClash=true
}

Diy-Part1() {
    
    mv -f  Customize/Upgradesystemx86_64 $GITHUB_WORKSPACE/openwrt/package/base-files/files/bin/Upgradesystem
    chmod +x $GITHUB_WORKSPACE/openwrt/package/base-files/files/bin/Upgradesystem
    Core_X86_64
    Date=`date "+%Y/%m/%d"`
    mkdir -p $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/config > /dev/null 2>1
    cd $GITHUB_WORKSPACE
    /usr/bin/cp /usr/bin/upx openwrt/staging_dir/host/bin
    /usr/bin/cp $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/banner $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/banner.back
    mv -f Customize/banner $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc
    cd $GITHUB_WORKSPACE/openwrt/package/base-files/files/bin
    /usr/bin/cp config_generate config_generate.back
    sed -i "s/192.168.1.1/10.10.1.1/g" config_generate
    sed -i "s/192.168/10.10/g" config_generate
    mkdir -p $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/config > /dev/null 2>1
    mkdir -p  $GITHUB_WORKSPACE/openwrt/package/CodeTiger > /dev/null 2>1
    cd $GITHUB_WORKSPACE/openwrt/package/CodeTiger
    svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/redsocks2
    git clone https://github.com/jerrykuku/luci-theme-argon.git
    git clone https://github.com/jerrykuku/luci-app-argon-config.git
    /usr/bin/cp $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/openwrt_release $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/openwrt_release.back
    sed -i '/DISTRIB_REVISION/d' $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/openwrt_release
    echo "DISTRIB_REVISION='codetiger 0.1 [$Date]'" >> $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/openwrt_release
    sed -i '/DISTRIB_DESCRIPTION/d' $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/openwrt_release
    echo "DISTRIB_DESCRIPTION='OpenWrt '" >> $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/openwrt_release
    if [ "$INCLUDE_SSR_Plus" == "true" ]; then
        cd $GITHUB_WORKSPACE/openwrt/package/CodeTiger
        git clone https://github.com/fw876/helloworld.git -b master
    fi
    if [ "$INCLUDE_SmartDNS" == "true" ]; then
        cd $GITHUB_WORKSPACE/openwrt/package/CodeTiger
        git clone https://github.com/pymumu/luci-app-smartdns.git
        /usr/bin/cp $GITHUB_WORKSPACE/Customize/smartdns $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/config
    fi
    if [ "$INCLUDE_Passwall" == "true" ]; then
        cd $GITHUB_WORKSPACE/openwrt/package/CodeTiger
        git clone https://github.com/xiaorouji/openwrt-passwall.git -b main
        /usr/bin/cp $GITHUB_WORKSPACE/Customize/passwall $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/config
    fi
    if [ "$INCLUDE_VSSR" == "true" ]; then
        cd $GITHUB_WORKSPACE/openwrt/package/CodeTiger
        git clone https://github.com/jerrykuku/lua-maxminddb.git
        git clone https://github.com/jerrykuku/luci-app-vssr.git 
    fi
    if [ "$INCLUDE_OpenClash" == "true" ]; then
        cd $GITHUB_WORKSPACE/openwrt/package/CodeTiger
        git clone https://github.com/vernesong/OpenClash.git
    fi
    sed -i "s?Openwrt?Openwrt Compiled By $Author?g" $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/banner
}

Diy-Part2_x86_64() {
    Date=`date "+%Y%m%d"`
	mkdir bin/Firmware
	mv -f bin/targets/x86/64/openwrt-x86-64-generic-ext4-combined-efi.img.gz bin/Firmware/"openwrt-x86-64-efi-$Date.img.gz"
    mv -f bin/targets/x86/64/openwrt-x86-64-generic-ext4-combined.img.gz bin/Firmware/"openwrt-x86-64-$Date.img.gz"
	_MD5_efi=$(md5sum bin/Firmware/"openwrt-x86-64-efi-$Date.img.gz" | cut -d ' ' -f1)
    _MD5=$(md5sum bin/Firmware/"openwrt-x86-64-$Date.img.gz" | cut -d ' ' -f1)
	_SHA256_efi=$(sha256sum bin/Firmware/"openwrt-x86-64-efi-$Date.img.gz" | cut -d ' ' -f1)
    _SHA256=$(sha256sum bin/Firmware/"openwrt-x86-64-$Date.img.gz" | cut -d ' ' -f1)
    echo -e "\nMD5:${_MD5}\nSHA256:${_SHA256}" > bin/Firmware/"openwrt-x86-64-$Date.detail"
    echo -e "\nMD5:${_MD5_efi}\nSHA256:${_SHA256_efi}" > bin/Firmware/"openwrt-x86-64-efi-$Date.detail"
}