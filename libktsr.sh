#!/system/bin/sh
# Written by Draco (tytydraco @ GitHub)
# KTSR by Pedro (pedrozzz0 @ GitHub)
# If you wanna use it as part of your project, please maintain the credits to it respective's author(s).

MODPATH=/data/adb/modules/KTSR

KLOG=/sdcard/KTSR/KTSR.log

# Log in white and continue (unnecessary)
kmsg() {
	echo -e "[*] $@" >> $KLOG
	echo -e "[*] $@"
}

kmsg1() {
	echo -e "$@" >> $KLOG
	echo -e "$@"
}

toast() {
	am start -a android.intent.action.MAIN -e toasttext "Applying $kts_profile profile..." -n bellavita.toast/.MainActivity
}
	
toast1() {
	am start -a android.intent.action.MAIN -e toasttext "$kts_profile profile applied" -n bellavita.toast/.MainActivity
}

toastpt() {
	am start -a android.intent.action.MAIN -e toasttext "Aplicando perfil $kts_profilept..." -n bellavita.toast/.MainActivity
}

toastpt1() {
	am start -a android.intent.action.MAIN -e toasttext "Perfil $kts_profilept aplicado" -n bellavita.toast/.MainActivity
}

toasttr() {
	am start -a android.intent.action.MAIN -e toasttext "$kts_profiletr profili uygulanıyor..." -n bellavita.toast/.MainActivity
}

toasttr1() {
	am start -a android.intent.action.MAIN -e toasttext "$kts_profiletr profili uygulandı" -n bellavita.toast/.MainActivity
}

toastin() {
	am start -a android.intent.action.MAIN -e toasttext "Menerapkan profil $kts_profilein..." -n bellavita.toast/.MainActivity
}

toastin1() {
	am start -a android.intent.action.MAIN -e toasttext "Profil $kts_profilein terpakai" -n bellavita.toast/.MainActivity
}

toastfr() {
	am start -a android.intent.action.MAIN -e toasttext "Chargement du profil $kts_profilefr..." -n bellavita.toast/.MainActivity
}

toastfr1() {
	am start -a android.intent.action.MAIN -e toasttext "Profil $kts_profilefr chargé" -n bellavita.toast/.MainActivity
}

write() {
	# Bail out if file does not exist
	if [[ ! -f "$1" ]]
	then
    kmsg "$1 doesn't exist, skipping..."
    return 1
    fi

	# Fetch the current key value
	local curval=`cat "$1" 2> /dev/null`
	
	# Bail out if value is already set
	if [[ "$curval" == "$2" ]]
	then
	kmsg "$1 is already set to $2, skipping..."
	return 1
	fi

	# Make file writable in case it is not already
	chmod +w "$1" 2> /dev/null

	# Write the new value and bail if there's an error
	if ! echo "$2" > "$1" 2> /dev/null
	then
		kmsg1 "[!] Failed: $1 -> $2"
		return 0
	fi

	# Log the success
	kmsg "$1 $curval -> $2"
}

# Detect if we are running on Android
grep -q android /proc/cmdline && ANDROID=true

# Duration in nanoseconds of one scheduling period
SCHED_PERIOD_LATENCY="$((1 * 1000 * 1000))"

SCHED_PERIOD_BALANCE="$((4 * 1000 * 1000))"

SCHED_PERIOD_BATTERY="$((8 * 1000 * 1000))"

SCHED_PERIOD_THROUGHPUT="$((10 * 1000 * 1000))"

# How many tasks should we have at a maximum in one scheduling period
SCHED_TASKS_LATENCY="10"

SCHED_TASKS_BATTERY="4"

SCHED_TASKS_BALANCE="8"

SCHED_TASKS_THROUGHPUT="6"

    # Variable to GPU directories
    for gpul in /sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0
    do
    if [ -d "$gpul" ]; then
        gpu=$gpul
        adreno=true
        fi
        done
        
    for gpul1 in /sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0
    do
    if [ -d "$gpul1" ]; then
        gpu=$gpul1
        adreno=true
        fi
        done
        
    for gpul2 in /sys/devices/*.mali
    do
    if [ -d "$gpul2" ]; then
        gpu=$gpul2
        fi
        done
        
    for gpul3 in /sys/devices/platform/*.gpu
    do
    if [ -d "$gpul3" ]; then
        gpu=$gpul3
        fi
        done
        
    for gpul4 in /sys/devices/platform/mali-*.0
    do
    if [ -d "$gpul4" ]; then
        gpu=$gpul4
        fi
        done
        
	if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
		gpu="/sys/class/kgsl/kgsl-3d0"
		adreno=true
	elif [ -d "/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0" ]; then
		gpu="/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0"
		adreno=true
	elif [ -d "/sys/devices/platform/gpusysfs" ]; then
		gpu="/sys/devices/platform/gpusysfs"
	elif [ -d "/sys/devices/platform/mali.0" ]; then
		gpu="/sys/devices/platform/mali.0"
		fi
		
		for gpul in /sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0/devfreq
        do
        if [ -d "$gpul" ]; then
         gpug=$gpul
         fi
         done  
         
       for gpul1 in /sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0/devfreq
       do
       if [ -d "$gpul1" ]; then
        gpug=$gpul1
        fi
        done
        
      for gpul2 in /sys/devices/platform/*.gpu
      do
      if [ -d "$gpul2" ]; then
        gpug=$gpul2
        fi
        done
        
	if [ -d "/sys/class/kgsl/kgsl-3d0/devfreq" ]; then
		gpug="/sys/class/kgsl/kgsl-3d0/devfreq"
	elif [ -d "/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/devfreq" ]; then
		gpug="/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/devfreq"
	elif [ -d "/sys/devices/platform/gpusysfs" ]; then
		gpug="/sys/devices/platform/gpusysfs"
	elif [ -d "/sys/module/mali/parameters" ]; then
		gpug="/sys/module/mali/parameters"		
	elif [ -d "/sys/kernel/gpu" ]; then
		gpug="/sys/kernel/gpu"
		fi

    if [[ -e $gpug/gpu_governor ]]; then
    GPU_GOVERNOR=`cat $gpug/gpu_governor`
    
    elif [[ -e $gpug/governor ]]; then
    GPU_GOVERNOR=`cat $gpug/governor`
    fi

    if [[ -e $gpu/num_pwrlevels ]]; then
    gpunpl=`cat $gpu/num_pwrlevels`
    fi
    
    gpumx=`cat $gpug/available_frequencies | awk -v var="$gpunpl" '{print $gpunpl}'`
    
    if [[ $gpumx != $gpufreq ]]; then
    gpumx=`cat $gpug/available_frequencies | awk '{print $1}'`

    elif [[ $gpumx != $gpufreq ]]; then
    gpumx=$gpufreq
    fi
    
    gpumx2=`cat $gpug/gpu_freq_table | awk '{print $7}'`
    
    if [[ $gpumx2 != $gpufreq ]]; then
    gpumx2=$gpufreq
    fi
    
    gpumin=`cat $gpug/gpu_freq_table | awk '{print $1}'`
    
# Get running CPU governor    
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do
CPU_GOVERNOR=`cat $cpu/scaling_governor` 
done

if [[ -z $adreno ]]; then
adreno=false
fi

# Get GPU minimum power level
gpuminpl=`cat $gpu/min_pwrlevel`

# Get GPU maximum power level
gpumaxpl=`cat $gpu/max_pwrlevel`

# Get max CPU frequency
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do
cpumxfreq=`cat $cpu/scaling_max_freq`
cpumxfreq2=`cat $cpu/cpuinfo_max_freq`

if [[ $cpumxfreq2 > $cpumxfreq ]]; then
cpumxfreq=$cpumxfreq2
fi
done

# Get max GPU frequency (gpumx does almost the same thing)
if [[ -e $gpu/max_gpuclk ]]; then
gpufreq=`cat $gpu/max_gpuclk`

elif [[ -e $gpug/gpu_max_clock ]]; then
gpufreq=`cat $gpug/gpu_max_clock`
fi

# Get SOC manufacturer
mf=`getprop ro.boot.hardware`

# Get device SOC
soc=`getprop ro.board.platform`

if [[ $soc == " " ]]; then
soc=`getprop ro.product.board`
fi

# Get device SDK
sdk=`getprop ro.build.version.sdk`

if [[ $sdk == " " ]]; then
sdk=`getprop ro.vendor.build.version.sdk`

elif [[ $sdk == " " ]]; then
sdk=`getprop ro.vndk.version`
fi

# Get device architeture
aarch=`getprop ro.product.cpu.abi | awk -F- '{print $1}'`

# Get android version
arv=`getprop ro.build.version.release`

# Get device codename
dcdm=`getprop ro.product.device`

# Variable to get magisk version
magisk=`magisk -c`

# Detect if we're running on a exynos SOC
if [[ `$mf | grep 'samsungexynos'` || `$soc | grep 'universal'` ]]; then
exynos=true
else
exynos=false
fi

# Detect if we're running on a mediatek SOC
if [[ `$soc | grep 'mt'` ]]; then
mtk=true
else
mtk=false
fi

# Detect CPU scheduling type
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do
if [[ `cat $cpu/scaling_available_governors | grep 'sched'` ]]; then
cpusched=EAS

elif [[ `cat $cpu/scaling_available_governors | grep 'interactive'` ]]; then
cpusched=HMP

else
cpusched=Unknown
fi
done

# Get kernel name
kname=`uname -r`

# Get kernel build date
kbdd=`uname -v | awk '{print $5, $6, $7, $8, $9, $10}'`

# Get device total amount of memory RAM
totalram=`free -m | awk '/Mem:/{print $2}'`

# Get device total amount of available RAM
availram=`free -m | grep Mem: | awk '{print $6}'`

# Get battery actual capacity
if [[ -e /sys/class/power_supply/battery/capacity ]]; then
gbpercentage=`cat /sys/class/power_supply/battery/capacity`

else
gbpercentage=`dumpsys battery | awk '/level/{print $2}'`
fi

# Get KTSR version
gbversion=`cat $MODPATH/module.prop | grep version= | sed "s/version=//"`

# Get KTSR build type
gbtype=`cat $MODPATH/ktsr.prop | grep buildtype= | sed "s/buildtype=//"`

# Get KTSR build date
gbdate=`cat $MODPATH/ktsr.prop | grep builddate= | sed "s/builddate=//"`

# Get KTSR build codename
gbcodename=`cat $MODPATH/ktsr.prop | grep codename= | sed "s/codename=//"`

# Get battery temperature
if [[ -e /sys/class/power_supply/battery/temp ]]
then
btemp=`cat /sys/class/power_supply/battery/temp`

elif [[ -e /sys/class/power_supply/battery/batt_temp ]]
then 
btemp=`cat /sys/class/power_supply/battery/batt_temp`

else 
btemp=`dumpsys battery | awk '/temperature/{print $2}'`
fi

# Get GPU info
gpuinfo=`dumpsys SurfaceFlinger | awk '/GLES/ {print $3,$4,$5}' | tr -d ,`

# Get drivers info
driversinfo=`dumpsys SurfaceFlinger | awk '/GLES/ {print $6,$7,$8,$9,$10,$11,$12,$13}' | tr -d ,`

# Ignore the decimal
gbtemp=$((btemp / 10))

# Get display FPS 
df=`dumpsys display | awk '/PhysicalDisplayInfo/{print $4}' | cut -c1-3 | tr -d .`

if [[ -z $df ]]; then
df=`dumpsys display | grep refreshRate | awk -F '=' '{print $6}' | cut -c1-3 | tr -d .`

elif [[ -z $df ]]; then
df=`dumpsys display | grep FrameRate | awk -F '=' '{print $6}' | cut -c1-3 | tr -d .`
fi

# Get battery health
if [[ -e /sys/class/power_supply/battery/health ]]; then
gbhealth=`cat /sys/class/power_supply/battery/health`

else
gbhealth=`dumpsys battery | awk '/health/{print $2}'`
fi

if [[ $gbhealth == "1" ]]; then
bhealth=Unknown

elif [[ $gbhealth == "2" ]]; then
bhealth=Good

elif [[ $gbhealth == "3" ]]; then
bhealth=Overheat

elif [[ $gbhealth == "4" ]]; then
bhealth=Dead

elif [[ $gbhealth == "5" ]]; then
bhealth=Over voltage

elif [[ $gbhealth == "6" ]]; then
bhealth=Unspecified failure

elif [[ $gbhealth == "7" ]]; then
bhealth=Cold

else
bhealth=$gbhealth
fi

# Get battery status
if [[ -e /sys/class/power_supply/battery/status ]]; then
gbstatus=`cat /sys/class/power_supply/battery/status`

else
gbstatus=`dumpsys battery | awk '/status/{print $2}'`
fi

if [[ $gbstatus == "1" ]]; then
bstatus=Unknown

elif [[ $gbstatus == "2" ]]; then
bstatus=Charging

elif [[ $gbstatus == "3" ]]; then
bstatus=Discharging

elif [[ $gbstatus == "4" ]]; then
bstatus=Not charging

elif [[ $gbstatus == "5" ]]; then
bstatus=Full

else
bstatus=$gbstatus
fi

###############################
# Abbreviations
###############################

tcp=/proc/sys/net/ipv4/

kernel=/proc/sys/kernel/

vm=/proc/sys/vm/

cpuset=/dev/cpuset/

stune=/dev/stune/

# Latency Profile
latency() {
     	init=`date +%s`
     	
kmsg1 "----------------------------------------------------- Info -------------------------------------------------------------------------------------------------"
kmsg1 "                                            🕛 Date of execution: $(date)                                                                                   " 
kmsg1 "                                            🔧 Kernel: $kname                                                                                               "
kmsg1 "                                            🗓️ Kernel Build Date: $kbdd                                                                                     "
kmsg1 "                                            🛠️ SOC: $mf, $soc                                                                                               "
kmsg1 "                                            ⚙️ SDK: $sdk                                                                                                    "
kmsg1 "                                            ⚒️ CPU Governor: $CPU_GOVERNOR                                                                                  "
kmsg1 "                                            ⚖️ CPU Scheduling Type: $cpusched                                                                               "
kmsg1 "                                            ⛓️ CPU AArch: $aarch                                                                                            "
kmsg1 "                                            🖼️ GPU Info: $gpuinfo                                                                                           "
kmsg1 "                                            📲 Drivers Info: $driversinfo                                                                                   "
kmsg1 "                                            ⛏️ GPU Governor: $GPU_GOVERNOR                                                                                  "
kmsg1 "                                            🅰️ndroid Version: $arv                                                                                          "
kmsg1 "                                            📱 Device: $dcdm                                                                                                "
kmsg1 "                                            🎞️ FPS: $df                                                                                                     "
kmsg1 "                                            👑 KTSR Version: $gbversion                                                                                     "
kmsg1 "                                            💭 KTSR Codename: $gbcodename                                                                                   "
kmsg1 "                                            📀 Build Type: $gbtype                                                                                          "
kmsg1 "                                            ⏰ Build Date: $gbdate                                                                                          "
kmsg1 "                                            🔋 Battery Charge Level: $gbpercentage%                                                                         "
kmsg1 "                                            🩹 Battery Health: $bhealth                                                                                     "
kmsg1 "                                            🔩 Battery Status: $bstatus                                                                                     "
kmsg1 "                                            🌡️ Battery Temperature: $gbtemp°C                                                                               "
kmsg1 "                                            💾 Device RAM: $totalram MB                                                                                     "
kmsg1 "                                            📁 Device Available RAM: $availram MB                                                                                     "
kmsg1 "                                            👺 Magisk: $magisk                                                                                              "
kmsg1 "------------------------------------------------------------------------------------------------------------------------------------------------------------"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLING LATENCY PROFILE.                                                                       "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

for panic in /proc/sys/*/*panic*
do
write "$panic" "0"
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED KERNEL PANIC.                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Enable perf and mpdecision.
start perfd  	
start mpdecision

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED PERFD AND MPDECISION.                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Do not stop thermal daemons, configure thermal config instead
if [[ -e "/sys/class/thermal/thermal_message" ]]; then
write "/sys/class/thermal/thermal_message/sconfig" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED THERMAL PROFILE.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]
then
write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "20"
write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1500"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED STUNE BOOST.                                                                                   "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# I/O Scheduler Tweaks
for queue in /sys/block/*/queue/
do

    # Choose the first governor available
	avail_scheds="$(cat "$queue/scheduler")"
	for sched in tripndroid bfq-sq bfq-mq bfq fiops zen sio anxiety mq-deadline cfq noop none
	do
		if [[ "$avail_scheds" == *"$sched"* ]]
		then
			write "$queue/scheduler" "$sched"
			break
		fi
	done
	
write "${queue}add_random" 0
write "${queue}iostats" 0
write "${queue}rotational" 0
write "${queue}read_ahead_kb" 32
write "${queue}iosched/low_latency" 1
write "${queue}nomerges" 2
write "${queue}rq_affinity" 2
write "${queue}nr_requests" 16
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED I/O SCHEDULER.                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# CPU Tweaks
for cpu in /sys/devices/system/cpu/cpu*/cpufreq
do
	# Fetch the available governors from the CPU
	avail_govs="$(cat "$cpu/scaling_available_governors")"

	# Attempt to set the governor in this order
	for governor in schedutil interactive
	do
		# Once a matching governor is found, set it and break for this CPU
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$cpu/scaling_governor" "$governor"
			break
		fi
	done
