#!/system/bin/sh
# KTSR by Pedro (pedrozzz0 @ GitHub)
# If you wanna use it as part of your project, please maintain the credits to it respective's author(s).

if [[ -e "/sdcard/KTSR/kcalkxvision.log" ]]; then
rm "/sdcard/KTSR/kcalkxvision.log"
fi

# King Xvision 
echo "1" > "/sys/devices/platform/kcal_ctrl.0/kcal_enable"
echo "236 238 240" > "/sys/devices/platform/kcal_ctrl.0/kcal"
echo "275" > "/sys/devices/platform/kcal_ctrl.0/kcal_sat"
echo "253" > "/sys/devices/platform/kcal_ctrl.0/kcal_val"
echo "258" > "/sys/devices/platform/kcal_ctrl.0/kcal_cont"

if [[ $? == "1" ]]; then
echo "[!] Kcal preset executed with errors." > /sdcard/KTSR/kcalkxvision.log
exit 1
else
echo "[*] Kcal preset executed without any errors! Enjoy." > /sdcard/KTSR/kcalkxvision.log
exit 0
fi