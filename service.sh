#!/system/bin/sh
# Written by Draco (tytydraco @github).
# Modified by pedrozzz (pedroginkgo @telegram).
# Enable cloudflare DNS by ROM (xerta555 @github).
# MMT Extended by Zackptg5 @ XDA

# Wait for boot to finish completely
while [[ `getprop sys.boot_completed` -ne 1 ]]
do
       sleep 2
done

# Sleep an additional 60s to ensure init is finished
sleep 60

# Setup tweaks
kingtweaks