done

# Apply governor specific tunables for schedutil
find /sys/devices/system/cpu/ -name schedutil -type d | while IFS= read -r governor
do
write "$governor/up_rate_limit_us" "1000"
write "$governor/down_rate_limit_us" "1000"
write "$governor/pl" "1"
write "$governor/iowait_boost_enable" "1"
write "$governor/rate_limit_us" "5000"
write "$governor/hispeed_load" "89"
write "$governor/hispeed_freq" "$cpumxfreq"
done

# Apply governor specific tunables for interactive
find /sys/devices/system/cpu/ -name interactive -type d | while IFS= read -r governor
do
write "$governor/timer_rate" "1000"
write "$governor/boost" "0"
write "$governor/timer_slack" "1000"
write "$governor/input_boost" "0"
write "$governor/use_migration_notif" "0" 
write "$governor/ignore_hispeed_on_notif" "1"
write "$governor/use_sched_load" "1"
write "$governor/fastlane" "1"
write "$governor/fast_ramp_down" "0"
write "$governor/sampling_rate" "1000"
write "$governor/sampling_rate_min" "5000"
write "$governor/min_sample_time" "5000"
write "$governor/go_hispeed_load" "89"
write "$governor/hispeed_freq" "$cpumxfreq"
done

for cpu in /sys/devices/system/cpu/cpu*
do
write "$cpu/online" "1"
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                         TWEAKED CPU.                                                                                          "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Schedtune Tweaks
[[ $ANDROID == "true" ]] && if [[ -d "$stune" ]]; then
write "${stune}background/schedtune.boost" "0"
write "${stune}background/schedtune.prefer_idle" "0"
write "${stune}background/schedtune.sched_boost" "0"
write "${stune}background/schedtune.prefer_perf" "0"

write "${stune}foreground/schedtune.boost" "10"
write "${stune}foreground/schedtune.prefer_idle" "1"
write "${stune}foreground/schedtune.sched_boost" "0"
write "${stune}foreground/schedtune.prefer_perf" "0"

write "${stune}rt/schedtune.boost" "0"
write "${stune}rt/schedtune.prefer_idle" "0"
write "${stune}rt/schedtune.sched_boost" "0"
write "${stune}rt/schedtune.prefer_perf" "0"

write "${stune}top-app/schedtune.boost" "10"
write "${stune}top-app/schedtune.prefer_idle" "1"
write "${stune}top-app/schedtune.sched_boost" "15"
write "${stune}top-app/schedtune.sched_boost_no_override" "1"
write "${stune}top-app/schedtune.prefer_perf" "1"

write "${stune}schedtune.boost" "0"
write "${stune}schedtune.prefer_idle" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED SCHEDTUNE TWEAKS.                                                                           "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# FS Tweaks
if [[ -d "/proc/sys/fs" ]]
then
write "/proc/sys/fs/dir-notify-enable" "0"
write "/proc/sys/fs/lease-break-time" "15"
write "/proc/sys/fs/leases-enable" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED FS TWEAKS.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Enable dynamic_fsync
if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]
then
write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED DYNAMIC FSYNC.                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Scheduler features
if [[ -e "/sys/kernel/debug/sched_features" ]]
then
write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
write "/sys/kernel/debug/sched_features" "NO_GENTLE_FAIR_SLEEPERS"
write "/sys/kernel/debug/sched_features" "NO_WAKEUP_PREEMPTION"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED SCHEDULER FEATURES.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi
 
# OP Chain disable
if [[ -d "/sys/module/opchain" ]]
then
write "/sys/module/opchain/parameters/chain_on" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED ONEPLUS CHAIN.                                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -d "/sys/module/mmc_core" ]];
then
write "/sys/module/mmc_core/parameters/use_spi_crc" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED MMC CRC.                                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Tweak some kernel settings to improve overall performance.
write "${kernel}sched_child_runs_first" "1"
write "${kernel}perf_cpu_time_max_percent" "4"
write "${kernel}sched_autogroup_enabled" "1"
write "${kernel}random/read_wakeup_threshold" "64"
write "${kernel}random/write_wakeup_threshold" "512"
write "${kernel}random/urandom_min_reseed_secs" "90"
write "${kernel}sched_tunable_scaling" "0"
write "${kernel}sched_latency_ns" "$SCHED_PERIOD_LATENCY"
write "${kernel}sched_min_granularity_ns" "$((SCHED_PERIOD_LATENCY / SCHED_TASKS_LATENCY))"
write "${kernel}sched_wakeup_granularity_ns" "$((SCHED_PERIOD_LATENCY / 2))"
write "${kernel}sched_migration_cost_ns" "5000000"
[[ "$ANDROID" == "true" ]] && write "${kernel}sched_min_task_util_for_colocation" "0"
[[ "$ANDROID" == "true" ]] && write "${kernel}sched_min_task_util_for_boost" "0"
write "${kernel}sched_nr_migrate" "2"
write "${kernel}sched_schedstats" "0"
write "${kernel}sched_enable_thread_grouping" "1"
write "${kernel}sched_rr_timeslice_ms" "1"
write "${kernel}sched_cstate_aware" "1"
write "${kernel}sched_sync_hint_enable" "0"
write "${kernel}sched_user_hint" "0"
write "${kernel}printk_devkmsg" "off"
write "${kernel}timer_migration" "0"

# Use rcu_normal instead of rcu_expedited
write "/sys/kernel/rcu_expedited" 0
write "/sys/kernel/rcu_normal" 1

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED KERNEL SETTINGS.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Set min and max clocks.
for minclk in /sys/devices/system/cpu/cpufreq/policy*/
do
if [[ -e "${minclk}scaling_min_freq" ]]
then
write "${minclk}scaling_min_freq" "300000"
write "${minclk}scaling_max_freq" "$cpumxfreq"
fi
done

for mnclk in /sys/devices/system/cpu/cpu*/cpufreq/
do
if [[ -e "${mnclk}scaling_min_freq" ]]
then
write "${mnclk}scaling_min_freq" "300000"
write "${mnclk}scaling_max_freq" "$cpumxfreq"
fi
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          SET MIN AND MAX CPU CLOCKS.                                                                      "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]] 
then
write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ALLOWED CPUIDLE TO USE DEEPEST STATE.                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

sync

# VM settings to improve overall user experience and smoothness.
write "${vm}dirty_background_ratio" "10"
write "${vm}dirty_ratio" "25"
write "${vm}dirty_expire_centisecs" "3000"
write "${vm}dirty_writeback_centisecs" "3000"
write "${vm}page-cluster" "0"
write "${vm}stat_interval" "60"
write "${vm}extfrag_threshold" "750"
# Follow SSWAP if device haven't more than 4 GB ram on exynos SOC's
if [[ $exynos == "true" && $totalram -lt "4000" ]]; then
write "${vm}swappiness" "150"
else
write "${vm}swappiness" "100"
fi
write "${vm}laptop_mode" "0"
write "${vm}vfs_cache_pressure" "200"
[[ $totalram -lt "5000" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED VM TWEAKS.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Enable power efficient workqueue.
if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]
then 
write "/sys/module/workqueue/parameters/power_efficient" "Y"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED POWER EFFICIENT WORKQUEUE.                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]
then
write "/sys/devices/system/cpu/sched_mc_power_savings" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED MULTICORE POWER SAVINGS.                                                                     "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Fetch the available TCP congestion control 
avail_con=`cat "${tcp}tcp_available_congestion_control"`
	
    # Attempt to set the TCP congestion control in this order
    for tcpcc in bbr2 bbr cubic westwood 
	do
	    # Once a matching TCP congestion control is found, set it and break
		if [[ "$avail_con" == *"$tcpcc"* ]]
		then
			write ${tcp}tcp_congestion_control $tcpcc
			break
		fi
	done
	
# Internet Tweaks
write "${tcp}ip_no_pmtu_disc" "0"
write "${tcp}tcp_ecn" "1"
write "${tcp}tcp_timestamps" "0"
write "${tcp}route.flush" "1"
write "${tcp}tcp_rfc1337" "1"
write "${tcp}tcp_tw_reuse" "1"
write "${tcp}tcp_sack" "1"
write "${tcp}tcp_fack" "1"
write "${tcp}tcp_fastopen" "3"
write "${tcp}tcp_tw_recycle" "1"
write "${tcp}tcp_no_metrics_save" "1"
write "${tcp}tcp_syncookies" "0"
write "${tcp}tcp_window_scaling" "1"
write "${tcp}tcp_keepalive_probes" "10"
write "${tcp}tcp_keepalive_intvl" "30"
write "${tcp}tcp_fin_timeout" "30"
write "${tcp}tcp_low_latency" "1"
write "/proc/sys/net/core/netdev_tstamp_prequeue" "0"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED INTERNET TWEAKS.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

if [[ -e "/sys/kernel/sched/gentle_fair_sleepers" ]]
then
write "/sys/kernel/sched/gentle_fair_sleepers" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DİSABLED GENTLE FAIR SLEEPERS.                                                                       "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Enable Fast Charging Rate
if [[ -e "/sys/kernel/fast_charge/force_fast_charge" ]]
then
write "/sys/kernel/fast_charge/force_fast_charge" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED USB FAST CHARGING.                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/class/sec/switch/afc_disable" ]];
then
write "/sys/class/sec/switch/afc_disable" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED FAST CHARGING ON SAMSUNG DEVICES.                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          LATENCY PROFILE APPLIED WITH SUCCESS.                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          END OF EXECUTION: $(date)                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
exit=`date +%s`

