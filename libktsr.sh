#!/system/bin/sh
# KTSR™ by Pedro (pedrozzz0 @ GitHub)
# Credits: Ktweak, by Draco (tytydraco @ GitHub), LSpeed, Dan (Paget69 @ XDA), mogoroku @ GitHub, vtools, by helloklf @ GitHub, Cuprum-Turbo-Adjustment, by chenzyadb @ CoolApk, qti-mem-opt & Uperf, by Matt Yang (yc9559 @ CoolApk) and Pandora's Box, by Eight (dlwlrma123 @ GitHub).
# Thanks: GR for some help
# If you wanna use it as part of your project, please maintain the credits to it's respectives authors.
# TODO: Implement a proper debug flag

###############################
# Variables
###############################
modpath="/data/adb/modules/KTSR/"
klog="/data/media/0/KTSR/KTSR.log"
kdbg="/data/media/0/KTSR/KTSR_DBG.log"
tcp="/proc/sys/net/ipv4/"
kernel="/proc/sys/kernel/"
vm="/proc/sys/vm/"
cpuset="/dev/cpuset/"
stune="/dev/stune/"
lmk="/sys/module/lowmemorykiller/parameters"
blkio="/dev/blkio/"
cpuctl="/dev/cpuctl/"
fs="/proc/sys/fs/"
f2fs="/sys/fs/f2fs/"
bbn_log="/data/media/0/KTSR/bourbon.log"
bbn_banner="/data/media/0/KTSR/bourbon.info"
adj_rel="${BIN_DIR}"
adj_nm="adjshield"
adj_cfg="/data/media/0/KTSR/adjshield.conf"
adj_log="/data/media/0/KTSR/adjshield.log"
fscc_nm="fscache-ctrl"
sys_frm="/system/framework"
sys_lib="/system/lib64"
vdr_lib="/vendor/lib64"
dvk="/data/dalvik-cache"
apx1="/apex/com.android.art/javalib"
apx2="/apex/com.android.runtime/javalib"
fscc_file_list=""
perfmgr="/proc/perfmgr/"
one_ui=false
miui=false
samsung=false
qcom=false
exynos=false
mtk=false
ppm=false
big_little=false
toptsdir="/dev/stune/top-app/tasks"
toptcdir="/dev/cpuset/top-app/tasks"
scrn_on=1
lib_ver="1.1.3-stable"
migt="/sys/module/migt/parameters/"
board_sensor_temp="/sys/class/thermal/thermal_message/board_sensor_temp"
memcg="/dev/memcg/"
zram="/sys/module/zram/parameters/"
lmk="$(pgrep -f lmkd)"

# Log in white and continue (unnecessary)
kmsg() { echo -e "[$(date +%T)]: [*] $@" >>"$klog"; }

kmsg1() {
	echo -e "$@" >>"$kdbg"
	echo -e "$@"
}

kmsg2() {
	echo -e "[!] $@" >>"$kdbg"
	echo -e "[!] $@"
}

kmsg3() { echo -e "$@" >>"$klog"; }

# toasttext: <text content>
toast() { am start -a android.intent.action.MAIN -e toasttext "Applying $ktsr_prof_en profile..." -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_1() { am start -a android.intent.action.MAIN -e toasttext "$ktsr_prof_en profile applied" -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_pt() { am start -a android.intent.action.MAIN -e toasttext "Aplicando perfil $ktsr_prof_pt..." -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_pt_1() { am start -a android.intent.action.MAIN -e toasttext "Perfil $ktsr_prof_pt aplicado" -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_tr() { am start -a android.intent.action.MAIN -e toasttext "$ktsr_prof_tr profili uygulanıyor..." -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_tr_1() { am start -a android.intent.action.MAIN -e toasttext "$ktsr_prof_tr profili uygulandı" -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_id() { am start -a android.intent.action.MAIN -e toasttext "Menerapkan profil $ktsr_prof_id..." -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_id_1() { am start -a android.intent.action.MAIN -e toasttext "Profil $ktsr_prof_id terpakai" -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_fr() { am start -a android.intent.action.MAIN -e toasttext "Chargement du profil $ktsr_prof_tr..." -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_fr_1() { am start -a android.intent.action.MAIN -e toasttext "Profil $ktsr_prof_fr chargé" -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

# write $1 <path> $2 <value>
write() {
	# Bail out if file does not exist
	[[ ! -f "$1" ]] && {
		kmsg2 "$1 doesn't exist, skipping..."
		return 1
	}

	# Make file writable in case it is not already
	chmod +rw "$1" 2>/dev/null

	# Fetch the current key value
	curval=$(cat "$1" 2>/dev/null)

	# Bail out if value is already set
	[[ "$curval" == "$2" ]] && {
		kmsg1 "$1 is already set to $2, skipping..."
		return 0
	}

	# Write the new value and bail if there's an error
	! echo -n "$2" >"$1" 2>/dev/null && {
		kmsg2 "Failed: $1 -> $2"
		return 1
	}

	# Sync the pending changes
	sync

	# Log the success
	kmsg1 "$1 $curval -> $2"
}

# Duration in nanoseconds of one scheduling period
sched_period_latency="$((1 * 1000 * 1000))"
sched_period_balance="$((4 * 1000 * 1000))"
sched_period_battery="$((5 * 1000 * 1000))"
sched_period_throughput="$((10 * 1000 * 1000))"

# How many tasks should we have at a maximum in one scheduling period
sched_tasks_latency="10"
sched_tasks_balanced="8"
sched_tasks_battery="5"
sched_tasks_throughput="6"

# Fetch GPU directories
for gpul in /sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0/; do
	[[ -d "$gpul" ]] && {
		gpu="$gpul"
		qcom=true
	}
done

for gpul1 in /sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0/; do
	[[ -d "$gpul1" ]] && {
		gpu="$gpul1"
		qcom=true
	}
done

for gpul2 in /sys/devices/*.mali/; do
	[[ -d "$gpul2" ]] && {
		gpu="$gpul2"
		qcom=false
	}
done

for gpul3 in /sys/devices/platform/*.gpu/; do
	[[ -d "$gpul3" ]] && {
		gpu="$gpul3"
		qcom=false
	}
done

for gpul4 in /sys/devices/platform/mali-*/; do
	[[ -d "$gpul4" ]] && {
		gpu="$gpul4"
		qcom=false
	}
done

for gpul5 in /sys/devices/platform/*.mali/; do
	[[ -d "$gpul5" ]] && {
		gpu="$gpul5"
		qcom=false
	}
done

for gpul6 in /sys/class/misc/mali*/device/devfreq/gpufreq/; do
	[[ -d "$gpul6" ]] && {
		gpu="$gpul6"
		qcom=false
	}
done

for gpul7 in /sys/class/misc/mali*/device/devfreq/*.gpu/; do
	[[ -d "$gpul7" ]] && {
		gpu="$gpul7"
		qcom=false
	}
done

for gpul8 in /sys/devices/platform/*.mali/misc/mali0/; do
	[[ -d "$gpul8" ]] && {
		gpu="$gpul8"
		qcom=false
	}
done

for gpul9 in /sys/devices/platform/mali.*/; do
	[[ -d "$gpul9" ]] && {
		gpu="$gpul9"
		qcom=false
	}
done

for gpul10 in /sys/devices/platform/*.mali/devfreq/*.mali/subsystem/*.mali; do
	[[ -d "$gpul10" ]] && {
		gpu="$gpul10"
		qcom=false
	}
done

if [[ -d "/sys/class/kgsl/kgsl-3d0/" ]]; then
	gpu="/sys/class/kgsl/kgsl-3d0/"
	qcom=true

elif [[ -d "/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/" ]]; then
	gpu="/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/"
	qcom=true

elif [[ -d "/sys/devices/platform/gpusysfs/" ]]; then
	gpu="/sys/devices/platform/gpusysfs/"

elif [[ -d "/sys/class/misc/mali0/device" ]]; then
	gpu="/sys/class/misc/mali0/device/"
fi

[[ -d "/sys/module/mali/parameters" ]] && gpug="/sys/module/mali/parameters/"

[[ -d "/sys/kernel/gpu" ]] && gpui="/sys/kernel/gpu/"

gpu_max="$gpu_max_freq"

if [[ -e "${gpu}devfreq/available_frequencies" ]] && [[ "$(cat "${gpu}devfreq/available_frequencies" | awk -F ' ' '{print $NF}')" -gt ${gpu_max} ]]; then
	gpu_max=$(cat "${gpu}devfreq/available_frequencies" | awk -F ' ' '{print $NF}')

elif [[ -e "${gpu}devfreq/available_frequencies" ]] && [[ "$(cat "${gpu}devfreq/available_frequencies" | awk '{print $1}')" -gt ${gpu_max} ]]; then
	gpu_max=$(cat "${gpu}devfreq/available_frequencies" | awk '{print $1}')

elif [[ -e "${gpu}available_frequencies" ]] && [[ "$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $NF}')" -gt ${gpu_max} ]]; then
	gpu_max=$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $NF}')

elif [[ -e "${gpu}available_frequencies" ]] && [[ "$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $1}')" -gt ${gpu_max} ]]; then
	gpu_max=$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $1}')

elif [[ -e "${gpui}gpu_freq_table" ]] && [[ "$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $NF}')" -gt ${gpu_max} ]]; then
	gpu_max=$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $NF}')

elif [[ -e "${gpui}gpu_freq_table" ]] && [[ "$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $1}')" -gt ${gpu_max} ]]; then
	gpu_max=$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $1}')
fi

gpu_min="$gpu_min_freq"

if [[ -e "${gpu}available_frequencies" ]] && [[ "$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $1}')" -lt ${gpu_min} ]]; then
	gpu_min=$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $1}')

elif [[ -e "${gpu}available_frequencies" ]] && [[ "$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $NF}')" -lt ${gpu_min} ]]; then
	gpu_min=$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $NF}')

elif [[ -e "${gpui}gpu_freq_table" ]] && [[ "$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $1}')" -lt ${gpu_min} ]]; then
	gpu_min=$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $1}')

elif [[ -e "${gpui}gpu_freq_table" ]] && [[ "$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $NF}')" -lt ${gpu_min} ]]; then
	gpu_min=$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $NF}')
fi

# Fetch the CPU governor
cpu_gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

# Fetch the GPU governor
if [[ -e "${gpui}gpu_governor" ]]; then
	gpu_gov=$(cat "${gpui}gpu_governor")

elif [[ -e "${gpu}governor" ]]; then
	gpu_gov=$(cat "${gpu}governor")

elif [[ -e "${gpu}devfreq/governor" ]]; then
	gpu_gov=$(cat "${gpu}devfreq/governor")
fi

define_gpu_pl() {
	# Fetch the amount of power levels from the GPU
	gpu_num_pl=$(cat "${gpu}num_pwrlevels")

	# Fetch the lower GPU power level
	gpu_min_pl=$((gpu_num_pl - 1))

	# Fetch the higher GPU power level
	gpu_max_pl=$(cat "${gpu}max_pwrlevel")
}

# Fetch max CPU clock
cpu_max_freq=$(cat /sys/devices/system/cpu/cpu7/cpufreq/cpuinfo_max_freq)
cpu_max_freq2=$(cat /sys/devices/system/cpu/cpu3/cpufreq/cpuinfo_max_freq)
cpu_max_freq3=$(cat /sys/devices/system/cpu/cpu5/cpufreq/cpuinfo_max_freq)
cpu_max_freq1=$(cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq)
cpu_max_freq1_2=$(cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq)
cpu_max_freq1_3=$(cat /sys/devices/system/cpu/cpu5/cpufreq/scaling_max_freq)

[[ "$cpu_max_freq2" -gt "$cpu_max_freq" ]] && [[ "$cpu_max_freq2" -gt "$cpu_max_freq3" ]] && cpu_max_freq="$cpu_max_freq2"
[[ "$cpu_max_freq3" -gt "$cpu_max_freq" ]] && [[ "$cpu_max_freq3" -gt "$cpu_max_freq2" ]] && cpu_max_freq="$cpu_max_freq3"
[[ "$cpu_max_freq1_2" -gt "$cpu_max_freq1" ]] && [[ "$cpu_max_freq1_2" -gt "$cpu_max_freq1_3" ]] && cpu_max_freq1="$cpu_max_freq1_2"
[[ "$cpu_max_freq1_3" -gt "$cpu_max_freq1" ]] && [[ "$cpu_max_freq1_3" -gt "$cpu_max_freq1_2" ]] && cpu_max_freq1="$cpu_max_freq1_3"
[[ "$cpu_max_freq1" -gt "$cpu_max_freq" ]] && cpu_max_freq="$cpu_max_freq1"

# Fetch min CPU clock
cpu_min_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
cpu_min_freq2=$(cat /sys/devices/system/cpu/cpu5/cpufreq/cpuinfo_min_freq)
cpu_min_freq1=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)
cpu_min_freq1_2=$(cat /sys/devices/system/cpu/cpu5/cpufreq/scaling_min_freq)

[[ "$cpu_min_freq2" -lt "$cpu_min_freq" ]] && cpu_min_freq="$cpu_min_freq2"
[[ "$cpu_min_freq1_2" -lt "$cpu_min_freq1" ]] && cpu_min_freq1="$cpu_min_freq1_2"
[[ "$cpu_min_freq1" -lt "$cpu_min_freq" ]] && cpu_min_freq="$cpu_min_freq1"

# Fetch CPU min clock in MHz
cpu_min_clk_mhz=$((cpu_min_freq / 1000))

# Fetch CPU max clock in MHz
cpu_max_clk_mhz=$((cpu_max_freq / 1000))

# Fetch maximum GPU frequency (gpu_max & gpu_max2 does almost the same thing)
if [[ -e "${gpu}max_gpuclk" ]]; then
	gpu_max_freq=$(cat "${gpu}max_gpuclk")

elif [[ -e "${gpu}max_clock" ]]; then
	gpu_max_freq=$(cat "${gpu}max_clock")

elif [[ -e "/proc/gpufreq/gpufreq_opp_dump" ]]; then
	gpu_max_freq=$(cat /proc/gpufreq/gpufreq_opp_dump | awk '{print $4}' | cut -f1 -d "," | head -n 1)
	mtk=true
fi

# Fetch minimum GPU frequency (gpumin also does almost the same thing)
if [[ -e "${gpu}min_clock_mhz" ]]; then
	gpu_min_freq=$(cat "${gpu}min_clock_mhz")
	gpu_min_freq=$((gpu_min_freq * 1000000))

elif [[ -e "${gpu}min_clock" ]]; then
	gpu_min_freq=$(cat "${gpu}min_clock")

elif [[ -e "/proc/gpufreq/gpufreq_opp_dump" ]]; then
	gpu_min_freq=$(cat /proc/gpufreq/gpufreq_opp_dump | tail -1 | awk '{print $4}' | cut -f1 -d ",")
fi

# Fetch maximum & minimum GPU clock in MHz
[[ "$gpu_max_freq" -ge "100000" ]] && {
	gpu_max_clk_mhz=$((gpu_max_freq / 1000))
	gpu_min_clk_mhz=$((gpu_min_freq / 1000))
} || [[ "$gpu_max_freq" -ge "100000000" ]] && {
	gpu_max_clk_mhz=$((gpu_max_freq / 1000000))
	gpu_min_clk_mhz=$((gpu_min_freq / 1000000))
}

soc_mf=$(getprop ro.soc.manufacturer)
[[ "$soc_mf" == "" ]] && soc_mf=$(getprop ro.boot.hardware)

# Fetch the device SOC
soc=$(getprop ro.soc.model)
[[ "$soc" == "" ]] && soc=$(getprop ro.chipname)
[[ "$soc" == "" ]] && soc=$(getprop ro.board.platform)
[[ "$soc" == "" ]] && soc=$(getprop ro.product.board)
[[ "$soc" == "" ]] && soc=$(getprop ro.product.platform)

# Fetch the device SDK
sdk=$(getprop ro.build.version.sdk)
[[ "$sdk" == "" ]] && sdk=$(getprop ro.vendor.build.version.sdk)
[[ "$sdk" == "" ]] && sdk=$(getprop ro.vndk.version)

# Fetch the device architeture
arch=$(getprop ro.product.cpu.abi | awk -F "-" '{print $1}')

# Fetch the android version
avs=$(getprop ro.build.version.release)

# Fetch the device codename
dvc_cdn=$(getprop ro.product.device)

# Fetch root method
root=$(su -v)

[[ "$(getprop ro.boot.hardware | grep qcom)" ]] || [[ "$(getprop ro.soc.manufacturer | grep QTI)" ]] || [[ "$(getprop ro.soc.manufacturer | grep Qualcomm)" ]] || [[ "$(getprop ro.hardware | grep qcom)" ]] || [[ "$(getprop ro.vendor.qti.soc_id)" ]] || [[ "$(getprop gsm.version.ril-impl | grep Qualcomm)" ]] && qcom=true

# Detect if we're running on a exynos powered device
[[ "$(getprop ro.boot.hardware | grep exynos)" ]] || [[ "$(getprop ro.board.platform | grep universal)" ]] || [[ "$(getprop ro.product.board | grep universal)" ]] && exynos=true

# Detect if we're running on a mediatek powered device
[[ "$(getprop ro.board.platform | grep mt)" ]] || [[ "$(getprop ro.product.board | grep mt)" ]] || [[ "$(getprop ro.hardware | grep mt)" ]] || [[ "$(getprop ro.boot.hardware | grep mt)" ]] && mtk=true

# Fetch the CPU scheduling type
for cpu in $(cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_available_governors); do
	case "$cpu" in
		*sched*) cpu_sched="EAS" ;;
		*util*) cpu_sched="EAS" ;;
		*interactive*) cpu_sched="HMP" ;;
		*) cpu_sched="Unknown" ;;
	esac
done

# Fetch kernel name and version
kern_ver_name=$(uname -r)

# Fetch kernel build date
kern_bd_dt=$(uname -v | awk '{print $5, $6, $7, $8, $9, $10}')

[[ "$(command -v busybox)" ]] && {
	total_ram=$(busybox free -m | awk '/Mem:/{print $2}')
	total_ram_kb=$(cat /proc/meminfo | awk '/kB/{print $2}' | grep [0-9] | head -n 1)
	avail_ram=$(busybox free -m | awk '/Mem:/{print $7}')
} || {
	total_ram="Please install busybox first"
	total_ram_kb="Please install busybox first"
	avail_ram="Please install busybox first"
}

# Fetch battery actual capacity
[[ -e "/sys/class/power_supply/battery/capacity" ]] && batt_pctg=$(cat /sys/class/power_supply/battery/capacity) || batt_pctg=$(dumpsys battery 2>/dev/null | awk '/level/{print $2}')

# Fetch build version
bd_ver=$(grep version= "${modpath}module.prop" | sed "s/version=//" | awk -F "-" '{print $1}')

# Fetch build type
bd_rel=$(grep version= "${modpath}module.prop" | sed "s/version=//" | awk -F "-" '{print $2}')

# Fetch build date
bd_dt=$(grep build_date= "${modpath}module.prop" | sed "s/build_date=//")

# Fetch build codename
bd_cdn=$(grep version= "${modpath}module.prop" | sed "s/version=//" | awk -F "-" '{print $3}')

# Fetch battery temperature
batt_tmp=$(dumpsys battery 2>/dev/null | awk '/temperature/{print $2}')
[[ "$batt_tmp" == "" ]] && [[ -e "/sys/class/power_supply/battery/temp" ]] && batt_tmp=$(cat /sys/class/power_supply/battery/temp) || [[ "$batt_tmp" == "" ]] && [[ -e "/sys/class/power_supply/battery/batt_temp" ]] && batt_tmp=$(cat /sys/class/power_supply/battery/batt_temp)

# Ignore the battery temperature decimal
batt_tmp=$((batt_tmp / 10))

# Fetch GPU model
[[ "$exynos" == "true" ]] || [[ "$mtk" == "true" ]] && gpu_mdl=$(cat "${gpu}gpuinfo" | awk '{print $1,$2,$3}')
[[ "$qcom" == "true" ]] && gpu_mdl=$(cat "${gpui}gpu_model")
[[ "$gpu_mdl" == "" ]] && gpu_mdl=$(dumpsys SurfaceFlinger 2>/dev/null | awk '/GLES/ {print $3,$4,$5}' | tr -d ,)

# Fetch max refresh rate
rr=$(dumpsys display 2>/dev/null | awk '/PhysicalDisplayInfo/{print $4}' | cut -c1-3 | tr -d .)

[[ -z "$rr" ]] && rr=$(dumpsys display 2>/dev/null | grep refreshRate | awk -F '=' '{print $6}' | cut -c1-3 | tail -n 1 | tr -d .) || rr=$(dumpsys display 2>/dev/null | grep FrameRate | awk -F '=' '{print $6}' | cut -c1-3 | tail -n 1 | tr -d .)

# Fetch battery health
batt_hth=$(dumpsys battery 2>/dev/null | awk '/health/{print $2}')
[[ -e "/sys/class/power_supply/battery/health" ]] && batt_hth=$(cat /sys/class/power_supply/battery/health)
case "$batt_hth" in
	1) batt_hth="Unknown" ;;
	2) batt_hth="Good" ;;
	3) batt_hth="Overheat" ;;
	4) batt_hth="Dead" ;;
	5) batt_hth="OV" ;;
	6) batt_hth="UF" ;;
	7) batt_hth="Cold" ;;
	*) batt_hth="$batt_hth" ;;
esac

# Fetch battery status
batt_sts=$(dumpsys battery 2>/dev/null | awk '/status/{print $2}')
[[ -e "/sys/class/power_supply/battery/status" ]] && batt_sts=$(cat /sys/class/power_supply/battery/status)
case "$batt_sts" in
	1) batt_sts="Unknown" ;;
	2) batt_sts="Charging" ;;
	3) batt_sts="Discharging" ;;
	4) batt_sts="Not charging" ;;
	5) batt_sts="Full" ;;
	*) batt_sts="$batt_sts" ;;
esac

# Fetch battery total capacity
batt_cpct=$(cat /sys/class/power_supply/battery/charge_full_design)
[[ "$batt_cpct" == "" ]] && batt_cpct=$(dumpsys batterystats 2>/dev/null | awk '/Capacity:/{print $2}' | cut -d "," -f 1)
[[ "$batt_cpct" -ge "1000000" ]] && batt_cpct=$((batt_cpct / 1000))

# Fetch busybox version
[[ "$(command -v busybox)" ]] && bb_ver=$(busybox | awk 'NR==1{print $2}') || bb_ver="Please install busybox first"

# Fetch ROM info
rom_info=$(getprop ro.build.description | awk '{print $1,$3,$4,$5}')
[[ "$rom_info" == "" ]] && rom_info=$(getprop ro.bootimage.build.description | awk '{print $1,$3,$4,$5}')
[[ "$rom_info" == "" ]] && rom_info=$(getprop ro.system.build.description | awk '{print $1,$3,$4,$5}')

# Fetch SELinux policy
[[ "$(cat /sys/fs/selinux/enforce)" == "1" ]] && slnx_stt="Enforcing" || slnx_stt="Permissive"

disable_adreno_gpu_thrtl() {
	gpu_thrtl_lvl=$(cat "${gpu}thermal_pwrlevel")
	[[ "$gpu_thrtl_lvl" -eq "1" ]] || [[ "$gpu_thrtl_lvl" -gt "1" ]] && gpu_calc_thrtl=$((gpu_thrtl_lvl - gpu_thrtl_lvl)) || gpu_calc_thrtl=0
}

# Fetch the number of CPU cores
nr_cores=$(cat /sys/devices/system/cpu/possible | awk -F "-" '{print $2}')
nr_cores=$((nr_cores + 1))

# Fetch device brand
dvc_brnd=$(getprop ro.product.brand)

# Check if we're running on OneUI
[[ "$(getprop net.knoxscep.version)" ]] || [[ "$(getprop ril.product_code)" ]] || [[ "$(getprop ro.boot.em.model)" ]] || [[ "$(getprop net.knoxvpn.version)" ]] || [[ "$(getprop ro.securestorage.knox)" ]] || [[ "$(getprop gsm.version.ril-impl | grep Samsung)" ]] || [[ "$(getprop ro.build.PDA)" ]] && {
	one_ui=true
	samsung=true
}

bt_dvc=$(getprop ro.boot.bootdevice)

# Fetch the amount of time since the system is running
sys_uptime=$(uptime | awk '{print $3,$4}' | cut -d "," -f 1)

[[ "$(command -v sqlite3)" ]] && {
	sql_ver=$(sqlite3 -version | awk '{print $1}')
	sql_bd_dt=$(sqlite3 -version | awk '{print $2,$3}')
} || {
	sql_ver="Please install SQLite3 first"
	sql_bd_dt="Please install SQLite3 first"
}

# Calculate CPU load (50 ms)
read -r cpu user nice system idle iowait irq softirq steal guest </proc/stat
cpu_active_prev=$((user + system + nice + softirq + steal))
cpu_total_prev=$((user + system + nice + softirq + steal + idle + iowait))
usleep 50000
read -r cpu user nice system idle iowait irq softirq steal guest </proc/stat
cpu_active_cur=$((user + system + nice + softirq + steal))
cpu_total_cur=$((user + system + nice + softirq + steal + idle + iowait))
cpu_load=$((100 * (cpu_active_cur - cpu_active_prev) / (cpu_total_cur - cpu_total_prev)))

[[ -d "/proc/ppm/" ]] && [[ "$mtk" == "true" ]] && ppm=true

# Check if CPU uses BIG.little architecture
for i in 1 2 3 4 5 6 7; do
	[[ -d "/sys/devices/system/cpu/cpufreq/policy0/" ]] && [[ -d "/sys/devices/system/cpu/cpufreq/policy${i}/" ]] && big_little=true
done

[[ "$(getprop ro.miui.ui.version.name)" ]] && miui=true

enable_devfreq_boost() {
	for dir in /sys/class/devfreq/*/; do
		max_devfreq=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $NF}')
		max_devfreq2=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $1}')
		[[ "$max_devfreq2" -gt "$max_devfreq" ]] && max_devfreq="$max_devfreq2"
		write "${dir}min_freq" "$max_devfreq"
	done
	kmsg "Enabled devfreq boost"
	kmsg3 ""
}

disable_devfreq_boost() {
	for dir in /sys/class/devfreq/*/; do
		min_devfreq=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $1}')
		min_devfreq2=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $NF}')
		[[ "$min_devfreq2" -lt "$min_devfreq" ]] && min_devfreq="$min_devfreq2"
		write "${dir}min_freq" "$min_devfreq"
	done
	kmsg "Disabled devfreq boost"
	kmsg3 ""
}

dram_max() {
	for i in /sys/devices/platform/*.dvfsrc/helio-dvfsrc/; do
		write "/sys/devices/platform/boot_dramboost/dramboost/dramboost" "1"
		ddr_opp=$(cat "${i}dvfsrc_opp_table" | head -1)
		write "${i}dvfsrc_force_vcore_dvfs_opp" "${ddr_opp:4:2}"
	done
	kmsg "Enabled DRAM boost"
	kmsg3 ""
}

dram_default() {
	for i in /sys/devices/platform/*.dvfsrc/helio-dvfsrc/; do
		write "/sys/devices/platform/boot_dramboost/dramboost/dramboost" "0"
		write "${i}dvfsrc_force_vcore_dvfs_opp" "-1"
	done
	kmsg "Disabled DRAM boost"
	kmsg3 ""
}

get_ka_pid() {
	[[ "$(pgrep -f kingauto)" != "" ]] && echo "$(pgrep -f kingauto)" || echo "[Not Running]"
}

[[ "$total_ram_kb" -gt "8388608" ]] && {
	minfree="25600,38400,51200,64000,256000,307200"
	efk="204800"
}
[[ "$total_ram_kb" -le "8388608" ]] && {
	minfree="25600,38400,51200,64000,153600,179200"
	efk="128000"
}
[[ "$total_ram_kb" -le "6291456" ]] && {
	minfree="25600,38400,51200,64000,102400,128000"
	efk="102400"
}
[[ "$total_ram_kb" -le "4197304" ]] && {
	minfree="12800,19200,25600,32000,76800,102400"
	efk="76800"
}
[[ "$total_ram_kb" -le "3145728" ]] && {
	minfree="12800,19200,25600,32000,51200,76800"
	efk="51200"
}
[[ "$total_ram_kb" -le "2098652" ]] && {
	minfree="12800,19200,25600,32000,38400,51200"
	efk="25600"
}
[[ "$total_ram_kb" -le "1049326" ]] && {
	minfree="5120,10240,12800,15360,25600,38400"
	efk="19200"
}

print_info() {
	kmsg3 ""
	kmsg "General info"
	kmsg3 ""
	kmsg3 "** Date of execution: $(date)"
	kmsg3 "** Kernel: $kern_ver_name"
	kmsg3 "** Kernel build date: $kern_bd_dt"
	kmsg3 "** SOC: $soc_mf, $soc"
	kmsg3 "** SDK: $sdk"
	kmsg3 "** Android version: $avs"
	kmsg3 "** Android ID: $(settings get secure android_id)"
	kmsg3 "** CPU governor: $cpu_gov"
	kmsg3 "** CPU load: $cpu_load%"
	kmsg3 "** Number of cores: $nr_cores"
	kmsg3 "** CPU freq: $cpu_min_clk_mhz-${cpu_max_clk_mhz}MHz"
	kmsg3 "** CPU scheduling type: $cpu_sched"
	kmsg3 "** Arch: $arch"
	kmsg3 "** GPU freq: $gpu_min_clk_mhz-${gpu_max_clk_mhz}MHz"
	kmsg3 "** GPU model: $gpu_mdl"
	kmsg3 "** GPU governor: $gpu_gov"
	kmsg3 "** Device: $dvc_brnd, $dvc_cdn"
	kmsg3 "** ROM: $rom_info"
	kmsg3 "** Screen resolution: $(wm size | awk '{print $3}' | tail -n 1)"
	kmsg3 "** Screen density: $(wm density | awk '{print $3}' | tail -n 1) PPI"
	kmsg3 "** Supported refresh rate: ${rr}HZ"
	kmsg3 "** KTSR build version: $bd_ver"
	kmsg3 "** KTSR build codename: $bd_cdn"
	kmsg3 "** KTSR build release: $bd_rel"
	kmsg3 "** KTSR build date: $bd_dt"
	kmsg3 "** KTSR lib version: $lib_ver"
	kmsg3 "** Battery charge lvl: $batt_pctg%"
	kmsg3 "** Battery capacity: ${batt_cpct}mAh"
	kmsg3 "** Battery health: $batt_hth"
	kmsg3 "** Battery status: $batt_sts"
	kmsg3 "** Battery temperature: $batt_tmp°C"
	kmsg3 "** Device RAM: ${total_ram}MB"
	kmsg3 "** Device available RAM: ${avail_ram}MB"
	kmsg3 "** Root: $root"
	kmsg3 "** SQLite version: $sql_ver"
	kmsg3 "** SQLite build date: $sql_bd_dt"
	kmsg3 "** System uptime: $sys_uptime"
	kmsg3 "** SELinux: $slnx_stt"
	kmsg3 "** Busybox: $bb_ver"
	kmsg3 "** Current KTSR PID: $$"
	kmsg3 "** Current automatic PID: $(get_ka_pid)"
	kmsg3 ""
	kmsg3 "** Author: Pedro | https://t.me/pedro3z0 | https://github.com/pedrozzz0"
	kmsg3 "** Telegram channel: https://t.me/kingprojectz"
	kmsg3 "** Telegram group: https://t.me/kingprojectzdiscussion"
	kmsg3 "** Credits to all people involved to make it possible."
	kmsg3 ""
}

stop_services() {
	# Stop perf and other userspace processes from tinkering with kernel parameters
	for v in 0 1 2 3 4; do
		stop vendor.qti.hardware.perf@$v.$v-service 2>/dev/null
		stop vendor.oneplus.hardware.brain@$v.$v-service 2>/dev/null
	done
	stop perfd 2>/dev/null
	stop mpdecision 2>/dev/null
	stop vendor.perfservice 2>/dev/null
	stop cnss_diag 2>/dev/null
	stop vendor.cnss_diag 2>/dev/null
	stop tcpdump 2>/dev/null
	stop vendor.tcpdump 2>/dev/null
	stop ipacm-diag 2>/dev/null
	stop vendor.ipacm-diag 2>/dev/null
	stop charge_logger 2>/dev/null
	stop oneplus_brain_service 2>/dev/null
	stop statsd 2>/dev/null
	write "/sys/kernel/debug/fpsgo/common/force_onoff" "0"
	write "/sys/kernel/debug/fpsgo/common/stop_boost" "1"
	write "/proc/sla/config" "enable=0"
	write "/proc/perfmgr/syslimiter/syslimiter_force_disable" "1"
	write "/proc/perfmgr/syslimiter/syslimitertolerance_percent" "100"
	# Disable MIUI useless daemons on AOSP
	[[ "$miui" == "false" ]] && stop mlid 2>/dev/null
	stop miuibooster 2>/dev/null
	[[ "$ktsr_prof_en" == "extreme" ]] || [[ "$ktsr_prof_en" == "gaming" ]] || [[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]] && {
		stop thermal 2>/dev/null
		stop thermald 2>/dev/null
		stop thermalservice 2>/dev/null
		stop mi_thermald 2>/dev/null
		stop thermal-engine 2>/dev/null
		stop vendor.thermal-engine 2>/dev/null
		stop thermanager 2>/dev/null
		stop thermal_manager 2>/dev/null
		write "/proc/driver/thermal/sspm_thermal_throttle" "1"
	} || {
		start thermal 2>/dev/null
		start thermald 2>/dev/null
		start thermalservice 2>/dev/null
		start mi_thermald 2>/dev/null
		start thermal-engine 2>/dev/null
		start vendor.thermal-engine 2>/dev/null
		start thermanager 2>/dev/null
		start thermal_manager 2>/dev/null
		write "/proc/driver/thermal/sspm_thermal_throttle" "0"
	}
	[[ -e "/data/system/perfd/default_values" ]] && rm -rf "/data/system/perfd/default_values" || [[ -e "/data/vendor/perfd/default_values" ]] && rm -rf "/data/vendor/perfd/default_values"
	kmsg "Disabled few debug services and userspace daemons that may conflict with KTSR"
	kmsg3 ""
}

disable_core_ctl() {
	for core_ctl in /sys/devices/system/cpu/cpu*/core_ctl/; do
		[[ -e "${core_ctl}enable" ]] && write "${core_ctl}enable" "0"
		[[ -e "${core_ctl}disable" ]] && write "${core_ctl}disable" "1"
	done

	[[ -e "/sys/power/cpuhotplug/enable" ]] && write "/sys/power/cpuhotplug/enable" "0"
	[[ -e "/sys/power/cpuhotplug/enabled" ]] && write "/sys/power/cpuhotplug/enabled" "0"
	[[ -e "/sys/devices/system/cpu/cpuhotplug/enabled" ]] && write "/sys/devices/system/cpu/cpuhotplug/enabled" "0"
	[[ -e "/sys/kernel/intelli_plug" ]] && write "/sys/kernel/intelli_plug/intelli_plug_active" "0"
	[[ -e "/sys/module/blu_plug" ]] && write "/sys/module/blu_plug/parameters/enabled" "0"
	[[ -e "/sys/devices/virtual/misc/mako_hotplug_control" ]] && write "/sys/devices/virtual/misc/mako_hotplug_control/enabled" "0"
	[[ -e "/sys/module/autosmp" ]] && write "/sys/module/autosmp/parameters/enabled" "0"
	[[ -e "/sys/kernel/zen_decision" ]] && write "/sys/kernel/zen_decision/enabled" "0"
	[[ -e "/proc/hps" ]] && write "/proc/hps/enabled" "0"
	kmsg "Disabled core control & CPU hotplug"
	kmsg3 ""
}

enable_core_ctl() {
	for i in 4 7; do
		for core_ctl in /sys/devices/system/cpu/cpu$i/core_ctl/; do
			[[ -e "${core_ctl}enable" ]] && write "${core_ctl}enable" "1"
			[[ -e "${core_ctl}disable" ]] && write "${core_ctl}disable" "0"
		done
	done

	[[ -e "/sys/power/cpuhotplug/enable" ]] && write "/sys/power/cpuhotplug/enable" "1"
	[[ -e "/sys/power/cpuhotplug/enabled" ]] && write "/sys/power/cpuhotplug/enabled" "1"
	[[ -e "/sys/devices/system/cpu/cpuhotplug/enabled" ]] && write "/sys/devices/system/cpu/cpuhotplug/enabled" "1"
	[[ -e "/sys/kernel/intelli_plug" ]] && write "/sys/kernel/intelli_plug/intelli_plug_active" "1"
	[[ -e "/sys/module/blu_plug" ]] && write "/sys/module/blu_plug/parameters/enabled" "1"
	[[ -e "/sys/devices/virtual/misc/mako_hotplug_control" ]] && write "/sys/devices/virtual/misc/mako_hotplug_control/enabled" "1"
	[[ -e "/sys/module/autosmp" ]] && write "/sys/module/autosmp/parameters/enabled" "1"
	[[ -e "/sys/kernel/zen_decision" ]] && write "/sys/kernel/zen_decision/enabled" "1"
	[[ -e "/proc/hps" ]] && write "/proc/hps/enabled" "1"
	kmsg "Enabled core control & CPU hotplug"
	kmsg3 ""
}

# Some of these are based from @helloklf (GitHub) vtools, credits to him.
config_cpuset_latency() {
	case "$soc" in
		"msm8937")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-3"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8952")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-3"
			write "${cpuset}system-background/cpus" "0-7"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8953")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-3"
			write "${cpuset}system-background/cpus" "0-7"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8996")
			write "${cpuset}camera-daemon/cpus" "0-3"
			write "${cpuset}foreground/cpus" "0-3"
			write "${cpuset}foreground/boost/cpus" "2-3"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-2"
			write "${cpuset}top-app/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8998")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-3"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msmnile")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-2"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM8150")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-2"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM7150")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-2"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SDM670")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-2"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6768")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-2"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6785")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-2"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6873")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-2"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6885")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-2"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"sdm710")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-2"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"sdm660")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-2"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"sdm845")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-2"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"lito")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-2"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM7250")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-3"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6350")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-3"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"lahaina")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-2"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM8350")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-2"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"exynos5")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-5"
			write "${cpuset}system-background/cpus" "0-5"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}dex2oat/cpus" "0-6"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"trinket")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-5"
			write "${cpuset}system-background/cpus" "0-5"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msmsteppe")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-5"
			write "${cpuset}system-background/cpus" "0-5"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6125")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-5"
			write "${cpuset}system-background/cpus" "0-5"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6150")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-5"
			write "${cpuset}system-background/cpus" "0-5"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6250")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-5"
			write "${cpuset}system-background/cpus" "0-5"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"bengal")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-5"
			write "${cpuset}system-background/cpus" "0-5"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6115")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-5"
			write "${cpuset}system-background/cpus" "0-5"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"kona")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-2"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM8250")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-2"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"universal9811")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-5"
			write "${cpuset}system-background/cpus" "0-5"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}dexopt/cpus" "0-6"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"universal9820")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-5"
			write "${cpuset}system-background/cpus" "0-5"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}dexopt/cpus" "0-6"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"atoll")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-3"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg3 ""
			;;
		"SM7125")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0-2"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
	esac
}

