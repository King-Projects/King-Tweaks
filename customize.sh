# !/system/bin/sh
# KTS by pedrozzz (pedrozzz0 @ GitHub)
DEBUG=true
ui_print ""
ui_print "╭╮╭━╮ ╭━━━━╮ ╭━━━╮"
ui_print "┃┃┃╭╯ ┃╭╮╭╮┃ ┃╭━╮┃"
ui_print "┃╰╯╯╱ ╰╯┃┃╰╯ ┃╰━━╮"
ui_print "┃╭╮┃╱ ╱╱┃┃╱╱ ╰━━╮┃"
ui_print "┃┃┃╰╮ ╱╱┃┃╱╱ ┃╰━╯┃"
ui_print "╰╯╰━╯ ╱╱╰╯╱╱ ╰━━━╯"
ui_print "╱╱╱╱╱ ╱╱╱╱╱╱ ╱╱╱╱╱"
ui_print "╱╱╱╱╱ ╱╱╱╱╱╱ ╱╱╱╱╱"
sleep 2
ui_print "by pedrozzz (pedrozzz0 @ GitHub)"
ui_print ""
sleep 3
ui_print "KTweak by Draco (tytydraco @ GitHub)"
ui_print ""
sleep 1
ui_print "Thanks to Dan (paget96 @ XDA)"
ui_print ""
sleep 1
ui_print "Thanks to bdashore3 @ GitHub"
ui_print ""
ui_print "Thanks to Eight (iamlazy123 @ GitHub)"
ui_print ""
sleep 1
ui_print "And a special thanks to everyone that supports King Tweaks since it's born and all the other projects also."
sleep 2
ui_print "With love, Pedrozzz, #KeepTheKing. ♡"
ui_print ""

set_permissions() {
  set_perm_recursive $MODPATH/system/bin root root 0777 0755
}

SKIPUNZIP=0
unzip -qjo "$ZIPFILE" 'common/functions.sh' -d $TMPDIR >&2
. $TMPDIR/functions.sh

ui_print ""
ui_print "[*] Fstrim partitions..."
fstrim -v /system
fstrim -v /data
fstrim -v /cache
ui_print ""
ui_print "[*] Installing King Tweaks app..."
pm install $MODPATH/KingTweaks.apk
ui_print ""
ui_print "[*] Installing King Toast app..."
pm install $MODPATH/KingToast.apk
ui_print ""
ui_print "[*] Cleaning stuff..."
if [[ -d "/data/adb/modules/KTKSR" ]]; then
rm -rf /data/adb/modules/KTKSR
fi
rm -rf $MODPATH/*.apk
ui_print ""
ui_print "[*] Logs are stored in your internal storage/KTS"
sleep 1
ui_print ""
ui_print "[*] Please reboot to the changes be applied."
sleep 1
ui_print ""