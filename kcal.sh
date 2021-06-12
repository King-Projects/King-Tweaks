#!/system/bin/sh
# KTSR by pedro (pedrozzz0 @ GitHub)

if [[ -e "/sdcard/KTSR/kxvision.log" ]]; then
    rm "/sdcard/KTSR/kxvision.log"
fi

# King Xvision 
echo "1" > "/sys/devices/platform/kcal_ctrl.0/kcal_enable"
echo "236 238 240" > "/sys/devices/platform/kcal_ctrl.0/kcal"
echo "275" > "/sys/devices/platform/kcal_ctrl.0/kcal_sat"
echo "253" > "/sys/devices/platform/kcal_ctrl.0/kcal_val"
echo "258" > "/sys/devices/platform/kcal_ctrl.0/kcal_cont"

if [[ $? == "1" ]]; then
    echo "[!] Kcal preset executed with errors." > /sdcard/KTSR/kxvision.log
    exit 1
    
else
    echo "[*] Kcal preset executed without any errors! Enjoy." > /sdcard/KTSR/kxvision.log
    exit 0
fi