config_cpuset_balanced() {
	case "$soc" in
		"msm8937")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-3"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8952")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-3"
			write "${cpuset}system-background/cpus" "0-7"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8953")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-3"
			write "${cpuset}system-background/cpus" "0-7"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8996")
			write "${cpuset}camera-daemon/cpus" "0-3"
			write "${cpuset}foreground/cpus" "0-3"
			write "${cpuset}foreground/boost/cpus" "1-3"
			write "${cpuset}background/cpus" "0-3"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8998")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msmnile")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM8150")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM7150")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SDM670")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6768")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6785")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6873")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6885")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-3,4-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"sdm710")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"sdm660")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"sdm845")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"lito")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM7250")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6350")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"lahaina")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM8350")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"exynos5")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}dex2oat/cpus" "0-6"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"trinket")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msmsteppe")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6125")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6150")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6250")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"bengal")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6115")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"kona")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM8250")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"universal9811")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}dexopt/cpus" "0-6"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"universal9820")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}dexopt/cpus" "0-6"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"atoll")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM7125")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-6"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
	esac
}

config_cpuset_extreme() {
	case "${soc}" in
		"msm8937")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8952")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-7"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8953")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-7"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8996")
			write "${cpuset}camera-daemon/cpus" "0-3"
			write "${cpuset}foreground/cpus" "0-3"
			write "${cpuset}foreground/boost/cpus" "2-3"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-2"
			write "${cpuset}top-app/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8998")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msmnile")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM8150")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM7150")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SDM670")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6768")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6785")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6873")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6885")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"sdm710")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"sdm660")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"sdm845")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"lito")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM7250")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6350")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"lahaina")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM8350")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"exynos5")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}dex2oat/cpus" "0-5"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"trinket")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msmsteppe")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6125")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6150")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6250")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"bengal")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6115")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"kona")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM8250")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"universal9811")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}dexopt/cpus" "0-6"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"universal9820")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}dexopt/cpus" "0-6"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"atoll")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM7125")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
	esac
}

config_cpuset_battery() {
	case "$soc" in
		"msm8937")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-3"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8952")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-3"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-7"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8953")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-3"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-7"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8996")
			write "${cpuset}camera-daemon/cpus" "0-3"
			write "${cpuset}foreground/cpus" "0-3"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-2"
			write "${cpuset}top-app/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8998")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-3"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msmnile")
			write "${cpuset}camera-daemon/cpus" "0-3"
			write "${cpuset}foreground/cpus" "0-3"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM8150")
			write "${cpuset}camera-daemon/cpus" "0-3"
			write "${cpuset}foreground/cpus" "0-3"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM7150")
			write "${cpuset}camera-daemon/cpus" "0-3"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SDM670")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6768")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6785")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6873")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6885")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"sdm710")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"sdm660")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"sdm845")
			write "${cpuset}camera-daemon/cpus" "0-3"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"lito")
			write "${cpuset}camera-daemon/cpus" "0-3"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-3"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM7250")
			write "${cpuset}camera-daemon/cpus" "0-3"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-3"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6350")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"lahaina")
			write "${cpuset}camera-daemon/cpus" "0-3"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-3"
			write "${cpuset}foreground/cpus" "0-3"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM8350")
			write "${cpuset}camera-daemon/cpus" "0-3"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-3"
			write "${cpuset}foreground/cpus" "0-3"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"exynos5")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}dex2oat/cpus" "0-5"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"trinket")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msmsteppe")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6125")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6150")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6250")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"bengal")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6115")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"kona")
			write "${cpuset}camera-daemon/cpus" "0-3"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-3"
			write "${cpuset}foreground/cpus" "0-3"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM8250")
			write "${cpuset}camera-daemon/cpus" "0-3"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-3"
			write "${cpuset}foreground/cpus" "0-3"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"universal9811")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}dexopt/cpus" "0-5"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"universal9820")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}dexopt/cpus" "0-5"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"atoll")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM7125")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
	esac
}

config_cpuset_gaming() {
	case "$soc" in
		"msm8937")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8952")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-7"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8953")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-7"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8996")
			write "${cpuset}camera-daemon/cpus" "0-3"
			write "${cpuset}foreground/cpus" "0-3"
			write "${cpuset}foreground/boost/cpus" "0-3"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-2"
			write "${cpuset}top-app/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msm8998")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-7"
			write "${cpuset}background/cpus" "0-1"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msmnile")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM8150")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM7150")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SDM670")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6768")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6785")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6873")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"mt6885")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"sdm710")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"sdm660")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"sdm845")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"lito")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM7250")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6350")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"lahaina")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM8350")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"exynos5")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}dex2oat/cpus" "0-6"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"trinket")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			write "${cpuset}game/cpus" "0-7"
			write "${cpuset}gamelite/cpus" "0-7"
			write "${cpuset}vr/cpus" "0-7"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"msmsteppe")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6125")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6150")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6250")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"bengal")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM6115")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"kona")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM8250")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"universal9811")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}dexopt/cpus" "0-6"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"universal9820")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}dexopt/cpus" "0-6"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"atoll")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
		"SM7125")
			write "${cpuset}camera-daemon/cpus" "0-7"
			write "${cpuset}foreground/cpus" "0-5,7"
			write "${cpuset}background/cpus" "0"
			write "${cpuset}system-background/cpus" "0-3"
			write "${cpuset}top-app/cpus" "0-7"
			write "${cpuset}restricted/cpus" "0-3"
			kmsg "Tweaked cpusets"
			kmsg3 ""
			;;
	esac
}

boost_latency() {
	[[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]] && {
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "15"
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "700"
		kmsg "Tweaked dynamic stune boost"
		kmsg3 ""
	}

	[[ -d "/sys/module/cpu_boost/" ]] && {
		write "/sys/module/cpu_boost/parameters/input_boost_ms" "128"
		write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "0"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_powerkey_input" "0"
		write "/sys/module/cpu_boost/parameters/powerkey_input_boost_ms" "500"
		kmsg "Tweaked CAF CPU input boost"
		kmsg3 ""
	} || [[ -d "/sys/module/cpu_input_boost/" ]] && {
		write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "128"
		kmsg "Tweaked CPU input boost"
		kmsg3 ""
	}
}

boost_balanced() {
	[[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]] && {
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "10"
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "700"
		kmsg "Tweaked dynamic stune boost"
		kmsg3 ""
	}

	[[ -d "/sys/module/cpu_boost/" ]] && {
		write "/sys/module/cpu_boost/parameters/input_boost_ms" "88"
		write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "0"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_powerkey_input" "1"
		write "/sys/module/cpu_boost/parameters/powerkey_input_boost_ms" "500"
		kmsg "Tweaked CAF CPU input boost"
		kmsg3 ""
	} || [[ -d "/sys/module/cpu_input_boost/" ]] && {
		write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "88"
		kmsg "Tweaked CPU input boost"
		kmsg3 ""
	}
}

boost_extreme() {
	[[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]] && {
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "50"
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "700"
		kmsg "Tweaked dynamic stune boost"
		kmsg3 ""
	}

	[[ -d "/sys/module/cpu_boost/" ]] && {
		write "/sys/module/cpu_boost/parameters/input_boost_ms" "156"
		write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "0"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_powerkey_input" "0"
		write "/sys/module/cpu_boost/parameters/powerkey_input_boost_ms" "500"
		kmsg "Tweaked CAF CPU input boost"
		kmsg3 ""
	} || [[ -d "/sys/module/cpu_input_boost/" ]] && {
		write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "156"
		kmsg "Tweaked CPU input boost"
		kmsg3 ""
	}
}

boost_battery() {
	[[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]] && {
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "1"
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "500"
		kmsg "Tweaked dynamic stune boost"
		kmsg3 ""
	}

	[[ -d "/sys/module/cpu_boost/" ]] && {
		write "/sys/module/cpu_boost/parameters/input_boost_ms" "64"
		write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "0"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_powerkey_input" "0"
		write "/sys/module/cpu_boost/parameters/powerkey_input_boost_ms" "500"
		kmsg "Tweaked CAF CPU input boost"
		kmsg3 ""
	} || [[ -d "/sys/module/cpu_input_boost/" ]] && {
		write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "64"
		kmsg "Tweaked CPU input boost"
		kmsg3 ""
	}
}

boost_gaming() {
	[[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]] && {
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "50"
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "700"
		kmsg "Tweaked dynamic stune boost"
		kmsg3 ""
	}

	[[ -d "/sys/module/cpu_boost/" ]] && {
		write "/sys/module/cpu_boost/parameters/input_boost_ms" "156"
		write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "0"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_powerkey_input" "0"
		write "/sys/module/cpu_boost/parameters/powerkey_input_boost_ms" "500"
		kmsg "Tweaked CAF CPU input boost"
		kmsg3 ""
	} || [[ -d "/sys/module/cpu_input_boost/" ]] && {
		write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "156"
		kmsg "Tweaked CPU input boost"
		kmsg3 ""
	}
}

# I/O Scheduler tweaks
io_latency() {
	for queue in /sys/block/*/queue/; do
		# Fetch the available schedulers from the block
		avail_scheds="$(cat "${queue}scheduler")"

		# Select the first scheduler available
		for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
			if [[ "$avail_scheds" == *"$sched"* ]]; then
				write "${queue}scheduler" "$sched"
				break
			fi
		done

		write "${queue}add_random" "0"
		write "${queue}iostats" "0"
		write "${queue}rotational" "0"
		write "${queue}iosched/slice_idle" "0"
		write "${queue}iosched/group_idle" "1"
		write "${queue}iosched/quantum" "16"
		write "${queue}read_ahead_kb" "32"
		write "${queue}nomerges" "0"
		write "${queue}rq_affinity" "2"
		write "${queue}nr_requests" "16"
		write "${queue}iosched/back_seek_penalty" "1"
	done

	for queue in /sys/block/zram*/queue/; do
		# Fetch the available schedulers from the block
		avail_scheds="$(cat "${queue}scheduler")"

		# Select the first scheduler available
		for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
			if [[ "$avail_scheds" == *"$sched"* ]]; then
				write "${queue}scheduler" "$sched"
				break
			fi
		done

		write "${queue}read_ahead_kb" "0"
	done

	for i in /sys/block/mmcblk*/bdi/; do
		write "${i}min_ratio" "5"
	done

	for i in /sys/block/sd*/bdi/; do
		write "${i}min_ratio" "5"
	done
	kmsg "Tweaked I/O scheduler"
	kmsg3 ""
}

io_balanced() {
	for queue in /sys/block/*/queue/; do
		avail_scheds="$(cat "${queue}scheduler")"

		for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
			if [[ "$avail_scheds" == *"$sched"* ]]; then
				write "${queue}scheduler" "$sched"
				break
			fi
		done

		write "${queue}add_random" "0"
		write "${queue}iostats" "0"
		write "${queue}rotational" "0"
		write "${queue}iosched/slice_idle" "0"
		write "${queue}iosched/group_idle" "1"
		write "${queue}iosched/quantum" "16"
		write "${queue}read_ahead_kb" "128"
		write "${queue}nomerges" "0"
		write "${queue}rq_affinity" "1"
		write "${queue}nr_requests" "64"
		write "${queue}iosched/back_seek_penalty" "1"
	done

	for queue in /sys/block/zram*/queue/; do
		avail_scheds="$(cat "${queue}scheduler")"

		for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
			if [[ "$avail_scheds" == *"$sched"* ]]; then
				write "${queue}scheduler" "$sched"
				break
			fi
		done

		write "${queue}read_ahead_kb" "0"
	done

	for i in /sys/block/mmcblk*/bdi/; do
		write "${i}min_ratio" "5"
	done

	for i in /sys/block/sd*/bdi/; do
		write "${i}min_ratio" "5"
	done
	kmsg "Tweaked I/O scheduler"
	kmsg3 ""
}

io_extreme() {
	for queue in /sys/block/*/queue/; do
		avail_scheds="$(cat "${queue}scheduler")"

		for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
			if [[ "$avail_scheds" == *"$sched"* ]]; then
				write "${queue}scheduler" "$sched"
				break
			fi
		done

		write "${queue}add_random" "0"
		write "${queue}iostats" "0"
		write "${queue}rotational" "0"
		write "${queue}iosched/slice_idle" "0"
		write "${queue}iosched/group_idle" "1"
		write "${queue}iosched/quantum" "16"
		write "${queue}read_ahead_kb" "256"
		write "${queue}nomerges" "2"
		write "${queue}rq_affinity" "2"
		write "${queue}nr_requests" "256"
		write "${queue}iosched/back_seek_penalty" "1"
	done

	for queue in /sys/block/zram*/queue/; do
		avail_scheds="$(cat "${queue}scheduler")"

		for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
			if [[ "$avail_scheds" == *"$sched"* ]]; then
				write "${queue}scheduler" "$sched"
				break
			fi
		done

		write "${queue}read_ahead_kb" "0"
	done

	for i in /sys/block/mmcblk*/bdi/; do
		write "${i}min_ratio" "5"
	done

	for i in /sys/block/sd*/bdi/; do
		write "${i}min_ratio" "5"
	done
	kmsg "Tweaked I/O scheduler"
	kmsg3 ""
}

io_battery() {
	for queue in /sys/block/*/queue/; do
		avail_scheds="$(cat "${queue}scheduler")"

		for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
			if [[ "$avail_scheds" == *"$sched"* ]]; then
				write "${queue}scheduler" "$sched"
				break
			fi
		done

		write "${queue}add_random" "0"
		write "${queue}iostats" "0"
		write "${queue}rotational" "0"
		write "${queue}iosched/slice_idle" "0"
		write "${queue}iosched/group_idle" "1"
		write "${queue}iosched/quantum" "16"
		write "${queue}read_ahead_kb" "64"
		write "${queue}nomerges" "0"
		write "${queue}rq_affinity" "0"
		write "${queue}nr_requests" "512"
		write "${queue}iosched/back_seek_penalty" "1"
	done

	for queue in /sys/block/zram*/queue/; do
		avail_scheds="$(cat "${queue}scheduler")"

		for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
			if [[ "$avail_scheds" == *"$sched"* ]]; then
				write "${queue}scheduler" "$sched"
				break
			fi
		done

		write "${queue}read_ahead_kb" "0"
	done

	for i in /sys/block/mmcblk*/bdi/; do
		write "${i}min_ratio" "5"
	done

	for i in /sys/block/sd*/bdi/; do
		write "${i}min_ratio" "5"
	done
	kmsg "Tweaked I/O scheduler"
	kmsg3 ""
}

