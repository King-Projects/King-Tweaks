#!/system/bin/sh
# Written by tytydraco (tytydraco @ GitHub)
# KTS by pedrozzz (pedrozzz0 @ GitHub)

wait_until_login() {
	# we doesn't have the permission to rw "/sdcard" before the user unlocks the screen
	while [[ `getprop sys.boot_completed` -ne 1 && -d "/sdcard" ]]
	do
       sleep 2
	done

    local test_file="/sdcard/.PERMISSION_TEST"
    touch "$test_file"
    while [ ! -f "$test_file" ]; do
        touch "$test_file"
        sleep 2
    done
    rm "$test_file"
}

wait_until_login

# Sleep a additional time to make sure that the system will not override any of the modifications of the main script.
sleep 55

# Execute the script
kingtweaks