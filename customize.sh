# !/system/bin/sh
# Written by Draco (tytydraco @ github).
# Modified by pedrozzz (pedroginkgo @ telegram).
# Enable cloudflare DNS by ROM (xerta555 @github).
# MMT Extended by Zackptg5 @ XDA

ui_print ""
ui_print "╭╮╭━╮ ╭━━━━╮ ╭━━━╮"
ui_print "┃┃┃╭╯ ┃╭╮╭╮┃ ┃╭━╮┃"
ui_print "┃╰╯╯╱ ╰╯┃┃╰╯ ┃╰━━╮"
ui_print "┃╭╮┃╱ ╱╱┃┃╱╱ ╰━━╮┃"
ui_print "┃┃┃╰╮ ╱╱┃┃╱╱ ┃╰━╯┃"
ui_print "╰╯╰━╯ ╱╱╰╯╱╱ ╰━━━╯"
ui_print "╱╱╱╱╱ ╱╱╱╱╱╱ ╱╱╱╱╱"
ui_print "╱╱╱╱╱ ╱╱╱╱╱╱ ╱╱╱╱╱"
sleep 1
ui_print "  by @pedroginkgo"
ui_print ""
sleep 1
ui_print "MMT Extended by Zackptg5 @ XDA"
ui_print ""
sleep 1
ui_print "🕛 Date of execution: $(date)"
ui_print ""
sleep 1
ui_print "🛠️ SOC: $(getprop ro.board.platform)"
ui_print ""
sleep 1
ui_print "⚙️ SDK: $(getprop ro.build.version.sdk)"
ui_print ""
sleep 1
ui_print "🅰️ndroid Version: $(getprop ro.build.version.release)"
ui_print ""
sleep 1
ui_print "🛡️ Security patch: $(getprop ro.build.version.security_patch)"
ui_print ""
sleep 1
ui_print "🔏 Fingerprint: $(getprop ro.build.fingerprint)"
ui_print ""
sleep 1
ui_print "📱 Device: $(getprop ro.product.odm.model)"
ui_print ""
sleep 1

loc=/data/adb/modules

    if [[ -d $loc/injector ]]
    then 
    echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
    exit 0
    
	elif [[ -d $loc/Pulsar_Engine ]]
	then 
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ -d $loc/zeetaatweaks ]] 
	then 
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ -d $loc/gaming ]] 
	then 
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ -d $loc/smext ]] 
	then 
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ -d $loc/fkm_spectrum_injector ]] 
	then 
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ -d $loc/NetworkTweak ]] 
	then 
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ -d $loc/MAGNETAR ]] 
	then 
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ -d $loc/FDE ]] 
	then 
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[  $(pm list package feravolt) ]] 
	then
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ -d $loc/ktweak ]] 
	then 
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ $(pm list package ktweak) ]] 
	then 
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ -d $loc/lspeed ]] 
	then 
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ $(pm list package lspeed) ]] 
	then 
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[  $(pm list package magnetarapp) ]] 
	then 
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ $(pm list package lsandroid) ]] 
	then 
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ -d $loc/sqinjector ]]    
	then 
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ -d $loc/ZeroLAG ]]    
	then 
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ -d $loc/AuroxT ]]    
	then 
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ -d $loc/ktks ]]
	then
	echo "[!] A old version of King Tweaks is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ -d $loc/ktksr ]]
	then
	echo "[!] A old version of King Tweaks is installed, please remove and then install King Tweaks again."
	exit 0
	
	elif [[ $(pm list package kitana) ]]
	then
	echo "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	exit 0
	fi
	