io_gaming() {
	for queue in /sys/block/*/queue/; do
		avail_scheds="$(cat "${queue}scheduler")"

		for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
			if [[ "$avail_scheds" == *"$sched"* ]]; then
				write "${queue}scheduler" "$sched"
				break
			fi
		done

		write "${queue}add_random" "0"
		write "${queue}iostats" "0"
		write "${queue}rotational" "0"
		write "${queue}iosched/slice_idle" "0"
		write "${queue}iosched/group_idle" "1"
		write "${queue}iosched/quantum" "16"
		write "${queue}read_ahead_kb" "256"
		write "${queue}nomerges" "2"
		write "${queue}rq_affinity" "2"
		write "${queue}nr_requests" "256"
		write "${queue}iosched/back_seek_penalty" "1"
	done

	for queue in /sys/block/zram*/queue/; do
		avail_scheds="$(cat "${queue}scheduler")"

		for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
			if [[ "$avail_scheds" == *"$sched"* ]]; then
				write "${queue}scheduler" "$sched"
				break
			fi
		done

		write "${queue}read_ahead_kb" "0"
	done

	for i in /sys/block/mmcblk*/bdi/; do
		write "${i}min_ratio" "5"
	done

	for i in /sys/block/sd*/bdi/; do
		write "${i}min_ratio" "5"
	done
	kmsg "Tweaked I/O scheduler"
	kmsg3 ""
}

cpu_latency() {
	# CPU tweaks
	for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
		# Fetch the available governors from the CPU
		avail_govs="$(cat "${cpu}scaling_available_governors")"

		# Attempt to set the governor in this order
		for governor in sched_pixel schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive; do
			# Once a matching governor is found, set it and break for this CPU
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${cpu}scaling_governor" "$governor"
				break
			fi
		done
	done

	# Apply governor specific tunables for schedutil, or it's modifications
	for governor in $(find /sys/devices/system/cpu/ -name *util* -type d); do
		write "$governor/up_rate_limit_us" "0"
		write "$governor/down_rate_limit_us" "0"
		write "$governor/pl" "1"
		write "$governor/iowait_boost_enable" "0"
		write "$governor/rate_limit_us" "0"
		write "$governor/hispeed_load" "85"
		write "$governor/hispeed_freq" "$cpu_max_freq"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d); do
		write "$governor/up_rate_limit_us" "0"
		write "$governor/down_rate_limit_us" "0"
		write "$governor/pl" "1"
		write "$governor/iowait_boost_enable" "0"
		write "$governor/rate_limit_us" "0"
		write "$governor/hispeed_load" "85"
		write "$governor/hispeed_freq" "$cpu_max_freq"
	done

	# Apply governor specific tunables for interactive
	for governor in $(find /sys/devices/system/cpu/ -name *interactive* -type d); do
		write "$governor/timer_rate" "0"
		write "$governor/boost" "0"
		write "$governor/io_is_busy" "0"
		write "$governor/timer_slack" "0"
		write "$governor/input_boost" "0"
		write "$governor/use_migration_notif" "1"
		write "$governor/ignore_hispeed_on_notif" "0"
		write "$governor/enable_prediction" "0"
		write "$governor/use_sched_load" "1"
		write "$governor/fastlane" "1"
		write "$governor/fast_ramp_down" "0"
		write "$governor/sampling_rate" "0"
		write "$governor/sampling_rate_min" "0"
		write "$governor/max_freq_hysteresis" "0"
		write "$governor/min_sample_time" "0"
		write "$governor/go_hispeed_load" "85"
		write "$governor/hispeed_freq" "$cpu_max_freq"
		write "$governor/sched_freq_inc_notify" "200000"
		write "$governor/sched_freq_dec_notify" "350000"
	done
}

cpu_balanced() {
	for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
		avail_govs="$(cat "${cpu}scaling_available_governors")"

		for governor in sched_pixel schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${cpu}scaling_governor" "$governor"
				break
			fi
		done
	done

	for governor in $(find /sys/devices/system/cpu/ -name *util* -type d); do
		write "$governor/up_rate_limit_us" "500"
		write "$governor/down_rate_limit_us" "20000"
		write "$governor/pl" "1"
		write "$governor/iowait_boost_enable" "0"
		write "$governor/rate_limit_us" "20000"
		write "$governor/hispeed_load" "85"
		write "$governor/hispeed_freq" "$cpu_max_freq"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d); do
		write "$governor/up_rate_limit_us" "500"
		write "$governor/down_rate_limit_us" "20000"
		write "$governor/pl" "1"
		write "$governor/iowait_boost_enable" "0"
		write "$governor/rate_limit_us" "20000"
		write "$governor/hispeed_load" "85"
		write "$governor/hispeed_freq" "$cpu_max_freq"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *interactive* -type d); do
		write "$governor/timer_rate" "20000"
		write "$governor/boost" "0"
		write "$governor/io_is_busy" "0"
		write "$governor/timer_slack" "500"
		write "$governor/input_boost" "0"
		write "$governor/use_migration_notif" "1"
		write "$governor/ignore_hispeed_on_notif" "0"
		write "$governor/enable_prediction" "0"
		write "$governor/use_sched_load" "1"
		write "$governor/boostpulse" "0"
		write "$governor/fastlane" "1"
		write "$governor/fast_ramp_down" "0"
		write "$governor/sampling_rate" "20000"
		write "$governor/sampling_rate_min" "20000"
		write "$governor/max_freq_hysteresis" "0"
		write "$governor/min_sample_time" "20000"
		write "$governor/go_hispeed_load" "85"
		write "$governor/hispeed_freq" "$cpu_max_freq"
		write "$governor/sched_freq_inc_notify" "200000"
		write "$governor/sched_freq_dec_notify" "200000"
	done
}

cpu_extreme() {
	for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
		avail_govs="$(cat "${cpu}scaling_available_governors")"

		for governor in sched_pixel schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${cpu}scaling_governor" "$governor"
				break
			fi
		done
	done

	for governor in $(find /sys/devices/system/cpu/ -name *util* -type d); do
		write "$governor/up_rate_limit_us" "0"
		write "$governor/down_rate_limit_us" "0"
		write "$governor/pl" "1"
		write "$governor/iowait_boost_enable" "0"
		write "$governor/rate_limit_us" "0"
		write "$governor/hispeed_load" "65"
		write "$governor/hispeed_freq" "$cpu_max_freq"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d); do
		write "$governor/up_rate_limit_us" "0"
		write "$governor/down_rate_limit_us" "0"
		write "$governor/pl" "1"
		write "$governor/iowait_boost_enable" "0"
		write "$governor/rate_limit_us" "0"
		write "$governor/hispeed_load" "65"
		write "$governor/hispeed_freq" "$cpu_max_freq"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *interactive* -type d); do
		write "$governor/timer_rate" "0"
		write "$governor/boost" "0"
		write "$governor/io_is_busy" "1"
		write "$governor/timer_slack" "0"
		write "$governor/input_boost" "0"
		write "$governor/use_migration_notif" "1"
		write "$governor/ignore_hispeed_on_notif" "0"
		write "$governor/enable_prediction" "0"
		write "$governor/use_sched_load" "1"
		write "$governor/fastlane" "1"
		write "$governor/fast_ramp_down" "0"
		write "$governor/sampling_rate" "0"
		write "$governor/sampling_rate_min" "0"
		write "$governor/max_freq_hysteresis" "79000"
		write "$governor/min_sample_time" "0"
		write "$governor/go_hispeed_load" "65"
		write "$governor/hispeed_freq" "$cpu_max_freq"
		write "$governor/sched_freq_inc_notify" "200000"
		write "$governor/sched_freq_dec_notify" "400000"
	done
}

cpu_battery() {
	for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
		avail_govs="$(cat "${cpu}scaling_available_governors")"

		for governor in sched_pixel schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${cpu}scaling_governor" "$governor"
				break
			fi
		done
	done

	for governor in $(find /sys/devices/system/cpu/ -name *util* -type d); do
		write "$governor/up_rate_limit_us" "5000"
		write "$governor/down_rate_limit_us" "20000"
		write "$governor/pl" "1"
		write "$governor/iowait_boost_enable" "0"
		write "$governor/rate_limit_us" "20000"
		write "$governor/hispeed_load" "99"
		write "$governor/hispeed_freq" "$cpu_max_freq"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d); do
		write "$governor/up_rate_limit_us" "5000"
		write "$governor/down_rate_limit_us" "20000"
		write "$governor/pl" "1"
		write "$governor/iowait_boost_enable" "0"
		write "$governor/rate_limit_us" "20000"
		write "$governor/hispeed_load" "99"
		write "$governor/hispeed_freq" "$cpu_max_freq"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *interactive* -type d); do
		write "$governor/timer_rate" "20000"
		write "$governor/boost" "0"
		write "$governor/io_is_busy" "0"
		write "$governor/timer_slack" "5000"
		write "$governor/input_boost" "0"
		write "$governor/use_migration_notif" "1"
		write "$governor/ignore_hispeed_on_notif" "0"
		write "$governor/enable_prediction" "0"
		write "$governor/use_sched_load" "1"
		write "$governor/boostpulse" "0"
		write "$governor/fastlane" "1"
		write "$governor/fast_ramp_down" "1"
		write "$governor/sampling_rate" "20000"
		write "$governor/sampling_rate_min" "20000"
		write "$governor/max_freq_hysteresis" "0"
		write "$governor/min_sample_time" "20000"
		write "$governor/go_hispeed_load" "99"
		write "$governor/hispeed_freq" "$cpu_max_freq"
		write "$governor/sched_freq_inc_notify" "200000"
		write "$governor/sched_freq_dec_notify" "200000"
	done
}

cpu_gaming() {
	for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
		avail_govs="$(cat "${cpu}scaling_available_governors")"

		for governor in sched_pixel schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${cpu}scaling_governor" "$governor"
				break
			fi
		done
	done

	for governor in $(find /sys/devices/system/cpu/ -name *util* -type d); do
		write "$governor/up_rate_limit_us" "0"
		write "$governor/down_rate_limit_us" "0"
		write "$governor/pl" "1"
		write "$governor/iowait_boost_enable" "0"
		write "$governor/rate_limit_us" "0"
		write "$governor/hispeed_load" "65"
		write "$governor/hispeed_freq" "$cpu_max_freq"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d); do
		write "$governor/up_rate_limit_us" "0"
		write "$governor/down_rate_limit_us" "0"
		write "$governor/pl" "1"
		write "$governor/iowait_boost_enable" "0"
		write "$governor/rate_limit_us" "0"
		write "$governor/hispeed_load" "65"
		write "$governor/hispeed_freq" "$cpu_max_freq"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *interactive* -type d); do
		write "$governor/timer_rate" "0"
		write "$governor/boost" "0"
		write "$governor/io_is_busy" "1"
		write "$governor/timer_slack" "0"
		write "$governor/input_boost" "0"
		write "$governor/use_migration_notif" "1"
		write "$governor/ignore_hispeed_on_notif" "0"
		write "$governor/enable_prediction" "0"
		write "$governor/use_sched_load" "1"
		write "$governor/fastlane" "1"
		write "$governor/fast_ramp_down" "0"
		write "$governor/sampling_rate" "0"
		write "$governor/sampling_rate_min" "0"
		write "$governor/max_freq_hysteresis" "79000"
		write "$governor/min_sample_time" "0"
		write "$governor/go_hispeed_load" "65"
		write "$governor/hispeed_freq" "$cpu_max_freq"
		write "$governor/sched_freq_inc_notify" "200000"
		write "$governor/sched_freq_dec_notify" "400000"
	done
}

misc_cpu_default() {
	[[ -e "/proc/cpufreq/cpufreq_power_mode" ]] && write "/proc/cpufreq/cpufreq_power_mode" "0"
	[[ -e "/proc/cpufreq/cpufreq_cci_mode" ]] && write "/proc/cpufreq/cpufreq_cci_mode" "0"
	[[ -e "/proc/cpufreq/cpufreq_stress_test" ]] && write "/proc/cpufreq/cpufreq_stress_test" "0"
	[[ -e "/proc/cpufreq/cpufreq_sched_disable" ]] && write "/proc/cpufreq/cpufreq_sched_disable" "0"
	[[ -e "/sys/devices/system/cpu/perf/enable" ]] && write "/sys/devices/system/cpu/perf/enable" "0"
}

misc_cpu_max_pwr() {
	[[ -e "/proc/cpufreq/cpufreq_power_mode" ]] && write "/proc/cpufreq/cpufreq_power_mode" "3"
	[[ -e "/proc/cpufreq/cpufreq_cci_mode" ]] && write "/proc/cpufreq/cpufreq_cci_mode" "1"
	[[ -e "/proc/cpufreq/cpufreq_stress_test" ]] && write "/proc/cpufreq/cpufreq_stress_test" "1"
	[[ -e "/proc/cpufreq/cpufreq_sched_disable" ]] && write "/proc/cpufreq/cpufreq_sched_disable" "0"
	[[ -e "/sys/devices/system/cpu/perf/enable" ]] && write "/sys/devices/system/cpu/perf/enable" "1"
}

misc_cpu_pwr_saving() {
	[[ -e "/proc/cpufreq/cpufreq_power_mode" ]] && write "/proc/cpufreq/cpufreq_power_mode" "1"
	[[ -e "/proc/cpufreq/cpufreq_cci_mode" ]] && write "/proc/cpufreq/cpufreq_cci_mode" "0"
	[[ -e "/proc/cpufreq/cpufreq_stress_test" ]] && write "/proc/cpufreq/cpufreq_stress_test" "0"
	[[ -e "/proc/cpufreq/cpufreq_sched_disable" ]] && write "/proc/cpufreq/cpufreq_sched_disable" "0"
	[[ -e "/sys/devices/system/cpu/perf/enable" ]] && write "/sys/devices/system/cpu/perf/enable" "0"
}

bring_all_cores() {
	for i in 0 1 2 3 4 5 6 7 8 9; do
		write "/sys/devices/system/cpu/cpu$i/online" "1"
	done
}

enable_ppm() {
	[[ "$ppm" == "true" ]] && write "/proc/ppm/enabled" "1"
	kmsg "Tweaked CPU parameters"
	kmsg3 ""
}

disable_ppm() {
	[[ "$ppm" == "true" ]] && write "/proc/ppm/enabled" "0"
	kmsg "Tweaked CPU parameters"
	kmsg3 ""
}

hmp_balanced() {
	[[ -d "/sys/kernel/hmp/" ]] && {
		write "/sys/kernel/hmp/boost" "0"
		write "/sys/kernel/hmp/down_compensation_enabled" "1"
		write "/sys/kernel/hmp/family_boost" "0"
		write "/sys/kernel/hmp/semiboost" "0"
		write "/sys/kernel/hmp/up_threshold" "524"
		write "/sys/kernel/hmp/down_threshold" "214"
		kmsg "Tweaked HMP parameters"
		kmsg3 ""
	}
}

hmp_extreme() {
	[[ -d "/sys/kernel/hmp/" ]] && {
		write "/sys/kernel/hmp/boost" "1"
		write "/sys/kernel/hmp/down_compensation_enabled" "1"
		write "/sys/kernel/hmp/family_boost" "1"
		write "/sys/kernel/hmp/semiboost" "1"
		write "/sys/kernel/hmp/up_threshold" "430"
		write "/sys/kernel/hmp/down_threshold" "150"
		kmsg "Tweaked HMP parameters"
		kmsg3 ""
	}
}

hmp_battery() {
	[[ -d "/sys/kernel/hmp/" ]] && {
		write "/sys/kernel/hmp/boost" "0"
		write "/sys/kernel/hmp/down_compensation_enabled" "1"
		write "/sys/kernel/hmp/family_boost" "0"
		write "/sys/kernel/hmp/semiboost" "0"
		write "/sys/kernel/hmp/up_threshold" "700"
		write "/sys/kernel/hmp/down_threshold" "256"
		kmsg "Tweaked HMP parameters"
		kmsg3 ""
	}
}

hmp_gaming() {
	[[ -d "/sys/kernel/hmp/" ]] && {
		write "/sys/kernel/hmp/boost" "1"
		write "/sys/kernel/hmp/down_compensation_enabled" "1"
		write "/sys/kernel/hmp/family_boost" "1"
		write "/sys/kernel/hmp/semiboost" "1"
		write "/sys/kernel/hmp/up_threshold" "430"
		write "/sys/kernel/hmp/down_threshold" "150"
		kmsg "Tweaked HMP parameters"
		kmsg3 ""
	}
}

gpu_latency() {
	# GPU tweaks
	if [[ "$qcom" == "true" ]]; then
		# Fetch the available governors from the GPU
		avail_govs="$(cat "${gpu}devfreq/available_governors")"

		# Attempt to set the governor in this order
		for governor in msm-adreno-tz simple_ondemand ondemand; do
			# Once a matching governor is found, set it and break
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${gpu}devfreq/governor" "$governor"
				break
			fi
		done

	elif [[ "$exynos" == "true" ]]; then
		avail_govs="$(cat "${gpui}gpu_available_governor")"

		for governor in Interactive Dynamic Static ondemand; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "$governor"
				break
			fi
		done

	elif [[ "$mtk" == "true" ]]; then
		avail_govs="$(cat "${gpu}available_governors")"

		for governor in Interactive Dynamic Static ondemand; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "$governor"
				break
			fi
		done
	fi

	if [[ "$qcom" == "true" ]]; then
		write "${gpu}throttling" "0"
		write "${gpu}thermal_pwrlevel" "$gpu_calc_thrtl"
		write "${gpu}devfreq/adrenoboost" "0"
		write "${gpu}force_no_nap" "0"
		write "${gpu}bus_split" "0"
		write "${gpu}devfreq/max_freq" "$gpu_max_freq"
		write "${gpu}devfreq/min_freq" "$gpu_min_freq"
		write "${gpu}min_pwrlevel" "$((gpu_min_pl - 2))"
		write "${gpu}force_bus_on" "0"
		write "${gpu}force_clk_on" "0"
		write "${gpu}force_rail_on" "0"
		write "${gpu}idle_timer" "64"
		write "${gpu}pwrnap" "1"
		write "/sys/kernel/debug/sde_rotator0/clk_always_on" "0"
	elif [[ "$qcom" == "false" ]]; then
		[[ "$one_ui" == "false" ]] && write "${gpu}dvfs" "1"
		write "${gpui}gpu_max_clock" "$gpu_max_freq"
		write "${gpui}gpu_min_clock" "$gpu_min"
		write "${gpu}highspeed_clock" "$gpu_max_freq"
		write "${gpu}highspeed_load" "80"
		write "${gpu}highspeed_delay" "0"
		write "${gpu}power_policy" "always_on"
		write "${gpui}boost" "0"
		write "${gpu}cl_boost_disable" "0"
		write "${gpug}mali_touch_boost_level" "0"
		write "${gpu}max_freq" "$gpu_max_freq"
		write "${gpu}min_freq" "$gpu_min"
		write "${gpu}tmu" "1"
		write "${gpu}devfreq/gpufreq/max_freq" "$gpu_max_freq"
		write "${gpu}devfreq/gpufreq/min_freq" "$gpu_min"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync" "1"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_upthreshold" "60"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_downdifferential" "40"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold" "50"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential" "30"
	fi

	[[ -d "/sys/module/ged/" ]] && {
		write "/sys/module/ged/parameters/ged_boost_enable" "0"
		write "/sys/module/ged/parameters/boost_gpu_enable" "0"
		write "/sys/module/ged/parameters/boost_extra" "0"
		write "/sys/module/ged/parameters/enable_cpu_boost" "0"
		write "/sys/module/ged/parameters/enable_gpu_boost" "0"
		write "/sys/module/ged/parameters/enable_game_self_frc_detect" "0"
		write "/sys/module/ged/parameters/ged_force_mdp_enable" "0"
		write "/sys/module/ged/parameters/ged_log_perf_trace_enable" "0"
		write "/sys/module/ged/parameters/ged_log_trace_enable" "0"
		write "/sys/module/ged/parameters/ged_monitor_3D_fence_debug" "0"
		write "/sys/module/ged/parameters/ged_monitor_3D_fence_disable" "0"
		write "/sys/module/ged/parameters/ged_monitor_3D_fence_systrace" "0"
		write "/sys/module/ged/parameters/ged_smart_boost" "1"
		write "/sys/module/ged/parameters/gpu_debug_enable" "0"
		write "/sys/module/ged/parameters/gpu_dvfs_enable" "1"
		write "/sys/module/ged/parameters/gx_3D_benchmark_on" "0"
		write "/sys/module/ged/parameters/gx_dfps" "0"
		write "/sys/module/ged/parameters/gx_force_cpu_boost" "0"
		write "/sys/module/ged/parameters/gx_frc_mode" "0"
		write "/sys/module/ged/parameters/gx_game_mode" "0"
		write "/sys/module/ged/parameters/is_GED_KPI_enabled" "1"
		write "/sys/module/ged/parameters/boost_amp" "0"
		write "/sys/module/ged/parameters/gx_boost_on" "0"
		write "/sys/module/ged/parameters/gpu_idle" "100"
	}

	[[ -d "/proc/gpufreq/" ]] && {
		write "/proc/gpufreq/gpufreq_opp_stress_test" "0"
		write "/proc/gpufreq/gpufreq_input_boost" "0"
		write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_oc_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "0"
		for i in 1 2 3 4 5 6 7 8 9 10; do
			write "/proc/gpufreq/gpufreq_limit_table" "$ 1 1"
		done
	}

	[[ -d "/sys/kernel/ged/" ]] && {
		write "/sys/kernel/ged/hal/timer_base_dvfs_margin" "25"
		write "/sys/kernel/ged/hal/dvfs_margin_value" "25"
	}

	# Tweak some other mali parameters
	[[ -d "/proc/mali/" ]] && {
		write "/proc/mali/dvfs_enable" "1"
		write "/proc/mali/always_on" "1"
	}

	[[ -d "/sys/module/pvrsrvkm/" ]] && write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"

	[[ -d "/sys/module/simple_gpu_algorithm/parameters/" ]] && {
		write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "1"
		write "/sys/module/simple_gpu_algorithm/parameters/default_laziness" "2"
		write "/sys/module/simple_gpu_algorithm/parameters/ramp_up_threshold" "2500"
		kmsg "Enabled and tweaked SGPU algorithm"
		kmsg3 ""
	}

	[[ -d "/sys/module/adreno_idler/" ]] && {
		write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
		kmsg "Disabled adreno idler"
		kmsg3 ""
	}
	kmsg "Tweaked GPU parameters"
	kmsg3 ""
}

gpu_balanced() {
	if [[ "$qcom" == "true" ]]; then
		avail_govs="$(cat "${gpu}devfreq/available_governors")"

		for governor in msm-adreno-tz simple_ondemand ondemand; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${gpu}devfreq/governor" "$governor"
				break
			fi
		done

	elif [[ "$exynos" == "true" ]]; then
		avail_govs="$(cat "${gpui}gpu_available_governor")"

		for governor in Interactive Dynamic Static ondemand; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "$governor"
				break
			fi
		done

	elif [[ "$mtk" == "true" ]]; then
		avail_govs="$(cat "${gpu}available_governors")"

		for governor in Interactive Dynamic Static ondemand; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "$governor"
				break
			fi
		done
	fi

	if [[ "$qcom" == "true" ]]; then
		write "${gpu}throttling" "0"
		write "${gpu}thermal_pwrlevel" "$gpu_calc_thrtl"
		write "${gpu}devfreq/adrenoboost" "0"
		write "${gpu}force_no_nap" "0"
		write "${gpu}bus_split" "1"
		write "${gpu}devfreq/max_freq" "$gpu_max_freq"
		write "${gpu}devfreq/min_freq" "$gpu_min_freq"
		write "${gpu}min_pwrlevel" "$gpu_min_pl"
		write "${gpu}force_bus_on" "0"
		write "${gpu}force_clk_on" "0"
		write "${gpu}force_rail_on" "0"
		write "${gpu}idle_timer" "64"
		write "${gpu}pwrnap" "1"
		write "/sys/kernel/debug/sde_rotator0/clk_always_on" "0"
	elif [[ "$qcom" == "false" ]]; then
		[[ "$one_ui" == "false" ]] && write "${gpu}dvfs" "1"
		write "${gpui}gpu_max_clock" "$gpu_max_freq"
		write "${gpui}gpu_min_clock" "$gpu_min"
		write "${gpu}highspeed_clock" "$gpu_max_freq"
		write "${gpu}highspeed_load" "86"
		write "${gpu}highspeed_delay" "0"
		write "${gpu}power_policy" "always_on"
		write "${gpu}boost" "0"
		write "${gpu}cl_boost_disable" "0"
		write "${gpug}mali_touch_boost_level" "0"
		write "${gpu}max_freq" "$gpu_max_freq"
		write "${gpu}min_freq" "$gpu_min"
		write "${gpu}tmu" "1"
		write "${gpu}devfreq/gpufreq/max_freq" "$gpu_max_freq"
		write "${gpu}devfreq/gpufreq/min_freq" "$gpu_min"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync" "1"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_upthreshold" "70"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_downdifferential" "45"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold" "65"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential" "40"
	fi

	[[ -d "/sys/module/ged/" ]] && {
		write "/sys/module/ged/parameters/ged_boost_enable" "0"
		write "/sys/module/ged/parameters/boost_gpu_enable" "0"
		write "/sys/module/ged/parameters/boost_extra" "0"
		write "/sys/module/ged/parameters/enable_cpu_boost" "0"
		write "/sys/module/ged/parameters/enable_gpu_boost" "0"
		write "/sys/module/ged/parameters/enable_game_self_frc_detect" "0"
		write "/sys/module/ged/parameters/ged_force_mdp_enable" "0"
		write "/sys/module/ged/parameters/ged_log_perf_trace_enable" "0"
		write "/sys/module/ged/parameters/ged_log_trace_enable" "0"
		write "/sys/module/ged/parameters/ged_monitor_3D_fence_debug" "0"
		write "/sys/module/ged/parameters/ged_monitor_3D_fence_disable" "1"
		write "/sys/module/ged/parameters/ged_monitor_3D_fence_systrace" "0"
		write "/sys/module/ged/parameters/ged_smart_boost" "1"
		write "/sys/module/ged/parameters/gpu_debug_enable" "0"
		write "/sys/module/ged/parameters/gpu_dvfs_enable" "1"
		write "/sys/module/ged/parameters/gx_3D_benchmark_on" "0"
		write "/sys/module/ged/parameters/gx_dfps" "0"
		write "/sys/module/ged/parameters/gx_force_cpu_boost" "0"
		write "/sys/module/ged/parameters/gx_frc_mode" "0"
		write "/sys/module/ged/parameters/gx_game_mode" "0"
		write "/sys/module/ged/parameters/is_GED_KPI_enabled" "1"
		write "/sys/module/ged/parameters/boost_amp" "0"
		write "/sys/module/ged/parameters/gx_boost_on" "0"
		write "/sys/module/ged/parameters/gpu_idle" "100"
	}

	[[ -d "/proc/gpufreq/" ]] && {
		write "/proc/gpufreq/gpufreq_opp_stress_test" "0"
		write "/proc/gpufreq/gpufreq_opp_freq" "0"
		write "/proc/gpufreq/gpufreq_input_boost" "0"
		write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_oc_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "0"
		for i in 1 2 3 4 5 6 7 8 9 10; do
			write "/proc/gpufreq/gpufreq_limit_table" "$ 1 1"
		done
	}

	[[ -d "/sys/kernel/ged/" ]] && {
		write "/sys/kernel/ged/hal/timer_base_dvfs_margin" "20"
		write "/sys/kernel/ged/hal/dvfs_margin_value" "20"
	}

	[[ -d "/proc/mali/" ]] && {
		write "/proc/mali/dvfs_enable" "1"
		write "/proc/mali/always_on" "1"
	}

	[[ -d "/sys/module/pvrsrvkm/" ]] && write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"

	[[ -d "/sys/module/simple_gpu_algorithm/" ]] && {
		write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "1"
		write "/sys/module/simple_gpu_algorithm/parameters/default_laziness" "3"
		write "/sys/module/simple_gpu_algorithm/parameters/ramp_up_threshold" "3500"
		kmsg "Enabled and tweaked SGPU algorithm"
		kmsg3 ""
	}

	[[ -d "/sys/module/adreno_idler" ]] && {
		write "/sys/module/adreno_idler/parameters/adreno_idler_active" "Y"
		write "/sys/module/adreno_idler/parameters/adreno_idler_idleworkload" "5000"
		write "/sys/module/adreno_idler/parameters/adreno_idler_downdifferential" "35"
		write "/sys/module/adreno_idler/parameters/adreno_idler_idlewait" "25"
		kmsg "Enabled and tweaked adreno idler"
		kmsg3 ""
	}
	kmsg "Tweaked GPU parameters"
	kmsg3 ""
}