exectime=$((exit - init))
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          EXECUTION DONE IN $exectime SECONDS.                                                                   "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
}
# Automatic Profile
automatic() {
     	
     	kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLING AUTOMATIC PROFILE...                                                                       "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"       	

	sync
	kingauto
	
	kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          AUTOMATIC PROFILE ENABLED.                                                                       "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
}
# Balanced Profile
balanced() {
         init=`date +%s`
     	
kmsg1 "----------------------------------------------------- Info -------------------------------------------------------------------------------------------------"
kmsg1 "                                            🕛 Date of execution: $(date)                                                                                   " 
kmsg1 "                                            🔧 Kernel: $kname                                                                                               "
kmsg1 "                                            🗓️ Kernel Build Date: $kbdd                                                                                     "
kmsg1 "                                            🛠️ SOC: $mf, $soc                                                                                               "
kmsg1 "                                            ⚙️ SDK: $sdk                                                                                                    "
kmsg1 "                                            ⚒️ CPU Governor: $CPU_GOVERNOR                                                                                  "
kmsg1 "                                            ⚖️ CPU Scheduling Type: $cpusched                                                                               "
kmsg1 "                                            ⛓️ CPU AArch: $aarch                                                                                            "
kmsg1 "                                            🖼️ GPU Info: $gpuinfo                                                                                           "
kmsg1 "                                            📲 Drivers Info: $driversinfo                                                                                   "
kmsg1 "                                            ⛏️ GPU Governor: $GPU_GOVERNOR                                                                                  "
kmsg1 "                                            🅰️ndroid Version: $arv                                                                                          "
kmsg1 "                                            📱 Device: $dcdm                                                                                                "
kmsg1 "                                            🎞️ FPS: $df                                                                                                     "
kmsg1 "                                            👑 KTSR Version: $gbversion                                                                                     "
kmsg1 "                                            💭 KTSR Codename: $gbcodename                                                                                   "
kmsg1 "                                            📀 Build Type: $gbtype                                                                                          "
kmsg1 "                                            ⏰ Build Date: $gbdate                                                                                          "
kmsg1 "                                            🔋 Battery Charge Level: $gbpercentage%                                                                         "
kmsg1 "                                            🩹 Battery Health: $bhealth                                                                                     "
kmsg1 "                                            🔩 Battery Status: $bstatus                                                                                     "
kmsg1 "                                            🌡️ Battery Temperature: $gbtemp°C                                                                               "
kmsg1 "                                            💾 Device RAM: $totalram MB                                                                                     "
kmsg1 "                                            📁 Device Available RAM: $availram MB                                                                                     "
kmsg1 "                                            👺 Magisk: $magisk                                                                                              "
kmsg1 "------------------------------------------------------------------------------------------------------------------------------------------------------------"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLING BALANCED PROFILE...                                                                       "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"       	

for panic in /proc/sys/*/*panic*
do
write "$panic" "0"
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED KERNEL PANIC.                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Enable perfd and mpdecision
start perfd
start mpdecision

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED PERFD AND MPDECISION.                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Do not stop thermal daemons, configure thermal config instead
if [[ -e "/sys/class/thermal/thermal_message" ]]; then
write "/sys/class/thermal/thermal_message/sconfig" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED THERMAL PROFILE.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]
then
write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "15"
write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1500"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED STUNE BOOST.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

for corectl in /sys/devices/system/cpu/cpu*/core_ctl
do
if [[ -e "${corectl}/enable" ]]
then
write "${corectl}/enable" "1"

elif [[ -e "${corectl}/disable" ]]
then
write "${corectl}/disable" "0"
fi
done

if [[ -e "/sys/power/cpuhotplug/enable" ]]
then
write "/sys/power/cpuhotplug/enable" "1"

elif [[ -e "/sys/power/cpuhotplug/enabled" ]]
then
write "/sys/power/cpuhotplug/enabled" "1"
fi

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED CORE CONTROL & CPU HOTPLUG.                                                                               "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# I/O Scheduler Tweaks
for queue in /sys/block/*/queue/
do

    # Choose the first governor available
	avail_scheds="$(cat "$queue/scheduler")"
	for sched in tripndroid bfq-sq bfq-mq bfq fiops zen sio anxiety mq-deadline cfq noop none
	do
		if [[ "$avail_scheds" == *"$sched"* ]]
		then
			write "$queue/scheduler" "$sched"
			break
		fi
	done
	
write "${queue}add_random" 0
write "${queue}iostats" 0
write "${queue}rotational" 0
write "${queue}read_ahead_kb" 128
write "${queue}iosched/low_latency" 1
write "${queue}nomerges" 2
write "${queue}rq_affinity" 1
write "${queue}nr_requests" 64
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED I/O SCHEDULER.                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# CPU Tweaks
for cpu in /sys/devices/system/cpu/cpu*/cpufreq
do
	# Fetch the available governors from the CPU
	avail_govs="$(cat "$cpu/scaling_available_governors")"

	# Attempt to set the governor in this order
	for governor in schedutil interactive
	do
		# Once a matching governor is found, set it and break for this CPU
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$cpu/scaling_governor" "$governor"
			break
		fi
	done
done

# Apply governor specific tunables for schedutil
find /sys/devices/system/cpu/ -name schedutil -type d | while IFS= read -r governor
do
write "$governor/up_rate_limit_us" "$((SCHED_PERIOD_BALANCE / 1000))"
write "$governor/down_rate_limit_us" "$((4 * SCHED_PERIOD_BALANCE / 1000))"
write "$governor/pl" "0"
write "$governor/iowait_boost_enable" "0"
write "$governor/rate_limit_us" "$((4 * SCHED_PERIOD_BALANCE / 1000))"
write "$governor/hispeed_load" "89"
write "$governor/hispeed_freq" "$cpumxfreq"
done

# Apply governor specific tunables for interactive
find /sys/devices/system/cpu/ -name interactive -type d | while IFS= read -r governor
do
write "$governor/timer_rate" "42000"
write "$governor/boost" "0"
write "$governor/timer_slack" "42000"
write "$governor/input_boost" "0"
write "$governor/use_migration_notif" "0" 
write "$governor/ignore_hispeed_on_notif" "1"
write "$governor/use_sched_load" "1"
write "$governor/boostpulse" "0"
write "$governor/fastlane" "1"
write "$governor/fast_ramp_down" "0"
write "$governor/sampling_rate" "42000"
write "$governor/sampling_rate_min" "60000"
write "$governor/min_sample_time" "60000"
write "$governor/go_hispeed_load" "89"
write "$governor/hispeed_freq" "$cpumxfreq"
done

for cpu in /sys/devices/system/cpu/cpu*
do
write "$cpu/online" "1"
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                         TWEAKED CPU.                                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# GPU Tweaks

	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpug/available_governors")"

	# Attempt to set the governor in this order
	for governor in simple_ondemand ondemand msm-adreno-tz
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpug/governor" "$governor"
			break
		fi
	done
	
	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpug/gpu_available_governor")"

	# Attempt to set the governor in this order
	for governor in Interactive Static
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpug/gpu_governor" "$governor"
			break
		fi
	done
	
[[ $adreno == "true" ]] && write "$gpu/throttling" "1"
[[ $adreno == "true" ]] && write "$gpu/thermal_pwrlevel" "0"
[[ $adreno == "true" ]] && write "$gpu/devfreq/adrenoboost" "0"
[[ $adreno == "true" ]] && write "$gpu/force_no_nap" "0"
[[ $adreno == "true" ]] && write "$gpu/bus_split" "1"
[[ $adreno == "true" ]] && write "$gpu/devfreq/max_freq" "$gpufreq"
[[ $adreno == "true" ]] && write "$gpu/devfreq/min_freq" "100000000"
[[ $adreno == "true" ]] && write "$gpu/default_pwrlevel" "$gpuminpl"
[[ $adreno == "true" ]] && write "$gpu/force_bus_on" "0"
[[ $adreno == "true" ]] && write "$gpu/force_clk_on" "0"
[[ $adreno == "true" ]] && write "$gpu/force_rail_on" "0"
[[ $adreno == "true" ]] && write "$gpu/idle_timer" "66"
[[ $adreno == "true" ]] && write "$gpu/pwrnap" "1"
[[ $adreno == "false" ]] && write "$gpug/gpu_min_clock" $gpumin

if [[ -e "/proc/gpufreq/gpufreq_limited_thermal_ignore" ]] 
then
write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
fi

# Enable dvfs
if [[ -e "/proc/mali/dvfs_enable" ]] 
then
write "/proc/mali/dvfs_enable" "1"
fi

if [[ -e "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" ]] 
then
write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"
fi

if [[ -e "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" ]]
then
write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "1"
fi

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED GPU.                                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
	
# Enable and tweak adreno idler
if [[ -d "/sys/module/adreno_idler" ]]
then
write "/sys/module/adreno_idler/parameters/adreno_idler_active" "Y"
write "/sys/module/adreno_idler/parameters/adreno_idler_idleworkload" "6000"
write "/sys/module/adreno_idler/parameters/adreno_idler_downdifferential" "25"
write "/sys/module/adreno_idler/parameters/adreno_idler_idlewait" "25"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED AND TWEAKED ADRENO IDLER...                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Schedtune Tweaks
[[ $ANDROID == "true" ]] && if [[ -d "$stune" ]]
then
write "${stune}background/schedtune.boost" "0"
write "${stune}background/schedtune.prefer_idle" "0"
write "${stune}background/schedtune.sched_boost" "0"
write "${stune}background/schedtune.prefer_perf" "0"

write "${stune}foreground/schedtune.boost" "5"
write "${stune}foreground/schedtune.prefer_idle" "1"
write "${stune}foreground/schedtune.sched_boost" "0"
write "${stune}foreground/schedtune.prefer_perf" "0"

write "${stune}rt/schedtune.boost" "0"
write "${stune}rt/schedtune.prefer_idle" "0"
write "${stune}rt/schedtune.sched_boost" "0"
write "${stune}rt/schedtune.prefer_perf" "0"

write "${stune}top-app/schedtune.boost" "10"
write "${stune}top-app/schedtune.prefer_idle" "1"
write "${stune}top-app/schedtune.sched_boost" "15"
write "${stune}top-app/schedtune.sched_boost_no_override" "1"
write "${stune}top-app/schedtune.prefer_perf" "1"

write "${stune}schedtune.boost" "0"
write "${stune}schedtune.prefer_idle" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED SCHEDTUNE TWEAKS.                                                                           "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# FS Tweaks
if [[ -d "/proc/sys/fs" ]]
then
write "/proc/sys/fs/dir-notify-enable" "0"
write "/proc/sys/fs/lease-break-time" "15"
write "/proc/sys/fs/leases-enable" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED FS TWEAKS.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Enable dynamic_fsync
if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]
then
write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED DYNAMIC FSYNC.                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Scheduler features
if [[ -e "/sys/kernel/debug/sched_features" ]]
then
write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
write "/sys/kernel/debug/sched_features" "NO_GENTLE_FAIR_SLEEPERS"
write "/sys/kernel/debug/sched_features" "WAKEUP_PREEMPTION"
fi

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED SCHEDULER FEATURES.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# OP Chain disable
if [[ -d "/sys/module/opchain" ]]
then
write "/sys/module/opchain/parameters/chain_on" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED ONEPLUS CHAIN.                                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -d "/sys/module/mmc_core" ]];
then
write "/sys/module/mmc_core/parameters/use_spi_crc" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED MMC CRC.                                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Tweak some kernel settings to improve overall performance
write "${kernel}sched_child_runs_first" "1"
write "${kernel}sched_boost" "0"
write "${kernel}perf_cpu_time_max_percent" "10"
write "${kernel}sched_autogroup_enabled" "1"
write "${kernel}random/read_wakeup_threshold" "64"
write "${kernel}random/write_wakeup_threshold" "256"
write "${kernel}sched_tunable_scaling" "0"
write "${kernel}sched_latency_ns" "$SCHED_PERIOD_BALANCE"
write "${kernel}sched_min_granularity_ns" "$((SCHED_PERIOD_BALANCE / SCHED_TASKS_BALANCE))"
write "${kernel}sched_wakeup_granularity_ns" "$((SCHED_PERIOD_BALANCE / 2))"
write "${kernel}sched_migration_cost_ns" "5000000"
[[ "$ANDROID" == "true" ]] && write "${kernel}sched_min_task_util_for_colocation" "0"
[[ "$ANDROID" == "true" ]] && write "${kernel}sched_min_task_util_for_boost" "0"
write "${kernel}sched_nr_migrate" "32"
write "${kernel}sched_schedstats" "0"
write "${kernel}sched_enable_thread_grouping" "1"
write "${kernel}sched_rr_timeslice_ms" "1"
write "${kernel}sched_cstate_aware" "1"
write "${kernel}sched_sync_hint_enable" "0"
write "${kernel}sched_user_hint" "0"
write "${kernel}printk_devkmsg" "off"
write "${kernel}timer_migration" "0"

# Use rcu_normal instead of rcu_expedited
write "/sys/kernel/rcu_expedited" 0
write "/sys/kernel/rcu_normal" 1

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED KERNEL SETTINGS.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Enable fingerprint boost
if [[ -e "/sys/kernel/fp_boost/enabled" ]]
then
write "/sys/kernel/fp_boost/enabled" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED FINGERPRINT BOOST.                                                                          "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Set min and max clocks
for minclk in /sys/devices/system/cpu/cpufreq/policy*/
do
if [[ -e "${minclk}scaling_min_freq" ]]
then
write "${minclk}scaling_min_freq" "300000"
write "${minclk}scaling_max_freq" "$cpumxfreq"
fi
done

for mnclk in /sys/devices/system/cpu/cpu*/cpufreq/
do
if [[ -e "${mnclk}scaling_min_freq" ]]
then
write "${mnclk}scaling_min_freq" "300000"
write "${mnclk}scaling_max_freq" "$cpumxfreq"
fi
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          SET MIN AND MAX CPU CLOCKS.                                                                      "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]] 
then
write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ALLOWED CPUIDLE TO USE DEEPEST STATE.                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Disable krait voltage boost
if [[ -e "/sys/module/acpuclock_krait/parameters/boost" ]] 
then
write "/sys/module/acpuclock_krait/parameters/boost" "N"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED KRAIT VOLTAGE BOOST.                                                                       "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

sync

