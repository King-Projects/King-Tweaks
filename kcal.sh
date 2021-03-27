#!/system/bin/sh

# King Xvision 
echo 1 > /sys/devices/platform/kcal_ctrl.0/kcal_enable
echo 236 238 240 > /sys/devices/platform/kcal_ctrl.0/kcal
echo 275 > /sys/devices/platform/kcal_ctrl.0/kcal_sat
echo 253 > /sys/devices/platform/kcal_ctrl.0/kcal_val
echo 258 > /sys/devices/platform/kcal_ctrl.0/kcal_cont