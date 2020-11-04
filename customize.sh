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
ui_print "Thanks a lot to Eight (iamlazy123 @ github)"
ui_print ""
sleep 1
ui_print "MMT Extended by (Zackptg5 @ XDA)"
ui_print ""
sleep 1
ui_print "KTweak by draco (tytydraco @ github)"
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

SKIPUNZIP=0
unzip -qjo "$ZIPFILE" 'common/functions.sh' -d $TMPDIR >&2
. $TMPDIR/functions.sh

key_selector() {
 local option
 local select

 while true
 do
  option="$(getevent -qlc 1 | awk '{ print $3 }')"
  case "$option" in
   KEY_VOLUMEUP)
    select="Yes"
    ;;
   KEY_VOLUMEDOWN)
    select="No"
    ;;
   *)
    continue
    ;;
  esac

  echo "$select"
  break
 done
}

ui_print ""
ui_print "[*] Do you wanna install DRM L1 Patch? (Enable 1080p on Netflix)"
ui_print " Volume + = Yes"
ui_print " Volume - = No"
ui_print ""
version="$(key_selector)"

ui_print "[!] Your choice: $version"
ui_print ""

if [ "$version" == "Yes" ]
then
ui_print "[*] You're installing DRM L1 Widevine patch..."
sleep 2
mv $MODPATH/vendor $MODPATH/system

else [ "$version" == "No" ]
ui_print "[!] Aborting DRM L1 Widevine patch installation..."
sleep 2
busybox rm -rf $MODPATH/vendor
fi

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