# VM settings to improve overall user experience and smoothness.
write "${vm}drop_caches" "3"
write "${vm}dirty_background_ratio" "10"
write "${vm}dirty_ratio" "30"
write "${vm}dirty_expire_centisecs" "1000"
write "${vm}dirty_writeback_centisecs" "3000"
write "${vm}page-cluster" "0"
write "${vm}stat_interval" "60"
write "${vm}extfrag_threshold" "750"
# Follow SSWAP if device haven't more than 4 GB ram on exynos SOC's
if [[ $exynos == "true" && $totalram -lt "4000" ]]; then
write "${vm}swappiness" "150"
else
write "${vm}swappiness" "100"
fi
write "${vm}laptop_mode" "0"
write "${vm}vfs_cache_pressure" "100"
[[ $totalram -lt "5000" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED VM TWEAKS.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# MSM thermal tweaks
if [[ -d "/sys/module/msm_thermal" ]]
then
write /sys/module/msm_thermal/vdd_restriction/enabled "0"
write /sys/module/msm_thermal/core_control/enabled "1"
write /sys/module/msm_thermal/parameters/enabled "Y"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED THERMAL TWEAKS.                                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Enable power efficient workqueue
if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]
then 
write "/sys/module/workqueue/parameters/power_efficient" "Y"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED POWER EFFICIENT WORKQUEUE.                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]
then
write "/sys/devices/system/cpu/sched_mc_power_savings" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED MULTICORE POWER SAVINGS.                                                                     "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Fix DT2W.
if [[ -e "/sys/touchpanel/double_tap" && -e "/proc/tp_gesture" && -e "/sys/class/sec/tsp/dt2w_enable" ]]
then
write "/sys/touchpanel/double_tap" "1"
write "/proc/tp_gesture" "1"
write "/sys/class/sec/tsp/dt2w_enable" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          FIXED DOUBLE TAP TO WAKEUP IF BROKEN.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

elif [[ -e /sys/class/sec/tsp/dt2w_enable ]]
then
write "/sys/class/sec/tsp/dt2w_enable" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          FIXED DOUBLE TAP TO WAKEUP IF BROKEN.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

elif [[ -e "/proc/tp_gesture" ]]
then
write "/proc/tp_gesture" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          FIXED DOUBLE TAP TO WAKEUP IF BROKEN.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

elif [[ -e "/sys/touchpanel/double_tap" ]]
then
write "/sys/touchpanel/double_tap" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          FIXED DOUBLE TAP TO WAKEUP IF BROKEN.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Disable touch boost on balance and battery profile
if [[ -e /sys/module/msm_performance/parameters/touchboost ]]
then
write "/sys/module/msm_performance/parameters/touchboost" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED TOUCH BOOST.                                                                               "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

elif [[ -e /sys/power/pnpmgr/touch_boost ]]
then
write "/sys/power/pnpmgr/touch_boost" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED TOUCH BOOST.                                                                               "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Fetch the available TCP congestion control 
avail_con=`cat "${tcp}tcp_available_congestion_control"`
	
    # Attempt to set the TCP congestion control in this order
    for tcpcc in bbr2 bbr cubic westwood 
	do
	    # Once a matching TCP congestion control is found, set it and break
		if [[ "$avail_con" == *"$tcpcc"* ]]
		then
			write ${tcp}tcp_congestion_control $tcpcc
			break
		fi
	done
	
# Internet Tweaks
write "${tcp}ip_no_pmtu_disc" "0"
write "${tcp}tcp_ecn" "1"
write "${tcp}tcp_timestamps" "0"
write "${tcp}route.flush" "1"
write "${tcp}tcp_rfc1337" "1"
write "${tcp}tcp_tw_reuse" "1"
write "${tcp}tcp_sack" "1"
write "${tcp}tcp_fack" "1"
write "${tcp}tcp_fastopen" "3"
write "${tcp}tcp_tw_recycle" "1"
write "${tcp}tcp_no_metrics_save" "1"
write "${tcp}tcp_syncookies" "0"
write "${tcp}tcp_window_scaling" "1"
write "${tcp}tcp_keepalive_probes" "10"
write "${tcp}tcp_keepalive_intvl" "30"
write "${tcp}tcp_fin_timeout" "30"
write "${tcp}tcp_low_latency" "1"
write "/proc/sys/net/core/netdev_tstamp_prequeue" "0"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED INTERNET TWEAKS.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Disable high perf audio
for hpm in /sys/module/snd_soc_wcd*
do
if [[ -e "$hpm" ]]
then
write "${hpm}/parameters/high_perf_mode" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED HIGH PERFORMANCE AUDIO.                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
break
fi
done

# Enable LPM sleep in balanced / battery profile
for lpm in /sys/module/lpm_levels/system/*/*/*/
do
if [[ -d "/sys/module/lpm_levels" ]]
then
write "/sys/module/lpm_levels/parameters/lpm_prediction" "Y"
write "/sys/module/lpm_levels/parameters/lpm_ipi_prediction" "Y"
write "/sys/module/lpm_levels/parameters/sleep_disabled" "N"
write "${lpm}idle_enabled" "Y"
write "${lpm}suspend_enabled" "Y"
fi
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED LPM SLEEP.                                                                                 "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

if [[ -e "/sys/module/pm2/parameters/idle_sleep_mode" ]] 
then
write "/sys/module/pm2/parameters/idle_sleep_mode" "Y"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED PM2 IDLE SLEEP MODE.                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/class/lcd/panel/power_reduce" ]] 
then
write "/sys/class/lcd/panel/power_reduce" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED LCD POWER REDUCE.                                                                          "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/kernel/sched/gentle_fair_sleepers" ]]
then
write "/sys/kernel/sched/gentle_fair_sleepers" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED GENTLE FAIR SLEEPERS.                                                                       "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Enable Fast Charging Rate
if [[ -e "/sys/kernel/fast_charge/force_fast_charge" ]]
then
write "/sys/kernel/fast_charge/force_fast_charge" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED USB FAST CHARGING.                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/class/sec/switch/afc_disable" ]];
then
write "/sys/class/sec/switch/afc_disable" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED FAST CHARGING ON SAMSUNG DEVICES.                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          BALANCED PROFILE APPLIED WITH SUCCESS.                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          END OF EXECUTION: $(date)                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
exit=`date +%s`

exectime=$((exit - init))
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          EXECUTION DONE IN $exectime SECONDS.                                                                   "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
}
# Extreme Profile
extreme() {
	init=`date +%s`
     	
kmsg1 "----------------------------------------------------- Info -------------------------------------------------------------------------------------------------"
kmsg1 "                                            🕛 Date of execution: $(date)                                                                                   " 
kmsg1 "                                            🔧 Kernel: $kname                                                                                               "
kmsg1 "                                            🗓️ Kernel Build Date: $kbdd                                                                                     "
kmsg1 "                                            🛠️ SOC: $mf, $soc                                                                                               "
kmsg1 "                                            ⚙️ SDK: $sdk                                                                                                    "
kmsg1 "                                            ⚒️ CPU Governor: $CPU_GOVERNOR                                                                                  "
kmsg1 "                                            ⚖️ CPU Scheduling Type: $cpusched                                                                               "
kmsg1 "                                            ⛓️ CPU AArch: $aarch                                                                                            "
kmsg1 "                                            🖼️ GPU Info: $gpuinfo                                                                                           "
kmsg1 "                                            📲 Drivers Info: $driversinfo                                                                                   "
kmsg1 "                                            ⛏️ GPU Governor: $GPU_GOVERNOR                                                                                  "
kmsg1 "                                            🅰️ndroid Version: $arv                                                                                          "
kmsg1 "                                            📱 Device: $dcdm                                                                                                "
kmsg1 "                                            🎞️ FPS: $df                                                                                                     "
kmsg1 "                                            👑 KTSR Version: $gbversion                                                                                     "
kmsg1 "                                            💭 KTSR Codename: $gbcodename                                                                                   "
kmsg1 "                                            📀 Build Type: $gbtype                                                                                          "
kmsg1 "                                            ⏰ Build Date: $gbdate                                                                                          "
kmsg1 "                                            🔋 Battery Charge Level: $gbpercentage%                                                                         "
kmsg1 "                                            🩹 Battery Health: $bhealth                                                                                     "
kmsg1 "                                            🔩 Battery Status: $bstatus                                                                                     "
kmsg1 "                                            🌡️ Battery Temperature: $gbtemp°C                                                                               "
kmsg1 "                                            💾 Device RAM: $totalram MB                                                                                     "
kmsg1 "                                            📁 Device Available RAM: $availram MB                                                                                     "
kmsg1 "                                            👺 Magisk: $magisk                                                                                              "
kmsg1 "------------------------------------------------------------------------------------------------------------------------------------------------------------"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLING EXTREME PROFILE...                                                                       "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"       	
  
for panic in /proc/sys/*/*panic*
do
write "$panic" "0"
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED KERNEL PANIC.                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Enable perfd and disable mpdecision.
start perfd
stop mpdecision

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED PERFD AND DISABLED MPDECISION.                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

if [[ -e "/sys/class/thermal/thermal_message" ]]; then
write "/sys/class/thermal/thermal_message/sconfig" "10"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED THERMAL PROFILE.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]
then
write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "50"
write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1500"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED STUNE BOOST.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

for corectl in /sys/devices/system/cpu/cpu*/core_ctl
do
if [[ -e "${corectl}/enable" ]]
then
write "${corectl}/enable" "0"

elif [[ -e "${corectl}/disable" ]]
then
write "${corectl}/disable" "1"
fi
done

if [[ -e "/sys/power/cpuhotplug/enable" ]]
then
write "/sys/power/cpuhotplug/enable" "0"

elif [[ -e "/sys/power/cpuhotplug/enabled" ]]
then
write "/sys/power/cpuhotplug/enabled" "0"
fi

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED CORE CONTROL & CPU HOTPLUG.                                                                               "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Caf CPU Boost
if [[ -d "/sys/module/cpu_boost" ]]
then
write "/sys/module/cpu_boost/parameters/input_boost_freq" "0:$cpumxfreq 1:$cpumxfreq 2:$cpumxfreq 3:$cpumxfreq 4:$cpumxfreq 5:$cpumxfreq 6:$cpumxfreq 7:$cpumxfreq"
write "/sys/module/cpu_boost/parameters/input_boost_ms" "500"
write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED CAF CPU INPUT BOOST.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# CPU input boost
elif [[ -d "/sys/module/cpu_input_boost" ]]
then
write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "500"
write "/sys/module/cpu_input_boost/parameters/input_boost_freq_hp" "$cpumxfreq"
write "/sys/module/cpu_input_boost/parameters/input_boost_freq_lp" "$cpumxfreq"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED CPU INPUT BOOST.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# I/O Scheduler Tweaks
for queue in /sys/block/*/queue/
do

    # Choose the first governor available
	avail_scheds="$(cat "$queue/scheduler")"
	for sched in tripndroid bfq-sq bfq-mq bfq fiops zen sio anxiety mq-deadline cfq noop none
	do
		if [[ "$avail_scheds" == *"$sched"* ]]
		then
			write "$queue/scheduler" "$sched"
			break
		fi
	done
	
write "${queue}add_random" 0
write "${queue}iostats" 0
write "${queue}rotational" 0
write "${queue}read_ahead_kb" 256
write "${queue}iosched/low_latency" 0
write "${queue}nomerges" 2
write "${queue}rq_affinity" 2
write "${queue}nr_requests" 128
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED I/O SCHEDULER.                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

for cpu in /sys/devices/system/cpu/cpu*/cpufreq
do
	# Fetch the available governors from the CPU
	avail_govs="$(cat "$cpu/scaling_available_governors")"

	# Attempt to set the governor in this order
	for governor in schedutil interactive
	do
		# Once a matching governor is found, set it and break for this CPU
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$cpu/scaling_governor" "$governor"
			break
		fi
	done
done

# Apply governor specific tunables for schedutil
find /sys/devices/system/cpu/ -name schedutil -type d | while IFS= read -r governor
do
write "$governor/up_rate_limit_us" "0"
write "$governor/down_rate_limit_us" "0"
write "$governor/pl" "1"
write "$governor/iowait_boost_enable" "1"
write "$governor/rate_limit_us" "0"
write "$governor/hispeed_load" "80"
write "$governor/hispeed_freq" "$cpumxfreq"
done

# Apply governor specific tunables for interactive
find /sys/devices/system/cpu/ -name interactive -type d | while IFS= read -r governor
do
write "$governor/timer_rate" "0"
write "$governor/boost" "1"
write "$governor/timer_slack" "0"
write "$governor/input_boost" "1"
write "$governor/use_migration_notif" "0"
write "$governor/ignore_hispeed_on_notif" "1"
write "$governor/use_sched_load" "1"
write "$governor/fastlane" "1"
write "$governor/fast_ramp_down" "0"
write "$governor/sampling_rate" "0"
write "$governor/sampling_rate_min" "0"
write "$governor/min_sample_time" "0"
write "$governor/go_hispeed_load" "80"
write "$governor/hispeed_freq" "$cpumxfreq"
done
	
for cpu in /sys/devices/system/cpu/cpu*
do
write "$cpu/online" "1"
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                         TWEAKED CPU.                                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# GPU Tweaks

	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpug/available_governors")"

	# Attempt to set the governor in this order
	for governor in msm-adreno-tz simple_ondemand ondemand
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpug/governor" "$governor"
			break
		fi
	done
	
	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpug/gpu_available_governor")"

	# Attempt to set the governor in this order
	for governor in Booster Interactive Static
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpug/gpu_governor" "$governor"
			break
		fi
	done

[[ $adreno == "true" ]] && write "$gpu/throttling" "0"
[[ $adreno == "true" ]] && write "$gpu/thermal_pwrlevel" "0"
[[ $adreno == "true" ]] && write "$gpu/devfreq/adrenoboost" "2"
[[ $adreno == "true" ]] && write "$gpu/force_no_nap" "0"
[[ $adreno == "true" ]] && write "$gpu/bus_split" "0"
[[ $adreno == "true" ]] && write "$gpu/devfreq/max_freq" $gpufreq
[[ $adreno == "true" ]] && write "$gpu/devfreq/min_freq" "100000000"
[[ $adreno == "true" ]] && write "$gpu/default_pwrlevel" "3"
[[ $adreno == "true" ]] && write "$gpu/force_bus_on" "0"
[[ $adreno == "true" ]] && write "$gpu/force_clk_on" "0"
[[ $adreno == "true" ]] && write "$gpu/force_rail_on" "0"
[[ $adreno == "true" ]] && write "$gpu/idle_timer" "156"
[[ $adreno == "true" ]] && write "$gpu/pwrnap" "1"
[[ $adreno == "false" ]] && write "$gpug/gpu_min_clock" $gpumin
[[ $adreno == "false" ]] && write "$gpu/highspeed_clock" $gpumx2

if [[ -e "/proc/gpufreq/gpufreq_limited_thermal_ignore" ]] 
then
write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
fi

# Enable dvfs
if [[ -e "/proc/mali/dvfs_enable" ]] 
then
write "/proc/mali/dvfs_enable" "1"
fi

if [[ -e "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" ]] 
then
write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"
fi

if [[ -e "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" ]]
then
write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "1"
fi

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED GPU.                                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Disable adreno idler
if [[ -d "/sys/module/adreno_idler" ]]
then
write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED ADRENO IDLER.                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Schedtune Tweaks
[[ $ANDROID == "true" ]] && if [[ -d "$stune" ]]
then
write "${stune}background/schedtune.boost" "0"
write "${stune}background/schedtune.prefer_idle" "0"
write "${stune}background/schedtune.sched_boost" "0"
write "${stune}background/schedtune.prefer_perf" "0"

write "${stune}foreground/schedtune.boost" "50"
write "${stune}foreground/schedtune.prefer_idle" "0"
write "${stune}foreground/schedtune.sched_boost" "15"
write "${stune}top-app/schedtune.sched_boost_no_override" "0"
write "${stune}foreground/schedtune.prefer_perf" "1"

write "${stune}rt/schedtune.boost" "0"
write "${stune}rt/schedtune.prefer_idle" "0"
write "${stune}rt/schedtune.sched_boost" "0"
write "${stune}rt/schedtune.prefer_perf" "0"

write "${stune}top-app/schedtune.boost" "50"
write "${stune}top-app/schedtune.prefer_idle" "0"
write "${stune}top-app/schedtune.sched_boost" "15"
write "${stune}top-app/schedtune.sched_boost_no_override" "1"
write "${stune}top-app/schedtune.prefer_perf" "1"

write "${stune}schedtune.boost" "0"
write "${stune}schedtune.prefer_idle" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED SCHEDTUNE TWEAKS.                                                                           "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# FS Tweaks
if [[ -d "/proc/sys/fs" ]]
then
write "/proc/sys/fs/dir-notify-enable" "0"
write "/proc/sys/fs/lease-break-time" "15"
write "/proc/sys/fs/leases-enable" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED FS TWEAKS.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Enable dynamic_fsync
if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]
then
write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED DYNAMIC FSYNC.                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Scheduler features
if [[ -e "/sys/kernel/debug/sched_features" ]]
then
write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
write "/sys/kernel/debug/sched_features" "NO_GENTLE_FAIR_SLEEPERS"
write "/sys/kernel/debug/sched_features" "NO_WAKEUP_PREEMPTION"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED SCHEDULER FEATURES.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# OP Tweaks
if [[ -d "/sys/module/opchain" ]]
then
write "/sys/module/opchain/parameters/chain_on" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED ONEPLUS CHAIN.                                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -d "/sys/module/mmc_core" ]];
then
write "/sys/module/mmc_core/parameters/use_spi_crc" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED MMC CRC.                                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Tweak some kernel settings to improve overall performance.
write "${kernel}sched_child_runs_first" "0"
write "${kernel}sched_boost" "1"
write "${kernel}perf_cpu_time_max_percent" "25"
write "${kernel}sched_autogroup_enabled" "0"
write "${kernel}random/read_wakeup_threshold" "128"
write "${kernel}random/write_wakeup_threshold" "1024"
write "${kernel}random/urandom_min_reseed_secs" "90"
write "${kernel}sched_tunable_scaling" "0"
write "${kernel}sched_latency_ns" "$SCHED_PERIOD_THROUGHPUT"
write "${kernel}sched_min_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / SCHED_TASKS_THROUGHPUT))"
write "${kernel}sched_wakeup_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / 2))"
write "${kernel}sched_migration_cost_ns" "5000000"
[[ "$ANDROID" == "true" ]] && write "${kernel}sched_min_task_util_for_colocation" "0"
[[ "$ANDROID" == "true" ]] && write "${kernel}sched_min_task_util_for_boost" "0"
write "${kernel}sched_nr_migrate" "128"
write "${kernel}sched_schedstats" "0"
write "${kernel}sched_enable_thread_grouping" "0"
write "${kernel}sched_rr_timeslice_ms" "1"
write "${kernel}sched_cstate_aware" "1"
write "${kernel}sched_sync_hint_enable" "0"
write "${kernel}sched_user_hint" "0"
write "${kernel}printk_devkmsg" "off"
write "${kernel}timer_migration" "0"