gpu_extreme() {
	if [[ "$qcom" == "true" ]]; then
		avail_govs="$(cat "${gpu}devfreq/available_governors")"

		for governor in msm-adreno-tz simple_ondemand ondemand; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${gpu}devfreq/governor" "$governor"
				break
			fi
		done

	elif [[ "$exynos" == "true" ]]; then
		avail_govs="$(cat "${gpui}gpu_available_governor")"

		for governor in Booster Interactive Dynamic Static ondemand; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "$governor"
				break
			fi
		done

	elif [[ "$mtk" == "true" ]]; then
		avail_govs="$(cat "${gpu}available_governors")"

		for governor in Booster Interactive Dynamic Static ondemand; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "$governor"
				break
			fi
		done
	fi

	if [[ "$qcom" == "true" ]]; then
		write "${gpu}throttling" "0"
		write "${gpu}thermal_pwrlevel" "$gpu_calc_thrtl"
		write "${gpu}devfreq/adrenoboost" "0"
		write "${gpu}force_no_nap" "0"
		write "${gpu}bus_split" "0"
		write "${gpu}devfreq/max_freq" "$gpu_max_freq"
		write "${gpu}devfreq/min_freq" "$gpu_min_freq"
		write "${gpu}min_pwrlevel" "1"
		write "${gpu}force_bus_on" "1"
		write "${gpu}force_clk_on" "1"
		write "${gpu}force_rail_on" "1"
		write "${gpu}idle_timer" "7500"
		write "${gpu}pwrnap" "1"
		write "/sys/kernel/debug/sde_rotator0/clk_always_on" "0"
	elif [[ "$qcom" == "false" ]]; then
		[[ "$one_ui" == "false" ]] && write "${gpu}dvfs" "1"
		write "${gpui}gpu_max_clock" "$gpu_max_freq"
		write "${gpui}gpu_min_clock" "$gpu_min"
		write "${gpu}highspeed_clock" "$gpu_max_freq"
		write "${gpu}highspeed_load" "76"
		write "${gpu}highspeed_delay" "0"
		write "${gpu}power_policy" "always_on"
		write "${gpui}boost" "0"
		write "${gpu}cl_boost_disable" "0"
		write "${gpug}mali_touch_boost_level" "0"
		write "${gpu}max_freq" "$gpu_max_freq"
		write "${gpu}min_freq" "$gpu_min"
		write "${gpu}tmu" "0"
		write "${gpu}devfreq/gpufreq/max_freq" "$gpu_max_freq"
		write "${gpu}devfreq/gpufreq/min_freq" "$gpu_min"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync" "0"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_upthreshold" "40"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_downdifferential" "20"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold" "30"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential" "10"
	fi

	[[ -d "/sys/module/ged/" ]] && {
		write "/sys/module/ged/parameters/ged_boost_enable" "1"
		write "/sys/module/ged/parameters/boost_gpu_enable" "0"
		write "/sys/module/ged/parameters/boost_extra" "1"
		write "/sys/module/ged/parameters/enable_cpu_boost" "0"
		write "/sys/module/ged/parameters/enable_gpu_boost" "0"
		write "/sys/module/ged/parameters/enable_game_self_frc_detect" "0"
		write "/sys/module/ged/parameters/ged_force_mdp_enable" "1"
		write "/sys/module/ged/parameters/ged_log_perf_trace_enable" "0"
		write "/sys/module/ged/parameters/ged_log_trace_enable" "0"
		write "/sys/module/ged/parameters/ged_monitor_3D_fence_debug" "0"
		write "/sys/module/ged/parameters/ged_monitor_3D_fence_disable" "1"
		write "/sys/module/ged/parameters/ged_monitor_3D_fence_systrace" "0"
		write "/sys/module/ged/parameters/ged_smart_boost" "0"
		write "/sys/module/ged/parameters/gpu_debug_enable" "0"
		write "/sys/module/ged/parameters/gpu_dvfs_enable" "1"
		write "/sys/module/ged/parameters/gx_3D_benchmark_on" "1"
		write "/sys/module/ged/parameters/gx_dfps" "0"
		write "/sys/module/ged/parameters/gx_force_cpu_boost" "0"
		write "/sys/module/ged/parameters/gx_frc_mode" "0"
		write "/sys/module/ged/parameters/gx_game_mode" "0"
		write "/sys/module/ged/parameters/is_GED_KPI_enabled" "1"
		write "/sys/module/ged/parameters/boost_amp" "1"
		write "/sys/module/ged/parameters/gx_boost_on" "1"
		write "/sys/module/ged/parameters/gpu_idle" "100"
	}

	[[ -d "/proc/gpufreq/" ]] && {
		write "/proc/gpufreq/gpufreq_opp_stress_test" "1"
		write "/proc/gpufreq/gpufreq_opp_freq" "0"
		write "/proc/gpufreq/gpufreq_input_boost" "0"
		write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "1"
		write "/proc/gpufreq/gpufreq_limited_oc_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "1"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "1"
		for i in 1 2 3 4 5 6 7 8 9 10; do
			write "/proc/gpufreq/gpufreq_limit_table" "$ 1 1"
		done
	}

	[[ -d "/sys/kernel/ged/" ]] && {
		write "/sys/kernel/ged/hal/timer_base_dvfs_margin" "30"
		write "/sys/kernel/ged/hal/dvfs_margin_value" "30"
	}

	[[ -d "/proc/mali/" ]] && {
		write "/proc/mali/dvfs_enable" "1"
		write "/proc/mali/always_on" "1"
	}

	[[ -d "/sys/module/pvrsrvkm/" ]] && write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"

	[[ -d "/sys/module/simple_gpu_algorithm/" ]] && {
		write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "0"
		kmsg "Disabled SGPU algorithm"
		kmsg3 ""
	}

	[[ -d "/sys/module/adreno_idler/" ]] && {
		write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
		kmsg "Disabled adreno idler"
		kmsg3 ""
	}
	kmsg "Tweaked GPU parameters"
	kmsg3 ""
}

gpu_battery() {
	if [[ "$qcom" == "true" ]]; then
		avail_govs="$(cat "${gpu}devfreq/available_governors")"

		for governor in msm-adreno-tz simple_ondemand ondemand; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${gpu}devfreq/governor" "$governor"
				break
			fi
		done

	elif [[ "$exynos" == "true" ]]; then
		avail_govs="$(cat "${gpui}gpu_available_governor")"

		for governor in Interactive mali_ondemand ondemand Dynamic Static; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "$governor"
				break
			fi
		done

	elif [[ "$mtk" == "true" ]]; then
		avail_govs="$(cat "${gpu}available_governors")"

		for governor in Interactive mali_ondemand ondemand Dynamic Static; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "$governor"
				break
			fi
		done
	fi

	if [[ "$qcom" == "true" ]]; then
		write "${gpu}throttling" "1"
		write "${gpu}thermal_pwrlevel" "$gpu_calc_thrtl"
		write "${gpu}devfreq/adrenoboost" "0"
		write "${gpu}force_no_nap" "0"
		write "${gpu}bus_split" "1"
		write "${gpu}devfreq/max_freq" "$gpu_max_freq"
		write "${gpu}devfreq/min_freq" "$gpu_min_freq"
		write "${gpu}min_pwrlevel" "$gpu_min_pl"
		write "${gpu}force_bus_on" "0"
		write "${gpu}force_clk_on" "0"
		write "${gpu}force_rail_on" "0"
		write "${gpu}idle_timer" "64"
		write "${gpu}pwrnap" "1"
		write "/sys/kernel/debug/sde_rotator0/clk_always_on" "0"
	elif [[ "$qcom" == "false" ]]; then
		[[ "$one_ui" == "false" ]] && write "${gpu}dvfs" "1"
		write "${gpui}gpu_max_clock" "$gpu_max_freq"
		write "${gpui}gpu_min_clock" "$gpu_min"
		write "${gpu}highspeed_clock" "$gpu_max_freq"
		write "${gpu}highspeed_load" "95"
		write "${gpu}highspeed_delay" "0"
		write "${gpu}power_policy" "coarse_demand"
		write "${gpu}cl_boost_disable" "1"
		write "${gpui}boost" "0"
		write "${gpug}mali_touch_boost_level" "0"
		write "${gpu}max_freq" "$gpu_max_freq"
		write "${gpu}min_freq" "$gpu_min"
		write "${gpu}tmu" "1"
		write "${gpu}devfreq/gpufreq/max_freq" "$gpu_max_freq"
		write "${gpu}devfreq/gpufreq/min_freq" "$gpu_min"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync" "1"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_upthreshold" "85"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_downdifferential" "65"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold" "75"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential" "55"
	fi

	[[ -d "/sys/module/ged/" ]] && {
		write "/sys/module/ged/parameters/ged_boost_enable" "0"
		write "/sys/module/ged/parameters/boost_gpu_enable" "0"
		write "/sys/module/ged/parameters/boost_extra" "0"
		write "/sys/module/ged/parameters/enable_cpu_boost" "0"
		write "/sys/module/ged/parameters/enable_gpu_boost" "0"
		write "/sys/module/ged/parameters/enable_game_self_frc_detect" "0"
		write "/sys/module/ged/parameters/ged_force_mdp_enable" "0"
		write "/sys/module/ged/parameters/ged_log_perf_trace_enable" "0"
		write "/sys/module/ged/parameters/ged_log_trace_enable" "0"
		write "/sys/module/ged/parameters/ged_monitor_3D_fence_debug" "0"
		write "/sys/module/ged/parameters/ged_monitor_3D_fence_disable" "1"
		write "/sys/module/ged/parameters/ged_monitor_3D_fence_systrace" "0"
		write "/sys/module/ged/parameters/ged_smart_boost" "0"
		write "/sys/module/ged/parameters/gpu_debug_enable" "0"
		write "/sys/module/ged/parameters/gpu_dvfs_enable" "1"
		write "/sys/module/ged/parameters/gx_3D_benchmark_on" "0"
		write "/sys/module/ged/parameters/gx_dfps" "0"
		write "/sys/module/ged/parameters/gx_force_cpu_boost" "0"
		write "/sys/module/ged/parameters/gx_frc_mode" "0"
		write "/sys/module/ged/parameters/gx_game_mode" "0"
		write "/sys/module/ged/parameters/is_GED_KPI_enabled" "0"
		write "/sys/module/ged/parameters/boost_amp" "0"
		write "/sys/module/ged/parameters/gx_boost_on" "0"
		write "/sys/module/ged/parameters/gpu_idle" "100"
	}

	[[ -d "/proc/gpufreq/" ]] && {
		write "/proc/gpufreq/gpufreq_opp_stress_test" "0"
		write "/proc/gpufreq/gpufreq_opp_freq" "0"
		write "/proc/gpufreq/gpufreq_input_boost" "0"
		write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_oc_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "0"
		for i in 1 2 3 4 5 6 7 8 9 10; do
			write "/proc/gpufreq/gpufreq_limit_table" "$ 1 1"
		done
	}

	[[ -d "/sys/kernel/ged/" ]] && {
		write "/sys/kernel/ged/hal/timer_base_dvfs_margin" "15"
		write "/sys/kernel/ged/hal/dvfs_margin_value" "15"
	}

	[[ -d "/proc/mali/" ]] && {
		write "/proc/mali/dvfs_enable" "1"
		write "/proc/mali/always_on" "0"
	}

	[[ -d "/sys/module/pvrsrvkm/" ]] && write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"

	[[ -d "/sys/module/simple_gpu_algorithm/" ]] && {
		write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "1"
		write "/sys/module/simple_gpu_algorithm/parameters/default_laziness" "4"
		write "/sys/module/simple_gpu_algorithm/parameters/ramp_up_threshold" "5000"
		kmsg "Enabled and tweaked SGPU algorithm"
		kmsg3 ""
	}

	[[ -d "/sys/module/adreno_idler/" ]] && {
		write "/sys/module/adreno_idler/parameters/adreno_idler_active" "Y"
		write "/sys/module/adreno_idler/parameters/adreno_idler_idleworkload" "10000"
		write "/sys/module/adreno_idler/parameters/adreno_idler_downdifferential" "45"
		write "/sys/module/adreno_idler/parameters/adreno_idler_idlewait" "15"
		kmsg "Enabled and tweaked adreno idler algorithm"
		kmsg3 ""
	}
	kmsg "Tweaked GPU parameters"
	kmsg3 ""
}

gpu_gaming() {
	if [[ "$qcom" == "true" ]]; then
		avail_govs="$(cat "${gpu}devfreq/available_governors")"

		for governor in msm-adreno-tz simple_ondemand ondemand; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${gpu}devfreq/governor" "$governor"
				break
			fi
		done

	elif [[ "$exynos" == "true" ]]; then
		avail_govs="$(cat "${gpui}gpu_available_governor")"

		for governor in Booster Interactive Dynamic Static ondemand; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "$governor"
				break
			fi
		done

	elif [[ "$mtk" == "true" ]]; then
		avail_govs="$(cat "${gpu}available_governors")"

		for governor in Booster Interactive Dynamic Static ondemand; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "$governor"
				break
			fi
		done
	fi

	if [[ "$qcom" == "true" ]]; then
		write "${gpu}throttling" "0"
		write "${gpu}thermal_pwrlevel" "$gpu_calc_thrtl"
		write "${gpu}devfreq/adrenoboost" "0"
		write "${gpu}force_no_nap" "1"
		write "${gpu}bus_split" "0"
		write "${gpu}devfreq/max_freq" "$gpu_max_freq"
		write "${gpu}devfreq/min_freq" "$gpu_min_freq"
		write "${gpu}min_pwrlevel" "$gpu_max_pl"
		write "${gpu}force_bus_on" "1"
		write "${gpu}force_clk_on" "1"
		write "${gpu}force_rail_on" "1"
		write "${gpu}idle_timer" "10000"
		write "${gpu}pwrnap" "0"
		write "/sys/kernel/debug/sde_rotator0/clk_always_on" "1"
	elif [[ "$qcom" == "false" ]]; then
		[[ "$one_ui" == "false" ]] && write "${gpu}dvfs" "0"
		write "${gpui}gpu_max_clock" "$gpu_max_freq"
		write "${gpui}gpu_min_clock" "$gpu_min"
		write "${gpu}highspeed_clock" "$gpu_max_freq"
		write "${gpu}highspeed_load" "76"
		write "${gpu}highspeed_delay" "0"
		write "${gpu}power_policy" "always_on"
		write "${gpui}boost" "1"
		write "${gpu}cl_boost_disable" "0"
		write "${gpug}mali_touch_boost_level" "1"
		write "${gpu}max_freq" "$gpu_max_freq"
		write "${gpu}min_freq" "$gpu_min"
		write "${gpu}tmu" "0"
		write "${gpu}devfreq/gpufreq/max_freq" "$gpu_max_freq"
		write "${gpu}devfreq/gpufreq/min_freq" "$gpu_min"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync" "0"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_upthreshold" "35"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_downdifferential" "15"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold" "25"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential" "10"
	fi

	[[ -d "/sys/module/ged/" ]] && {
		write "/sys/module/ged/parameters/ged_boost_enable" "1"
		write "/sys/module/ged/parameters/boost_gpu_enable" "0"
		write "/sys/module/ged/parameters/boost_extra" "1"
		write "/sys/module/ged/parameters/enable_cpu_boost" "1"
		write "/sys/module/ged/parameters/enable_gpu_boost" "0"
		write "/sys/module/ged/parameters/enable_game_self_frc_detect" "1"
		write "/sys/module/ged/parameters/ged_force_mdp_enable" "1"
		write "/sys/module/ged/parameters/ged_log_perf_trace_enable" "0"
		write "/sys/module/ged/parameters/ged_log_trace_enable" "0"
		write "/sys/module/ged/parameters/ged_monitor_3D_fence_debug" "0"
		write "/sys/module/ged/parameters/ged_monitor_3D_fence_disable" "1"
		write "/sys/module/ged/parameters/ged_monitor_3D_fence_systrace" "0"
		write "/sys/module/ged/parameters/ged_smart_boost" "0"
		write "/sys/module/ged/parameters/gpu_debug_enable" "0"
		write "/sys/module/ged/parameters/gpu_dvfs_enable" "0"
		write "/sys/module/ged/parameters/gx_3D_benchmark_on" "1"
		write "/sys/module/ged/parameters/gx_dfps" "0"
		write "/sys/module/ged/parameters/gx_force_cpu_boost" "1"
		write "/sys/module/ged/parameters/gx_frc_mode" "1"
		write "/sys/module/ged/parameters/gx_game_mode" "1"
		write "/sys/module/ged/parameters/is_GED_KPI_enabled" "1"
		write "/sys/module/ged/parameters/boost_amp" "1"
		write "/sys/module/ged/parameters/gx_boost_on" "1"
		write "/sys/module/ged/parameters/gpu_idle" "0"
	}

	[[ -d "/proc/gpufreq/" ]] && {
		write "/proc/gpufreq/gpufreq_opp_stress_test" "1"
		write "/proc/gpufreq/gpufreq_opp_freq" "$gpu_max"
		write "/proc/gpufreq/gpufreq_input_boost" "0"
		write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "1"
		write "/proc/gpufreq/gpufreq_limited_oc_ignore" "1"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "1"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "1"
		for i in 1 2 3 4 5 6 7 8 9 10; do
			write "/proc/gpufreq/gpufreq_limit_table" "$ 0 0"
		done
	}

	[[ -d "/sys/kernel/ged/" ]] && {
		write "/sys/kernel/ged/hal/timer_base_dvfs_margin" "130"
		write "/sys/kernel/ged/hal/dvfs_margin_value" "130"
	}

	[[ -d "/proc/mali/" ]] && {
		write "/proc/mali/dvfs_enable" "0"
		write "/proc/mali/always_on" "1"
	}

	[[ -d "/sys/module/pvrsrvkm/" ]] && write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"

	[[ -d "/sys/module/simple_gpu_algorithm/" ]] && {
		write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "0"
		kmsg "Disabled SGPU algorithm"
		kmsg3 ""
	}

	[[ -d "/sys/module/adreno_idler/" ]] && {
		write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
		kmsg "Disabled adreno idler"
		kmsg3 ""
	}
	kmsg "Tweaked GPU parameters"
	kmsg3 ""
}

disable_crypto_tests() {
	[[ -e "/sys/module/cryptomgr/parameters/notests" ]] && {
		write "/sys/module/cryptomgr/parameters/notests" "Y"
		kmsg "Disabled cryptography tests"
		kmsg3 ""
	}
}

disable_spd_freqs() {
	[[ -e "/sys/module/exynos_acme/parameters/enable_suspend_freqs" ]] && {
		write "/sys/module/exynos_acme/parameters/enable_suspend_freqs" "N"
		kmsg "Disabled suspend frequencies"
		kmsg3 ""
	}
}

config_pwr_spd() {
	[[ -e "/sys/kernel/power_suspend/power_suspend_mode" ]] && {
		write "/sys/kernel/power_suspend/power_suspend_mode" "3"
		kmsg "Tweaked power suspend mode"
		kmsg3 ""
	}
}

schedtune_latency() {
	[[ -d "$stune" ]] && {
		write "${stune}background/schedtune.boost" "0"
		write "${stune}background/schedtune.colocate" "0"
		write "${stune}background/schedtune.prefer_idle" "0"
		write "${stune}background/schedtune.sched_boost" "0"
		write "${stune}background/schedtune.sched_boost_no_override" "1"
		write "${stune}background/schedtune.prefer_perf" "0"
		write "${stune}background/schedtune.util_est_en" "0"
		write "${stune}background/schedtune.ontime_en" "0"
		write "${stune}background/schedtune.prefer_high_cap" "0"
		write "${stune}foreground/schedtune.boost" "0"
		write "${stune}foreground/schedtune.colocate" "0"
		write "${stune}foreground/schedtune.prefer_idle" "0"
		write "${stune}foreground/schedtune.sched_boost" "0"
		write "${stune}foreground/schedtune.sched_boost_no_override" "1"
		write "${stune}foreground/schedtune.prefer_perf" "0"
		write "${stune}foreground/schedtune.util_est_en" "0"
		write "${stune}foreground/schedtune.ontime_en" "0"
		write "${stune}foreground/schedtune.prefer_high_cap" "0"
		write "${stune}nnapi-hal/schedtune.boost" "1"
		write "${stune}nnapi-hal/schedtune.colocate" "0"
		write "${stune}nnapi-hal/schedtune.prefer_idle" "1"
		write "${stune}nnapi-hal/schedtune.sched_boost" "0"
		write "${stune}nnapi-hal/schedtune.sched_boost_no_override" "1"
		write "${stune}nnapi-hal/schedtune.prefer_perf" "0"
		write "${stune}nnapi-hal/schedtune.util_est_en" "0"
		write "${stune}nnapi-hal/schedtune.ontime_en" "0"
		write "${stune}nnapi-hal/schedtune.prefer_high_cap" "0"
		write "${stune}rt/schedtune.boost" "0"
		write "${stune}rt/schedtune.colocate" "0"
		write "${stune}rt/schedtune.prefer_idle" "0"
		write "${stune}rt/schedtune.sched_boost" "0"
		write "${stune}rt/schedtune.sched_boost_no_override" "1"
		write "${stune}rt/schedtune.prefer_perf" "0"
		write "${stune}rt/schedtune.util_est_en" "0"
		write "${stune}rt/schedtune.ontime_en" "0"
		write "${stune}rt/schedtune.prefer_high_cap" "0"
		write "${stune}camera-daemon/schedtune.boost" "0"
		write "${stune}camera-daemon/schedtune.colocate" "0"
		write "${stune}camera-daemon/schedtune.prefer_idle" "1"
		write "${stune}camera-daemon/schedtune.sched_boost" "0"
		write "${stune}camera-daemon/schedtune.sched_boost_no_override" "1"
		write "${stune}camera-daemon/schedtune.prefer_perf" "0"
		write "${stune}camera-daemon/schedtune.util_est_en" "0"
		write "${stune}camera-daemon/schedtune.ontime_en" "0"
		write "${stune}camera-daemon/schedtune.prefer_high_cap" "1"
		write "${stune}top-app/schedtune.boost" "10"
		write "${stune}top-app/schedtune.colocate" "1"
		write "${stune}top-app/schedtune.prefer_idle" "1"
		write "${stune}top-app/schedtune.sched_boost" "0"
		write "${stune}top-app/schedtune.sched_boost_no_override" "1"
		write "${stune}top-app/schedtune.prefer_perf" "1"
		write "${stune}top-app/schedtune.util_est_en" "1"
		write "${stune}top-app/schedtune.ontime_en" "1"
		write "${stune}top-app/schedtune.prefer_high_cap" "1"
		write "${stune}schedtune.boost" "0"
		write "${stune}schedtune.colocate" "0"
		write "${stune}schedtune.prefer_idle" "0"
		write "${stune}schedtune.sched_boost" "0"
		write "${stune}schedtune.sched_boost_no_override" "0"
		write "${stune}schedtune.prefer_perf" "0"
		write "${stune}schedtune.util_est_en" "0"
		write "${stune}schedtune.ontime_en" "0"
		write "${stune}schedtune.prefer_high_cap" "0"
		kmsg "Tweaked schedtune settings"
		kmsg3 ""
	}
}

