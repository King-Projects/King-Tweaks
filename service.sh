#!/system/bin/sh
# Written by tytydraco
# KTS by pedrozzz (pedroginkgo @ telegram pedrozzz0 @ github).

# Wait for boot to finish completely
while [[ `getprop sys.boot_completed` -ne 1 ]]
do
       sleep 2
done

sleep 30

# Setup tweaks
kingtweaks