# Use rcu_normal instead of rcu_expedited
write "/sys/kernel/rcu_expedited" 0
write "/sys/kernel/rcu_normal" 1

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED KERNEL SETTINGS.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Enable fingerprint boost.
if [[ -e "/sys/kernel/fp_boost/enabled" ]]
then
write "/sys/kernel/fp_boost/enabled" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED FINGERPRINT BOOST.                                                                          "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Set max clocks in gaming / performance profile.
for minclk in /sys/devices/system/cpu/cpufreq/policy*/
do
if [[ -e "${minclk}scaling_min_freq" ]]
then
write "${minclk}scaling_min_freq" "$cpumxfreq"
write "${minclk}scaling_max_freq" "$cpumxfreq"
fi
done

for mnclk in /sys/devices/system/cpu/cpu*/cpufreq/
do
if [[ -e "${mnclk}scaling_min_freq" ]]
then
write "${mnclk}scaling_min_freq" "$cpumxfreq"
write "${mnclk}scaling_max_freq" "$cpumxfreq"
fi
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          SET MIN AND MAX CPU CLOCKS.                                                                      "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]] 
then
write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                         NOT ALLOWED CPUIDLE TO USE DEEPEST STATE.                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Enable krait voltage boost
if [[ -e "/sys/module/acpuclock_krait/parameters/boost" ]] 
then
write "/sys/module/acpuclock_krait/parameters/boost" "Y"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED KRAIT VOLTAGE BOOST.                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

sync

# VM settings to improve overall user experience and performance.
write "${vm}drop_caches" "3"
write "${vm}dirty_background_ratio" "5"
write "${vm}dirty_ratio" "30"
write "${vm}dirty_expire_centisecs" "500"
write "${vm}dirty_writeback_centisecs" "200"
write "${vm}page-cluster" "0"
write "${vm}stat_interval" "60"
write "${vm}extfrag_threshold" "750"
# Follow SSWAP if device haven't more than 4 GB ram on exynos SOC's
if [[ $exynos == "true" && $totalram -lt "4000" ]]; then
write "${vm}swappiness" "150"
else
write "${vm}swappiness" "100"
fi
write "${vm}laptop_mode" "0"
write "${vm}vfs_cache_pressure" "150"
[[ $totalram -lt "5000" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED VM TWEAKS.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# MSM thermal tweaks
if [[ -d "/sys/module/msm_thermal" ]]
then
write /sys/module/msm_thermal/vdd_restriction/enabled "0"
write /sys/module/msm_thermal/core_control/enabled "0"
write /sys/module/msm_thermal/parameters/enabled "N"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED THERMAL TWEAKS.                                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Disable power efficient workqueue.
if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]
then 
write "/sys/module/workqueue/parameters/power_efficient" "N" 
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED POWER EFFICIENT WORKQUEUE.                                                                 "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]
then
write "/sys/devices/system/cpu/sched_mc_power_savings" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED MULTICORE POWER SAVINGS.                                                                    "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Fix DT2W.
if [[ -e "/sys/touchpanel/double_tap" && -e "/proc/tp_gesture" ]]
then
write "/sys/touchpanel/double_tap" "1"
write "/proc/tp_gesture" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          FIXED DOUBLE TAP TO WAKEUP IF BROKEN.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

elif [[ -e /sys/class/sec/tsp/dt2w_enable ]]
then
write "/sys/class/sec/tsp/dt2w_enable" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          FIXED DOUBLE TAP TO WAKEUP IF BROKEN.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

elif [[ -e "/proc/tp_gesture" ]]
then
write "/proc/tp_gesture" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          FIXED DOUBLE TAP TO WAKEUP IF BROKEN.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

elif [[ -e "/sys/touchpanel/double_tap" ]]
then
write "/sys/touchpanel/double_tap" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          FIXED DOUBLE TAP TO WAKEUP IF BROKEN.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Enable touch boost on gaming and performance profile.
if [[ -e /sys/module/msm_performance/parameters/touchboost ]]
then
write "/sys/module/msm_performance/parameters/touchboost" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED TOUCH BOOST.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

elif [[ -e /sys/power/pnpmgr/touch_boost ]]
then
write "/sys/power/pnpmgr/touch_boost" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED TOUCH BOOST.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Fetch the available TCP congestion control 
avail_con=`cat "${tcp}tcp_available_congestion_control"`
	
    # Attempt to set the TCP congestion control in this order
    for tcpcc in bbr2 bbr cubic westwood 
	do
	    # Once a matching TCP congestion control is found, set it and break
		if [[ "$avail_con" == *"$tcpcc"* ]]
		then
			write ${tcp}tcp_congestion_control $tcpcc
			break
		fi
	done
	
# Internet Tweaks
write "${tcp}ip_no_pmtu_disc" "0"
write "${tcp}tcp_ecn" "1"
write "${tcp}tcp_timestamps" "0"
write "${tcp}route.flush" "1"
write "${tcp}tcp_rfc1337" "1"
write "${tcp}tcp_tw_reuse" "1"
write "${tcp}tcp_sack" "1"
write "${tcp}tcp_fack" "1"
write "${tcp}tcp_fastopen" "3"
write "${tcp}tcp_tw_recycle" "1"
write "${tcp}tcp_no_metrics_save" "1"
write "${tcp}tcp_syncookies" "0"
write "${tcp}tcp_window_scaling" "1"
write "${tcp}tcp_keepalive_probes" "10"
write "${tcp}tcp_keepalive_intvl" "30"
write "${tcp}tcp_fin_timeout" "30"
write "${tcp}tcp_low_latency" "1"
write "/proc/sys/net/core/netdev_tstamp_prequeue" "0"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED INTERNET TWEAKS.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Disable battery saver
if [[ -d "/sys/module/battery_saver" ]]
then
write "/sys/module/battery_saver/parameters/enabled" "N"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED BATTERY SAVER.                                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Enable high perf audio
for hpm in /sys/module/snd_soc_wcd*
do
if [[ -e "$hpm" ]]
then
write "${hpm}/parameters/high_perf_mode" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                           ENABLED HIGH PERFORMANCE AUDIO.                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
break
fi
done

# Disable arch power
if [[ -e "/sys/kernel/sched/arch_power" ]] 
then
write "/sys/kernel/sched/arch_power" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED ARCH POWER.                                                                                "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Disable LPM sleep in extreme / gaming profile
for lpm in /sys/module/lpm_levels/system/*/*/*/
do
if [[ -d "/sys/module/lpm_levels" ]]
then
write "/sys/module/lpm_levels/parameters/lpm_prediction" "N"
write "/sys/module/lpm_levels/parameters/lpm_ipi_prediction" "N"
write "/sys/module/lpm_levels/parameters/sleep_disabled" "Y"
write "${lpm}idle_enabled" "N"
write "${lpm}suspend_enabled" "N"
fi
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED LPM SLEEP.                                                                                 "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

if [[ -e "/sys/module/pm2/parameters/idle_sleep_mode" ]] 
then
write "/sys/module/pm2/parameters/idle_sleep_mode" "N"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED PM2 IDLE SLEEP MODE.                                                                       "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/class/lcd/panel/power_reduce" ]] 
then
write "/sys/class/lcd/panel/power_reduce" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED LCD POWER REDUCE..                                                                           "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/kernel/sched/gentle_fair_sleepers" ]]
then
write "/sys/kernel/sched/gentle_fair_sleepers" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED GENTLE FAIR SLEEPERS.                                                                      "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Enable Fast Charging Rate
if [[ -e "/sys/kernel/fast_charge/force_fast_charge" ]]
then
write "/sys/kernel/fast_charge/force_fast_charge" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED USB FAST CHARGING.                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/class/sec/switch/afc_disable" ]];
then
write "/sys/class/sec/switch/afc_disable" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED FAST CHARGING ON SAMSUNG DEVICES.                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi
  
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          EXTREME PROFILE APPLIED WITH SUCCESS.                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          END OF EXECUTION: $(date)                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
exit=`date +%s`