schedtune_balanced() {
	[[ -d "$stune" ]] && {
		write "${stune}background/schedtune.boost" "0"
		write "${stune}background/schedtune.colocate" "0"
		write "${stune}background/schedtune.prefer_idle" "0"
		write "${stune}background/schedtune.sched_boost" "0"
		write "${stune}background/schedtune.sched_boost_no_override" "1"
		write "${stune}background/schedtune.prefer_perf" "0"
		write "${stune}background/schedtune.util_est_en" "0"
		write "${stune}background/schedtune.ontime_en" "0"
		write "${stune}background/schedtune.prefer_high_cap" "0"
		write "${stune}foreground/schedtune.boost" "0"
		write "${stune}foreground/schedtune.colocate" "0"
		write "${stune}foreground/schedtune.prefer_idle" "0"
		write "${stune}foreground/schedtune.sched_boost" "0"
		write "${stune}foreground/schedtune.sched_boost_no_override" "1"
		write "${stune}foreground/schedtune.prefer_perf" "0"
		write "${stune}foreground/schedtune.util_est_en" "0"
		write "${stune}foreground/schedtune.ontime_en" "0"
		write "${stune}foreground/schedtune.prefer_high_cap" "0"
		write "${stune}nnapi-hal/schedtune.boost" "1"
		write "${stune}nnapi-hal/schedtune.colocate" "0"
		write "${stune}nnapi-hal/schedtune.prefer_idle" "1"
		write "${stune}nnapi-hal/schedtune.sched_boost" "0"
		write "${stune}nnapi-hal/schedtune.sched_boost_no_override" "1"
		write "${stune}nnapi-hal/schedtune.prefer_perf" "0"
		write "${stune}nnapi-hal/schedtune.util_est_en" "0"
		write "${stune}nnapi-hal/schedtune.ontime_en" "0"
		write "${stune}nnapi-hal/schedtune.prefer_high_cap" "0"
		write "${stune}rt/schedtune.boost" "0"
		write "${stune}rt/schedtune.colocate" "0"
		write "${stune}rt/schedtune.prefer_idle" "0"
		write "${stune}rt/schedtune.sched_boost" "0"
		write "${stune}rt/schedtune.sched_boost_no_override" "1"
		write "${stune}rt/schedtune.prefer_perf" "0"
		write "${stune}rt/schedtune.util_est_en" "0"
		write "${stune}rt/schedtune.ontime_en" "0"
		write "${stune}rt/schedtune.prefer_high_cap" "0"
		write "${stune}camera-daemon/schedtune.boost" "0"
		write "${stune}camera-daemon/schedtune.colocate" "0"
		write "${stune}camera-daemon/schedtune.prefer_idle" "1"
		write "${stune}camera-daemon/schedtune.sched_boost" "0"
		write "${stune}camera-daemon/schedtune.sched_boost_no_override" "1"
		write "${stune}camera-daemon/schedtune.prefer_perf" "0"
		write "${stune}camera-daemon/schedtune.util_est_en" "0"
		write "${stune}camera-daemon/schedtune.ontime_en" "0"
		write "${stune}camera-daemon/schedtune.prefer_high_cap" "1"
		write "${stune}top-app/schedtune.boost" "10"
		write "${stune}top-app/schedtune.colocate" "1"
		write "${stune}top-app/schedtune.prefer_idle" "1"
		write "${stune}top-app/schedtune.sched_boost" "0"
		write "${stune}top-app/schedtune.sched_boost_no_override" "1"
		write "${stune}top-app/schedtune.prefer_perf" "1"
		write "${stune}top-app/schedtune.util_est_en" "1"
		write "${stune}top-app/schedtune.ontime_en" "1"
		write "${stune}top-app/schedtune.prefer_high_cap" "1"
		write "${stune}schedtune.boost" "0"
		write "${stune}schedtune.colocate" "0"
		write "${stune}schedtune.prefer_idle" "0"
		write "${stune}schedtune.sched_boost" "0"
		write "${stune}schedtune.sched_boost_no_override" "0"
		write "${stune}schedtune.prefer_perf" "0"
		write "${stune}schedtune.util_est_en" "0"
		write "${stune}schedtune.ontime_en" "0"
		write "${stune}schedtune.prefer_high_cap" "0"
		kmsg "Tweaked schedtune settings"
		kmsg3 ""
	}
}

schedtune_extreme() {
	[[ -d "$stune" ]] && {
		write "${stune}background/schedtune.boost" "0"
		write "${stune}background/schedtune.colocate" "0"
		write "${stune}background/schedtune.prefer_idle" "0"
		write "${stune}background/schedtune.sched_boost" "0"
		write "${stune}background/schedtune.sched_boost_no_override" "1"
		write "${stune}background/schedtune.prefer_perf" "0"
		write "${stune}background/schedtune.util_est_en" "0"
		write "${stune}background/schedtune.ontime_en" "0"
		write "${stune}background/schedtune.prefer_high_cap" "0"
		write "${stune}foreground/schedtune.boost" "0"
		write "${stune}foreground/schedtune.colocate" "0"
		write "${stune}foreground/schedtune.prefer_idle" "1"
		write "${stune}foreground/schedtune.sched_boost" "0"
		write "${stune}foreground/schedtune.sched_boost_no_override" "1"
		write "${stune}foreground/schedtune.prefer_perf" "0"
		write "${stune}foreground/schedtune.util_est_en" "0"
		write "${stune}foreground/schedtune.ontime_en" "0"
		write "${stune}foreground/schedtune.prefer_high_cap" "0"
		write "${stune}nnapi-hal/schedtune.boost" "0"
		write "${stune}nnapi-hal/schedtune.colocate" "0"
		write "${stune}nnapi-hal/schedtune.prefer_idle" "1"
		write "${stune}nnapi-hal/schedtune.sched_boost" "0"
		write "${stune}nnapi-hal/schedtune.sched_boost_no_override" "1"
		write "${stune}nnapi-hal/schedtune.prefer_perf" "0"
		write "${stune}nnapi-hal/schedtune.util_est_en" "0"
		write "${stune}nnapi-hal/schedtune.ontime_en" "0"
		write "${stune}nnapi-hal/schedtune.prefer_high_cap" "0"
		write "${stune}rt/schedtune.boost" "0"
		write "${stune}rt/schedtune.colocate" "0"
		write "${stune}rt/schedtune.prefer_idle" "0"
		write "${stune}rt/schedtune.sched_boost" "0"
		write "${stune}rt/schedtune.sched_boost_no_override" "1"
		write "${stune}rt/schedtune.prefer_perf" "0"
		write "${stune}rt/schedtune.util_est_en" "0"
		write "${stune}rt/schedtune.ontime_en" "0"
		write "${stune}rt/schedtune.prefer_high_cap" "0"
		write "${stune}camera-daemon/schedtune.boost" "0"
		write "${stune}camera-daemon/schedtune.colocate" "0"
		write "${stune}camera-daemon/schedtune.prefer_idle" "1"
		write "${stune}camera-daemon/schedtune.sched_boost" "0"
		write "${stune}camera-daemon/schedtune.sched_boost_no_override" "1"
		write "${stune}camera-daemon/schedtune.prefer_perf" "0"
		write "${stune}camera-daemon/schedtune.util_est_en" "0"
		write "${stune}camera-daemon/schedtune.ontime_en" "0"
		write "${stune}camera-daemon/schedtune.prefer_high_cap" "1"
		write "${stune}top-app/schedtune.boost" "100"
		write "${stune}top-app/schedtune.colocate" "1"
		write "${stune}top-app/schedtune.prefer_idle" "1"
		write "${stune}top-app/schedtune.sched_boost" "15"
		write "${stune}top-app/schedtune.sched_boost_no_override" "1"
		write "${stune}top-app/schedtune.prefer_perf" "1"
		write "${stune}top-app/schedtune.util_est_en" "1"
		write "${stune}top-app/schedtune.ontime_en" "1"
		write "${stune}top-app/schedtune.prefer_high_cap" "1"
		write "${stune}schedtune.boost" "0"
		write "${stune}schedtune.colocate" "0"
		write "${stune}schedtune.prefer_idle" "0"
		write "${stune}schedtune.sched_boost" "0"
		write "${stune}schedtune.sched_boost_no_override" "0"
		write "${stune}schedtune.prefer_perf" "0"
		write "${stune}schedtune.util_est_en" "0"
		write "${stune}schedtune.ontime_en" "0"
		write "${stune}schedtune.prefer_high_cap" "0"
		kmsg "Tweaked schedtune settings"
		kmsg3 ""
	}
}

schedtune_battery() {
	[[ -d "$stune" ]] && {
		write "${stune}background/schedtune.boost" "0"
		write "${stune}background/schedtune.colocate" "0"
		write "${stune}background/schedtune.prefer_idle" "0"
		write "${stune}background/schedtune.sched_boost" "0"
		write "${stune}background/schedtune.sched_boost_no_override" "1"
		write "${stune}background/schedtune.prefer_perf" "0"
		write "${stune}background/schedtune.util_est_en" "0"
		write "${stune}background/schedtune.ontime_en" "0"
		write "${stune}background/schedtune.prefer_high_cap" "0"
		write "${stune}foreground/schedtune.boost" "0"
		write "${stune}foreground/schedtune.colocate" "0"
		write "${stune}foreground/schedtune.prefer_idle" "1"
		write "${stune}foreground/schedtune.sched_boost" "0"
		write "${stune}foreground/schedtune.sched_boost_no_override" "1"
		write "${stune}foreground/schedtune.prefer_perf" "0"
		write "${stune}foreground/schedtune.util_est_en" "0"
		write "${stune}foreground/schedtune.ontime_en" "0"
		write "${stune}foreground/schedtune.prefer_high_cap" "0"
		write "${stune}nnapi-hal/schedtune.boost" "0"
		write "${stune}nnapi-hal/schedtune.colocate" "0"
		write "${stune}nnapi-hal/schedtune.prefer_idle" "1"
		write "${stune}nnapi-hal/schedtune.sched_boost" "0"
		write "${stune}nnapi-hal/schedtune.sched_boost_no_override" "1"
		write "${stune}nnapi-hal/schedtune.prefer_perf" "0"
		write "${stune}nnapi-hal/schedtune.util_est_en" "0"
		write "${stune}nnapi-hal/schedtune.ontime_en" "0"
		write "${stune}nnapi-hal/schedtune.prefer_high_cap" "0"
		write "${stune}rt/schedtune.boost" "0"
		write "${stune}rt/schedtune.colocate" "0"
		write "${stune}rt/schedtune.prefer_idle" "0"
		write "${stune}rt/schedtune.sched_boost" "0"
		write "${stune}rt/schedtune.sched_boost_no_override" "1"
		write "${stune}rt/schedtune.prefer_perf" "0"
		write "${stune}rt/schedtune.util_est_en" "0"
		write "${stune}rt/schedtune.ontime_en" "0"
		write "${stune}rt/schedtune.prefer_high_cap" "0"
		write "${stune}camera-daemon/schedtune.boost" "0"
		write "${stune}camera-daemon/schedtune.colocate" "0"
		write "${stune}camera-daemon/schedtune.prefer_idle" "1"
		write "${stune}camera-daemon/schedtune.sched_boost" "0"
		write "${stune}camera-daemon/schedtune.sched_boost_no_override" "1"
		write "${stune}camera-daemon/schedtune.prefer_perf" "0"
		write "${stune}camera-daemon/schedtune.util_est_en" "0"
		write "${stune}camera-daemon/schedtune.ontime_en" "0"
		write "${stune}camera-daemon/schedtune.prefer_high_cap" "1"
		write "${stune}top-app/schedtune.boost" "0"
		write "${stune}top-app/schedtune.colocate" "1"
		write "${stune}top-app/schedtune.prefer_idle" "1"
		write "${stune}top-app/schedtune.sched_boost" "0"
		write "${stune}top-app/schedtune.sched_boost_no_override" "1"
		write "${stune}top-app/schedtune.prefer_perf" "1"
		write "${stune}top-app/schedtune.util_est_en" "1"
		write "${stune}top-app/schedtune.ontime_en" "1"
		write "${stune}top-app/schedtune.prefer_high_cap" "1"
		write "${stune}schedtune.boost" "0"
		write "${stune}schedtune.colocate" "0"
		write "${stune}schedtune.prefer_idle" "0"
		write "${stune}schedtune.sched_boost" "0"
		write "${stune}schedtune.sched_boost_no_override" "0"
		write "${stune}schedtune.prefer_perf" "0"
		write "${stune}schedtune.util_est_en" "0"
		write "${stune}schedtune.ontime_en" "0"
		write "${stune}schedtune.prefer_high_cap" "0"
		kmsg "Tweaked schedtune settings"
		kmsg3 ""
	}
}

schedtune_gaming() {
	[[ -d "$stune" ]] && {
		write "${stune}background/schedtune.boost" "0"
		write "${stune}background/schedtune.prefer_idle" "0"
		write "${stune}background/schedtune.sched_boost" "0"
		write "${stune}background/schedtune.sched_boost_no_override" "1"
		write "${stune}background/schedtune.prefer_perf" "0"
		write "${stune}background/schedtune.util_est_en" "0"
		write "${stune}background/schedtune.ontime_en" "0"
		write "${stune}background/schedtune.prefer_high_cap" "0"
		write "${stune}foreground/schedtune.boost" "0"
		write "${stune}foreground/schedtune.colocate" "0"
		write "${stune}foreground/schedtune.prefer_idle" "1"
		write "${stune}foreground/schedtune.sched_boost" "15"
		write "${stune}foreground/schedtune.sched_boost_no_override" "1"
		write "${stune}foreground/schedtune.prefer_perf" "0"
		write "${stune}foreground/schedtune.util_est_en" "1"
		write "${stune}foreground/schedtune.ontime_en" "1"
		write "${stune}foreground/schedtune.prefer_high_cap" "1"
		write "${stune}nnapi-hal/schedtune.boost" "0"
		write "${stune}nnapi-hal/schedtune.colocate" "0"
		write "${stune}nnapi-hal/schedtune.prefer_idle" "1"
		write "${stune}nnapi-hal/schedtune.sched_boost" "0"
		write "${stune}nnapi-hal/schedtune.sched_boost_no_override" "1"
		write "${stune}nnapi-hal/schedtune.prefer_perf" "0"
		write "${stune}nnapi-hal/schedtune.util_est_en" "0"
		write "${stune}nnapi-hal/schedtune.ontime_en" "0"
		write "${stune}nnapi-hal/schedtune.prefer_high_cap" "0"
		write "${stune}rt/schedtune.boost" "0"
		write "${stune}rt/schedtune.colocate" "0"
		write "${stune}rt/schedtune.prefer_idle" "0"
		write "${stune}rt/schedtune.sched_boost" "0"
		write "${stune}rt/schedtune.prefer_perf" "0"
		write "${stune}rt/schedtune.util_est_en" "0"
		write "${stune}rt/schedtune.ontime_en" "0"
		write "${stune}rt/schedtune.prefer_high_cap" "0"
		write "${stune}camera-daemon/schedtune.boost" "0"
		write "${stune}camera-daemon/schedtune.colocate" "0"
		write "${stune}camera-daemon/schedtune.prefer_idle" "1"
		write "${stune}camera-daemon/schedtune.sched_boost" "0"
		write "${stune}camera-daemon/schedtune.sched_boost_no_override" "1"
		write "${stune}camera-daemon/schedtune.prefer_perf" "0"
		write "${stune}camera-daemon/schedtune.util_est_en" "0"
		write "${stune}camera-daemon/schedtune.ontime_en" "0"
		write "${stune}camera-daemon/schedtune.prefer_high_cap" "0"
		write "${stune}top-app/schedtune.boost" "100"
		write "${stune}top-app/schedtune.colocate" "1"
		write "${stune}top-app/schedtune.prefer_idle" "1"
		write "${stune}top-app/schedtune.sched_boost" "15"
		write "${stune}top-app/schedtune.sched_boost_no_override" "1"
		write "${stune}top-app/schedtune.prefer_perf" "0"
		write "${stune}top-app/schedtune.util_est_en" "1"
		write "${stune}top-app/schedtune.ontime_en" "1"
		write "${stune}top-app/schedtune.prefer_high_cap" "0"
		write "${stune}schedtune.boost" "0"
		write "${stune}schedtune.colocate" "0"
		write "${stune}schedtune.prefer_high_cap" "0"
		write "${stune}schedtune.prefer_idle" "0"
		write "${stune}schedtune.sched_boost" "0"
		write "${stune}schedtune.sched_boost_no_override" "0"
		write "${stune}schedtune.prefer_perf" "0"
		write "${stune}schedtune.util_est_en" "0"
		write "${stune}schedtune.ontime_en" "0"
		write "${stune}schedtune.prefer_high_cap" "0"
		kmsg "Tweaked schedtune settings"
		kmsg3 ""
	}
}

uclamp_latency() {
	[[ -e "${cpuctl}top-app/cpu.uclamp.max" ]] && {
		write "${kernel}sched_util_clamp_min" "392"
		write "${kernel}sched_util_clamp_max" "1024"
		write "${cpuctl}top-app/cpu.uclamp.max" "max"
		write "${cpuctl}top-app/cpu.uclamp.min" "20"
		write "${cpuctl}top-app/cpu.uclamp.boosted" "1"
		write "${cpuctl}top-app/cpu.uclamp.latency_sensitive" "1"
		write "${cpuctl}foreground/cpu.uclamp.max" "max"
		write "${cpuctl}foreground/cpu.uclamp.min" "10"
		write "${cpuctl}foreground/cpu.uclamp.boosted" "0"
		write "${cpuctl}foreground/cpu.uclamp.latency_sensitive" "0"
		write "${cpuctl}background/cpu.uclamp.max" "50"
		write "${cpuctl}background/cpu.uclamp.min" "0"
		write "${cpuctl}background/cpu.uclamp.boosted" "0"
		write "${cpuctl}background/cpu.uclamp.latency_sensitive" "0"
		write "${cpuctl}system-background/cpu.uclamp.max" "40"
		write "${cpuctl}system-background/cpu.uclamp.min" "0"
		write "${cpuctl}system-background/cpu.uclamp.boosted" "0"
		write "${cpuctl}system-background/cpu.uclamp.latency_sensitive" "0"
		kmsg "Tweaked Uclamp parameters"
		kmsg3 ""
	}
}

uclamp_balanced() {
	[[ -e "${cpuctl}top-app/cpu.uclamp.max" ]] && {
		write "${kernel}sched_util_clamp_min" "256"
		write "${kernel}sched_util_clamp_max" "1024"
		write "${cpuctl}top-app/cpu.uclamp.max" "max"
		write "${cpuctl}top-app/cpu.uclamp.min" "10"
		write "${cpuctl}top-app/cpu.uclamp.boosted" "1"
		write "${cpuctl}top-app/cpu.uclamp.latency_sensitive" "1"
		write "${cpuctl}foreground/cpu.uclamp.max" "max"
		write "${cpuctl}foreground/cpu.uclamp.min" "5"
		write "${cpuctl}foreground/cpu.uclamp.boosted" "0"
		write "${cpuctl}foreground/cpu.uclamp.latency_sensitive" "0"
		write "${cpuctl}background/cpu.uclamp.max" "50"
		write "${cpuctl}background/cpu.uclamp.min" "0"
		write "${cpuctl}background/cpu.uclamp.boosted" "0"
		write "${cpuctl}background/cpu.uclamp.latency_sensitive" "0"
		write "${cpuctl}system-background/cpu.uclamp.max" "40"
		write "${cpuctl}system-background/cpu.uclamp.min" "0"
		write "${cpuctl}system-background/cpu.uclamp.boosted" "0"
		write "${cpuctl}system-background/cpu.uclamp.latency_sensitive" "0"
		kmsg "Tweaked Uclamp parameters"
		kmsg3 ""
	}
}

uclamp_extreme() {
	[[ -e "${cpuctl}top-app/cpu.uclamp.max" ]] && {
		write "${kernel}sched_util_clamp_min" "1024"
		write "${kernel}sched_util_clamp_max" "1024"
		write "${cpuctl}top-app/cpu.uclamp.max" "max"
		write "${cpuctl}top-app/cpu.uclamp.min" "max"
		write "${cpuctl}top-app/cpu.uclamp.boosted" "1"
		write "${cpuctl}top-app/cpu.uclamp.latency_sensitive" "1"
		write "${cpuctl}foreground/cpu.uclamp.max" "max"
		write "${cpuctl}foreground/cpu.uclamp.min" "max"
		write "${cpuctl}foreground/cpu.uclamp.boosted" "1"
		write "${cpuctl}foreground/cpu.uclamp.latency_sensitive" "1"
		write "${cpuctl}background/cpu.uclamp.max" "50"
		write "${cpuctl}background/cpu.uclamp.min" "0"
		write "${cpuctl}background/cpu.uclamp.boosted" "0"
		write "${cpuctl}background/cpu.uclamp.latency_sensitive" "0"
		write "${cpuctl}system-background/cpu.uclamp.max" "40"
		write "${cpuctl}system-background/cpu.uclamp.min" "0"
		write "${cpuctl}system-background/cpu.uclamp.boosted" "0"
		write "${cpuctl}system-background/cpu.uclamp.latency_sensitive" "0"
		kmsg "Tweaked Uclamp parameters"
		kmsg3 ""
	}
}

uclamp_battery() {
	[[ -e "${cpuctl}top-app/cpu.uclamp.max" ]] && {
		write "${kernel}sched_util_clamp_min" "256"
		write "${kernel}sched_util_clamp_max" "768"
		write "${cpuctl}top-app/cpu.uclamp.max" "max"
		write "${cpuctl}top-app/cpu.uclamp.min" "5"
		write "${cpuctl}top-app/cpu.uclamp.boosted" "1"
		write "${cpuctl}top-app/cpu.uclamp.latency_sensitive" "1"
		write "${cpuctl}foreground/cpu.uclamp.max" "max"
		write "${cpuctl}foreground/cpu.uclamp.min" "0"
		write "${cpuctl}foreground/cpu.uclamp.boosted" "0"
		write "${cpuctl}foreground/cpu.uclamp.latency_sensitive" "0"
		write "${cpuctl}background/cpu.uclamp.max" "50"
		write "${cpuctl}background/cpu.uclamp.min" "0"
		write "${cpuctl}background/cpu.uclamp.boosted" "0"
		write "${cpuctl}background/cpu.uclamp.latency_sensitive" "0"
		write "${cpuctl}system-background/cpu.uclamp.max" "40"
		write "${cpuctl}system-background/cpu.uclamp.min" "0"
		write "${cpuctl}system-background/cpu.uclamp.boosted" "0"
		write "${cpuctl}system-background/cpu.uclamp.latency_sensitive" "0"
		kmsg "Tweaked Uclamp parameters"
		kmsg3 ""
	}
}

uclamp_gaming() {
	[[ -e "${cpuctl}top-app/cpu.uclamp.max" ]] && {
		write "${kernel}sched_util_clamp_min" "1024"
		write "${kernel}sched_util_clamp_max" "1024"
		write "${cpuctl}top-app/cpu.uclamp.max" "max"
		write "${cpuctl}top-app/cpu.uclamp.min" "max"
		write "${cpuctl}top-app/cpu.uclamp.boosted" "1"
		write "${cpuctl}top-app/cpu.uclamp.latency_sensitive" "1"
		write "${cpuctl}foreground/cpu.uclamp.max" "max"
		write "${cpuctl}foreground/cpu.uclamp.min" "max"
		write "${cpuctl}foreground/cpu.uclamp.boosted" "1"
		write "${cpuctl}foreground/cpu.uclamp.latency_sensitive" "1"
		write "${cpuctl}background/cpu.uclamp.max" "50"
		write "${cpuctl}background/cpu.uclamp.min" "0"
		write "${cpuctl}background/cpu.uclamp.boosted" "0"
		write "${cpuctl}background/cpu.uclamp.latency_sensitive" "0"
		write "${cpuctl}system-background/cpu.uclamp.max" "40"
		write "${cpuctl}system-background/cpu.uclamp.min" "0"
		write "${cpuctl}system-background/cpu.uclamp.boosted" "0"
		write "${cpuctl}system-background/cpu.uclamp.latency_sensitive" "0"
		kmsg "Tweaked Uclamp parameters"
		kmsg3 ""
	}
}

config_fs() {
	# Raise inotify limit, disable the notification of files / directories changes
	[[ -d "$fs" ]] && {
		write "${fs}dir-notify-enable" "0"
		write "${fs}lease-break-time" "15"
		write "${fs}leases-enable" "1"
		write "${fs}file-max" "2097152"
		write "${fs}inotify/max_queued_events" "131072"
		write "${fs}inotify/max_user_watches" "131072"
		write "${fs}inotify/max_user_instances" "1024"
		kmsg "Tweaked FS"
		kmsg3 ""
	}
}

config_dyn_fsync() {
	[[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]] && {
		write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
		kmsg "Enabled dynamic fsync"
		kmsg3 ""
	}
}

sched_ft_latency() {
	# Scheduler features
	[[ -e "/sys/kernel/debug/sched_features" ]] && {
		write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
		write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
		write "/sys/kernel/debug/sched_features" "ENERGY_AWARE"
		kmsg "Tweaked scheduler features"
		kmsg3 ""
	}
}

sched_ft_balanced() {
	[[ -e "/sys/kernel/debug/sched_features" ]] && {
		write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
		write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
		write "/sys/kernel/debug/sched_features" "ENERGY_AWARE"
		kmsg "Tweaked scheduler features"
		kmsg3 ""
	}
}

sched_ft_extreme() {
	[[ -e "/sys/kernel/debug/sched_features" ]] && {
		write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
		write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
		write "/sys/kernel/debug/sched_features" "NO_ENERGY_AWARE"
		kmsg "Tweaked scheduler features"
		kmsg3 ""
	}
}

sched_ft_battery() {
	[[ -e "/sys/kernel/debug/sched_features" ]] && {
		write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
		write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
		write "/sys/kernel/debug/sched_features" "ENERGY_AWARE"
		kmsg "Tweaked scheduler features"
		kmsg3 ""
	}
}

sched_ft_gaming() {
	[[ -e "/sys/kernel/debug/sched_features" ]] && {
		write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
		write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
		write "/sys/kernel/debug/sched_features" "NO_ENERGY_AWARE"
		kmsg "Tweaked scheduler features"
		kmsg3 ""
	}
}

disable_crc() {
	[[ -e "/sys/module/mmc_core/parameters/use_spi_crc" ]] && {
		write "/sys/module/mmc_core/parameters/use_spi_crc" "N"
		kmsg "Disabled MMC CRC"
		kmsg3 ""
	} || [[ -e "/sys/module/mmc_core/parameters/removable" ]] && {
		write "/sys/module/mmc_core/parameters/removable" "N"
		kmsg "Disabled MMC CRC"
		kmsg3 ""
	} || [[ -e "/sys/module/mmc_core/parameters/crc" ]] && {
		write "/sys/module/mmc_core/parameters/crc" "N"
		kmsg "Disabled MMC CRC"
		kmsg3 ""
	}
}

