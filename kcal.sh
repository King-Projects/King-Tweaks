#!/system/bin/sh
# KTSR by pedro (pedrozzz0 @ GitHub)

KXLOG=/data/media/0/KTSR/kxvision.log

if [[ -e "$KXLOG" ]]; then
    rm -rf "$KXLOG"
fi

# King Xvision 
echo "1" > "/sys/devices/platform/kcal_ctrl.0/kcal_enable"
echo "236 238 240" > "/sys/devices/platform/kcal_ctrl.0/kcal"
echo "275" > "/sys/devices/platform/kcal_ctrl.0/kcal_sat"
echo "253" > "/sys/devices/platform/kcal_ctrl.0/kcal_val"
echo "258" > "/sys/devices/platform/kcal_ctrl.0/kcal_cont"

if [[ $? == "1" ]]; then
    echo "[!] Kcal preset executed with errors." > "$KXLOG"
    exit 1
else
    echo "[*] Kcal preset executed without any errors! Enjoy." > "$KXLOG"
    exit 0
fi