exectime=$((exit - init))
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          EXECUTION DONE IN $exectime SECONDS.                                                                   "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
}
# Battery Profile
battery() {
	init=`date +%s`
     	
kmsg1 "----------------------------------------------------- Info -------------------------------------------------------------------------------------------------"
kmsg1 "                                            🕛 Date of execution: $(date)                                                                                   " 
kmsg1 "                                            🔧 Kernel: $kname                                                                                               "
kmsg1 "                                            🗓️ Kernel Build Date: $kbdd                                                                                     "
kmsg1 "                                            🛠️ SOC: $mf, $soc                                                                                               "
kmsg1 "                                            ⚙️ SDK: $sdk                                                                                                    "
kmsg1 "                                            ⚒️ CPU Governor: $CPU_GOVERNOR                                                                                  "
kmsg1 "                                            ⚖️ CPU Scheduling Type: $cpusched                                                                               "
kmsg1 "                                            ⛓️ CPU AArch: $aarch                                                                                            "
kmsg1 "                                            🖼️ GPU Info: $gpuinfo                                                                                           "
kmsg1 "                                            📲 Drivers Info: $driversinfo                                                                                   "
kmsg1 "                                            ⛏️ GPU Governor: $GPU_GOVERNOR                                                                                  "
kmsg1 "                                            🅰️ndroid Version: $arv                                                                                          "
kmsg1 "                                            📱 Device: $dcdm                                                                                                "
kmsg1 "                                            🎞️ FPS: $df                                                                                                     "
kmsg1 "                                            👑 KTSR Version: $gbversion                                                                                     "
kmsg1 "                                            💭 KTSR Codename: $gbcodename                                                                                   "
kmsg1 "                                            📀 Build Type: $gbtype                                                                                          "
kmsg1 "                                            ⏰ Build Date: $gbdate                                                                                          "
kmsg1 "                                            🔋 Battery Charge Level: $gbpercentage%                                                                         "
kmsg1 "                                            🩹 Battery Health: $bhealth                                                                                     "
kmsg1 "                                            🔩 Battery Status: $bstatus                                                                                     "
kmsg1 "                                            🌡️ Battery Temperature: $gbtemp°C                                                                               "
kmsg1 "                                            💾 Device RAM: $totalram MB                                                                                     "
kmsg1 "                                            📁 Device Available RAM: $availram MB                                                                                     "
kmsg1 "                                            👺 Magisk: $magisk                                                                                              "
kmsg1 "------------------------------------------------------------------------------------------------------------------------------------------------------------"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLING BATTERY PROFILE...                                                                       "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"       	
    	
for panic in /proc/sys/*/*panic*
do
write "$panic" "0"
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED KERNEL PANIC.                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Enable perfd and mpdecision.
start perfd
start mpdecision

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED PERFD AND MPDECISION.                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

if [[ -e "/sys/class/thermal/thermal_message" ]]; then
write "/sys/class/thermal/thermal_message/sconfig" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED THERMAL PROFILE.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]
then
write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "10"
write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1500"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED STUNE BOOST.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

for corectl in /sys/devices/system/cpu/cpu*/core_ctl
do
if [[ -e "${corectl}/enable" ]]
then
write "${corectl}/enable" "1"

elif [[ -e "${corectl}/disable" ]]
then
write "${corectl}/disable" "0"
fi
done

if [[ -e "/sys/power/cpuhotplug/enable" ]]
then
write "/sys/power/cpuhotplug/enable" "1"

elif [[ -e "/sys/power/cpuhotplug/enabled" ]]
then
write "/sys/power/cpuhotplug/enabled" "1"
fi

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED CORE CONTROL & CPU HOTPLUG.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Caf CPU Boost
if [[ -e "/sys/module/cpu_boost/parameters/input_boost_ms" ]]
then
write "/sys/module/cpu_boost/parameters/input_boost_ms" "0"
write "/sys/module/cpu_boost/parameters/input_boost_enabled" "0"
write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED CAF CPU INPUT BOOST.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# CPU input boost
if [[ -e "/sys/module/cpu_input_boost/parameters/input_boost_duration" ]]
then
write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED CPU INPUT BOOST.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# I/O Scheduler Tweaks
for queue in /sys/block/*/queue/
do

    # Choose the first governor available
	avail_scheds="$(cat "$queue/scheduler")"
	for sched in tripndroid bfq-sq bfq-mq bfq fiops zen sio anxiety mq-deadline cfq noop none
	do
		if [[ "$avail_scheds" == *"$sched"* ]]
		then
			write "$queue/scheduler" "$sched"
			break
		fi
	done
	
write "${queue}add_random" 0
write "${queue}iostats" 0
write "${queue}rotational" 0
write "${queue}read_ahead_kb" 64
write "${queue}iosched/low_latency" 1
write "${queue}nomerges" 0
write "${queue}rq_affinity" 0
write "${queue}nr_requests" 512
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED I/O SCHEDULER.                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# CPU Tweaks
for cpu in /sys/devices/system/cpu/cpu*/cpufreq
do
	# Fetch the available governors from the CPU
	avail_govs="$(cat "$cpu/scaling_available_governors")"

	# Attempt to set the governor in this order
	for governor in schedutil interactive
	do
		# Once a matching governor is found, set it and break for this CPU
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$cpu/scaling_governor" "$governor"
			break
		fi
	done
done

# Apply governor specific tunables for schedutil
find /sys/devices/system/cpu/ -name schedutil -type d | while IFS= read -r governor
do
write "$governor/up_rate_limit_us" "46000"
write "$governor/down_rate_limit_us" "24000"
write "$governor/pl" "0"
write "$governor/iowait_boost_enable" "0"
write "$governor/rate_limit_us" "46000"
write "$governor/hispeed_load" "99"
write "$governor/hispeed_freq" "$cpumxfreq"
done

# Apply governor specific tunables for interactive
find /sys/devices/system/cpu/ -name interactive -type d | while IFS= read -r governor
do
write "$governor/timer_rate" "50000"
write "$governor/boost" "0"
write "$governor/timer_slack" "50000"
write "$governor/input_boost" "0"
write "$governor/use_migration_notif" "0" 
write "$governor/ignore_hispeed_on_notif" "1"
write "$governor/use_sched_load" "1"
write "$governor/boostpulse" "0"
write "$governor/fastlane" "1"
write "$governor/fast_ramp_down" "1"
write "$governor/sampling_rate" "50000"
write "$governor/sampling_rate_min" "70000"
write "$governor/min_sample_time" "70000"
write "$governor/go_hispeed_load" "99"
write "$governor/hispeed_freq" "$cpumxfreq"
done

for cpu in /sys/devices/system/cpu/cpu*
do
if [[ $gbpercentage < "20" ]]
then
write "/sys/devices/system/cpu/cpu1/online" "0"
write "/sys/devices/system/cpu/cpu2/online" "0"
write "/sys/devices/system/cpu/cpu5/online" "0"
write "/sys/devices/system/cpu/cpu6/online" "0"

elif [[ $gbpercentage > "20" ]]
then
write "$cpu/online" "1"
fi
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                         TWEAKED CPU.                                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# GPU Tweaks

	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpug/available_governors")"

	# Attempt to set the governor in this order
	for governor in simple_ondemand ondemand msm-adreno-tz
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpug/governor" "$governor"
			break
		fi
	done
	
	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpug/gpu_available_governor")"

	# Attempt to set the governor in this order
	for governor in Interactive Static
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpug/gpu_governor" "$governor"
			break
		fi
	done

[[ $adreno == "true" ]] && write "$gpu/throttling" "1"
[[ $adreno == "true" ]] && write "$gpu/thermal_pwrlevel" "0"
[[ $adreno == "true" ]] && write "$gpu/devfreq/adrenoboost" "0"
[[ $adreno == "true" ]] && write "$gpu/force_no_nap" "0"
[[ $adreno == "true" ]] && write "$gpu/bus_split" "1"
[[ $adreno == "true" ]] && write "$gpu/devfreq/min_freq" "100000000"
[[ $adreno == "true" ]] && write "$gpu/default_pwrlevel" "$gpuminpl"
[[ $adreno == "true" ]] && write "$gpu/force_bus_on" "0"
[[ $adreno == "true" ]] && write "$gpu/force_clk_on" "0"
[[ $adreno == "true" ]] && write "$gpu/force_rail_on" "0"
[[ $adreno == "true" ]] && write "$gpu/idle_timer" "36"
[[ $adreno == "true" ]] && write "$gpu/pwrnap" "1"
[[ $adreno == "false" ]] && write "$gpug/gpu_min_clock" $gpumin

if [[ -e "/proc/gpufreq/gpufreq_limited_thermal_ignore" ]] 
then
write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
fi

# Enable dvfs
if [[ -e "/proc/mali/dvfs_enable" ]] 
then
write "/proc/mali/dvfs_enable" "1"
fi

if [[ -e "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" ]] 
then
write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"
fi

if [[ -e "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" ]]
then
write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "1"
fi

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                         TWEAKED GPU.                                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Enable and tweak adreno idler
if [[ -d "/sys/module/adreno_idler" ]]
then
write "/sys/module/adreno_idler/parameters/adreno_idler_active" "Y"
write "/sys/module/adreno_idler/parameters/adreno_idler_idleworkload" "10000"
write "/sys/module/adreno_idler/parameters/adreno_idler_downdifferential" "25"
write "/sys/module/adreno_idler/parameters/adreno_idler_idlewait" "15"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                         ENABLED AND TWEAKED ADRENO IDLER.                                                                 "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Schedtune tweaks
[[ $ANDROID == "true" ]] && if [[ -d "$stune" ]]
then
write "${stune}background/schedtune.boost" "0"
write "${stune}background/schedtune.prefer_idle" "0"
write "${stune}background/schedtune.sched_boost" "0"
write "${stune}background/schedtune.prefer_perf" "0"

write "${stune}foreground/schedtune.boost" "0"
write "${stune}foreground/schedtune.prefer_idle" "1"
write "${stune}foreground/schedtune.sched_boost" "0"
write "${stune}foreground/schedtune.prefer_perf" "0"

write "${stune}rt/schedtune.boost" "0"
write "${stune}rt/schedtune.prefer_idle" "0"
write "${stune}rt/schedtune.sched_boost" "0"
write "${stune}rt/schedtune.prefer_perf" "0"

write "${stune}top-app/schedtune.boost" "0"
write "${stune}top-app/schedtune.prefer_idle" "1"
write "${stune}top-app/schedtune.sched_boost" "15"
write "${stune}top-app/schedtune.sched_boost_no_override" "1"
write "${stune}top-app/schedtune.prefer_perf" "1"

write "${stune}schedtune.boost" "0"
write "${stune}schedtune.prefer_idle" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED SCHEDTUNE TWEAKS.                                                                           "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# FS Tweaks
if [[ -d "/proc/sys/fs" ]]
then
write "/proc/sys/fs/dir-notify-enable" "0"
write "/proc/sys/fs/lease-break-time" "45"
write "/proc/sys/fs/leases-enable" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED FS TWEAKS.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi
    
# Enable dynamic_fsync
if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]
then
write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED DYNAMIC FSYNC.                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Scheduler features
if [[ -e "/sys/kernel/debug/sched_features" ]]
then
write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
write "/sys/kernel/debug/sched_features" "NO_WAKEUP_PREEMPTION"
write "/sys/kernel/debug/sched_features" "NO_GENTLE_FAIR_SLEEPERS"
write "/sys/kernel/debug/sched_features" "ARCH_POWER" 
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED SCHEDULER FEATURES.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi
	
# OP Chain disable
if [[ -d "/sys/module/opchain" ]]
then
write "/sys/module/opchain/parameters/chain_on" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED ONEPLUS CHAIN.                                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -d "/sys/module/mmc_core" ]];
then
write "/sys/module/mmc_core/parameters/use_spi_crc" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED MMC CRC.                                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Tweak some kernel settings to improve overall performance.
write "${kernel}sched_child_runs_first" "0"
write "${kernel}sched_boost" "0"
write "${kernel}perf_cpu_time_max_percent" "3"
write "${kernel}sched_autogroup_enabled" "1"
write "${kernel}random/read_wakeup_threshold" "64"
write "${kernel}random/write_wakeup_threshold" "128"
write "${kernel}random/urandom_min_reseed_secs" "90"
write "${kernel}sched_tunable_scaling" "0"
write "${kernel}sched_latency_ns" "$SCHED_PERIOD_BATTERY"
write "${kernel}sched_min_granularity_ns" "$((SCHED_PERIOD_BATTERY / SCHED_TASKS_BATTERY))"
write "${kernel}sched_wakeup_granularity_ns" "$((SCHED_PERIOD_BATTERY / 2))"
write "${kernel}sched_migration_cost_ns" "5000000"
[[ "$ANDROID" == "true" ]] && write "${kernel}sched_min_task_util_for_colocation" "0"
[[ "$ANDROID" == "true" ]] && write "${kernel}sched_min_task_util_for_boost" "0"
write "${kernel}sched_nr_migrate" "192"
write "${kernel}sched_schedstats" "0"
write "${kernel}sched_enable_thread_grouping" "1"
write "${kernel}sched_rr_timeslice_ms" "1"
write "${kernel}sched_cstate_aware" "1"
write "${kernel}sched_sync_hint_enable" "0"
write "${kernel}sched_user_hint" "0"
write "${kernel}printk_devkmsg" "off"
write "${kernel}timer_migration" "1"

# Use rcu_normal instead of rcu_expedited
write "/sys/kernel/rcu_expedited" 0
write "/sys/kernel/rcu_normal" 1

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED KERNEL SETTINGS.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Disable fingerprint boost.
if [[ -e "/sys/kernel/fp_boost/enabled" ]]
then
write "/sys/kernel/fp_boost/enabled" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED FINGERPRINT BOOST.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Set min and max clocks.
for minclk in /sys/devices/system/cpu/cpufreq/policy*/
do
if [[ -e "${minclk}scaling_min_freq" && $bpercentage > "20" ]]
then
write "${minclk}scaling_min_freq" "300000"
write "${minclk}scaling_max_freq" "$cpumxfreq"
fi
done

for mnclk in /sys/devices/system/cpu/cpu*/cpufreq/
do
if [[ -e "${mnclk}scaling_min_freq" && $bpercentage > "20" ]]
then
write "${mnclk}scaling_min_freq" "300000"
write "${mnclk}scaling_max_freq" "$cpumxfreq"
fi
done

# Set min and max clocks.
for minclk in /sys/devices/system/cpu/cpufreq/policy*/
do
if [[ -e "${minclk}scaling_min_freq" && $bpercentage < "20" ]]
then
write "${minclk}scaling_min_freq" "300000"
write "${minclk}scaling_max_freq" "$cpumxfreq"
fi
done