sched_latency() {
	# Tweak kernel settings to improve overall performance
	[[ -e "${kernel}sched_child_runs_first" ]] && write "${kernel}sched_child_runs_first" "1"
	[[ -e "${kernel}perf_cpu_time_max_percent" ]] && write "${kernel}perf_cpu_time_max_percent" "3"
	[[ -e "${kernel}sched_autogroup_enabled" ]] && write "${kernel}sched_autogroup_enabled" "0"
	write "${kernel}sched_tunable_scaling" "0"
	[[ -e "${kernel}sched_latency_ns" ]] && write "${kernel}sched_latency_ns" "$sched_period_latency"
	[[ -e "${kernel}sched_min_granularity_ns" ]] && write "${kernel}sched_min_granularity_ns" "$((sched_period_latency / sched_tasks_latency))"
	[[ -e "${kernel}sched_wakeup_granularity_ns" ]] && write "${kernel}sched_wakeup_granularity_ns" "$((sched_period_latency / sched_tasks_latency))"
	[[ -e "${kernel}sched_migration_cost_ns" ]] && write "${kernel}sched_migration_cost_ns" "2000000"
	[[ -e "/proc/perfmgr/boost_ctrl/eas_ctrl/m_sched_migrate_cost_n" ]] && write "/proc/perfmgr/boost_ctrl/eas_ctrl/m_sched_migrate_cost_n" "2000000"
	[[ -e "${kernel}sched_min_task_util_for_colocation" ]] && write "${kernel}sched_min_task_util_for_colocation" "0"
	[[ -e "${kernel}sched_min_task_util_for_boost" ]] && write "${kernel}sched_min_task_util_for_boost" "0"
	write "${kernel}sched_nr_migrate" "8"
	[[ -e "${kernel}sched_schedstats" ]] && write "${kernel}sched_schedstats" "0"
	[[ -e "${kernel}sched_cstate_aware" ]] && write "${kernel}sched_cstate_aware" "1"
	write "${kernel}printk_devkmsg" "off"
	[[ -e "${kernel}timer_migration" ]] && write "${kernel}timer_migration" "0"
	[[ -e "${kernel}sched_boost" ]] && write "${kernel}sched_boost" "0"
	[[ -e "/sys/devices/system/cpu/eas/enable" ]] && write "/sys/devices/system/cpu/eas/enable" "1"
	[[ -e "${kernel}sched_walt_rotate_big_tasks" ]] && write "${kernel}sched_walt_rotate_big_tasks" "1"
	[[ -e "${kernel}sched_prefer_sync_wakee_to_waker" ]] && write "${kernel}sched_prefer_sync_wakee_to_waker" "1"
	[[ -e "${kernel}sched_boost_top_app" ]] && write "${kernel}sched_boost_top_app" "1"
	[[ -e "${kernel}sched_init_task_load" ]] && write "${kernel}sched_init_task_load" "25"
	[[ -e "${kernel}sched_migration_fixup" ]] && write "${kernel}sched_migration_fixup" "0"
	[[ -e "${kernel}sched_energy_aware" ]] && write "${kernel}sched_energy_aware" "1"
	[[ -e "${kernel}hung_task_timeout_secs" ]] && write "${kernel}hung_task_timeout_secs" "0"
	# We do not need it on android, and also is disabled by default on redhat for security purposes
	[[ -e "${kernel}sysrq" ]] && write "${kernel}sysrq" "0"
	# Set memory sleep mode to s2idle
	[[ -e "/sys/power/mem_sleep" ]] && write "/sys/power/mem_sleep" "s2idle"
	[[ -e "${kernel}sched_conservative_pl" ]] && write "${kernel}sched_conservative_pl" "0"
	[[ -e "/sys/devices/system/cpu/sched/sched_boost" ]] && write "/sys/devices/system/cpu/sched/sched_boost" "0"
	[[ -e "/sys/kernel/ems/eff_mode" ]] && write "/sys/kernel/ems/eff_mode" "0"
	[[ -e "/sys/module/opchain/parameters/chain_on" ]] && write "/sys/module/opchain/parameters/chain_on" "0"
	[[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]] && write "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
	[[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]] && write "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
	[[ -e "${kernel}sched_initial_task_util" ]] && write "${kernel}sched_initial_task_util" "0"
	# Disable ram-boost relying memplus prefetcher, use traditional swapping
	[[ -d "/sys/module/memplus_core/" ]] && write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
	# Disable kernel debug by default
	write "/sys/kernel/debug/debug_enabled" "0"
	# Use normal grace periods to reduce power usage
	write "/sys/kernel/rcu_expedited" "0"
	write "/sys/kernel/rcu_normal" "1"
	# Tweak VIDC DDR
	write "/sys/kernel/debug/msm_vidc/disable_thermal_mitigation" "0"
	write "/sys/kernel/debug/msm_vidc/fw_low_power_mode" "0"
	write "/sys/devices/system/cpu/sched/hint_enable" "0"
	write "${kernel}slide_boost_enabled" "0"
	write "${kernel}launcher_boost_enabled" "0"
	write "/sys/kernel/tracing/events/sched/sched_boost_cpu" "0"
	for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
		[[ -e "$bcl_md" ]] && write "$bcl_md" "0"
	done
	write "/proc/sys/dev/tty/ldisc_autoload" "0"
	kmsg "Tweaked various kernel parameters"
	kmsg3 ""
}

sched_balanced() {
	[[ -e "${kernel}sched_child_runs_first" ]] && write "${kernel}sched_child_runs_first" "1"
	[[ -e "${kernel}perf_cpu_time_max_percent" ]] && write "${kernel}perf_cpu_time_max_percent" "5"
	[[ -e "${kernel}sched_autogroup_enabled" ]] && write "${kernel}sched_autogroup_enabled" "0"
	write "${kernel}sched_tunable_scaling" "0"
	[[ -e "${kernel}sched_latency_ns" ]] && write "${kernel}sched_latency_ns" "$sched_period_balance"
	[[ -e "${kernel}sched_min_granularity_ns" ]] && write "${kernel}sched_min_granularity_ns" "$((sched_period_balance / sched_tasks_balance))"
	[[ -e "${kernel}sched_wakeup_granularity_ns" ]] && write "${kernel}sched_wakeup_granularity_ns" "$((sched_period_balance / 2))"
	[[ -e "${kernel}sched_migration_cost_ns" ]] && write "${kernel}sched_migration_cost_ns" "2500000"
	[[ -e "/proc/perfmgr/boost_ctrl/eas_ctrl/m_sched_migrate_cost_n" ]] && write "/proc/perfmgr/boost_ctrl/eas_ctrl/m_sched_migrate_cost_n" "2500000"
	[[ -e "${kernel}sched_min_task_util_for_colocation" ]] && write "${kernel}sched_min_task_util_for_colocation" "0"
	[[ -e "${kernel}sched_min_task_util_for_boost" ]] && write "${kernel}sched_min_task_util_for_boost" "0"
	write "${kernel}sched_nr_migrate" "32"
	[[ -e "${kernel}sched_schedstats" ]] && write "${kernel}sched_schedstats" "0"
	[[ -e "${kernel}sched_cstate_aware" ]] && write "${kernel}sched_cstate_aware" "1"
	write "${kernel}printk_devkmsg" "off"
	[[ -e "${kernel}timer_migration" ]] && write "${kernel}timer_migration" "0"
	[[ -e "${kernel}sched_boost" ]] && write "${kernel}sched_boost" "0"
	[[ -e "/sys/devices/system/cpu/eas/enable" ]] && write "/sys/devices/system/cpu/eas/enable" "1"
	[[ -e "${kernel}sched_walt_rotate_big_tasks" ]] && write "${kernel}sched_walt_rotate_big_tasks" "1"
	[[ -e "${kernel}sched_prefer_sync_wakee_to_waker" ]] && write "${kernel}sched_prefer_sync_wakee_to_waker" "1"
	[[ -e "${kernel}sched_boost_top_app" ]] && write "${kernel}sched_boost_top_app" "1"
	[[ -e "${kernel}sched_init_task_load" ]] && write "${kernel}sched_init_task_load" "20"
	[[ -e "${kernel}sched_migration_fixup" ]] && write "${kernel}sched_migration_fixup" "0"
	[[ -e "${kernel}sched_energy_aware" ]] && write "${kernel}sched_energy_aware" "1"
	[[ -e "${kernel}hung_task_timeout_secs" ]] && write "${kernel}hung_task_timeout_secs" "0"
	[[ -e "${kernel}sysrq" ]] && write "${kernel}sysrq" "0"
	[[ -e "/sys/power/mem_sleep" ]] && write "/sys/power/mem_sleep" "s2idle"
	[[ -e "${kernel}sched_conservative_pl" ]] && write "${kernel}sched_conservative_pl" "0"
	[[ -e "/sys/devices/system/cpu/sched/sched_boost" ]] && write "/sys/devices/system/cpu/sched/sched_boost" "0"
	[[ -e "/sys/kernel/ems/eff_mode" ]] && write "/sys/kernel/ems/eff_mode" "0"
	[[ -e "/sys/module/opchain/parameters/chain_on" ]] && write "/sys/module/opchain/parameters/chain_on" "0"
	[[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]] && write "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
	[[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]] && write "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
	[[ -e "${kernel}sched_initial_task_util" ]] && write "${kernel}sched_initial_task_util" "0"
	[[ -d "/sys/module/memplus_core/" ]] && write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
	write "/sys/kernel/debug/debug_enabled" "0"
	write "/sys/kernel/rcu_expedited" "0"
	write "/sys/kernel/rcu_normal" "1"
	write "/sys/kernel/debug/msm_vidc/disable_thermal_mitigation" "0"
	write "/sys/kernel/debug/msm_vidc/fw_low_power_mode" "1"
	write "/sys/devices/system/cpu/sched/hint_enable" "0"
	write "${kernel}slide_boost_enabled" "0"
	write "${kernel}launcher_boost_enabled" "0"
	write "/sys/kernel/tracing/events/sched/sched_boost_cpu" "0"
	for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
		[[ -e "$bcl_md" ]] && write "$bcl_md" "0"
	done
	write "/proc/sys/dev/tty/ldisc_autoload" "0"
	kmsg "Tweaked various kernel parameters"
	kmsg3 ""
}

sched_extreme() {
	[[ -e "${kernel}sched_child_runs_first" ]] && write "${kernel}sched_child_runs_first" "0"
	[[ -e "${kernel}perf_cpu_time_max_percent" ]] && write "${kernel}perf_cpu_time_max_percent" "20"
	[[ -e "${kernel}sched_autogroup_enabled" ]] && write "${kernel}sched_autogroup_enabled" "0"
	write "${kernel}sched_tunable_scaling" "0"
	[[ -e "${kernel}sched_latency_ns" ]] && write "${kernel}sched_latency_ns" "$sched_period_throughput"
	[[ -e "${kernel}sched_min_granularity_ns" ]] && write "${kernel}sched_min_granularity_ns" "$((sched_period_throughput / sched_tasks_throughput))"
	[[ -e "${kernel}sched_wakeup_granularity_ns" ]] && write "${kernel}sched_wakeup_granularity_ns" "$((sched_period_throughput / 2))"
	[[ -e "${kernel}sched_migration_cost_ns" ]] && write "${kernel}sched_migration_cost_ns" "0"
	[[ -e "/proc/perfmgr/boost_ctrl/eas_ctrl/m_sched_migrate_cost_n" ]] && write "/proc/perfmgr/boost_ctrl/eas_ctrl/m_sched_migrate_cost_n" "0"
	[[ -e "${kernel}sched_min_task_util_for_colocation" ]] && write "${kernel}sched_min_task_util_for_colocation" "0"
	[[ -e "${kernel}sched_min_task_util_for_boost" ]] && write "${kernel}sched_min_task_util_for_boost" "0"
	write "${kernel}sched_nr_migrate" "128"
	write "${kernel}sched_schedstats" "0"
	[[ -e "${kernel}sched_cstate_aware" ]] && write "${kernel}sched_cstate_aware" "1"
	write "${kernel}printk_devkmsg" "off"
	[[ -e "${kernel}timer_migration" ]] && write "${kernel}timer_migration" "0"
	[[ -e "${kernel}sched_boost" ]] && write "${kernel}sched_boost" "0"
	[[ -e "/sys/devices/system/cpu/eas/enable" ]] && write "/sys/devices/system/cpu/eas/enable" "0"
	[[ -e "${kernel}sched_walt_rotate_big_tasks" ]] && write "${kernel}sched_walt_rotate_big_tasks" "1"
	[[ -e "${kernel}sched_prefer_sync_wakee_to_waker" ]] && write "${kernel}sched_prefer_sync_wakee_to_waker" "1"
	[[ -e "${kernel}sched_boost_top_app" ]] && write "${kernel}sched_boost_top_app" "1"
	[[ -e "${kernel}sched_init_task_load" ]] && write "${kernel}sched_init_task_load" "30"
	[[ -e "${kernel}sched_migration_fixup" ]] && write "${kernel}sched_migration_fixup" "0"
	[[ -e "${kernel}sched_energy_aware" ]] && write "${kernel}sched_energy_aware" "0"
	[[ -e "${kernel}hung_task_timeout_secs" ]] && write "${kernel}hung_task_timeout_secs" "0"
	[[ -e "${kernel}sysrq" ]] && write "${kernel}sysrq" "0"
	[[ -e "/sys/power/mem_sleep" ]] && write "/sys/power/mem_sleep" "s2idle"
	[[ -e "${kernel}sched_conservative_pl" ]] && write "${kernel}sched_conservative_pl" "0"
	[[ -e "/sys/devices/system/cpu/sched/sched_boost" ]] && write "/sys/devices/system/cpu/sched/sched_boost" "0"
	[[ -e "/sys/kernel/ems/eff_mode" ]] && write "/sys/kernel/ems/eff_mode" "0"
	[[ -e "/sys/module/opchain/parameters/chain_on" ]] && write "/sys/module/opchain/parameters/chain_on" "0"
	[[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]] && write "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
	[[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]] && write "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
	[[ -e "${kernel}sched_initial_task_util" ]] && write "${kernel}sched_initial_task_util" "0"
	[[ -d "/sys/module/memplus_core/" ]] && write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
	write "/sys/kernel/debug/debug_enabled" "0"
	write "/sys/kernel/rcu_expedited" "0"
	write "/sys/kernel/rcu_normal" "1"
	write "/sys/kernel/debug/msm_vidc/disable_thermal_mitigation" "1"
	write "/sys/kernel/debug/msm_vidc/fw_low_power_mode" "0"
	write "/sys/devices/system/cpu/sched/hint_enable" "0"
	write "${kernel}slide_boost_enabled" "0"
	write "${kernel}launcher_boost_enabled" "0"
	write "/sys/kernel/tracing/events/sched/sched_boost_cpu" "0"
	for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
		[[ -e "$bcl_md" ]] && write "$bcl_md" "0"
	done
	write "/proc/sys/dev/tty/ldisc_autoload" "0"
	kmsg "Tweaked various kernel parameters"
	kmsg3 ""
}

sched_battery() {
	[[ -e "${kernel}sched_child_runs_first" ]] && write "${kernel}sched_child_runs_first" "0"
	[[ -e "${kernel}perf_cpu_time_max_percent" ]] && write "${kernel}perf_cpu_time_max_percent" "2"
	[[ -e "${kernel}sched_autogroup_enabled" ]] && write "${kernel}sched_autogroup_enabled" "0"
	write "${kernel}sched_tunable_scaling" "0"
	[[ -e "${kernel}sched_latency_ns" ]] && write "${kernel}sched_latency_ns" "$sched_period_battery"
	[[ -e "${kernel}sched_min_granularity_ns" ]] && write "${kernel}sched_min_granularity_ns" "$((sched_period_battery / sched_tasks_battery))"
	[[ -e "${kernel}sched_wakeup_granularity_ns" ]] && write "${kernel}sched_wakeup_granularity_ns" "$((sched_period_battery / 2))"
	[[ -e "${kernel}sched_migration_cost_ns" ]] && write "${kernel}sched_migration_cost_ns" "3000000"
	[[ -e "/proc/perfmgr/boost_ctrl/eas_ctrl/m_sched_migrate_cost_n" ]] && write "/proc/perfmgr/boost_ctrl/eas_ctrl/m_sched_migrate_cost_n" "3000000"
	[[ -e "${kernel}sched_min_task_util_for_colocation" ]] && write "${kernel}sched_min_task_util_for_colocation" "0"
	[[ -e "${kernel}sched_min_task_util_for_boost" ]] && write "${kernel}sched_min_task_util_for_boost" "0"
	write "${kernel}sched_nr_migrate" "256"
	write "${kernel}sched_schedstats" "0"
	[[ -e "${kernel}sched_cstate_aware" ]] && write "${kernel}sched_cstate_aware" "1"
	write "${kernel}printk_devkmsg" "off"
	[[ -e "${kernel}timer_migration" ]] && write "${kernel}timer_migration" "0"
	[[ -e "${kernel}sched_boost" ]] && write "${kernel}sched_boost" "0"
	[[ -e "/sys/devices/system/cpu/eas/enable" ]] && write "/sys/devices/system/cpu/eas/enable" "1"
	[[ -e "${kernel}sched_walt_rotate_big_tasks" ]] && write "${kernel}sched_walt_rotate_big_tasks" "1"
	[[ -e "${kernel}sched_prefer_sync_wakee_to_waker" ]] && write "${kernel}sched_prefer_sync_wakee_to_waker" "1"
	[[ -e "${kernel}sched_boost_top_app" ]] && write "${kernel}sched_boost_top_app" "0"
	[[ -e "${kernel}sched_init_task_load" ]] && write "${kernel}sched_init_task_load" "15"
	[[ -e "${kernel}sched_migration_fixup" ]] && write "${kernel}sched_migration_fixup" "0"
	[[ -e "${kernel}sched_energy_aware" ]] && write "${kernel}sched_energy_aware" "1"
	[[ -e "${kernel}hung_task_timeout_secs" ]] && write "${kernel}hung_task_timeout_secs" "0"
	[[ -e "${kernel}sysrq" ]] && write "${kernel}sysrq" "0"
	[[ -e "/sys/power/mem_sleep" ]] && write "/sys/power/mem_sleep" "s2idle"
	[[ -e "${kernel}sched_conservative_pl" ]] && write "${kernel}sched_conservative_pl" "1"
	[[ -e "/sys/devices/system/cpu/sched/sched_boost" ]] && write "/sys/devices/system/cpu/sched/sched_boost" "0"
	[[ -e "/sys/kernel/ems/eff_mode" ]] && write "/sys/kernel/ems/eff_mode" "0"
	[[ -e "/sys/module/opchain/parameters/chain_on" ]] && write "/sys/module/opchain/parameters/chain_on" "0"
	[[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]] && write "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
	[[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]] && write "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
	[[ -e "${kernel}sched_initial_task_util" ]] && write "${kernel}sched_initial_task_util" "0"
	[[ -d "/sys/module/memplus_core/" ]] && write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
	write "/sys/kernel/debug/debug_enabled" "0"
	write "/sys/kernel/rcu_expedited" "0"
	write "/sys/kernel/rcu_normal" "1"
	write "/sys/kernel/debug/msm_vidc/disable_thermal_mitigation" "0"
	write "/sys/kernel/debug/msm_vidc/fw_low_power_mode" "1"
	write "/sys/devices/system/cpu/sched/hint_enable" "0"
	write "${kernel}slide_boost_enabled" "0"
	write "${kernel}launcher_boost_enabled" "0"
	write "/sys/kernel/tracing/events/sched/sched_boost_cpu" "0"
	for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
		[[ -e "$bcl_md" ]] && write "$bcl_md" "0"
	done
	write "/proc/sys/dev/tty/ldisc_autoload" "0"
	kmsg "Tweaked various kernel parameters"
	kmsg3 ""
}

sched_gaming() {
	[[ -e "${kernel}sched_child_runs_first" ]] && write "${kernel}sched_child_runs_first" "0"
	[[ -e "${kernel}perf_cpu_time_max_percent" ]] && write "${kernel}perf_cpu_time_max_percent" "20"
	[[ -e "${kernel}sched_autogroup_enabled" ]] && write "${kernel}sched_autogroup_enabled" "0"
	write "${kernel}sched_tunable_scaling" "0"
	[[ -e "${kernel}sched_latency_ns" ]] && write "${kernel}sched_latency_ns" "$sched_period_throughput"
	[[ -e "${kernel}sched_min_granularity_ns" ]] && write "${kernel}sched_min_granularity_ns" "$((sched_period_throughput / sched_tasks_throughput))"
	[[ -e "${kernel}sched_wakeup_granularity_ns" ]] && write "${kernel}sched_wakeup_granularity_ns" "$((sched_period_throughput / 2))"
	[[ -e "${kernel}sched_migration_cost_ns" ]] && write "${kernel}sched_migration_cost_ns" "0"
	[[ -e "/proc/perfmgr/boost_ctrl/eas_ctrl/m_sched_migrate_cost_n" ]] && write "/proc/perfmgr/boost_ctrl/eas_ctrl/m_sched_migrate_cost_n" "0"
	[[ -e "${kernel}sched_min_task_util_for_colocation" ]] && write "${kernel}sched_min_task_util_for_colocation" "0"
	[[ -e "${kernel}sched_min_task_util_for_boost" ]] && write "${kernel}sched_min_task_util_for_boost" "0"
	write "${kernel}sched_nr_migrate" "128"
	write "${kernel}sched_schedstats" "0"
	[[ -e "${kernel}sched_cstate_aware" ]] && write "${kernel}sched_cstate_aware" "1"
	write "${kernel}printk_devkmsg" "off"
	[[ -e "${kernel}timer_migration" ]] && write "${kernel}timer_migration" "0"
	[[ -e "${kernel}sched_boost" ]] && write "${kernel}sched_boost" "0"
	[[ -e "/sys/devices/system/cpu/eas/enable" ]] && write "/sys/devices/system/cpu/eas/enable" "0"
	[[ -e "${kernel}sched_walt_rotate_big_tasks" ]] && write "${kernel}sched_walt_rotate_big_tasks" "1"
	[[ -e "${kernel}sched_prefer_sync_wakee_to_waker" ]] && write "${kernel}sched_prefer_sync_wakee_to_waker" "1"
	[[ -e "${kernel}sched_boost_top_app" ]] && write "${kernel}sched_boost_top_app" "1"
	[[ -e "${kernel}sched_init_task_load" ]] && write "${kernel}sched_init_task_load" "30"
	[[ -e "${kernel}sched_migration_fixup" ]] && write "${kernel}sched_migration_fixup" "0"
	[[ -e "${kernel}sched_energy_aware" ]] && write "${kernel}sched_energy_aware" "0"
	[[ -e "${kernel}hung_task_timeout_secs" ]] && write "${kernel}hung_task_timeout_secs" "0"
	[[ -e "${kernel}sysrq" ]] && write "${kernel}sysrq" "0"
	[[ -e "/sys/power/mem_sleep" ]] && write "/sys/power/mem_sleep" "s2idle"
	[[ -e "${kernel}sched_conservative_pl" ]] && write "${kernel}sched_conservative_pl" "0"
	[[ -e "/sys/devices/system/cpu/sched/sched_boost" ]] && write "/sys/devices/system/cpu/sched/sched_boost" "0"
	[[ -e "/sys/kernel/ems/eff_mode" ]] && write "/sys/kernel/ems/eff_mode" "0"
	[[ -e "/sys/module/opchain/parameters/chain_on" ]] && write "/sys/module/opchain/parameters/chain_on" "0"
	[[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]] && write "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
	[[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]] && write "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
	[[ -e "${kernel}sched_initial_task_util" ]] && write "${kernel}sched_initial_task_util" "0"
	[[ -d "/sys/module/memplus_core/" ]] && write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
	write "/sys/kernel/debug/debug_enabled" "0"
	write "/sys/kernel/rcu_expedited" "0"
	write "/sys/kernel/rcu_normal" "1"
	write "/sys/kernel/debug/msm_vidc/disable_thermal_mitigation" "1"
	write "/sys/kernel/debug/msm_vidc/fw_low_power_mode" "0"
	write "/sys/devices/system/cpu/sched/hint_enable" "0"
	write "${kernel}slide_boost_enabled" "0"
	write "${kernel}launcher_boost_enabled" "0"
	write "/sys/kernel/tracing/events/sched/sched_boost_cpu" "0"
	for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
		[[ -e "$bcl_md" ]] && write "$bcl_md" "0"
	done
	write "/proc/sys/dev/tty/ldisc_autoload" "0"
	kmsg "Tweaked various kernel parameters"
	kmsg3 ""
}

enable_kvb() {
	[[ -e "/sys/module/acpuclock_krait/parameters/boost" ]] && {
		write "/sys/module/acpuclock_krait/parameters/boost" "Y"
		kmsg "Enabled krait voltage boost"
		kmsg3 ""
	}
}

disable_kvb() {
	[[ -e "/sys/module/acpuclock_krait/parameters/boost" ]] && {
		write "/sys/module/acpuclock_krait/parameters/boost" "N"
		kmsg "Disabled krait voltage boost"
		kmsg3 ""
	}
}

enable_fp_boost() {
	[[ -e "/sys/kernel/fp_boost/enabled" ]] && {
		write "/sys/kernel/fp_boost/enabled" "1"
		kmsg "Enabled fingerprint boost"
		kmsg3 ""
	}
}

disable_fp_boost() {
	[[ -e "/sys/kernel/fp_boost/enabled" ]] && {
		write "/sys/kernel/fp_boost/enabled" "0"
		kmsg "Disabled fingerprint boost"
		kmsg3 ""
	}
}

ppm_policy_default() {
	[[ "$ppm" == "true" ]] && {
		write "/proc/ppm/policy_status" "1 0"
		write "/proc/ppm/policy_status" "2 0"
		write "/proc/ppm/policy_status" "3 0"
		write "/proc/ppm/policy_status" "4 1"
		write "/proc/ppm/policy_status" "5 0"
		write "/proc/ppm/policy_status" "7 1"
		write "/proc/ppm/policy_status" "9 0"
		kmsg "Tweaked PPM Policies"
		kmsg3 ""
		write "/proc/ppm/policy/hard_userlimit_min_cpu_freq" "0 $cpu_min_freq"
		write "/proc/ppm/policy/hard_userlimit_min_cpu_freq" "1 $cpu_min_freq"
		write "/proc/ppm/policy/hard_userlimit_max_cpu_freq" "0 $cpu_max_freq"
		write "/proc/ppm/policy/hard_userlimit_max_cpu_freq" "1 $cpu_max_freq"
		kmsg "Tweaked PPM CPU clocks"
		kmsg3 ""
	}
}

ppm_policy_max() {
	[[ "$ppm" == "true" ]] && {
		write "/proc/ppm/policy_status" "1 0"
		write "/proc/ppm/policy_status" "2 1"
		write "/proc/ppm/policy_status" "3 0"
		write "/proc/ppm/policy_status" "4 0"
		write "/proc/ppm/policy_status" "5 0"
		write "/proc/ppm/policy_status" "7 1"
		write "/proc/ppm/policy_status" "9 1"
		kmsg "Tweaked PPM Policies"
		kmsg3 ""
		write "/proc/ppm/policy/hard_userlimit_min_cpu_freq" "0 $cpu_max_freq"
		write "/proc/ppm/policy/hard_userlimit_min_cpu_freq" "1 $cpu_max_freq"
		write "/proc/ppm/policy/hard_userlimit_max_cpu_freq" "0 $cpu_max_freq"
		write "/proc/ppm/policy/hard_userlimit_max_cpu_freq" "1 $cpu_max_freq"
		kmsg "Tweaked PPM CPU clocks"
		kmsg3 ""
	}
}