set_permissions() {
	chmod 0755 $MODPATH/system/$b/*
  set_perm_recursive $MODPATH/system/bin root root 0777 0755
}

SKIPUNZIP=1
unzip -qjo "$ZIPFILE" 'common/functions.sh' -d $TMPDIR >&2
. $TMPDIR/functions.sh
unzip -o "$ZIPFILE" 'system' -d $MODPATH >&2
unzip -o "$ZIPFILE" 'vendor' -d $MODPATH >&2

ui_print ""
ui_print "[!] Do you wanna install DRM L1 Widevine patch? (Enable 1080p on Netflix)"
ui_print ""
ui_print " Volume + = Switch number"
ui_print " Volume - = Select"
ui_print ""
ui_print " 1 = Yes "
ui_print " 2 = No"
ui_print ""
TI=1
while true; do
	ui_print "  $TI"
	if $VKSEL; then
		TI=$((TI + 1))
	else 
		break
	fi
	if [ $TI -gt 2 ]; then
		TI=1
	fi
done

case $TI in
	1 ) FCTEXTAD1="Yes";;
	2 ) FCTEXTAD1="No";;
esac
ui_print ""
ui_print "Your choice: $FCTEXTAD1"

if [[ "$FCTEXTAD1" == "Yes" ]]
then
ui_print ""
ui_print "[*] You're installing DRM L1 Widevine patch..."
sleep 2
mkdir -p $MODPATH/system/vendor/bin
mkdir -p $MODPATH/system/vendor/lib
mkdir -p $MODPATH/system/vendor/lib64
mkdir -p $MODPATH/system/vendor/framework
mv $MODPATH/vendor/lib/libcpion.so $MODPATH/system/vendor/lib
mv $MODPATH/vendor/lib/libdrmclearkeyplugin.so $MODPATH/system/vendor/lib
mv $MODPATH/vendor/lib/libwvdrmengine.so $MODPATH/system/vendor/lib
mv $MODPATH/vendor/lib/libdrmframework_jni.so $MODPATH/system/vendor/lib
mv $MODPATH/vendor/lib64/libcppf.so $MODPATH/system/vendor/lib64
mv $MODPATH/vendor/lib64/libdrmclearkeyplugin.so $MODPATH/system/vendor/lib64
mv $MODPATH/vendor/lib64/libwvdrmengine.so $MODPATH/system/vendor/lib64
mv $MODPATH/vendor/lib64/libdrmframework_jni.so $MODPATH/system/vendor/lib64
mv $MODPATH/vendor/lib64/liboemcrypto.so $MODPATH/system/vendor/lib64
mv $MODPATH/vendor/bin/hw $MODPATH/system/vendor/bin
mv $MODPATH/vendor/framework/com.android.mediadrm.signer.jar $MODPATH/system/vendor/framework
mv $MODPATH/vendor/framework/oat $MODPATH/system/vendor/framework

else [[ "$FCTEXTAD1" == "No" ]]
ui_print ""
ui_print "[!] Aborting DRM L1 Widevine patch installation..."
sleep 2
fi

ui_print ""
ui_print "[!] Do you wanna install empty thermal? (Snapdragon only)"
ui_print ""
ui_print " Volume + = Switch number"
ui_print " Volume - = Select"
ui_print ""
ui_print " 1 = Empty thermal "
ui_print " 2 = Stock thermal "
ui_print ""
DS=1
while true; do
	ui_print "  $DS"
	if $VKSEL; then
		DS=$((DS + 1))
	else 
		break
	fi
	if [ $DS -gt 2 ]; then
		DS=1
	fi
done

case $DS in
	1 ) FCTEXTAD2="Empty thermal";;
	2 ) FCTEXTAD2="Stock thermal";;
esac
ui_print ""
ui_print "Your choice: $FCTEXTAD2"

if [[ "$FCTEXTAD2" == "Empty thermal" ]]
then
ui_print ""
ui_print "[*] You're installing empty thermal..."
sleep 2
mv $MODPATH/vendor/lib64/libthermalclient.so $MODPATH/system/vendor/lib64
mv $MODPATH/vendor/lib/libthermalclient.so $MODPATH/system/vendor/lib
mv $MODPATH/vendor/bin/thermal-engine $MODPATH/system/vendor/bin
busybox rm -rf $MODPATH/vendor

else [[ "$FCTEXTAD2" == "Stock thermal" ]]
ui_print ""
ui_print "[!] Aborting empty thermal installation..."
sleep 2
busybox rm -rf $MODPATH/vendor
fi

ui_print ""
ui_print "👑 KTS Version: $(grep_prop version $MODPATH/module.prop)"
sleep 1
ui_print ""
fstrim -v /system
fstrim -v /data
fstrim -v /cache
ui_print ""
ui_print "[*] You can access logs by writing kingtweaks in a root terminal."
sleep 1
ui_print ""
echo "[*] Now, reboot."
sleep 1
ui_print ""