for mnclk in /sys/devices/system/cpu/cpu*/cpufreq/
do
if [[ -e "${mnclk}scaling_min_freq" && $bpercentage < "20" ]]
then
write "${mnclk}scaling_min_freq" "300000"
write "${mnclk}scaling_max_freq" "$cpumxfreq"
fi
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          SET MIN AND MAX CPU CLOCKS.                                                                      "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]] 
then
write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ALLOWED CPUIDLE TO USE DEEPEST STATE.                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Disable krait voltage boost
if [[ -e "/sys/module/acpuclock_krait/parameters/boost" ]] 
then
write "/sys/module/acpuclock_krait/parameters/boost" "N"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED KRAIT VOLTAGE BOOST.                                                                       "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# VM settings to improve overall user experience and performance.
write "${vm}dirty_background_ratio" "5"
write "${vm}dirty_ratio" "10"
write "${vm}dirty_expire_centisecs" "500"
write "${vm}dirty_writeback_centisecs" "200"
write "${vm}page-cluster" "0"
write "${vm}stat_interval" "60"
write "${vm}extfrag_threshold" "750"
# Follow SSWAP if device haven't more than 4 GB ram on exynos SOC's
if [[ $exynos == "true" && $totalram -lt "4000" ]]; then
write "${vm}swappiness" "150"
else
write "${vm}swappiness" "100"
fi
write "${vm}laptop_mode" "0"
write "${vm}vfs_cache_pressure" "50"
[[ $totalram -lt "5000" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED VM TWEAKS.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# MSM thermal tweaks
if [[ -d "/sys/module/msm_thermal" ]]
then
write /sys/module/msm_thermal/vdd_restriction/enabled "1"
write /sys/module/msm_thermal/core_control/enabled "1"
write /sys/module/msm_thermal/parameters/enabled "Y"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED THERMAL TWEAKS.                                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Enable power efficient workqueue.
if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]
then 
write "/sys/module/workqueue/parameters/power_efficient" "Y"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED POWER EFFICIENT WORKQUEUE.                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]
then
write "/sys/devices/system/cpu/sched_mc_power_savings" "2"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED AGGRESSIVE MULTICORE POWER SAVINGS.                                                          "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Fix DT2W.
if [[ -e "/sys/touchpanel/double_tap" && -e "/proc/tp_gesture" ]]
then
write "/sys/touchpanel/double_tap" "1"
write "/proc/tp_gesture" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          FIXED DOUBLE TAP TO WAKEUP IF BROKEN.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

elif [[ -e /sys/class/sec/tsp/dt2w_enable ]]
then
write "/sys/class/sec/tsp/dt2w_enable" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          FIXED DOUBLE TAP TO WAKEUP IF BROKEN.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

elif [[ -e "/proc/tp_gesture" ]]
then
write "/proc/tp_gesture" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          FIXED DOUBLE TAP TO WAKEUP IF BROKEN.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

elif [[ -e "/sys/touchpanel/double_tap" ]]
then
write "/sys/touchpanel/double_tap" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          FIXED DOUBLE TAP TO WAKEUP IF BROKEN.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Disable touch boost on battery and balance profile.
if [[ -e /sys/module/msm_performance/parameters/touchboost ]]
then
write "/sys/module/msm_performance/parameters/touchboost" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED TOUCH BOOST.                                                                               "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

elif [[ -e /sys/power/pnpmgr/touch_boost ]]
then
write "/sys/power/pnpmgr/touch_boost" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED TOUCH BOOST.                                                                               "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Fetch the available TCP congestion control 
avail_con=`cat "${tcp}tcp_available_congestion_control"`
	
    # Attempt to set the TCP congestion control in this order
    for tcpcc in bbr2 bbr cubic westwood 
	do
	    # Once a matching TCP congestion control is found, set it and break
		if [[ "$avail_con" == *"$tcpcc"* ]]
		then
			write ${tcp}tcp_congestion_control $tcpcc
			break
		fi
	done
	
# Internet Tweaks
write "${tcp}ip_no_pmtu_disc" "0"
write "${tcp}tcp_ecn" "1"
write "${tcp}tcp_timestamps" "0"
write "${tcp}route.flush" "1"
write "${tcp}tcp_rfc1337" "1"
write "${tcp}tcp_tw_reuse" "1"
write "${tcp}tcp_sack" "1"
write "${tcp}tcp_fack" "1"
write "${tcp}tcp_fastopen" "3"
write "${tcp}tcp_tw_recycle" "1"
write "${tcp}tcp_no_metrics_save" "1"
write "${tcp}tcp_syncookies" "0"
write "${tcp}tcp_window_scaling" "1"
write "${tcp}tcp_keepalive_probes" "10"
write "${tcp}tcp_keepalive_intvl" "30"
write "${tcp}tcp_fin_timeout" "30"
write "${tcp}tcp_low_latency" "1"
write "/proc/sys/net/core/netdev_tstamp_prequeue" "0"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED INTERNET TWEAKS.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Enable battery saver
if [[ -d "/sys/module/battery_saver" ]]
then
write "/sys/module/battery_saver/parameters/enabled" "Y"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED BATTERY SAVER.                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Disable high perf audio
for hpm in /sys/module/snd_soc_wcd*
do
if [[ -e "$hpm" ]]
then
write "${hpm}/parameters/high_perf_mode" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED HIGH PERFORMANCE AUDIO.                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
break
fi
done

# Enable LPM sleep in balanced / battery profile
for lpm in /sys/module/lpm_levels/system/*/*/*/
do
if [[ -d "/sys/module/lpm_levels" ]]
then
write "/sys/module/lpm_levels/parameters/lpm_prediction" "Y"
write "/sys/module/lpm_levels/parameters/lpm_ipi_prediction" "Y"
write "/sys/module/lpm_levels/parameters/sleep_disabled" "N"
write "${lpm}idle_enabled" "Y"
write "${lpm}suspend_enabled" "Y"
fi
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED LPM SLEEP.                                                                                 "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

if [[ -e "/sys/class/lcd/panel/power_reduce" ]] 
then
write "/sys/class/lcd/panel/power_reduce" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED LCD POWER REDUCE.                                                                          "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/kernel/sched/gentle_fair_sleepers" ]]
then
write "/sys/kernel/sched/gentle_fair_sleepers" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED GENTLE FAIR SLEEPERS.                                                                      "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Enable Fast Charging Rate
if [[ -e "/sys/kernel/fast_charge/force_fast_charge" ]]
then
write "/sys/kernel/fast_charge/force_fast_charge" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED USB FAST CHARGING.                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/class/sec/switch/afc_disable" ]];
then
write "/sys/class/sec/switch/afc_disable" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED FAST CHARGING ON SAMSUNG DEVICES.                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi
  
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          BATTERY PROFILE APPLIED WITH SUCCESS.                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          END OF EXECUTION: $(date)                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
exit=`date +%s`

exectime=$((exit - init))
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          EXECUTION DONE IN $exectime SECONDS.                                                                   "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
}
# Gaming Profile
gaming() {
	init=`date +%s`
     	
kmsg1 "----------------------------------------------------- Info -------------------------------------------------------------------------------------------------"
kmsg1 "                                            🕛 Date of execution: $(date)                                                                                   " 
kmsg1 "                                            🔧 Kernel: $kname                                                                                               "
kmsg1 "                                            🗓️ Kernel Build Date: $kbdd                                                                                     "
kmsg1 "                                            🛠️ SOC: $mf, $soc                                                                                               "
kmsg1 "                                            ⚙️ SDK: $sdk                                                                                                    "
kmsg1 "                                            ⚒️ CPU Governor: $CPU_GOVERNOR                                                                                  "
kmsg1 "                                            ⚖️ CPU Scheduling Type: $cpusched                                                                               "
kmsg1 "                                            ⛓️ CPU AArch: $aarch                                                                                            "
kmsg1 "                                            🖼️ GPU Info: $gpuinfo                                                                                           "
kmsg1 "                                            📲 Drivers Info: $driversinfo                                                                                   "
kmsg1 "                                            ⛏️ GPU Governor: $GPU_GOVERNOR                                                                                  "
kmsg1 "                                            🅰️ndroid Version: $arv                                                                                          "
kmsg1 "                                            📱 Device: $dcdm                                                                                                "
kmsg1 "                                            🎞️ FPS: $df                                                                                                     "
kmsg1 "                                            👑 KTSR Version: $gbversion                                                                                     "
kmsg1 "                                            💭 KTSR Codename: $gbcodename                                                                                   "
kmsg1 "                                            📀 Build Type: $gbtype                                                                                          "
kmsg1 "                                            ⏰ Build Date: $gbdate                                                                                          "
kmsg1 "                                            🔋 Battery Charge Level: $gbpercentage%                                                                         "
kmsg1 "                                            🩹 Battery Health: $bhealth                                                                                     "
kmsg1 "                                            🔩 Battery Status: $bstatus                                                                                     "
kmsg1 "                                            🌡️ Battery Temperature: $gbtemp°C                                                                               "
kmsg1 "                                            💾 Device RAM: $totalram MB                                                                                     "
kmsg1 "                                            📁 Device Available RAM: $availram MB                                                                                     "
kmsg1 "                                            👺 Magisk: $magisk                                                                                              "
kmsg1 "------------------------------------------------------------------------------------------------------------------------------------------------------------"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLING GAMING PROFILE...                                                                       "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"       	

for panic in /proc/sys/*/*panic*
do
write "$panic" "0"
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED KERNEL PANIC.                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Disable perfd and mpdecision.
stop perfd
stop mpdecision

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED PERFD AND MPDECISION.                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

if [[ -e "/sys/class/thermal/thermal_message" ]]; then
write "/sys/class/thermal/thermal_message/sconfig" "10"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED THERMAL PROFILE.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]
then
write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "50"
write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1500"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED STUNE BOOST.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

for corectl in /sys/devices/system/cpu/cpu*/core_ctl
do
if [[ -e "${corectl}/enable" ]]
then
write "${corectl}/enable" "0"

elif [[ -e "${corectl}/disable" ]]
then
write "${corectl}/disable" "1"
fi
done

if [[ -e "/sys/power/cpuhotplug/enable" ]]
then
write "/sys/power/cpuhotplug/enable" "0"

elif [[ -e "/sys/power/cpuhotplug/enabled" ]]
then
write "/sys/power/cpuhotplug/enabled" "0"
fi

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED CORE CONTROL & CPU HOTPLUG.                                                                               "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Caf CPU Boost
if [[ -d "/sys/module/cpu_boost" ]]
then
write "/sys/module/cpu_boost/parameters/input_boost_freq" "0:$cpumxfreq 1:$cpumxfreq 2:$cpumxfreq 3:$cpumxfreq 4:$cpumxfreq 5:$cpumxfreq 6:$cpumxfreq 7:$cpumxfreq"
write "/sys/module/cpu_boost/parameters/input_boost_ms" "500"
write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED CAF CPU INPUT BOOST.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# CPU input boost
elif [[ -d "/sys/module/cpu_input_boost" ]]
then
write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "500"
write "/sys/module/cpu_input_boost/parameters/input_boost_freq_hp" "$cpumxfreq"
write "/sys/module/cpu_input_boost/parameters/input_boost_freq_lp" "$cpumxfreq"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED CPU INPUT BOOST.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# I/O Scheduler Tweaks
for queue in /sys/block/*/queue/
do

    # Choose the first governor available
	avail_scheds="$(cat "$queue/scheduler")"
	for sched in tripndroid bfq-sq bfq-mq bfq fiops zen sio anxiety mq-deadline cfq noop none
	do
		if [[ "$avail_scheds" == *"$sched"* ]]
		then
			write "$queue/scheduler" "$sched"
			break
		fi
	done
	
write "${queue}add_random" 0
write "${queue}iostats" 0
write "${queue}rotational" 0
write "${queue}read_ahead_kb" 256
write "${queue}iosched/low_latency" 0
write "${queue}nomerges" 2
write "${queue}rq_affinity" 2
write "${queue}nr_requests" 128
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED I/O SCHEDULER.                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# CPU Tweaks
for cpu in /sys/devices/system/cpu/cpu*/cpufreq
do
	# Fetch the available governors from the CPU
	avail_govs="$(cat "$cpu/scaling_available_governors")"

	# Attempt to set the governor in this order
	for governor in schedutil interactive
	do
		# Once a matching governor is found, set it and break for this CPU
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$cpu/scaling_governor" "$governor"
			break
		fi
	done
done

# Apply governor specific tunables for schedutil
find /sys/devices/system/cpu/ -name schedutil -type d | while IFS= read -r governor
do
write "$governor/up_rate_limit_us" "0"
write "$governor/down_rate_limit_us" "0"
write "$governor/pl" "1"
write "$governor/iowait_boost_enable" "1"
write "$governor/rate_limit_us" "0"
write "$governor/hispeed_load" "80"
write "$governor/hispeed_freq" "cpumxfreq"
done

# Apply governor specific tunables for interactive
find /sys/devices/system/cpu/ -name interactive -type d | while IFS= read -r governor
do
write "$governor/timer_rate" "0"
write "$governor/boost" "1"
write "$governor/timer_slack" "0"
write "$governor/input_boost" "1"
write "$governor/use_migration_notif" "0"
write "$governor/ignore_hispeed_on_notif" "1"
write "$governor/use_sched_load" "1"
write "$governor/boostpulse" "0"
write "$governor/fastlane" "1"
write "$governor/fast_ramp_down" "0"
write "$governor/sampling_rate" "0"
write "$governor/sampling_rate_min" "0"
write "$governor/min_sample_time" "0"
write "$governor/go_hispeed_load" "80"
write "$governor/hispeed_freq" "$cpumxfreq"
done

for cpu in /sys/devices/system/cpu/cpu*
do
write "$cpu/online" "1"
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                         TWEAKED CPU.                                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# GPU Tweaks

	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpug/available_governors")"

	# Attempt to set the governor in this order
	for governor in msm-adreno-tz simple_ondemand ondemand
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpug/governor" "$governor"
			break
		fi
	done
	
	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpug/gpu_available_governor")"

	# Attempt to set the governor in this order
	for governor in Booster Interactive Static
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpug/gpu_governor" "$governor"
			break
		fi
	done

[[ $adreno == "true" ]] && write "$gpu/throttling" "0"
[[ $adreno == "true" ]] && write "$gpu/thermal_pwrlevel" "0"
[[ $adreno == "true" ]] && write "$gpu/devfreq/adrenoboost" "3"
[[ $adreno == "true" ]] && write "$gpu/force_no_nap" "1"
[[ $adreno == "true" ]] && write "$gpu/bus_split" "0"
[[ $adreno == "true" ]] && write "$gpu/devfreq/max_freq" $gpufreq
[[ $adreno == "true" ]] && write "$gpu/devfreq/min_freq" $gpumx
[[ $adreno == "true" ]] && write "$gpu/default_pwrlevel" $gpumaxpl
[[ $adreno == "true" ]] && write "$gpu/force_bus_on" "1"
[[ $adreno == "true" ]] && write "$gpu/force_clk_on" "1"
[[ $adreno == "true" ]] && write "$gpu/force_rail_on" "1"
[[ $adreno == "true" ]] && write "$gpu/idle_timer" "1006"
[[ $adreno == "true" ]] && write "$gpu/pwrnap" "0"
[[ $adreno == "false" ]] && write "$gpug/gpu_min_clock" $gpumx2
[[ $adreno == "false" ]] && write "$gpu/highspeed_clock" $gpumx2

if [[ -e "/proc/gpufreq/gpufreq_limited_thermal_ignore" ]]
then
write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "1"
fi

# Enable dvfs
if [[ -e "/proc/mali/dvfs_enable" ]] 
then
write "/proc/mali/dvfs_enable" "1"
fi

if [[ -e "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" ]] 
then
write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"
fi

if [[ -e "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" ]]
then
write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "1"
fi

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED GPU.                                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Disable adreno idler
if [[ -d "/sys/module/adreno_idler" ]]
then
write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED ADRENO IDLER.                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Schedtune Tweaks
[[ $ANDROID == "true" ]] && if [[ -d "$stune" ]]
then
write "${stune}background/schedtune.boost" "0"
write "${stune}background/schedtune.prefer_idle" "0"
write "${stune}background/schedtune.sched_boost" "0"
write "${stune}background/schedtune.prefer_perf" "0"

write "${stune}foreground/schedtune.boost" "50"
write "${stune}foreground/schedtune.prefer_idle" "0"
write "${stune}foreground/schedtune.sched_boost" "15"
write "${stune}foreground/schedtune.sched_boost_no_override" "0"
write "${stune}foreground/schedtune.prefer_perf" "0"

write "${stune}rt/schedtune.boost" "0"
write "${stune}rt/schedtune.prefer_idle" "0"
write "${stune}rt/schedtune.sched_boost" "0"
write "${stune}rt/schedtune.prefer_perf" "0"

write "${stune}top-app/schedtune.boost" "50"
write "${stune}top-app/schedtune.prefer_idle" "0"
write "${stune}top-app/schedtune.sched_boost" "15"
write "${stune}top-app/schedtune.sched_boost_no_override" "1"
write "${stune}top-app/schedtune.prefer_perf" "1"

write "${stune}schedtune.boost" "0"
write "${stune}schedtune.prefer_idle" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED SCHEDTUNE TWEAKS.                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# FS Tweaks
if [[ -d "/proc/sys/fs" ]]
then
write "/proc/sys/fs/dir-notify-enable" "0"
write "/proc/sys/fs/lease-break-time" "15"
write "/proc/sys/fs/leases-enable" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                            APPLIED FS TWEAKS.                                                                                "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Enable dynamic_fsync
if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]
then
write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED DYNAMIC FSYNC.                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Scheduler features
if [[ -e "/sys/kernel/debug/sched_features" ]]
then
write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
write "/sys/kernel/debug/sched_features" "NO_GENTLE_FAIR_SLEEPERS"
write "/sys/kernel/debug/sched_features" "NO_WAKEUP_PREEMPTION"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED SCHEDULER FEATURES.                                                                           "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# OP Tweaks
if [[ -d "/sys/module/opchain" ]]
then
write "/sys/module/opchain/parameters/chain_on" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED ONEPLUS CHAIN.                                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -d "/sys/module/mmc_core" ]];
then
write "/sys/module/mmc_core/parameters/use_spi_crc" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED MMC CRC.                                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Tweak some kernel settings to improve overall performance.
write "${kernel}sched_child_runs_first" "0"
write "${kernel}sched_boost" "1"
write "${kernel}perf_cpu_time_max_percent" "25"
write "${kernel}sched_autogroup_enabled" "0"
write "${kernel}random/read_wakeup_threshold" "128"
write "${kernel}random/write_wakeup_threshold" "1024"
write "${kernel}random/urandom_min_reseed_secs" "90"
write "${kernel}sched_tunable_scaling" "0"
write "${kernel}sched_latency_ns" "$SCHED_PERIOD_THROUGHPUT"
write "${kernel}sched_min_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / SCHED_TASKS_THROUGHPUT))"
write "${kernel}sched_wakeup_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / 2))"
write "${kernel}sched_migration_cost_ns" "5000000"
[[ "$ANDROID" == "true" ]] && write "${kernel}sched_min_task_util_for_colocation" "0"
[[ "$ANDROID" == "true" ]] && write "${kernel}sched_min_task_util_for_boost" "0"
write "${kernel}sched_nr_migrate" "128"
write "${kernel}sched_schedstats" "0"
write "${kernel}sched_enable_thread_grouping" "0"
write "${kernel}sched_rr_timeslice_ms" "1"
write "${kernel}sched_cstate_aware" "1"
write "${kernel}sched_sync_hint_enable" "0"
write "${kernel}sched_user_hint" "0"
write "${kernel}printk_devkmsg" "off"
write "${kernel}timer_migration" "0"