cpu_clk_min() {
	# Set min I'mefficient CPUs frequency
	for pl in /sys/devices/system/cpu/cpufreq/policy*/; do
		for i in 576000 652800 691200 748800 768000 787200 806400 825600 844800 852600 864000 902400 940800 960000 979200 998400 1036800 1075200 1113600 1152000 1209600 1459200 1478400 1516800 1689600 1708800 1766400; do
			[[ "$(grep $i ${pl}scaling_available_frequencies)" ]] && write "${pl}scaling_min_freq" "$i"
		done
	done
}

cpu_clk_default() {
	# Set default CPUs frequency
	for cpus in /sys/devices/system/cpu/cpufreq/policy*/; do
		[[ -e "${cpus}scaling_max_freq" ]] && {
			write "${cpus}scaling_max_freq" "$cpu_max_freq"
			write "${cpus}user_scaling_max_freq" "$cpu_max_freq"
		}
	done

	for cpus in /sys/devices/system/cpu/cpu*/cpufreq/; do
		[[ -e "${cpus}scaling_max_freq" ]] && {
			write "${cpus}scaling_max_freq" "$cpu_max_freq"
			write "${cpus}user_scaling_max_freq" "$cpu_max_freq"
		}
	done
	kmsg "Tweaked CPU clocks"
	kmsg3 ""

	[[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]] && {
		write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "1"
		kmsg "Allow CPUs to use it's deepest sleep state"
		kmsg3 ""
	}
}

cpu_clk_max() {
	# Set max CPUs frequency
	for cpus in /sys/devices/system/cpu/cpufreq/policy*/; do
		[[ -e "${cpus}scaling_min_freq" ]] && {
			write "${cpus}scaling_min_freq" "$cpu_max_freq"
			write "${cpus}scaling_max_freq" "$cpu_max_freq"
			write "${cpus}user_scaling_min_freq" "$cpu_max_freq"
			write "${cpus}user_scaling_max_freq" "$cpu_max_freq"
		}
	done

	for cpus in /sys/devices/system/cpu/cpu*/cpufreq/; do
		[[ -e "${cpus}scaling_min_freq" ]] && {
			write "${cpus}scaling_min_freq" "$cpu_max_freq"
			write "${cpus}scaling_max_freq" "$cpu_max_freq"
			write "${cpus}user_scaling_min_freq" "$cpu_max_freq"
			write "${cpus}user_scaling_max_freq" "$cpu_max_freq"
		}
	done
	kmsg "Tweaked CPU clocks"
	kmsg3 ""

	[[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]] && {
		write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "0"
		kmsg "Don't allow CPUs to use it's deepest sleep state"
		kmsg3 ""
	}
}

vm_lmk_latency() {
	# Always sync before dropping caches
	sync
	# VM settings to improve overall user experience and performance
	write "${vm}drop_caches" "3"
	write "${vm}dirty_background_ratio" "15"
	write "${vm}dirty_ratio" "40"
	write "${vm}dirty_expire_centisecs" "4000"
	write "${vm}dirty_writeback_centisecs" "4000"
	write "${vm}page-cluster" "0"
	write "${vm}stat_interval" "120"
	write "${vm}overcommit_ratio" "100"
	# Use more zRAM / swap by default if possible
	[[ "$total_ram" -le "6144" ]] && write "${vm}swappiness" "160"
	[[ "$total_ram" -ge "8192" ]] && write "${vm}swappiness" "120"
	[[ "$total_ram" -gt "8192" ]] && write "${vm}rswappiness" "90"
	[[ "$(cat ${vm}swappiness)" -ne "160" ]] || [[ "$(cat ${vm}swappiness)" -ne "120" ]] || [[ "$(cat ${vm}swappiness)" -ne "90" ]] && write "${vm}swappiness" "100"
	write "${vm}laptop_mode" "0"
	write "${vm}vfs_cache_pressure" "200"
	[[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	[[ ! "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "1" || [[ "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "0"
	[[ -e "${vm}swap_ratio" ]] && write "${vm}swap_ratio" "100"
	[[ -e "${vm}oom_dump_tasks" ]] && write "${vm}oom_dump_tasks" "0"
	[[ -e "${lmk}minfree" ]] && write "${lmk}minfree" "$minfree"
	[[ -e "${lmk}oom_reaper" ]] && write "${lmk}oom_reaper" "1"
	[[ -e "${lmk}lmk_fast_run" ]] && write "${lmk}lmk_fast_run" "0"
	[[ -e "${lmk}enable_adaptive_lmk" ]] && write "${lmk}enable_adaptive_lmk" "0"
	[[ -e "${vm}extra_free_kbytes" ]] && write "${vm}extra_free_kbytes" "$efk"
	[[ -e "${lmk}cost" ]] && write "${lmk}cost" "4096"
	[[ -e "${vm}watermark_scale_factor" ]] && write "${vm}watermark_scale_factor" "100"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -le "4096" ]] && write "${zram}wb_start_mins" "180"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "6144" ]] && write "${zram}wb_start_mins" "240"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "8192" ]] && write "${zram}wb_start_mins" "360"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -gt "8192" ]] && write "${zram}wb_start_mins" "480"
	kmsg "Tweaked various VM / LMK parameters for a improved user-experience"
	kmsg3 ""
}

vm_lmk_balanced() {
	sync
	write "${vm}drop_caches" "2"
	write "${vm}dirty_background_ratio" "5"
	write "${vm}dirty_ratio" "30"
	write "${vm}dirty_expire_centisecs" "3000"
	write "${vm}dirty_writeback_centisecs" "3000"
	write "${vm}page-cluster" "0"
	write "${vm}stat_interval" "120"
	write "${vm}overcommit_ratio" "100"
	[[ "$total_ram" -le "6144" ]] && write "${vm}swappiness" "160"
	[[ "$total_ram" -ge "8192" ]] && write "${vm}swappiness" "120"
	[[ "$total_ram" -gt "8192" ]] && write "${vm}rswappiness" "90"
	[[ "$(cat ${vm}swappiness)" -ne "160" ]] || [[ "$(cat ${vm}swappiness)" -ne "120" ]] || [[ "$(cat ${vm}swappiness)" -ne "90" ]] && write "${vm}swappiness" "100"
	write "${vm}laptop_mode" "0"
	write "${vm}vfs_cache_pressure" "100"
	[[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	[[ ! "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "1" || [[ "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "0"
	[[ -e "${vm}swap_ratio" ]] && write "${vm}swap_ratio" "100"
	[[ -e "${vm}oom_dump_tasks" ]] && write "${vm}oom_dump_tasks" "0"
	[[ -e "${lmk}minfree" ]] && write "${lmk}minfree" "$minfree"
	[[ -e "${lmk}oom_reaper" ]] && write "${lmk}oom_reaper" "1"
	[[ -e "${lmk}lmk_fast_run" ]] && write "${lmk}lmk_fast_run" "0"
	[[ -e "${lmk}enable_adaptive_lmk" ]] && write "${lmk}enable_adaptive_lmk" "0"
	[[ -e "${vm}extra_free_kbytes" ]] && write "${vm}extra_free_kbytes" "$efk"
	[[ -e "${lmk}cost" ]] && write "${lmk}cost" "4096"
	[[ -e "${vm}watermark_scale_factor" ]] && write "${vm}watermark_scale_factor" "100"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -le "4096" ]] && write "${zram}wb_start_mins" "180"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "6144" ]] && write "${zram}wb_start_mins" "240"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "8192" ]] && write "${zram}wb_start_mins" "360"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -gt "8192" ]] && write "${zram}wb_start_mins" "480"
	kmsg "Tweaked various VM and LMK parameters for a improved user-experience"
	kmsg3 ""
}

vm_lmk_extreme() {
	sync
	write "${vm}drop_caches" "3"
	write "${vm}dirty_background_ratio" "10"
	write "${vm}dirty_ratio" "40"
	write "${vm}dirty_expire_centisecs" "5000"
	write "${vm}dirty_writeback_centisecs" "5000"
	write "${vm}page-cluster" "0"
	write "${vm}stat_interval" "120"
	write "${vm}overcommit_ratio" "100"
	[[ "$total_ram" -le "6144" ]] && write "${vm}swappiness" "160"
	[[ "$total_ram" -ge "8192" ]] && write "${vm}swappiness" "120"
	[[ "$total_ram" -gt "8192" ]] && write "${vm}rswappiness" "90"
	[[ "$(cat ${vm}swappiness)" -ne "160" ]] || [[ "$(cat ${vm}swappiness)" -ne "120" ]] || [[ "$(cat ${vm}swappiness)" -ne "90" ]] && write "${vm}swappiness" "100"
	write "${vm}laptop_mode" "0"
	write "${vm}vfs_cache_pressure" "200"
	[[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	[[ ! "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "1" || [[ "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "0"
	[[ -e "${vm}swap_ratio" ]] && write "${vm}swap_ratio" "100"
	[[ -e "${vm}oom_dump_tasks" ]] && write "${vm}oom_dump_tasks" "0"
	[[ -e "${lmk}minfree" ]] && write "${lmk}minfree" "$minfree"
	[[ -e "${lmk}oom_reaper" ]] && write "${lmk}oom_reaper" "1"
	[[ -e "${lmk}lmk_fast_run" ]] && write "${lmk}lmk_fast_run" "0"
	[[ -e "${lmk}enable_adaptive_lmk" ]] && write "${lmk}enable_adaptive_lmk" "0"
	[[ -e "${vm}extra_free_kbytes" ]] && write "${vm}extra_free_kbytes" "$efk"
	[[ -e "${lmk}cost" ]] && write "${lmk}cost" "4096"
	[[ -e "${vm}watermark_scale_factor" ]] && write "${vm}watermark_scale_factor" "100"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -le "4096" ]] && write "${zram}wb_start_mins" "180"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "6144" ]] && write "${zram}wb_start_mins" "240"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "8192" ]] && write "${zram}wb_start_mins" "360"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -gt "8192" ]] && write "${zram}wb_start_mins" "480"
	kmsg "Tweaked various VM and LMK parameters for a improved user-experience"
	kmsg3 ""
}

vm_lmk_battery() {
	sync
	write "${vm}drop_caches" "0"
	write "${vm}dirty_background_ratio" "5"
	write "${vm}dirty_ratio" "20"
	write "${vm}dirty_expire_centisecs" "200"
	write "${vm}dirty_writeback_centisecs" "500"
	write "${vm}page-cluster" "0"
	write "${vm}stat_interval" "120"
	write "${vm}overcommit_ratio" "100"
	[[ "$total_ram" -le "6144" ]] && write "${vm}swappiness" "160"
	[[ "$total_ram" -ge "8192" ]] && write "${vm}swappiness" "120"
	[[ "$total_ram" -gt "8192" ]] && write "${vm}rswappiness" "90"
	[[ "$(cat ${vm}swappiness)" -ne "160" ]] || [[ "$(cat ${vm}swappiness)" -ne "120" ]] || [[ "$(cat ${vm}swappiness)" -ne "90" ]] && write "${vm}swappiness" "100"
	write "${vm}laptop_mode" "0"
	write "${vm}vfs_cache_pressure" "60"
	[[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	[[ ! "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "1" || [[ "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "0"
	[[ -e "${vm}swap_ratio" ]] && write "${vm}swap_ratio" "100"
	[[ -e "${vm}oom_dump_tasks" ]] && write "${vm}oom_dump_tasks" "0"
	[[ -e "${lmk}minfree" ]] && write "${lmk}minfree" "$minfree"
	[[ -e "${lmk}oom_reaper" ]] && write "${lmk}oom_reaper" "1"
	[[ -e "${lmk}lmk_fast_run" ]] && write "${lmk}lmk_fast_run" "0"
	[[ -e "${lmk}enable_adaptive_lmk" ]] && write "${lmk}enable_adaptive_lmk" "0"
	[[ -e "${vm}extra_free_kbytes" ]] && write "${vm}extra_free_kbytes" "$efk"
	[[ -e "${lmk}cost" ]] && write "${lmk}cost" "4096"
	[[ -e "${vm}watermark_scale_factor" ]] && write "${vm}watermark_scale_factor" "100"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -le "4096" ]] && write "${zram}wb_start_mins" "180"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "6144" ]] && write "${zram}wb_start_mins" "240"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "8192" ]] && write "${zram}wb_start_mins" "360"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -gt "8192" ]] && write "${zram}wb_start_mins" "480"
	kmsg "Tweaked various VM and LMK parameters for a improved user-experience"
	kmsg3 ""
}

vm_lmk_gaming() {
	sync
	write "${vm}drop_caches" "3"
	write "${vm}dirty_background_ratio" "10"
	write "${vm}dirty_ratio" "40"
	write "${vm}dirty_expire_centisecs" "5000"
	write "${vm}dirty_writeback_centisecs" "5000"
	write "${vm}page-cluster" "0"
	write "${vm}stat_interval" "120"
	write "${vm}overcommit_ratio" "100"
	[[ "$total_ram" -le "6144" ]] && write "${vm}swappiness" "160"
	[[ "$total_ram" -ge "8192" ]] && write "${vm}swappiness" "120"
	[[ "$total_ram" -gt "8192" ]] && write "${vm}rswappiness" "90"
	[[ "$(cat ${vm}swappiness)" -ne "160" ]] || [[ "$(cat ${vm}swappiness)" -ne "120" ]] || [[ "$(cat ${vm}swappiness)" -ne "90" ]] && write "${vm}swappiness" "100"
	write "${vm}laptop_mode" "0"
	write "${vm}vfs_cache_pressure" "200"
	[[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	[[ ! "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "1" || [[ "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "0"
	[[ -e "${vm}swap_ratio" ]] && write "${vm}swap_ratio" "100"
	[[ -e "${vm}oom_dump_tasks" ]] && write "${vm}oom_dump_tasks" "0"
	[[ -e "${lmk}minfree" ]] && write "${lmk}minfree" "$minfree"
	[[ -e "${lmk}oom_reaper" ]] && write "${lmk}oom_reaper" "1"
	[[ -e "${lmk}lmk_fast_run" ]] && write "${lmk}lmk_fast_run" "0"
	[[ -e "${lmk}enable_adaptive_lmk" ]] && write "${lmk}enable_adaptive_lmk" "0"
	[[ -e "${vm}extra_free_kbytes" ]] && write "${vm}extra_free_kbytes" "$efk"
	[[ -e "${lmk}cost" ]] && write "${lmk}cost" "4096"
	[[ -e "${vm}watermark_scale_factor" ]] && write "${vm}watermark_scale_factor" "100"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -le "4096" ]] && write "${zram}wb_start_mins" "180"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "6144" ]] && write "${zram}wb_start_mins" "240"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "8192" ]] && write "${zram}wb_start_mins" "360"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -gt "8192" ]] && write "${zram}wb_start_mins" "480"
	kmsg "Tweaked various VM and LMK parameters for a improved user-experience"
	kmsg3 ""
}

disable_msm_thermal() {
	[[ -d "/sys/module/msm_thermal/" ]] && {
		write "/sys/module/msm_thermal/vdd_restriction/enabled" "0"
		write "/sys/module/msm_thermal/core_control/enabled" "0"
		write "/sys/module/msm_thermal/parameters/enabled" "N"
		kmsg "Disabled msm_thermal"
		kmsg3 ""
	}
}

enable_pewq() {
	[[ -e "/sys/module/workqueue/parameters/power_efficient" ]] && {
		write "/sys/module/workqueue/parameters/power_efficient" "Y"
		kmsg "Enabled power efficient workqueue"
		kmsg3 ""
	}
}

disable_pewq() {
	[[ -e "/sys/module/workqueue/parameters/power_efficient" ]] && {
		write "/sys/module/workqueue/parameters/power_efficient" "N"
		kmsg "Disabled power efficient workqueue"
		kmsg3 ""
	}
}

enable_mcps() {
	[[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]] && {
		write "/sys/devices/system/cpu/sched_mc_power_savings" "2"
		kmsg "Enabled scheduler multi-core power-saving"
		kmsg3 ""
	}
}

disable_mcps() {
	[[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]] && {
		write "/sys/devices/system/cpu/sched_mc_power_savings" "0"
		kmsg "Disabled scheduler multi-core power-saving"
		kmsg3 ""
	}
}

fix_dt2w() {
	[[ -e "/sys/touchpanel/double_tap" ]] && [[ -e "/proc/tp_gesture" ]] && {
		write "/sys/touchpanel/double_tap" "1"
		write "/proc/tp_gesture" "1"
		kmsg "Fixed DT2W if broken"
		kmsg3 ""
	} || [[ -e "/sys/class/sec/tsp/dt2w_enable" ]] && {
		write "/sys/class/sec/tsp/dt2w_enable" "1"
		kmsg "Fixed DT2W if broken"
		kmsg3 ""
	} || [[ -e "/proc/tp_gesture" ]] && {
		write "/proc/tp_gesture" "1"
		kmsg "Fixed DT2W if broken"
		kmsg3 ""
	} || [[ -e "/sys/touchpanel/double_tap" ]] && {
		write "/sys/touchpanel/double_tap" "1"
		kmsg "Fixed DT2W if broken"
		kmsg3 ""
	} || [[ -e "/proc/touchpanel/double_tap_enable" ]] && {
		write "/proc/touchpanel/double_tap_enable" "1"
		kmsg "Fixed DT2W if broken"
		kmsg3 ""
	}
}

enable_tb() {
	[[ -e "/sys/module/msm_performance/parameters/touchboost" ]] && {
		write "/sys/module/msm_performance/parameters/touchboost" "1"
		kmsg "Enabled msm_performance touch boost"
		kmsg3 ""
	} || [[ -e "/sys/power/pnpmgr/touch_boost" ]] && {
		write "/sys/power/pnpmgr/touch_boost" "1"
		write "/sys/power/pnpmgr/long_duration_touch_boost" "1"
		kmsg "Enabled pnpmgr touch boost"
		kmsg3 ""
	}

	[[ -e "/proc/touchpanel/oplus_tp_limit_enable" ]] && {
		write "/proc/touchpanel/oplus_tp_limit_enable" "0"
		write "/proc/touchpanel/oplus_tp_direction" "1"
		write "/proc/touchpanel/game_switch_enable" "1"
		kmsg "Enabled improved touch mode"
		kmsg3 ""
	}
}

disable_tb() {
	[[ -e "/sys/module/msm_performance/parameters/touchboost" ]] && {
		write "/sys/module/msm_performance/parameters/touchboost" "0"
		kmsg "Disabled msm_performance touch boost"
		kmsg3 ""
	} || [[ -e "/sys/power/pnpmgr/touch_boost" ]] && {
		write "/sys/power/pnpmgr/touch_boost" "0"
		write "/sys/power/pnpmgr/long_duration_touch_boost" "0"
		kmsg "Disabled pnpmgr touch boost"
		kmsg3 ""
	}

	[[ -e "/proc/touchpanel/oplus_tp_limit_enable" ]] && {
		write "/proc/touchpanel/oplus_tp_limit_enable" "0"
		write "/proc/touchpanel/oplus_tp_direction" "1"
		write "/proc/touchpanel/game_switch_enable" "0"
		kmsg "Disabled improved touch mode"
		kmsg3 ""
	}
}

config_tcp() {
	# Fetch the available TCP congestion control
	avail_con="$(cat "${tcp}tcp_available_congestion_control")"

	# Attempt to set the TCP congestion control in this order
	for tcpcc in bbr2 bbr westwood cubic bic; do
		# Once a matching TCP congestion control is found, set it and break
		if [[ "$avail_con" == *"$tcpcc"* ]]; then
			write "${tcp}tcp_congestion_control" "$tcpcc"
			break
		fi
	done

	write "${tcp}ip_no_pmtu_disc" "0"
	write "${tcp}tcp_ecn" "1"
	write "${tcp}tcp_timestamps" "0"
	write "${tcp}route/flush" "1"
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
	write "${tcp}tcp_mtu_probing" "1"
	kmsg "Applied TCP tweaks"
	kmsg3 ""
}

enable_kern_batt_saver() {
	[[ -d "/sys/module/battery_saver/" ]] && {
		write "/sys/module/battery_saver/parameters/enabled" "Y"
		kmsg "Enabled kernel battery saver"
		kmsg3 ""
	}
}

disable_kern_batt_saver() {
	[[ -d "/sys/module/battery_saver/" ]] && {
		write "/sys/module/battery_saver/parameters/enabled" "N"
		kmsg "Disabled kernel battery saver"
		kmsg3 ""
	}
}

enable_hp_snd() {
	for hpm in /sys/module/snd_soc_wcd*/; do
		[[ -d "$hpm" ]] && {
			write "${hpm}parameters/high_perf_mode" "1"
			kmsg "Enabled high performance audio"
			kmsg3 ""
		}
		break
	done
}

disable_hp_snd() {
	for hpm in /sys/module/snd_soc_wcd*/; do
		[[ -d "$hpm" ]] && {
			write "${hpm}parameters/high_perf_mode" "0"
			kmsg "Disabled high performance audio"
			kmsg3 ""
		}
		break
	done
}

enable_lpm() {
	for lpm in /sys/module/lpm_levels/system/*/*/*/; do
		[[ -d "/sys/module/lpm_levels/" ]] && {
			write "/sys/module/lpm_levels/parameters/lpm_prediction" "N"
			write "/sys/module/lpm_levels/parameters/lpm_ipi_prediction" "Y"
			write "/sys/module/lpm_levels/parameters/sleep_disabled" "N"
			write "${lpm}idle_enabled" "Y"
			write "${lpm}suspend_enabled" "Y"
		}
	done
	kmsg "Enabled LPM"
	kmsg3 ""
}

disable_lpm() {
	for lpm in /sys/module/lpm_levels/system/*/*/*/; do
		[[ -d "/sys/module/lpm_levels/" ]] && {
			write "/sys/module/lpm_levels/parameters/lpm_prediction" "N"
			write "/sys/module/lpm_levels/parameters/lpm_ipi_prediction" "N"
			write "/sys/module/lpm_levels/parameters/sleep_disabled" "Y"
			write "${lpm}idle_enabled" "N"
			write "${lpm}suspend_enabled" "N"
		}
	done
	kmsg "Disabled LPM"
	kmsg3 ""
}

enable_pm2_idle_mode() {
	[[ -d "/sys/module/pm2/parameters/" ]] && {
		write "/sys/module/pm2/parameters/idle_sleep_mode" "Y"
		kmsg "Enabled pm2 idle sleep mode"
		kmsg3 ""
	}
}

disable_pm2_idle_mode() {
	[[ -d "/sys/module/pm2/parameters/" ]] && {
		write "/sys/module/pm2/parameters/idle_sleep_mode" "N"
		kmsg "Disabled pm2 idle sleep mode"
		kmsg3 ""
	}
}

enable_lcd_prdc() {
	[[ -e "/sys/class/lcd/panel/power_reduce" ]] && {
		write "/sys/class/lcd/panel/power_reduce" "1"
		kmsg "Enabled LCD power reduce"
		kmsg3 ""
	}
}

disable_lcd_prdc() {
	[[ -e "/sys/class/lcd/panel/power_reduce" ]] && {
		write "/sys/class/lcd/panel/power_reduce" "0"
		kmsg "Disabled LCD power reduce"
		kmsg3 ""
	}
}

enable_usb_fast_chrg() {
	[[ -e "/sys/kernel/fast_charge/force_fast_charge" ]] && {
		write "/sys/kernel/fast_charge/force_fast_charge" "1"
		kmsg "Enabled USB 3.0 fast charging"
		kmsg3 ""
	}
}

enable_sam_fast_chrg() {
	[[ -e "/sys/class/sec/switch/afc_disable" ]] && {
		write "/sys/class/sec/switch/afc_disable" "0"
		kmsg "Enabled fast charging on Samsung devices"
		kmsg3 ""
	}
}

disable_debug() {
	# Disable kernel debugging / logging
	for i in debug_mask log_level* debug_level* *debug_mode enable_ramdumps edac_mc_log* enable_event_log *log_level* *log_ue* *log_ce* log_ecn_error snapshot_crashdumper seclog* compat-log *log_enabled tracing_on mballoc_debug; do
		for o in $(find /sys/ -type f -name "$i"); do
			write "$o" "0"
		done
	done
	write "/sys/module/spurious/parameters/noirqdebug" "1"
	write "/sys/kernel/debug/sde_rotator0/evtlog/enable" "0"
	write "/sys/kernel/debug/dri/0/debug/enable" "0"
	kmsg "Disabled misc debugging"
	kmsg3 ""
}

perfmgr_default() {
	[[ -d "${perfmgr}boost_ctrl/eas_ctrl/" ]] && {
		write "${perfmgr}boost_ctrl/eas_ctrl/perfserv_prefer_idle" "0"
		write "${perfmgr}boost_ctrl/eas_ctrl/perfserv_fg_boost" "0"
		write "${perfmgr}boost_ctrl/eas_ctrl/perfserv_ta_boost" "0"
		write "${perfmgr}boost_ctrl/eas_ctrl/perfserv_bg_boost" "-100"
		write "${perfmgr}boost_ctrl/eas_ctrl/perfserv_uclamp_min" "0"
		write "${perfmgr}boost_ctrl/eas_ctrl/perfserv_fg_uclamp_min" "0"
		write "${perfmgr}boost_ctrl/eas_ctrl/perfserv_ta_uclamp_min" "0"
		write "${perfmgr}boost_ctrl/eas_ctrl/perfserv_bg_uclamp_min" "0"
		write "${perfmgr}boost_ctrl/cpu_ctrl/cfp_enable" "1"
		write "${perfmgr}boost_ctrl/cpu_ctrl/cfp_up_loading" "60"
		write "${perfmgr}boost_ctrl/cpu_ctrl/cfp_down_loading" "80"
		kmsg "Tweaked perfmgr settings"
		kmsg3 ""
	}
}

perfmgr_pwr_saving() {
	[[ -d "${perfmgr}boost_ctrl/eas_ctrl/" ]] && {
		write "${perfmgr}boost_ctrl/eas_ctrl/perfserv_prefer_idle" "0"
		write "${perfmgr}boost_ctrl/eas_ctrl/perfserv_fg_boost" "0"
		write "${perfmgr}boost_ctrl/eas_ctrl/perfserv_ta_boost" "0"
		write "${perfmgr}boost_ctrl/eas_ctrl/perfserv_bg_boost" "-100"
		write "${perfmgr}boost_ctrl/eas_ctrl/perfserv_uclamp_min" "0"
		write "${perfmgr}boost_ctrl/eas_ctrl/perfserv_fg_uclamp_min" "0"
		write "${perfmgr}boost_ctrl/eas_ctrl/perfserv_ta_uclamp_min" "0"
		write "${perfmgr}boost_ctrl/eas_ctrl/perfserv_bg_uclamp_min" "0"
		write "${perfmgr}boost_ctrl/cpu_ctrl/cfp_enable" "1"
		write "${perfmgr}boost_ctrl/cpu_ctrl/cfp_up_loading" "80"
		write "${perfmgr}boost_ctrl/cpu_ctrl/cfp_down_loading" "60"
		kmsg "Tweaked perfmgr settings"
		kmsg3 ""
	}
}

