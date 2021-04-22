#!/system/bin/sh
# KTSR by pedro (pedrozzz0 @ GitHub)

if [[ -e "/sdcard/KTSR/kxvision.log" ]]; then
rm "/sdcard/KTSR/kxvision.log"
fi

# King Xvision 
write "/sys/devices/platform/kcal_ctrl.0/kcal_enable" "1"
write "/sys/devices/platform/kcal_ctrl.0/kcal" "236 238 240"
write "/sys/devices/platform/kcal_ctrl.0/kcal_sat" "275"
write "/sys/devices/platform/kcal_ctrl.0/kcal_val" "253"
write "/sys/devices/platform/kcal_ctrl.0/kcal_cont" "258"

if [[ $? == "1" ]]; then
echo "[!] Kcal preset executed with errors." > /sdcard/KTSR/kxvision.log
exit 1
else
echo "[*] Kcal preset executed without any errors! Enjoy." > /sdcard/KTSR/kxvision.log
exit 0
fi