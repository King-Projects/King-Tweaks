# !/system/bin/sh
# Written by Draco (tytydraco @ github).
# Modified by pedrozzz (pedroginkgo @ telegram).

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
ui_print "by pedrozzz (pedrozzz0 @ github)"
ui_print ""
sleep 1
ui_print "Thanks a lot to Eight (iamlazy123 @ github)"
ui_print ""
sleep 1
ui_print "KTweak by draco (tytydraco @ github)"
ui_print ""
sleep 1

loc=/data/adb/modules

    if [[ -d $loc/injector ]]
    then
    abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
    
	elif [[ -d $loc/Pulsar_Engine ]]
	then 
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[ -d $loc/zeetaatweaks ]] 
	then 
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[ -d $loc/gaming ]] 
	then 
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[ -d $loc/smext ]] 
	then 
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[ -d $loc/fkm_spectrum_injector ]] 
	then 
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[ -d $loc/NetworkTweak ]] 
	then 
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[ -d $loc/MAGNETAR ]] 
	then 
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[ -d $loc/FDE ]] 
	then 
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[  $(pm list package feravolt) ]] 
	then
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[ -d $loc/ktweak ]] 
	then 
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[ $(pm list package ktweak) ]] 
	then 
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[ -d $loc/lspeed ]] 
	then 
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[ $(pm list package lspeed) ]] 
	then 
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[  $(pm list package magnetarapp) ]] 
	then 
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[ $(pm list package lsandroid) ]] 
	then 
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[ -d $loc/sqinjector ]]    
	then 
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[ -d $loc/ZeroLAG ]]    
	then 
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[ -d $loc/AuroxT ]]    
	then 
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	
	elif [[ -d $loc/ktks ]]
	then
	abort "[!] A old version of King Tweaks is installed, please remove and then install King Tweaks again."
	
	elif [[ -d $loc/ktksr ]]
	then
	abort "[!] A old version of King Tweaks is installed, please remove and then install King Tweaks again."
	
	elif [[ $(pm list package kitana) ]]
	then
	abort "[!] A conflicting module/app is installed, please remove and then install King Tweaks again."
	fi
	
set_permissions() {
	chmod 0755 $MODPATH/system/$b/*
  set_perm_recursive $MODPATH/system/bin root root 0777 0755
}

SKIPUNZIP=0
unzip -qjo "$ZIPFILE" 'common/functions.sh' -d $TMPDIR >&2
. $TMPDIR/functions.sh

ui_print ""
fstrim -v /system
fstrim -v /data
fstrim -v /cache
ui_print ""
ui_print "[*] Logs are stored in your internal storage/KTS"
sleep 1
ui_print ""
ui_print "[*] You still can access it by writing kingtweaks in a root terminal (not recommended)."
sleep 1
ui_print ""
echo "[*] Now, reboot."
sleep 1
ui_print ""