disable_migt() {
	[[ -d "$migt" ]] && {
		write "${migt}migt_freq" "0:0 1:0 2:0 3:0 4:0 5:0 6:0 7:0"
		write "${migt}glk_freq_limit_start" "0"
		write "${migt}glk_freq_limit_walt" "0"
		write "${migt}glk_maxfreq" "0 0 0"
		write "${migt}migt_ceiling_freq" "0 0 0"
		write "${migt}glk_disable" "1"
		settings put secure speed_mode_enable 1
	}
}

enable_thermal_disguise() {
	disable_migt
	write "$board_sensor_temp" "36000"
	chmod 000 "$board_sensor_temp" 2>/dev/null
	nohup pm clear com.xiaomi.gamecenter.sdk.service >/dev/null 2>&1 &
	nohup pm disable com.xiaomi.gamecenter.sdk.service/.PidService >/dev/null 2>&1 &
}

disable_thermal_disguise() {
	chmod 644 "$board_sensor_temp" 2>/dev/null
	nohup pm enable com.xiaomi.gamecenter.sdk.service/.PidService >/dev/null 2>&1 &
}

# $1:content
write_panel() { echo "$1" >>"$bbn_banner"; }

save_panel() {
	write_panel "[*] Bourbon - the essential task optimizer 
Version: 1.3.3-r5-stable
Last performed: $(date '+%Y-%m-%d %H:%M:%S')
FSCC status: $(fscc_status)
Adjshield status: $(adjshield_status)
Adjshield config file: $adj_cfg"
}

# $1:str
adjshield_write_cfg() { echo "$1" >>"$adj_cfg"; }

adjshield_create_default_cfg() {
	adjshield_write_cfg "# AdjShield Config File
# Prevent given packages from being killed by LMK by protecting oom_score_adj.
# List all the package names of the apps which you want to keep alive.
com.riotgames.league.wildrift
com.activision.callofduty.shooter
com.mobile.legends
com.tencent.ig
"
}

# Credits to DavidPisces @ GitHub
config_f2fs() {
	write "$f2fs$(getprop dev.mnt.blk.data)/cp_interval" "200"
	write "$f2fs$(getprop dev.mnt.blk.data)/gc_urgent_sleep_time" "50"
	write "$f2fs$(getprop dev.mnt.blk.data)/iostat_enable" "0"
}

realme_gt() {
	gt=$(settings get system gt_mode_state_setting)
	[[ "$gt" == "1" ]] || [[ "$gt" == "0" ]] && [[ "$gt" != "$1" ]] && {
		[[ "$1" == "1" ]] && action='open' || action='close'
		gt_receiver='com.coloros.oppoguardelf/com.coloros.performance.GTModeBroadcastReceiver'
		[[ -n "$(pm query-receivers --brief -n $gt_receiver | grep $gt_receiver)" ]] && am broadcast -a gt_mode_broadcast_intent_${action}_action -n $gt_receiver -f 0x01000000 || am broadcast -a gt_mode_broadcast_intent_${action}_action -f 0x01000000
	}
}

sched_deisolation() {
	for i in 0 1 2 3 4 5 6 7; do
		write "/sys/devices/system/cpu/sched/set_sched_deisolation" "$i"
	done
	chmod 000 "/sys/devices/system/cpu/sched/set_sched_isolation"
}

sched_isolation() {
	for i in 0 1 2 3 4 5 6 7; do
		write "/sys/devices/system/cpu/sched/set_sched_isolation" "$i"
	done
}

adjshield_start() {
	# clear logs
	rm -rf "$adj_log"
	rm -rf "$bbn_log"
	rm -rf "$bbn_banner"
	# check interval: 120 seconds - Deprecated, use event driven instead
	${modpath}system/bin/adjshield -o $adj_log -c $adj_cfg &
}

adjshield_stop() { killall "$adj_nm" 2>/dev/null; }

# return:status
adjshield_status() {
	[[ "$(ps -A | grep "$adj_nm")" != "" ]] && echo "Adjshield running. see $adj_log for details." || {
		# Error: Log file not found
		err="$(cat "$adj_log" | grep Error | head -n 1 | cut -d: -f2)"
		[[ "$err" != "" ]] && echo "Not running. $err." || echo "Not running. Unknown reason."
	}
}

# $1:task_name $2:cgroup_name $3:"cpuset"/"stune"
change_task_cgroup() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			comm="$(cat "/proc/$temp_pid/task/$temp_tid/comm")"
			echo "$temp_tid" >"/dev/$3/$2/tasks"
		done
	done
}

# $1:process_name $2:cgroup_name $3:"cpuset"/"stune"
change_proc_cgroup() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		comm="$(cat "/proc/$temp_pid/comm")"
		echo "$temp_pid" >"/dev/$3/$2/cgroup.procs"
	done
}

# $1:task_name $2:thread_name $3:cgroup_name $4:"cpuset"/"stune"
change_thread_cgroup() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			comm="$(cat "/proc/$temp_pid/task/$temp_tid/comm")"
			[[ "$(echo "$comm" | grep -i -E "$2")" != "" ]] && echo "$temp_tid" >"/dev/$4/$3/tasks"
		done
	done
}

# $1:task_name $2:cgroup_name $3:"cpuset"/"stune"
change_main_thread_cgroup() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		comm="$(cat "/proc/$temp_pid/comm")"
		echo "$temp_pid" >"/dev/$3/$2/tasks"
	done
}

# $1:task_name $2:hex_mask(0x00000003 is CPU0 and CPU1)
change_task_affinity() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			comm="$(cat "/proc/$temp_pid/task/$temp_tid/comm")"
			taskset -p "$2" "$temp_tid" >>"$bbn_log"
		done
	done
}

# $1:task_name $2:thread_name $3:hex_mask(0x00000003 is CPU0 and CPU1)
change_thread_affinity() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			comm="$(cat "/proc/$temp_pid/task/$temp_tid/comm")"
			[[ "$(echo "$comm" | grep -i -E "$2")" != "" ]] && taskset -p "$3" "$temp_tid" >>"$bbn_log"
		done
	done
}

# $1:task_name $2:nice(relative to 120)
change_task_nice() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			renice -n +40 -p "$temp_tid"
			renice -n -19 -p "$temp_tid"
			renice -n "$2" -p "$temp_tid"
		done
	done
}

# $1:task_name $2:thread_name $3:nice(relative to 120)
change_thread_nice() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			comm="$(cat "/proc/$temp_pid/task/$temp_tid/comm")"
			[[ "$(echo "$comm" | grep -i -E "$2")" != "" ]] && {
				renice -n +40 -p "$temp_tid"
				renice -n -19 -p "$temp_tid"
				renice -n "$3" -p "$temp_tid"
			}
		done
	done
}

# $1:task_name $2:priority(99-x, 1<=x<=99) (SCHED_RR)
change_task_rt() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			comm="$(cat "/proc/$temp_pid/task/$temp_tid/comm")"
			chrt -p "$temp_tid" "$2" >>"$bbn_log"
		done
	done
}

# $1:task_name $2:priority(99-x, 1<=x<=99) (SCHED_FIFO)
change_task_rt_ff() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			comm="$(cat "/proc/$temp_pid/task/$temp_tid/comm")"
			chrt -f -p "$temp_tid" "$2" >>"$bbn_log"
		done
	done
}

# $1:task_name $2:thread_name $3:priority(99-x, 1<=x<=99)
change_thread_rt() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			comm="$(cat "/proc/$temp_pid/task/$temp_tid/comm")"
			[[ "$(echo "$comm" | grep -i -E "$2")" != "" ]] && chrt -p "$3" "$temp_tid" >>"$bbn_log"
		done
	done
}

# $1:task_name
# audio thread nice => -19
change_task_high_prio() { change_task_nice "$1" "-19"; }

# $1:task_name $2:thread_name
change_thread_high_prio() { change_thread_nice "$1" "$2" "-19"; }

unpin_thread() { change_thread_cgroup "$1" "$2" "" "cpuset"; }

pin_thread_on_pwr() {
	unpin_thread "$1" "$2"
	change_thread_affinity "$1" "$2" "0f"
}

pin_thread_on_mid() {
	unpin_thread "$1" "$2"
	change_thread_affinity "$1" "$2" "7f"
}

pin_thread_on_perf() {
	unpin_thread "$1" "$2"
	change_thread_affinity "$1" "$2" "f0"
}

# $1:task_name
unpin_proc() { change_task_cgroup "$1" "" "cpuset"; }

pin_proc_on_pwr() {
	unpin_proc "$1"
	change_task_affinity "$1" "0f"
}

pin_proc_on_mid() {
	unpin_proc "$1"
	change_task_affinity "$1" "7f"
}

pin_proc_on_perf() {
	unpin_proc "$1"
	change_task_affinity "$1" "f0"
}

pin_proc_on_all() {
	unpin_proc "$1"
	change_task_affinity "$1" "ff"
}

# avoid matching grep itself
# ps -Ao pid,args | grep kswapd
# 150 [kswapd0]
# 16490 grep kswapd
rebuild_process_scan_cache() { ps_ret="$(ps -Ao pid,args)"; }

# $1:apk_path $return:oat_path
# OPSystemUI/OPSystemUI.apk -> OPSystemUI/oat
fscc_path_apk_to_oat() { echo "${1%/*}/oat"; }

# $1:file/dir
fscc_list_append() { fscc_file_list="$fscc_file_list $1"; }

fscc_add_obj() { [[ -e "$1" ]] && fscc_list_append "$1"; }

# $1:package_name
# pm path -> "package:/system/product/priv-app/OPSystemUI/OPSystemUI.apk"
fscc_add_apk() { [[ "$1" != "" ]] && fscc_add_obj "$(pm path "$1" | head -n 1 | cut -d: -f2)"; }

# $1:package_name
fscc_add_dex() {
	[[ "$1" != "" ]] \
		&& {
			# pm path -> "package:/system/product/priv-app/OPSystemUI/OPSystemUI.apk"
			package_apk_path="$(pm path "$1" | head -n 1 | cut -d: -f2)"
			# User app: OPSystemUI/OPSystemUI.apk -> OPSystemUI/oat
			fscc_add_obj "${package_apk_path%/*}/oat"
			# Remove apk name suffix
			apk_nm="${package_apk_path%/*}"
			# Remove path prefix
			apk_nm="${apk_nm##*/}"
			# System app: get dex & vdex
			# /data/dalvik-cache/arm64/system@product@priv-app@OPSystemUI@OPSystemUI.apk@classes.dex
		}
	for dex in $(find "$dvk" | grep "@$apk_name@"); do
		fscc_add_obj "$dex"
	done
}

fscc_add_app_home() {
	# Well, not working on Android 7.1
	intent_act="android.intent.action.MAIN"
	intent_cat="android.intent.category.HOME"
	# "  packageName=com.microsoft.launcher"
	pkg_nm="$(pm resolve-activity -a "$intent_act" -c "$intent_cat" | grep packageName | head -n 1 | cut -d= -f2)"
	# /data/dalvik-cache/arm64/system@priv-app@OPLauncher2@OPLauncher2.apk@classes.dex 16M/31M  53.2%
	# /data/dalvik-cache/arm64/system@priv-app@OPLauncher2@OPLauncher2.apk@classes.vdex 120K/120K  100%
	# /system/priv-app/OPLauncher2/OPLauncher2.apk 14M/30M  46.1%
	fscc_add_apk "$pkg_nm"
	fscc_add_dex "$pkg_nm"
}

fscc_add_app_ime() {
	# "      packageName=com.baidu.input_yijia"
	pkg_nm="$(ime list | grep packageName | head -n 1 | cut -d= -f2)"
	# /data/dalvik-cache/arm/system@app@baidushurufa@baidushurufa.apk@classes.dex 5M/17M  33.1%
	# /data/dalvik-cache/arm/system@app@baidushurufa@baidushurufa.apk@classes.vdex 2M/7M  28.1%
	# /system/app/baidushurufa/baidushurufa.apk 1M/28M  5.71%
	# pin apk file in memory is not valuable
	fscc_add_dex "$pkg_nm"
}

# $1:package_name
fscc_add_apex_lib() { fscc_add_obj "$(find /apex -name "$1" | head -n 1)"; }

# After appending fscc_file_list
# Multiple parameters, cannot be warped by ""
fscc_start() { ${modpath}system/bin/$fscc_nm -fdlb0 $fscc_file_list; }

fscc_stop() { killall "$fscc_nm" 2>/dev/null; }

# Return:status
fscc_status() {
	# Get the correct value after waiting for fscc loading files
	sleep 2
	[[ "$(ps -A | grep "$fscc_nm")" != "" ]] && echo "Running $(cat /proc/meminfo | grep Mlocked | cut -d: -f2 | tr -d ' ') in cache." || echo "Not running."
}

# Userspace bourbon optimization
usr_bbn_opt() {
	# Input Dispatcher / Reader
	change_thread_nice "system_server" "Input" "-20"
	# Not important
	change_thread_nice "system_server" "Greezer|TaskSnapshot|Oom" "4"
	# Speed up searching service manager, pin it to the perf cluster
	change_task_nice "servicemanag" "-20"
	pin_proc_on_perf "servicemanag"
	# Let KGSL and mali worker thread run with max nice and pin it on perf cluster as it is a perf critical task (rendering frames to the display)
	change_task_nice "kgsl_worker" "-20"
	pin_proc_on_perf "kgsl_worker_thread"
	change_task_nice "mali_jd_thread" "-20"
	change_task_nice "mali_event_thread" "-20"
	# Let RCU tasks kthread run on perf cluster
	pin_proc_on_perf "rcu_task"
	# Pin LMKD to perf cluster as it is has the critical task of reclaiming memory to the system
	pin_proc_on_perf "lmkd"
	# Kernel reclaim threads run on more power-efficient cores
	change_task_nice "kswapd" "-2"
	change_task_nice "oom_reaper" "-2"
	# Let system run with max nice too
	change_task_nice "system" "-20"
	# Let devfreq boost run with max nice as it is also a perf critical task (boosting DDR)
	change_task_nice "devfreq_boost" "-20"
	# Pin these kthreads to the perf cluster as they also play a major role in rendering frames to the display
	pin_proc_on_perf "crtc_event"
	pin_proc_on_perf "crtc_commit"
	pin_proc_on_perf "pp_event"
	pin_proc_on_perf "mdss_fb"
	pin_proc_on_perf "mdss_display_wake"
	pin_proc_on_perf "vsync_retire_work"
	# Pin SF to perf cluster
	pin_proc_on_perf "surfaceflinger"
	# Pin TS workqueue to perf cluster to reduce latency
	pin_proc_on_perf "fts_wq"
	pin_proc_on_perf "nvt_ts"
	pin_proc_on_perf "nvt_fwu"
	# Pin Samsung HyperHAL, wifi HAL and daemon to perf cluster
	pin_proc_on_perf "hardware.hyper"
	pin_proc_on_perf "hardware.wifi"
	pin_proc_on_perf "wlbtd"
	# Queue UFS / MMC clock gating workqueue with max nice
	change_task_nice "ufs_clk_gating" "-20"
	change_task_nice "mmc_clk_gate" "-20"
	# Pin fingerprint service to perf cluster to reduce latency
	pin_proc_on_perf "erprint"
	# Pin HWC on perf cluster to reduce jitter / latency
	pin_proc_on_perf "composer"
	# Queue CVP fence request handler with max nice
	change_task_nice "thread_fence" "-20"
	# Queue powerkey_cpu_boost, cpu_boostd and worker on perf cluster with max nice for obvious reasons
	change_task_nice "cpu_boostd" "-20"
	pin_proc_on_perf "cpu_boostd"
	change_task_rt "cpu_boost_worker_thread" "2"
	change_task_nice "cpu_boost_worker_thread" "-20"
	pin_proc_on_perf "cpu_boost_worker_thread"
	change_task_nice "key_cpu_bo" "-20"
	pin_proc_on_perf "key_cpu_bo"
	# Queue touchscreen related workers with max nice
	change_task_nice "speedup_resume_wq" "-20"
	change_task_nice "lcd_trigger_load_tp_fw_wq" "-20"
	change_task_nice "syna_tcm_freq_hop" "-20"
	change_task_nice "touch_delta_wq" "-20"
	change_task_nice "tp_async" "-20"
	change_task_nice "early_wakeup_clk_wq" "-20"
	# Move some critical tasks to SCHED_RR
	change_task_rt "kgsl_worker_thread" "16"
	change_task_rt "adreno_dispatch" "16"
	change_task_rt "crtc_commit" "16"
	change_task_rt "crtc_event" "16"
	change_task_rt "pp_event" "16"
	change_task_rt "rot_commitq" "5"
	change_task_rt "rot_doneq" "5"
	change_task_rt "rot_fenceq" "5"
	change_task_rt "miui.home" "0"
	# Boost app boot process, zygote--com.xxxx.xxx
	change_task_nice "zygote" "-20"
}

clear_logs() {
	# Remove debug log if size is >= 1 MB
	kdbg_max_size=1000000
	# Do the same to sqlite opt log
	sqlite_opt_max_size=1000000
	[[ "$(stat -t "$kdbg" 2>/dev/null | awk '{print $2}')" -ge "$kdbg_max_size" ]] && rm -rf "$kdbg"
	[[ "$(stat -t "/data/media/0/KTSR/sqlite_opt.log" 2>/dev/null | awk '{print $2}')" -ge "$sqlite_opt_max_size" ]] && rm -rf "/data/media/0/KTSR/sqlite_opt.log"
}

# Return <0/1>
get_scrn_state() {
	scrn_state=$(dumpsys power 2>/dev/null | grep state=O | cut -d "=" -f 2)
	[[ "$scrn_state" == "" ]] && scrn_state=$(dumpsys window policy | grep screenState | awk -F '=' '{print $2}')
	[[ "$scrn_state" == "OFF" ]] && scrn_on=0 || scrn_on=1
	[[ "$scrn_state" == "SCREEN_STATE_OFF" ]] && scrn_on=0 || scrn_on=1
}

[[ "$qcom" == "true" ]] && {
	define_gpu_pl
	disable_adreno_gpu_thrtl
}

apply_all() {
	print_info
	stop_services
	[[ "$ktsr_prof_en" == "extreme" ]] || [[ "$ktsr_prof_en" == "gaming" ]] && enable_devfreq_boost || disable_devfreq_boost
	[[ "$ktsr_prof_en" == "extreme" ]] || [[ "$ktsr_prof_en" == "gaming" ]] && dram_max || dram_default
	[[ "$ktsr_prof_en" == "balanced" ]] || [[ "$ktsr_prof_en" == "battery" ]] && enable_core_ctl || disable_core_ctl
	[[ "$ktsr_prof_en" == "extreme" ]] || [[ "$ktsr_prof_en" == "gaming" ]] && sched_deisolation || sched_isolation
	boost_"$ktsr_prof_en"
	io_"$ktsr_prof_en"
	cpu_"$ktsr_prof_en"
	[[ "$ktsr_prof_en" == "extreme" ]] || [[ "$ktsr_prof_en" == "gaming" ]] && enable_kvb || disable_kvb
	bring_all_cores
	config_cpuset_"$ktsr_prof_en"
	[[ "$ktsr_prof_en" == "latency" ]] || [[ "$ktsr_prof_en" == "balanced" ]] && misc_cpu_default
	[[ "$ktsr_prof_en" == "battery" ]] && misc_cpu_pwr_saving || misc_cpu_max_pwr
	[[ "$ktsr_prof_en" != "gaming" ]] && enable_ppm || disable_ppm
	[[ "$ktsr_prof_en" == "latency" ]] || [[ "$ktsr_prof_en" == "balanced" ]] || [[ "$ktsr_prof_en" == "battery" ]] && ppm_policy_default
	[[ "$ktsr_prof_en" == "extreme" ]] && ppm_policy_max
	hmp_"$ktsr_prof_en"
	gpu_"$ktsr_prof_en"
	schedtune_"$ktsr_prof_en"
	sched_ft_"$ktsr_prof_en"
	sched_"$ktsr_prof_en"
	uclamp_"$ktsr_prof_en"
	vm_lmk_"$ktsr_prof_en"
	[[ "$ktsr_prof_en" == "balanced" ]] || [[ "$ktsr_prof_en" == "battery" ]] && enable_pewq || disable_pewq
	[[ "$ktsr_prof_en" == "battery" ]] && enable_mcps || disable_mcps
	[[ "$ktsr_prof_en" == "extreme" ]] || [[ "$ktsr_prof_en" == "gaming" ]] && enable_tb || disable_tb
	[[ "$ktsr_prof_en" == "battery" ]] && enable_kern_batt_saver || disable_kern_batt_saver
	[[ "$ktsr_prof_en" == "battery" ]] || [[ "$ktsr_prof_en" == "balanced" ]] || [[ "$ktsr_prof_en" == "latency" ]] && enable_lpm || disable_lpm
	[[ "$ktsr_prof_en" != "extreme" ]] && [[ "$ktsr_prof_en" != "gaming" ]] && enable_pm2_idle_mode || disable_pm2_idle_mode
	[[ "$ktsr_prof_en" == "battery" ]] && enable_lcd_prdc || disable_lcd_prdc
	[[ "$ktsr_prof_en" != "battery" ]] && perfmgr_default || perfmgr_pwr_saving
	[[ -e "$board_sensor_temp" ]] && [[ "$ktsr_prof_en" == "extreme" ]] || [[ "$ktsr_prof_en" == "gaming" ]] && enable_thermal_disguise || disable_thermal_disguise
	[[ "$ktsr_prof_en" == "gaming" ]] || [[ "$ktsr_prof_en" == "extreme" ]] && realme_gt 1 || realme_gt 0
}

apply_all_auto() {
	print_info
	stop_services
	[[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]] && enable_devfreq_boost || disable_devfreq_boost
	[[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]] && dram_max || dram_default
	[[ "$(getprop kingauto.prof)" == "balanced" ]] || [[ "$(getprop kingauto.prof)" == "battery" ]] && enable_core_ctl || disable_core_ctl
	[[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]] && sched_deisolation || sched_isolation
	boost_$(getprop kingauto.prof)
	io_$(getprop kingauto.prof)
	cpu_$(getprop kingauto.prof)
	[[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]] && enable_kvb || disable_kvb
	bring_all_cores
	config_cpuset_$(getprop kingauto.prof)
	[[ "$(getprop kingauto.prof)" == "latency" ]] || [[ "$(getprop kingauto.prof)" == "balanced" ]] && misc_cpu_default
	[[ "$(getprop kingauto.prof)" == "battery" ]] && misc_cpu_pwr_saving || misc_cpu_max_pwr
	[[ "$(getprop kingauto.prof)" != "gaming" ]] && enable_ppm || disable_ppm
	[[ "$(getprop kingauto.prof)" == "latency" ]] || [[ "$(getprop kingauto.prof)" == "balanced" ]] || [[ "$(getprop kingauto.prof)" == "battery" ]] && ppm_policy_default
	[[ "$(getprop kingauto.prof)" == "extreme" ]] && ppm_policy_max
	hmp_$(getprop kingauto.prof)
	gpu_$(getprop kingauto.prof)
	schedtune_$(getprop kingauto.prof)
	sched_ft_$(getprop kingauto.prof)
	sched_$(getprop kingauto.prof)
	uclamp_$(getprop kingauto.prof)
	vm_lmk_$(getprop kingauto.prof)
	[[ "$(getprop kingauto.prof)" == "balanced" ]] || [[ "$(getprop kingauto.prof)" == "battery" ]] && enable_pewq || disable_pewq
	[[ "$(getprop kingauto.prof)" == "battery" ]] && enable_mcps || disable_mcps
	[[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]] && enable_tb || disable_tb
	[[ "$(getprop kingauto.prof)" == "battery" ]] && enable_kern_batt_saver || disable_kern_batt_saver
	[[ "$(getprop kingauto.prof)" == "battery" ]] || [[ "$(getprop kingauto.prof)" == "balanced" ]] || [[ "$(getprop kingauto.prof)" == "latency" ]] && enable_lpm || disable_lpm
	[[ "$(getprop kingauto.prof)" != "extreme" ]] && [[ "$(getprop kingauto.prof)" != "gaming" ]] && enable_pm2_idle_mode || disable_pm2_idle_mode
	[[ "$(getprop kingauto.prof)" == "battery" ]] && enable_lcd_prdc || disable_lcd_prdc
	[[ "$(getprop kingauto.prof)" != "battery" ]] && perfmgr_default || perfmgr_pwr_saving
	[[ -e "$board_sensor_temp" ]] && [[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]] && enable_thermal_disguise || disable_thermal_disguise
	[[ "$(getprop kingauto.prof)" == "gaming" ]] || [[ "$(getprop kingauto.prof)" == "extreme" ]] && realme_gt 1 || realme_gt 0
}

latency() {
	init=$(date +%s)
	sync
	apply_all
	cmd thermalservice reset >/dev/null 2>&1
	kmsg "Latency profile applied. Enjoy!"
	kmsg3 ""
	exit=$(date +%s)
	exec_time=$((exit - init))
	kmsg "Spent time: $exec_time seconds."
}
automatic() {
	kmsg "Applying automatic profile"
	kmsg3 ""
	sync
	kingauto &
	kmsg "Applied automatic profile"
	kmsg3 ""
}
balanced() {
	init=$(date +%s)
	sync
	apply_all
	cmd thermalservice reset >/dev/null 2>&1
	kmsg "Balanced profile applied. Enjoy!"
	kmsg3 ""
	exit=$(date +%s)
	exec_time=$((exit - init))
	kmsg "Spent time: $exec_time seconds."
}
extreme() {
	init=$(date +%s)
	sync
	apply_all
	cmd thermalservice override-status 0 >/dev/null 2>&1l
	kmsg "Extreme profile applied. Enjoy!"
	kmsg3 ""
	exit=$(date +%s)
	exec_time=$((exit - init))
	kmsg "Spent time: $exec_time seconds."
}
battery() {
	init=$(date +%s)
	sync
	apply_all
	cmd thermalservice reset >/dev/null 2>&1
	kmsg "Battery profile applied. Enjoy!"
	kmsg3 ""
	exit=$(date +%s)
	exec_time=$((exit - init))
	kmsg "Spent time: $exec_time seconds."
}
gaming() {
	init=$(date +%s)
	sync
	apply_all
	cmd thermalservice override-status 0 >/dev/null 2>&1
	kmsg "Gaming profile applied. Enjoy!"
	kmsg3 ""
	exit=$(date +%s)
	exec_time=$((exit - init))
	kmsg "Spent time: $exec_time seconds."
}