# Use rcu_normal instead of rcu_expedited
write "/sys/kernel/rcu_expedited" 0
write "/sys/kernel/rcu_normal" 1

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          TWEAKED KERNEL SETTINGS.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Enable fingerprint boost.
if [[ -e "/sys/kernel/fp_boost/enabled" ]]
then
write "/sys/kernel/fp_boost/enabled" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED FINGERPRINT BOOST.                                                                          "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Set max clocks in gaming / performance profile.
for minclk in /sys/devices/system/cpu/cpufreq/policy*/
do
if [[ -e "${minclk}scaling_min_freq" ]]
then
write "${minclk}scaling_min_freq" "$cpumxfreq"
write "${minclk}scaling_max_freq" "$cpumxfreq"
fi
done

for mnclk in /sys/devices/system/cpu/cpu*/cpufreq/
do
if [[ -e "${mnclk}scaling_min_freq" ]]
then
write "${mnclk}scaling_min_freq" "$cpumxfreq"
write "${mnclk}scaling_max_freq" "$cpumxfreq"
fi
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          SET MIN AND MAX CPU CLOCKS.                                                                      "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]] 
then
write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                         NOT ALLOWED CPUIDLE TO USE DEEPEST STATE.                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Enable krait voltage boost
if [[ -e "/sys/module/acpuclock_krait/parameters/boost" ]] 
then
write "/sys/module/acpuclock_krait/parameters/boost" "Y"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED KRAIT VOLTAGE BOOST.                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

sync

# VM settings to improve overall user experience and performance.
write "${vm}drop_caches" "3"
write "${vm}dirty_background_ratio" "5"
write "${vm}dirty_ratio" "20"
write "${vm}dirty_expire_centisecs" "3000"
write "${vm}dirty_writeback_centisecs" "3000"
write "${vm}page-cluster" "0"
write "${vm}stat_interval" "60"
write "${vm}extfrag_threshold" "750"
# Follow SSWAP if device haven't more than 4 GB ram on exynos SOC's
if [[ $exynos == "true" && $totalram -lt "4000" ]]; then
write "${vm}swappiness" "150"
else
write "${vm}swappiness" "100"
fi
write "${vm}laptop_mode" "0"
write "${vm}vfs_cache_pressure" "500"
[[ $totalram -lt "5000" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED VM TWEAKS.                                                                                  "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# MSM thermal tweaks
if [[ -d "/sys/module/msm_thermal" ]]
then
write /sys/module/msm_thermal/vdd_restriction/enabled "0"
write /sys/module/msm_thermal/core_control/enabled "0"
write /sys/module/msm_thermal/parameters/enabled "N"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED THERMAL TWEAKS.                                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Disable power efficient workqueue.
if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]
then 
write "/sys/module/workqueue/parameters/power_efficient" "N" 
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED POWER EFFICIENT WORKQUEUE.                                                                 "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]
then
write "/sys/devices/system/cpu/sched_mc_power_savings" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED MULTICORE POWER SAVINGS.                                                                    "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Fix DT2W.
if [[ -e "/sys/touchpanel/double_tap" && -e "/proc/tp_gesture" ]]
then
write "/sys/touchpanel/double_tap" "1"
write "/proc/tp_gesture" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          FIXED DOUBLE TAP TO WAKEUP IF BROKEN.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

elif [[ -e /sys/class/sec/tsp/dt2w_enable ]]
then
write "/sys/class/sec/tsp/dt2w_enable" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          FIXED DOUBLE TAP TO WAKEUP IF BROKEN.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

elif [[ -e "/proc/tp_gesture" ]]
then
write "/proc/tp_gesture" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          FIXED DOUBLE TAP TO WAKEUP IF BROKEN.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

elif [[ -e "/sys/touchpanel/double_tap" ]]
then
write "/sys/touchpanel/double_tap" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          FIXED DOUBLE TAP TO WAKEUP IF BROKEN.                                                                         "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Enable touch boost on gaming and performance profile.
if [[ -e /sys/module/msm_performance/parameters/touchboost ]]
then
write "/sys/module/msm_performance/parameters/touchboost" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED TOUCH BOOST.                                                                                "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

elif [[ -e /sys/power/pnpmgr/touch_boost ]]
then
write "/sys/power/pnpmgr/touch_boost" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED TOUCH BOOST.                                                                                "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Fetch the available TCP congestion control 
avail_con=`cat "${tcp}tcp_available_congestion_control"`
	
    # Attempt to set the TCP congestion control in this order
    for tcpcc in bbr2 bbr cubic westwood 
	do
	    # Once a matching TCP congestion control is found, set it and break
		if [[ "$avail_con" == *"$tcpcc"* ]]
		then
			write ${tcp}tcp_congestion_control $tcpcc
			break
		fi
	done
	
# Internet Tweaks
write "${tcp}ip_no_pmtu_disc" "0"
write "${tcp}tcp_ecn" "1"
write "${tcp}tcp_timestamps" "0"
write "${tcp}route.flush" "1"
write "${tcp}tcp_rfc1337" "1"
write "${tcp}tcp_tw_reuse" "1"
write "${tcp}tcp_sack" "1"
write "${tcp}tcp_fack" "1"
write "${tcp}tcp_fastopen" "3"
write "${tcp}tcp_tw_recycle" "1"
write "${tcp}tcp_no_metrics_save" "1"
write "${tcp}tcp_syncookies" "0"
write "${tcp}tcp_window_scaling" "1"
write "${tcp}tcp_keepalive_probes" "10"
write "${tcp}tcp_keepalive_intvl" "30"
write "${tcp}tcp_fin_timeout" "30"
write "${tcp}tcp_low_latency" "1"
write "/proc/sys/net/core/netdev_tstamp_prequeue" "0"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          APPLIED INTERNET TWEAKS.                                                                            "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

# Disable battery saver
if [[ -d "/sys/module/battery_saver" ]]
then
write "/sys/module/battery_saver/parameters/enabled" "N"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED BATTERY SAVER.                                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Enable high perf audio
for hpm in /sys/module/snd_soc_wcd*
do
if [[ -e "$hpm" ]]
then
write "${hpm}/parameters/high_perf_mode" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED HIGH PERFORMANCE AUDIO.                                                                       "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
break
fi
done

# Disable arch power
if [[ -e "/sys/kernel/sched/arch_power" ]] 
then
write "/sys/kernel/sched/arch_power" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED ARCH POWER.                                                                                "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Disable LPM sleep in extreme / gaming profile
for lpm in /sys/module/lpm_levels/system/*/*/*/
do
if [[ -d "/sys/module/lpm_levels" ]]
then
write "/sys/module/lpm_levels/parameters/lpm_prediction" "N"
write "/sys/module/lpm_levels/parameters/lpm_ipi_prediction" "N"
write "/sys/module/lpm_levels/parameters/sleep_disabled" "Y"
write "${lpm}idle_enabled" "N"
write "${lpm}suspend_enabled" "N"
fi
done

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED LPM SLEEP.                                                                                 "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

if [[ -e "/sys/module/pm2/parameters/idle_sleep_mode" ]] 
then
write "/sys/module/pm2/parameters/idle_sleep_mode" "N"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED PM2 IDLE SLEEP MODE.                                                                       "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/class/lcd/panel/power_reduce" ]] 
then
write "/sys/class/lcd/panel/power_reduce" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED LCD POWER REDUCE.                                                                          "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/kernel/sched/gentle_fair_sleepers" ]]
then
write "/sys/kernel/sched/gentle_fair_sleepers" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          DISABLED GENTLE FAIR SLEEPERS.                                                                      "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

# Enable Fast Charging Rate
if [[ -e "/sys/kernel/fast_charge/force_fast_charge" ]]
then
write "/sys/kernel/fast_charge/force_fast_charge" "1"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED USB FAST CHARGING.                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi

if [[ -e "/sys/class/sec/switch/afc_disable" ]];
then
write "/sys/class/sec/switch/afc_disable" "0"
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          ENABLED FAST CHARGING ON SAMSUNG DEVICES.                                                                        "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
fi
  
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          GAMING PROFILE APPLIED WITH SUCCESS.                                                             "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"

kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          END OF EXECUTION: $(date)                                                                              "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
exit=`date +%s`

exectime=$((exit - init))
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
kmsg1 "                                          EXECUTION DONE IN $exectime SECONDS.                                                                   "
kmsg1 "-------------------------------------------------------------------------------------------------------------------------------------------------"
}