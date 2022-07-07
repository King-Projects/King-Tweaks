#!/system/bin/sh
# KTSR™ by Pedro (pedrozzz0 @ GitHub)
# Credits: Ktweak, by Draco (tytydraco @ GitHub), LSpeed, Dan (Paget69 @ XDA), mogoroku @ GitHub, vtools, by helloklf @ GitHub, Cuprum-Turbo-Adjustment, by chenzyadb @ CoolApk, qti-mem-opt & Uperf, by Matt Yang (yc9559 @ CoolApk) and Pandora's Box, by Eight (dlwlrma123 @ GitHub)
# Thanks: GR for some help
# If you wanna use the code as part of your project, please maintain the credits to it's respectives authors

log_i() {
	echo "[$(date +%T)]: [*] $1" >>"$klog"
	echo "" >>"$klog"
}

log_d() {
	echo "$1" >>"$kdbg"
	echo "$1"
}

log_e() {
	echo "[!] $1" >>"$kdbg"
	echo "[!] $1"
}

notif_start() { su -lp 2000 -c "cmd notification post -S bigtext -t 'King Tweaks is executing' tag 'Applying $ktsr_prof_en profile...'" >/dev/null 2>&1; }

notif_end() { su -lp 2000 -c "cmd notification post -S bigtext -t 'King Tweaks is executing' tag '$ktsr_prof_en profile applied'" >/dev/null 2>&1; }

notif_pt_start() { su -lp 2000 -c "cmd notification post -S bigtext -t 'King Tweaks is executing' tag 'Aplicando perfil $ktsr_prof_pt...'" >/dev/null 2>&1; }

notif_pt_end() { su -lp 2000 -c "cmd notification post -S bigtext -t 'King Tweaks is executing' tag 'Perfil $ktsr_prof_pt aplicado'" >/dev/null 2>&1; }

notif_tr_start() { su -lp 2000 -c "cmd notification post -S bigtext -t 'King Tweaks is executing' tag '$ktsr_prof_tr profili uygulanıyor...'" >/dev/null 2>&1; }

notif_tr_end() { su -lp 2000 -c "cmd notification post -S bigtext -t 'King Tweaks is executing' tag '$ktsr_prof_tr profili uygulandı'" >/dev/null 2>&1; }

notif_id_start() { su -lp 2000 -c "cmd notification post -S bigtext -t 'King Tweaks is executing' tag 'Menerapkan profil $ktsr_prof_id...'" >/dev/null 2>&1; }

notif_id_end() { su -lp 2000 -c "cmd notification post -S bigtext -t 'King Tweaks is executing' tag 'Profil $ktsr_prof_id terpakai'" >/dev/null 2>&1; }

notif_fr_start() { su -lp 2000 -c "cmd notification post -S bigtext -t 'King Tweaks is executing' tag 'Chargement du profil $ktsr_prof_tr...'" >/dev/null 2>&1; }

notif_fr_end() { su -lp 2000 -c "cmd notification post -S bigtext -t 'King Tweaks is executing' tag 'Profil $ktsr_prof_fr chargé'" >/dev/null 2>&1; }

write() {
	# Bail out if file does not exist
	[[ ! -f "$1" ]] && return 1

	# Make file writable in case it is not already
	chmod +w "$1" 2>/dev/null

	# Write the new value and bail if an error is present
	! echo "$2" >"$1" 2>/dev/null && {
		log_e "Failed: $1 → $2"
		return 1
	}
	log_d "$1 → $2"
}

kill_svc() {
	stop "$1" 2>/dev/null
	killall -9 "$1" 2>/dev/null
	killall -9 $(find /vendor/bin -type f -name "$1") 2>/dev/null
}

#####################
# Variables
#####################
modpath="/data/adb/modules/KTSR/"
klog="/data/media/0/KTSR/KTSR.log"
kdbg="/data/media/0/KTSR/KTSR_DBG.log"
tcp="/proc/sys/net/ipv4/"
kernel="/proc/sys/kernel/"
vm="/proc/sys/vm/"
cpuset="/dev/cpuset/"
stune="/dev/stune/"
lmk="/sys/module/lowmemorykiller/parameters"
cpuctl="/dev/cpuctl/"
fs="/proc/sys/fs/"
f2fs="/sys/fs/f2fs/"
bbn_log="/data/media/0/KTSR/bourbon.log"
bbn_banner="/data/media/0/KTSR/bourbon.info"
adj_cfg="/data/media/0/KTSR/adjshield.conf"
adj_log="/data/media/0/KTSR/adjshield.log"
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
lib_ver="1.2.5-stable"
migt="/sys/module/migt/parameters/"
board_sensor_temp="/sys/class/thermal/thermal_message/board_sensor_temp"
zram="/sys/module/zram/parameters/"
lmk="$(pgrep -f lmkd)"
fpsgo="/sys/module/mtk_fpsgo/parameters/"
t_msg="/sys/class/thermal/thermal_message/"
therm="/sys/class/thermal/tz-by-name/"

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

# Find GPU working directory
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

for gpul11 in /sys/class/misc/mali*/device/; do
	[[ -d "$gpul11" ]] && {
		gpu="$gpul11"
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

if [[ -e "${gpu}devfreq/available_frequencies" ]] && [[ "$(cat "${gpu}devfreq/available_frequencies" | awk -F ' ' '{print $NF}')" -gt "$gpu_max" ]]; then
	gpu_max=$(cat "${gpu}devfreq/available_frequencies" | awk -F ' ' '{print $NF}')

elif [[ -e "${gpu}devfreq/available_frequencies" ]] && [[ "$(cat "${gpu}devfreq/available_frequencies" | awk '{print $1}')" -gt "$gpu_max" ]]; then
	gpu_max=$(cat "${gpu}devfreq/available_frequencies" | awk '{print $1}')

elif [[ -e "${gpu}available_frequencies" ]] && [[ "$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $NF}')" -gt "$gpu_max" ]]; then
	gpu_max=$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $NF}')

elif [[ -e "${gpu}available_frequencies" ]] && [[ "$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $1}')" -gt "$gpu_max" ]]; then
	gpu_max=$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $1}')

elif [[ -e "${gpui}gpu_freq_table" ]] && [[ "$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $NF}')" -gt "$gpu_max" ]]; then
	gpu_max=$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $NF}')

elif [[ -e "${gpui}gpu_freq_table" ]] && [[ "$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $1}')" -gt "$gpu_max" ]]; then
	gpu_max=$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $1}')
fi

gpu_min="$gpu_min_freq"

if [[ -e "${gpu}available_frequencies" ]] && [[ "$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $1}')" -lt $"$gpu_min" ]]; then
	gpu_min=$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $1}')

elif [[ -e "${gpu}available_frequencies" ]] && [[ "$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $NF}')" -lt "$gpu_min" ]]; then
	gpu_min=$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $NF}')

elif [[ -e "${gpui}gpu_freq_table" ]] && [[ "$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $1}')" -lt "$gpu_min" ]]; then
	gpu_min=$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $1}')

elif [[ -e "${gpui}gpu_freq_table" ]] && [[ "$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $NF}')" -lt "$gpu_min" ]]; then
	gpu_min=$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $NF}')
fi

# CPU governor
cpu_gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

# GPU governor
if [[ -e "${gpui}gpu_governor" ]]; then
	gpu_gov=$(cat "${gpui}gpu_governor")

elif [[ -e "${gpu}governor" ]]; then
	gpu_gov=$(cat "${gpu}governor")

elif [[ -e "${gpu}devfreq/governor" ]]; then
	gpu_gov=$(cat "${gpu}devfreq/governor")
fi

# Qualcomm's power level implementation
define_gpu_pl() {
	gpu_num_pl=$(cat "${gpu}num_pwrlevels")
	gpu_min_pl=$((gpu_num_pl - 1))
	gpu_max_pl=$(cat "${gpu}max_pwrlevel")
}

# Max CPU clock
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

# Min CPU clock
cpu_min_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
cpu_min_freq2=$(cat /sys/devices/system/cpu/cpu5/cpufreq/cpuinfo_min_freq)
cpu_min_freq1=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)
cpu_min_freq1_2=$(cat /sys/devices/system/cpu/cpu5/cpufreq/scaling_min_freq)

[[ "$cpu_min_freq2" -lt "$cpu_min_freq" ]] && cpu_min_freq="$cpu_min_freq2"
[[ "$cpu_min_freq1_2" -lt "$cpu_min_freq1" ]] && cpu_min_freq1="$cpu_min_freq1_2"
[[ "$cpu_min_freq1" -lt "$cpu_min_freq" ]] && cpu_min_freq="$cpu_min_freq1"

# HZ -> MHz
cpu_min_clk_mhz=$((cpu_min_freq / 1000))
cpu_max_clk_mhz=$((cpu_max_freq / 1000))

# Max GPU frequency
if [[ -e "${gpu}max_gpuclk" ]]; then
	gpu_max_freq=$(cat "${gpu}max_gpuclk")

elif [[ -e "${gpu}max_clock" ]]; then
	gpu_max_freq=$(cat "${gpu}max_clock")

elif [[ -e "/proc/gpufreq/gpufreq_opp_dump" ]]; then
	gpu_max_freq=$(cat /proc/gpufreq/gpufreq_opp_dump | awk '{print $4}' | cut -f1 -d "," | head -1)
	mtk=true
fi

# Min GPU frequency
if [[ -e "${gpu}min_clock_mhz" ]]; then
	gpu_min_freq=$(cat "${gpu}min_clock_mhz")
	gpu_min_freq=$((gpu_min_freq * 1000000))

elif [[ -e "${gpu}min_clock" ]]; then
	gpu_min_freq=$(cat "${gpu}min_clock")

elif [[ -e "/proc/gpufreq/gpufreq_opp_dump" ]]; then
	gpu_min_freq=$(cat /proc/gpufreq/gpufreq_opp_dump | tail -1 | awk '{print $4}' | cut -f1 -d ",")
fi

# HZ → MHZ
[[ "$gpu_max_freq" -ge "100000" ]] && {
	gpu_max_clk_mhz=$((gpu_max_freq / 1000))
	gpu_min_clk_mhz=$((gpu_min_freq / 1000))
} || [[ "$gpu_max_freq" -ge "100000000" ]] && {
	gpu_max_clk_mhz=$((gpu_max_freq / 1000000))
	gpu_min_clk_mhz=$((gpu_min_freq / 1000000))
}

# SOC info
soc=$(getprop ro.soc.model)
[[ "$soc" == "" ]] && soc=$(getprop ro.chipname)
[[ "$soc" == "" ]] && soc=$(getprop ro.board.platform)
[[ "$soc" == "" ]] && soc=$(getprop ro.product.board)
[[ "$soc" == "" ]] && soc=$(getprop ro.product.platform)

# Number of CPU cores
nr_cores=$(cat /sys/devices/system/cpu/possible | awk -F "-" '{print $2}')
nr_cores=$((nr_cores + 1))

# Manufacturer
soc_mf=$(getprop ro.soc.manufacturer)
[[ "$soc_mf" == "" ]] && soc_mf=$(getprop ro.boot.hardware)

# CPU architeture
arch=$(getprop ro.product.cpu.abi | awk -F "-" '{print $1}')

# GPU model
[[ "$exynos" == "true" ]] || [[ "$mtk" == "true" ]] && gpu_mdl=$(cat "${gpu}gpuinfo" | awk '{print $1,$2,$3}')
[[ "$qcom" == "true" ]] && gpu_mdl=$(cat "${gpui}gpu_model")
[[ "$gpu_mdl" == "" ]] && gpu_mdl=$(dumpsys SurfaceFlinger 2>/dev/null | awk '/GLES/ {print $3,$4,$5}' | tr -d ,)

# Check in which SOC we are running
[[ "$(getprop ro.boot.hardware | grep qcom)" ]] || [[ "$(getprop ro.soc.manufacturer | grep QTI)" ]] || [[ "$(getprop ro.soc.manufacturer | grep Qualcomm)" ]] || [[ "$(getprop ro.hardware | grep qcom)" ]] || [[ "$(getprop ro.vendor.qti.soc_id)" ]] || [[ "$(getprop gsm.version.ril-impl | grep Qualcomm)" ]] && qcom=true
[[ "$(getprop ro.boot.hardware | grep exynos)" ]] || [[ "$(getprop ro.board.platform | grep universal)" ]] || [[ "$(getprop ro.product.board | grep universal)" ]] && exynos=true
[[ "$(getprop ro.board.platform | grep mt)" ]] || [[ "$(getprop ro.product.board | grep mt)" ]] || [[ "$(getprop ro.hardware | grep mt)" ]] || [[ "$(getprop ro.boot.hardware | grep mt)" ]] && mtk=true

# Whether CPU uses BIG.little arch or not
for i in {1..7}; do
	[[ -d "/sys/devices/system/cpu/cpufreq/policy0/" ]] && [[ -d "/sys/devices/system/cpu/cpufreq/policy${i}/" ]] && big_little=true
done

# Device info
# Codename
dvc_cdn=$(getprop ro.product.device)

# Device brand
dvc_brnd=$(getprop ro.product.brand)

# Max refresh rate
rr=$(dumpsys display 2>/dev/null | awk '/PhysicalDisplayInfo/{print $4}' | cut -c1-3 | tr -d .)
[[ -z "$rr" ]] && rr=$(dumpsys display 2>/dev/null | grep refreshRate | awk -F '=' '{print $6}' | cut -c1-3 | tail -n 1 | tr -d .) || rr=$(dumpsys display 2>/dev/null | grep FrameRate | awk -F '=' '{print $6}' | cut -c1-3 | tail -n 1 | tr -d .)

# Kernel info
kern_ver_name=$(uname -r)
kern_bd_dt=$(uname -v | awk '{print $5, $6, $7, $8, $9, $10}')

[[ "$(command -v busybox)" ]] && {
	total_ram=$(busybox free -m | awk '/Mem:/{print $2}')
	total_ram_kb=$(cat /proc/meminfo | awk '/kB/{print $2}' | grep [0-9] | head -1)
	avail_ram=$(busybox free -m | awk '/Mem:/{print $7}')
} || {
	total_ram="Please install busybox first"
	total_ram_kb="Please install busybox first"
	avail_ram="Please install busybox first"
}

# CPU scheduling model
for cpu in $(cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_available_governors); do
	case "$cpu" in
		*sched*) cpu_sched="EAS" ;;
		*util*) cpu_sched="EAS" ;;
		*interactive*) cpu_sched="HMP" ;;
		*) cpu_sched="Unknown" ;;
	esac
done

# KTSR build info
bd_ver=$(grep version= "${modpath}module.prop" | sed "s/version=//" | awk -F "-" '{print $1}')
bd_rel=$(grep version= "${modpath}module.prop" | sed "s/version=//" | awk -F "-" '{print $2}')
bd_dt=$(grep build_date= "${modpath}module.prop" | sed "s/build_date=//")
bd_cdn=$(grep version= "${modpath}module.prop" | sed "s/version=//" | awk -F "-" '{print $3}')

# Battery info
# Current battery capacity available
[[ -e "/sys/class/power_supply/battery/capacity" ]] && batt_pctg=$(cat /sys/class/power_supply/battery/capacity) || batt_pctg=$(dumpsys battery 2>/dev/null | awk '/level/{print $2}')

batt_tmp=$(dumpsys battery 2>/dev/null | awk '/temperature/{print $2}')
[[ "$batt_tmp" == "" ]] && [[ -e "/sys/class/power_supply/battery/temp" ]] && batt_tmp=$(cat /sys/class/power_supply/battery/temp) || [[ "$batt_tmp" == "" ]] && [[ -e "/sys/class/power_supply/battery/batt_temp" ]] && batt_tmp=$(cat /sys/class/power_supply/battery/batt_temp)

# Transform this since we need two algarisms only
batt_tmp=$((batt_tmp / 10))

# Battery health
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

# Battery status
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

# Battery total capacity
batt_cpct=$(cat /sys/class/power_supply/battery/charge_full_design)
[[ "$batt_cpct" == "" ]] && batt_cpct=$(dumpsys batterystats 2>/dev/null | awk '/Capacity:/{print $2}' | cut -d "," -f 1)

# MA → MAh
[[ "$batt_cpct" -ge "1000000" ]] && batt_cpct=$((batt_cpct / 1000))

# Busybox version
[[ "$(command -v busybox)" ]] && bb_ver=$(busybox | awk 'NR==1{print $2}') || bb_ver="Please install busybox first"

# ROM info
# Fingerprint, keys and related stuff
rom_info=$(getprop ro.build.description | awk '{print $1,$3,$4,$5}')
[[ "$rom_info" == "" ]] && rom_info=$(getprop ro.bootimage.build.description | awk '{print $1,$3,$4,$5}')
[[ "$rom_info" == "" ]] && rom_info=$(getprop ro.system.build.description | awk '{print $1,$3,$4,$5}')

# Android SDK
sdk=$(getprop ro.build.version.sdk)
[[ "$sdk" == "" ]] && sdk=$(getprop ro.vendor.build.version.sdk)
[[ "$sdk" == "" ]] && sdk=$(getprop ro.vndk.version)

# ARV (Android release version)
arv=$(getprop ro.build.version.release)

# Root method
root=$(su -v)

# SELinux policy
[[ "$(cat /sys/fs/selinux/enforce)" == "1" ]] && slnx_stt="Enforcing" || slnx_stt="Permissive"

# Check if we're running on OneUI
[[ "$(getprop net.knoxscep.version)" ]] || [[ "$(getprop ril.product_code)" ]] || [[ "$(getprop ro.boot.em.model)" ]] || [[ "$(getprop net.knoxvpn.version)" ]] || [[ "$(getprop ro.securestorage.knox)" ]] || [[ "$(getprop gsm.version.ril-impl | grep Samsung)" ]] || [[ "$(getprop ro.build.PDA)" ]] && {
	one_ui=true
	samsung=true
}

# Amount of time that system has been running
sys_uptime=$(uptime | awk '{print $3,$4}' | cut -d "," -f 1)

[[ "$(command -v sqlite3)" ]] && {
	sql_ver=$(sqlite3 -version | awk '{print $1}')
	sql_bd_dt=$(sqlite3 -version | awk '{print $2,$3}')
} || {
	sql_ver="Please install SQLite3 first"
	sql_bd_dt="Please install SQLite3 first"
}

[[ -d "/proc/ppm/" ]] && [[ "$mtk" == "true" ]] && ppm=true

# Check if we're running on MIUI
[[ "$(getprop ro.miui.ui.version.name)" ]] && miui=true

enable_devfreq_boost() {
	for dir in /sys/class/devfreq/*/; do
		max_devfreq=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $NF}')
		max_devfreq2=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $1}')
		[[ "$max_devfreq2" -gt "$max_devfreq" ]] && max_devfreq="$max_devfreq2"
		write "${dir}min_freq" "$max_devfreq"
	done
	for i in DDR LLCC L3; do
		write "/sys/devices/system/cpu/bus_dcvs/$i/*/max_freq" "9999000000"
	done
	log_i "Enabled devfreq boost"
}

disable_devfreq_boost() {
	for dir in /sys/class/devfreq/*/; do
		min_devfreq=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $1}')
		min_devfreq2=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $NF}')
		[[ "$min_devfreq2" -lt "$min_devfreq" ]] && min_devfreq="$min_devfreq2"
		write "${dir}min_freq" "$min_devfreq"
	done
	log_i "Disabled devfreq boost"
}

dram_max() {
	for i in /sys/devices/platform/*.dvfsrc/helio-dvfsrc/; do
		write "/sys/devices/platform/boot_dramboost/dramboost/dramboost" "1"
		ddr_opp=$(cat "${i}dvfsrc_opp_table" | head -1)
		write "${i}dvfsrc_force_vcore_dvfs_opp" "${ddr_opp:4:2}"
	done
	log_i "Enabled DRAM boost"
}

dram_default() {
	for i in /sys/devices/platform/*.dvfsrc/helio-dvfsrc/; do
		write "/sys/devices/platform/boot_dramboost/dramboost/dramboost" "0"
		write "${i}dvfsrc_force_vcore_dvfs_opp" "-1"
	done
	log_i "Disabled DRAM boost"
}

# Set thermal policy to step_wise as a attempt of reducing thermal throttling
set_therm_pol() {
	[[ -d "$therm" ]] && {
		write "${therm}xo-therm-adc/policy" "step_wise"
		write "${therm}skin-therm-adc/policy" "step_wise"
		write "${therm}camera-ftherm-adc/policy" "step_wise"
		write "${therm}camera-flash-therm-adc/policy" "step_wise"
		write "${therm}rf-pa0-therm-adc/policy" "step_wise"
		write "${therm}rf-pa1-therm-adc/policy" "step_wise"
		write "${therm}modem0-pa0-usr/policy" "step_wise"
		write "${therm}modem0-pa1-usr/policy" "step_wise"
		write "${therm}modem1-pa0-usr/policy" "step_wise"
		write "${therm}modem1-pa1-usr/policy" "step_wise"
		write "${therm}modem1-pa2-usr/policy" "step_wise"
		write "${therm}modem1-qfe-wtr-usr/policy" "step_wise"
		write "${therm}modem1-modem-usr/policy" "step_wise"
		write "${therm}modem1-mmw0-usr/policy" "step_wise"
		write "${therm}modem1-mmw1-usr/policy" "step_wise"
		write "${therm}modem1-mmw2-usr/policy" "step_wise"
		write "${therm}modem1-mmw3-usr/policy" "step_wise"
		write "${therm}modem1-skin-usr/policy" "step_wise"
		write "${therm}modem1-pa-mdm-usr/policy" "step_wise"
		write "${therm}modem1-pa-wtr-usr/policy" "step_wise"
		write "${therm}aoss0-usr/policy" "step_wise"
		write "${therm}cpu-0-0-usr/policy" "step_wise"
		write "${therm}cpu-0-1-usr/policy" "step_wise"
		write "${therm}cpu-0-2-usr/policy" "step_wise"
		write "${therm}cpu-0-3-usr/policy" "step_wise"
		write "${therm}cpu-1-0-usr/policy" "step_wise"
		write "${therm}cpu-1-1-usr/policy" "step_wise"
		write "${therm}cpu-1-2-usr/policy" "step_wise"
		write "${therm}cpu-1-3-usr/policy" "step_wise"
		write "${therm}gpu-usr/policy" "step_wise"
		write "${therm}cpuss-0-usr/policy" "step_wise"
		write "${therm}cpuss-1-usr/policy" "step_wise"
		write "${therm}cpuss-2-usr/policy" "step_wise"
		write "${therm}lmh-dcvs-00/policy" "step_wise"
		write "${therm}lmh-dcvs-01/policy" "step_wise"
		write "${therm}quiet-therm-adc/policy" "step_wise"
		write "${therm}emmc-ufs-therm-adc" "step_wise"
		write "${therm}quiet-therm-adc/policy" "step_wise"
		write "${therm}sdm-therm-adc/policy" "step_wise"
		write "${therm}charger-skin-therm-adc/policy" "step_wise"
		write "${therm}conn-therm-adc/policy" "step_wise"
		log_i "Tweaked thermal policies"
	}
}

get_ka_pid() {
	[[ "$(pgrep -f kingauto)" != "" ]] && echo "$(pgrep -f kingauto)" || echo "[Service not running]"
}

print_info() {
	echo "General info

		** Date of execution: $(date)
		** Kernel: $kern_ver_name, $kern_bd_dt
		** SOC: $soc_mf, $soc
		** SDK: $sdk
		** Android version: $avs
		** Android ID: $(settings get secure android_id)
		** CPU governor: $cpu_gov
		** Number of CPUs: $nr_cores
		** CPU freq: $cpu_min_clk_mhz-${cpu_max_clk_mhz}MHz
		** CPU scheduling type: $cpu_sched
		** Arch: $arch
		** GPU freq: $gpu_min_clk_mhz-${gpu_max_clk_mhz}MHz
		** GPU model: $gpu_mdl
		** GPU governor: $gpu_gov
		** Device: $dvc_brnd, $dvc_cdn
		** ROM: $rom_info
		** Screen resolution: $(wm size | awk '{print $3}' | tail -n 1)
		** Screen density: $(wm density | awk '{print $3}' | tail -n 1) PPI
		** Supported refresh rate: ${rr}HZ
		** KTSR build version: $bd_ver
		** KTSR build codename: $bd_cdn
		** KTSR build release: $bd_rel
		** KTSR build date: $bd_dt
		** KTSR lib version: $lib_ver
		** Battery charge level: $batt_pctg%
		** Battery total capacity: ${batt_cpct}mAh
		** Battery health: $batt_hth
		** Battery status: $batt_sts
		** Battery temperature: $batt_tmp°C
		** Device RAM: ${total_ram}MB
		** Device available RAM: ${avail_ram}MB
		** Root: $root
		** SQLite version: $sql_ver
		** SQLite build date: $sql_bd_dt
		** System uptime: $sys_uptime
		** SELinux: $slnx_stt
		** Busybox: $bb_ver
		** Current KTSR PID: $$
		** Current automatic PID: $(get_ka_pid)
	
		** Author: Pedro | https://t.me/pedro3z0 | https://github.com/pedrozzz0
		** Telegram channel: https://t.me/kingprojectz
		** Telegram group: https://t.me/kingprojectzdiscussion
		** Thanks to all people involved to make this project possible
"
}

# Stop perf and other userspace processes from tinkering with kernel parameters
stop_services() {
	for v in 0 1 2 3 4; do
		kill_svc vendor.qti.hardware.perf@"$v"."$v"-service
		kill_svc vendor.oneplus.hardware.brain@"$v"."$v"-service
	done
	kill_svc perfd
	kill_svc mpdecision
	kill_svc perfservice
	kill_svc vendor.perfservice
	kill_svc cnss_diag
	kill_svc vendor.cnss_diag
	kill_svc tcpdump
	kill_svc vendor.tcpdump
	kill_svc ipacm-diag
	kill_svc vendor.ipacm-diag
	kill_svc charge_logger
	kill_svc oneplus_brain_service
	kill_svc statsd
	[[ "$miui" == "false" ]] && kill_svc mlid
	[[ "$ktsr_prof_en" == "extreme" ]] || [[ "$ktsr_prof_en" == "gaming" ]] || [[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]] && {
		kill_svc thermal
		kill_svc thermald
		kill_svc thermalservice
		kill_svc mi_thermald
		kill_svc thermal-engine
		kill_svc vendor.thermal-engine
		kill_svc thermanager
		kill_svc thermal_manager
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
	log_i "Disabled few debug services and userspace daemons that may conflict with KTSR"
}

disable_core_ctl() {
	for core_ctl in /sys/devices/system/cpu/cpu*/core_ctl/; do
		[[ -e "${core_ctl}enable" ]] && write "${core_ctl}enable" "0"
		[[ -e "${core_ctl}disable" ]] && write "${core_ctl}disable" "1"
	done

	[[ -d "/sys/power/cpuhotplug/" ]] && write "/sys/power/cpuhotplug/enable" "0" || [[ -d "/sys/power/cpuhotplug/" ]] && write "/sys/power/cpuhotplug/enabled" "0"
	[[ -d "/sys/devices/system/cpu/cpuhotplug/" ]] && write "/sys/devices/system/cpu/cpuhotplug/enabled" "0"
	[[ -d "/sys/kernel/intelli_plug/" ]] && write "/sys/kernel/intelli_plug/intelli_plug_active" "0"
	[[ -d "/sys/module/blu_plug/" ]] && write "/sys/module/blu_plug/parameters/enabled" "0"
	[[ -d "/sys/devices/virtual/misc/mako_hotplug_control/" ]] && write "/sys/devices/virtual/misc/mako_hotplug_control/enabled" "0"
	[[ -d "/sys/module/autosmp/" ]] && write "/sys/module/autosmp/parameters/enabled" "0"
	[[ -d "/sys/kernel/zen_decision/" ]] && write "/sys/kernel/zen_decision/enabled" "0"
	[[ -d "/proc/hps/" ]] && write "/proc/hps/enabled" "0"
	[[ -d "/sys/module/scheduler/" ]] && write "/sys/module/scheduler/holders/mtk_core_ctl/parameters/policy_enable" "0"
	[[ -d "/sys/module/thermal_interface/" ]] && write "/sys/module/thermal_interface/holders/mtk_core_ctl/parameters/policy_enable" "0"
	[[ -d "/sys/module/mtk_core_ctl/" ]] && write "/sys/module/mtk_core_ctl/policy_enable" "0"
	[[ -d "/sys/module/cpufreq_sugov_ext/" ]] && write "/sys/module/cpufreq_sugov_ext/holders/mtk_core_ctl/parameters/policy_enable" "0"
	[[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]] && write "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
	[[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]] && write "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
	log_i "Disabled core control & CPU hotplug"
}

enable_core_ctl() {
	for i in 4 6 7; do
		for core_ctl in /sys/devices/system/cpu/cpu$i/core_ctl/; do
			[[ -e "${core_ctl}enable" ]] && write "${core_ctl}enable" "1"
			[[ -e "${core_ctl}disable" ]] && write "${core_ctl}disable" "0"
		done
	done

	[[ -d "/sys/power/cpuhotplug/" ]] && write "/sys/power/cpuhotplug/enable" "1" || [[ -d "/sys/power/cpuhotplug/" ]] && write "/sys/power/cpuhotplug/enabled" "1"
	[[ -d "/sys/devices/system/cpu/cpuhotplug/" ]] && write "/sys/devices/system/cpu/cpuhotplug/enabled" "1"
	[[ -d "/sys/kernel/intelli_plug/" ]] && write "/sys/kernel/intelli_plug/intelli_plug_active" "1"
	[[ -d "/sys/module/blu_plug/" ]] && write "/sys/module/blu_plug/parameters/enabled" "1"
	[[ -d "/sys/devices/virtual/misc/mako_hotplug_control/" ]] && write "/sys/devices/virtual/misc/mako_hotplug_control/enabled" "1"
	[[ -d "/sys/module/autosmp/" ]] && write "/sys/module/autosmp/parameters/enabled" "1"
	[[ -d "/sys/kernel/zen_decision/" ]] && write "/sys/kernel/zen_decision/enabled" "1"
	[[ -d "/proc/hps/" ]] && write "/proc/hps/enabled" "1"
	[[ -d "/sys/module/scheduler/" ]] && write "/sys/module/scheduler/holders/mtk_core_ctl/parameters/policy_enable" "1"
	[[ -d "/sys/module/thermal_interface/" ]] && write "/sys/module/thermal_interface/holders/mtk_core_ctl/parameters/policy_enable" "1"
	[[ -d "/sys/module/mtk_core_ctl/" ]] && write "/sys/module/mtk_core_ctl/policy_enable" "1"
	[[ -d "/sys/module/cpufreq_sugov_ext/" ]] && write "/sys/module/cpufreq_sugov_ext/holders/mtk_core_ctl/parameters/policy_enable" "1"
	[[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]] && write "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "1"
	[[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]] && write "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "0"
	log_i "Enabled core control & CPU hotplug"
}

boost_latency() {
	[[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]] && {
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "15"
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "700"
		log_i "Tweaked dynamic stune boost"
	}

	[[ -d "/sys/module/cpu_boost/" ]] && {
		write "/sys/module/cpu_boost/parameters/input_boost_ms" "128"
		write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "0"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_powerkey_input" "0"
		write "/sys/module/cpu_boost/parameters/powerkey_input_boost_ms" "500"
		log_i "Tweaked CAF CPU input boost"
	} || [[ -d "/sys/module/cpu_input_boost/" ]] && {
		write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "128"
		log_i "Tweaked CPU input boost"
	}
}

boost_balanced() {
	[[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]] && {
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "10"
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "700"
		log_i "Tweaked dynamic stune boost"
	}

	[[ -d "/sys/module/cpu_boost/" ]] && {
		write "/sys/module/cpu_boost/parameters/input_boost_ms" "88"
		write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "0"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_powerkey_input" "1"
		write "/sys/module/cpu_boost/parameters/powerkey_input_boost_ms" "500"
		log_i "Tweaked CAF CPU input boost"
	} || [[ -d "/sys/module/cpu_input_boost/" ]] && {
		write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "88"
		log_i "Tweaked CPU input boost"
	}
}

boost_extreme() {
	[[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]] && {
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "50"
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "700"
		log_i "Tweaked dynamic stune boost"
	}

	[[ -d "/sys/module/cpu_boost/" ]] && {
		write "/sys/module/cpu_boost/parameters/input_boost_ms" "156"
		write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "0"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_powerkey_input" "0"
		write "/sys/module/cpu_boost/parameters/powerkey_input_boost_ms" "500"
		log_i "Tweaked CAF CPU input boost"
	} || [[ -d "/sys/module/cpu_input_boost/" ]] && {
		write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "156"
		log_i "Tweaked CPU input boost"
	}
}

boost_battery() {
	[[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]] && {
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "1"
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "500"
		log_i "Tweaked dynamic stune boost"
	}

	[[ -d "/sys/module/cpu_boost/" ]] && {
		write "/sys/module/cpu_boost/parameters/input_boost_ms" "64"
		write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "0"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_powerkey_input" "0"
		write "/sys/module/cpu_boost/parameters/powerkey_input_boost_ms" "500"
		log_i "Tweaked CAF CPU input boost"
	} || [[ -d "/sys/module/cpu_input_boost/" ]] && {
		write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "64"
		log_i "Tweaked CPU input boost"
	}
}

boost_gaming() {
	[[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]] && {
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "50"
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "700"
		log_i "Tweaked dynamic stune boost"
	}

	[[ -d "/sys/module/cpu_boost/" ]] && {
		write "/sys/module/cpu_boost/parameters/input_boost_ms" "156"
		write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "0"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_powerkey_input" "0"
		write "/sys/module/cpu_boost/parameters/powerkey_input_boost_ms" "500"
		log_i "Tweaked CAF CPU input boost"
	} || [[ -d "/sys/module/cpu_input_boost/" ]] && {
		write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "156"
		log_i "Tweaked CPU input boost"

	}
}

io_latency() {
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
		write "${queue}read_ahead_kb" "32"
		write "${queue}nomerges" "0"
		write "${queue}rq_affinity" "2"
		write "${queue}nr_requests" "16"
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

	log_i "Tweaked I/O scheduler"
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

	log_i "Tweaked I/O scheduler"
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

	log_i "Tweaked I/O scheduler"
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

	log_i "Tweaked I/O scheduler"
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

	log_i "Tweaked I/O scheduler"
}

cpu_latency() {
	for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
		# Available governors from the CPU
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

	# Apply governor specific tunables for available governors
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
		write "$governor/hispeed_load" "75"
		write "$governor/hispeed_freq" "$cpu_max_freq"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d); do
		write "$governor/up_rate_limit_us" "0"
		write "$governor/down_rate_limit_us" "0"
		write "$governor/pl" "1"
		write "$governor/iowait_boost_enable" "0"
		write "$governor/rate_limit_us" "0"
		write "$governor/hispeed_load" "75"
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
		write "$governor/go_hispeed_load" "75"
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
		write "$governor/hispeed_load" "75"
		write "$governor/hispeed_freq" "$cpu_max_freq"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d); do
		write "$governor/up_rate_limit_us" "0"
		write "$governor/down_rate_limit_us" "0"
		write "$governor/pl" "1"
		write "$governor/iowait_boost_enable" "0"
		write "$governor/rate_limit_us" "0"
		write "$governor/hispeed_load" "75"
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
		write "$governor/go_hispeed_load" "75"
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
	for i in {0..7}; do
		write "/sys/devices/system/cpu/cpu$i/online" "1"
	done
}

enable_ppm() {
	[[ "$ppm" == "true" ]] && write "/proc/ppm/enabled" "1"
	log_i "Tweaked CPU parameters"
}

disable_ppm() {
	[[ "$ppm" == "true" ]] && write "/proc/ppm/enabled" "0"
	log_i "Tweaked CPU parameters"
}

hmp_balanced() {
	[[ -d "/sys/kernel/hmp/" ]] && {
		write "/sys/kernel/hmp/boost" "0"
		write "/sys/kernel/hmp/down_compensation_enabled" "1"
		write "/sys/kernel/hmp/family_boost" "0"
		write "/sys/kernel/hmp/semiboost" "0"
		write "/sys/kernel/hmp/up_threshold" "524"
		write "/sys/kernel/hmp/down_threshold" "214"
		log_i "Tweaked HMP parameters"
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
		log_i "Tweaked HMP parameters"
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
		log_i "Tweaked HMP parameters"
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
		log_i "Tweaked HMP parameters"
	}
}

gpu_latency() {
	if [[ "$qcom" == "true" ]]; then
		# Acailable governors from the GPU
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
		write "/sys/module/ged/parameters/enable_cpu_boost" "1"
		write "/sys/module/ged/parameters/enable_gpu_boost" "1"
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
		write "/sys/module/ged/parameters/gpu_cust_boost_freq" "0"
	}

	[[ -d "/sys/kernel/gbe/" ]] && {
		write "/sys/kernel/gbe/gbe_enable1" "1"
		write "/sys/kernel/gbe/gbe_enable2" "1"
		write "/sys/kernel/gbe/gbe2_max_boost_cnt" "2"
		write "/sys/kernel/gbe/gbe2_loading_th" "20"
	}

	[[ -d "/proc/gpufreq/" ]] && {
		write "/proc/gpufreq/gpufreq_opp_stress_test" "0"
		write "/proc/gpufreq/gpufreq_input_boost" "0"
		write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_oc_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "0"
	}

	[[ -d "/sys/kernel/ged/" ]] && {
		write "/sys/kernel/ged/hal/timer_base_dvfs_margin" "25"
		write "/sys/kernel/ged/hal/dvfs_margin_value" "25"
		write "/sys/kernel/ged/hal/dcs_mode" "0"
	}

	[[ -d "/proc/mali/" ]] && {
		write "/proc/mali/dvfs_enable" "1"
		write "/proc/mali/always_on" "1"
	}

	[[ -d "/sys/module/pvrsrvkm/" ]] && write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"

	[[ -d "/sys/module/simple_gpu_algorithm/parameters/" ]] && {
		write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "1"
		write "/sys/module/simple_gpu_algorithm/parameters/default_laziness" "2"
		write "/sys/module/simple_gpu_algorithm/parameters/ramp_up_threshold" "2500"
		log_i "Enabled and tweaked SGPU algorithm"
	}

	[[ -d "/sys/module/adreno_idler/" ]] && {
		write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
		log_i "Disabled adreno idler"
	}
	log_i "Tweaked GPU parameters"
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
		write "/sys/module/ged/parameters/gpu_cust_boost_freq" "0"
	}

	[[ -d "/sys/kernel/gbe/" ]] && {
		write "/sys/kernel/gbe/gbe_enable1" "0"
		write "/sys/kernel/gbe/gbe_enable2" "0"
		write "/sys/kernel/gbe/gbe2_max_boost_cnt" "5"
	}

	[[ -d "/proc/gpufreq/" ]] && {
		write "/proc/gpufreq/gpufreq_opp_stress_test" "0"
		write "/proc/gpufreq/gpufreq_opp_freq" "0"
		write "/proc/gpufreq/gpufreq_input_boost" "0"
		write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_oc_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "0"
	}

	[[ -d "/sys/kernel/ged/" ]] && {
		write "/sys/kernel/ged/hal/timer_base_dvfs_margin" "20"
		write "/sys/kernel/ged/hal/dvfs_margin_value" "20"
		write "/sys/kernel/ged/hal/dcs_mode" "0"
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
		log_i "Enabled and tweaked SGPU algorithm"
	}

	[[ -d "/sys/module/adreno_idler" ]] && {
		write "/sys/module/adreno_idler/parameters/adreno_idler_active" "Y"
		write "/sys/module/adreno_idler/parameters/adreno_idler_idleworkload" "5000"
		write "/sys/module/adreno_idler/parameters/adreno_idler_downdifferential" "35"
		write "/sys/module/adreno_idler/parameters/adreno_idler_idlewait" "25"
		log_i "Enabled and tweaked adreno idler"
	}
	log_i "Tweaked GPU parameters"
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
		write "/sys/module/ged/parameters/enable_cpu_boost" "1"
		write "/sys/module/ged/parameters/enable_gpu_boost" "1"
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
		write "/sys/module/ged/parameters/gpu_cust_boost_freq" "0"
	}

	[[ -d "/sys/kernel/gbe/" ]] && {
		write "/sys/kernel/gbe/gbe_enable1" "1"
		write "/sys/kernel/gbe/gbe_enable2" "1"
		write "/sys/kernel/gbe/gbe2_max_boost_cnt" "2"
		write "/sys/kernel/gbe/gbe2_loading_th" "20"
	}

	[[ -d "/proc/gpufreq/" ]] && {
		write "/proc/gpufreq/gpufreq_opp_stress_test" "1"
		write "/proc/gpufreq/gpufreq_opp_freq" "0"
		write "/proc/gpufreq/gpufreq_input_boost" "0"
		write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "1"
		write "/proc/gpufreq/gpufreq_limited_oc_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "1"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "1"
	}

	[[ -d "/sys/kernel/ged/" ]] && {
		write "/sys/kernel/ged/hal/timer_base_dvfs_margin" "30"
		write "/sys/kernel/ged/hal/dvfs_margin_value" "30"
		write "/sys/kernel/ged/hal/dcs_mode" "0"
	}

	[[ -d "/proc/mali/" ]] && {
		write "/proc/mali/dvfs_enable" "1"
		write "/proc/mali/always_on" "1"
	}

	[[ -d "/sys/module/pvrsrvkm/" ]] && write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"

	[[ -d "/sys/module/simple_gpu_algorithm/" ]] && {
		write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "0"
		log_i "Disabled SGPU algorithm"
	}

	[[ -d "/sys/module/adreno_idler/" ]] && {
		write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
		log_i "Disabled adreno idler"
	}
	log_i "Tweaked GPU parameters"
}

gpu_battery() {
	if [[ "$qcom" == "true" ]]; then
		avail_govs="$(cat "${gpu}devfreq/available_governors")"

		for governor in simple_ondemand msm-adreno-tz ondemand; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${gpu}devfreq/governor" "$governor"
				break
			fi
		done

	elif [[ "$exynos" == "true" ]]; then
		avail_govs="$(cat "${gpui}gpu_available_governor")"

		for governor in mali_ondemand Interactive ondemand Dynamic Static; do
			if [[ "$avail_govs" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "$governor"
				break
			fi
		done

	elif [[ "$mtk" == "true" ]]; then
		avail_govs="$(cat "${gpu}available_governors")"

		for governor in mali_ondemand Interactive ondemand Dynamic Static; do
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
		write "/sys/module/ged/parameters/gpu_cust_boost_freq" "0"
	}

	[[ -d "/sys/kernel/gbe/" ]] && {
		write "/sys/kernel/gbe/gbe_enable1" "0"
		write "/sys/kernel/gbe/gbe_enable2" "0"
		write "/sys/kernel/gbe/gbe2_max_boost_cnt" "5"
	}

	[[ -d "/proc/gpufreq/" ]] && {
		write "/proc/gpufreq/gpufreq_opp_stress_test" "0"
		write "/proc/gpufreq/gpufreq_opp_freq" "0"
		write "/proc/gpufreq/gpufreq_input_boost" "0"
		write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_oc_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "0"
	}

	[[ -d "/sys/kernel/ged/" ]] && {
		write "/sys/kernel/ged/hal/timer_base_dvfs_margin" "15"
		write "/sys/kernel/ged/hal/dvfs_margin_value" "15"
		write "/sys/kernel/ged/hal/dcs_mode" "0"
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
		log_i "Enabled and tweaked SGPU algorithm"
	}

	[[ -d "/sys/module/adreno_idler/" ]] && {
		write "/sys/module/adreno_idler/parameters/adreno_idler_active" "Y"
		write "/sys/module/adreno_idler/parameters/adreno_idler_idleworkload" "10000"
		write "/sys/module/adreno_idler/parameters/adreno_idler_downdifferential" "45"
		write "/sys/module/adreno_idler/parameters/adreno_idler_idlewait" "15"
		log_i "Enabled and tweaked adreno idler algorithm"
	}
	log_i "Tweaked GPU parameters"
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
		write "/sys/module/ged/parameters/enable_gpu_boost" "1"
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
		write "/sys/module/ged/parameters/gpu_cust_boost_freq" "0"
	}

	[[ -d "/sys/kernel/gbe/" ]] && {
		write "/sys/kernel/gbe/gbe_enable1" "1"
		write "/sys/kernel/gbe/gbe_enable2" "1"
		write "/sys/kernel/gbe/gbe2_max_boost_cnt" "2"
		write "/sys/kernel/gbe/gbe2_loading_th" "20"
	}

	[[ -d "/proc/gpufreq/" ]] && {
		write "/proc/gpufreq/gpufreq_opp_stress_test" "1"
		write "/proc/gpufreq/gpufreq_opp_freq" "$gpu_max"
		write "/proc/gpufreq/gpufreq_input_boost" "0"
		write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "1"
		write "/proc/gpufreq/gpufreq_limited_oc_ignore" "1"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "1"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "1"
	}

	[[ -d "/sys/kernel/ged/" ]] && {
		write "/sys/kernel/ged/hal/timer_base_dvfs_margin" "130"
		write "/sys/kernel/ged/hal/dvfs_margin_value" "130"
		write "/sys/kernel/ged/hal/dcs_mode" "0"
	}

	[[ -d "/proc/mali/" ]] && {
		write "/proc/mali/dvfs_enable" "0"
		write "/proc/mali/always_on" "1"
	}

	[[ -d "/sys/module/pvrsrvkm/" ]] && write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"

	[[ -d "/sys/module/simple_gpu_algorithm/" ]] && {
		write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "0"
		log_i "Disabled SGPU algorithm"
	}

	[[ -d "/sys/module/adreno_idler/" ]] && {
		write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
		log_i "Disabled adreno idler"
	}
	log_i "Tweaked GPU parameters"
}

disable_crypto_tests() {
	[[ -d "/sys/module/cryptomgr/" ]] && {
		write "/sys/module/cryptomgr/parameters/notests" "Y"
		log_i "Disabled forced cryptography tests"
	}
}

disable_spd_freqs() {
	[[ -d "/sys/module/exynos_acme/" ]] && {
		write "/sys/module/exynos_acme/parameters/enable_suspend_freqs" "N"
		log_i "Disabled suspend frequencies"
	}
}

config_pwr_spd() {
	[[ -d "/sys/kernel/power_suspend/" ]] && {
		write "/sys/kernel/power_suspend/power_suspend_mode" "3"
		log_i "Tweaked power suspend mode"
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
		log_i "Tweaked schedtune settings"
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
		write "${stune}top-app/schedtune.boost" "5"
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
		log_i "Tweaked schedtune settings"
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
		write "${stune}foreground/schedtune.boost" "50"
		write "${stune}foreground/schedtune.colocate" "0"
		write "${stune}foreground/schedtune.prefer_idle" "1"
		write "${stune}foreground/schedtune.sched_boost" "0"
		write "${stune}foreground/schedtune.sched_boost_no_override" "1"
		write "${stune}foreground/schedtune.prefer_perf" "0"
		write "${stune}foreground/schedtune.util_est_en" "0"
		write "${stune}foreground/schedtune.ontime_en" "0"
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
		write "${stune}top-app/schedtune.boost" "50"
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
		log_i "Tweaked schedtune settings"
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
		write "${stune}top-app/schedtune.boost" "1"
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
		log_i "Tweaked schedtune settings"
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
		write "${stune}top-app/schedtune.prefer_perf" "1"
		write "${stune}top-app/schedtune.util_est_en" "1"
		write "${stune}top-app/schedtune.ontime_en" "1"
		write "${stune}top-app/schedtune.prefer_high_cap" "1"
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
		log_i "Tweaked schedtune settings"
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
		log_i "Tweaked Uclamp parameters"
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
		log_i "Tweaked Uclamp parameters"
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
		log_i "Tweaked Uclamp parameters"
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
		log_i "Tweaked Uclamp parameters"
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
		log_i "Tweaked Uclamp parameters"
	}
}

# Raise inotify limit, disable the notification of files changes
config_fs() {
	[[ -d "$fs" ]] && {
		write "${fs}dir-notify-enable" "0"
		write "${fs}lease-break-time" "15"
		write "${fs}leases-enable" "1"
		write "${fs}file-max" "2097152"
		write "${fs}inotify/max_queued_events" "131072"
		write "${fs}inotify/max_user_watches" "131072"
		write "${fs}inotify/max_user_instances" "1024"
		log_i "Tweaked FS"
	}
}

config_dyn_fsync() {
	[[ -d "/sys/kernel/dyn_fsync/" ]] && {
		write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
		log_i "Enabled dynamic fsync"
	}
}

sched_ft_latency() {
	[[ -e "/sys/kernel/debug/sched_features" ]] && {
		write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
		write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
		write "/sys/kernel/debug/sched_features" "ENERGY_AWARE"
		log_i "Tweaked scheduler features"
	}
}

sched_ft_balanced() {
	[[ -e "/sys/kernel/debug/sched_features" ]] && {
		write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
		write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
		write "/sys/kernel/debug/sched_features" "ENERGY_AWARE"
		log_i "Tweaked scheduler features"
	}
}

sched_ft_extreme() {
	[[ -e "/sys/kernel/debug/sched_features" ]] && {
		write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
		write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
		write "/sys/kernel/debug/sched_features" "NO_ENERGY_AWARE"
		log_i "Tweaked scheduler features"
	}
}

sched_ft_battery() {
	[[ -e "/sys/kernel/debug/sched_features" ]] && {
		write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
		write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
		write "/sys/kernel/debug/sched_features" "ENERGY_AWARE"
		log_i "Tweaked scheduler features"
	}
}

sched_ft_gaming() {
	[[ -e "/sys/kernel/debug/sched_features" ]] && {
		write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
		write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
		write "/sys/kernel/debug/sched_features" "NO_ENERGY_AWARE"
		log_i "Tweaked scheduler features"
	}
}

disable_crc() {
	[[ -d "/sys/module/mmc_core/" ]] && {
		write "/sys/module/mmc_core/parameters/use_spi_crc" "N"
		write "/sys/module/mmc_core/parameters/removable" "N"
		write "/sys/module/mmc_core/parameters/crc" "N"
		log_i "Disabled CRC"
	}
}

sched_latency() {
	[[ -e "${kernel}sched_child_runs_first" ]] && write "${kernel}sched_child_runs_first" "0"
	[[ -e "${kernel}perf_cpu_time_max_percent" ]] && write "${kernel}perf_cpu_time_max_percent" "15"
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
	write "${kernel}printk_devlog_i" "off"
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
	[[ -e "${kernel}sched_conservative_pl" ]] && write "${kernel}sched_conservative_pl" "0"
	[[ -e "/sys/devices/system/cpu/sched/sched_boost" ]] && write "/sys/devices/system/cpu/sched/sched_boost" "0"
	[[ -e "/sys/kernel/ems/eff_mode" ]] && write "/sys/kernel/ems/eff_mode" "0"
	[[ -e "/sys/module/opchain/parameters/chain_on" ]] && write "/sys/module/opchain/parameters/chain_on" "0"
	[[ -e "${kernel}sched_initial_task_util" ]] && write "${kernel}sched_initial_task_util" "0"
	[[ -d "/sys/module/memplus_core/" ]] && write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
	write "/sys/kernel/debug/debug_enabled" "0"
	write "/sys/kernel/rcu_expedited" "0"
	write "/sys/kernel/rcu_normal" "1"
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
	write "${kernel}sched_force_lb_enable" "0"
	write "/sys/power/pm_freeze_timeout" "1000"
	log_i "Tweaked various kernel parameters to a better overall performance"
}

sched_balanced() {
	[[ -e "${kernel}sched_child_runs_first" ]] && write "${kernel}sched_child_runs_first" "0"
	[[ -e "${kernel}perf_cpu_time_max_percent" ]] && write "${kernel}perf_cpu_time_max_percent" "10"
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
	write "${kernel}printk_devlog_i" "off"
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
	write "${kernel}sched_force_lb_enable" "0"
	write "/sys/power/pm_freeze_timeout" "1000"
	log_i "Tweaked various kernel parameters to a better overall performance"
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
	write "${kernel}printk_devlog_i" "off"
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
	write "${kernel}sched_force_lb_enable" "0"
	write "/sys/power/pm_freeze_timeout" "1000"
	log_i "Tweaked various kernel parameters to a better overall performance"
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
	write "${kernel}printk_devlog_i" "off"
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
	write "${kernel}sched_force_lb_enable" "0"
	write "/sys/power/pm_freeze_timeout" "1000"
	log_i "Tweaked various kernel parameters to a better overall performance"
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
	write "${kernel}printk_devlog_i" "off"
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
	write "${kernel}sched_force_lb_enable" "0"
	write "/sys/power/pm_freeze_timeout" "1000"
	log_i "Tweaked various kernel parameters to a better overall performance"
}

enable_fp_boost() {
	[[ -d "/sys/kernel/fp_boost/" ]] && {
		write "/sys/kernel/fp_boost/enabled" "1"
		log_i "Enabled fingerprint boost"
	}
}

disable_fp_boost() {
	[[ -d "/sys/kernel/fp_boost/" ]] && {
		write "/sys/kernel/fp_boost/enabled" "0"
		log_i "Disabled fingerprint boost"
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
		log_i "Tweaked PPM policies"
		write "/proc/ppm/policy/hard_userlimit_min_cpu_freq" "0 $cpu_min_freq"
		write "/proc/ppm/policy/hard_userlimit_min_cpu_freq" "1 $cpu_min_freq"
		write "/proc/ppm/policy/hard_userlimit_max_cpu_freq" "0 $cpu_max_freq"
		write "/proc/ppm/policy/hard_userlimit_max_cpu_freq" "1 $cpu_max_freq"
		log_i "Tweaked PPM CPU clocks"
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
		log_i "Tweaked PPM policies"
		write "/proc/ppm/policy/hard_userlimit_min_cpu_freq" "0 $cpu_max_freq"
		write "/proc/ppm/policy/hard_userlimit_min_cpu_freq" "1 $cpu_max_freq"
		write "/proc/ppm/policy/hard_userlimit_max_cpu_freq" "0 $cpu_max_freq"
		write "/proc/ppm/policy/hard_userlimit_max_cpu_freq" "1 $cpu_max_freq"
		log_i "Tweaked PPM CPU clocks"
	}
}

# Try to set an more efficient CPU min frequency
cpu_clk_default() {
	for pl in /sys/devices/system/cpu/cpufreq/policy*/; do
		write "${pl}scaling_max_freq" "$cpu_max_freq"
		write "${pl}user_scaling_max_freq" "$cpu_max_freq"
		for i in 576000 652800 691200 748800 768000 787200 806400 825600 844800 852600 864000 902400 940800 960000 979200 998400 1036800 1075200 1113600 1152000 1209600 1459200 1478400 1516800 1689600 1708800 1766400; do
			[[ "$(grep "$i" "${pl}scaling_available_frequencies")" ]] && {
				write "${pl}scaling_min_freq" "$i"
				write "${pl}user_scaling_min_freq" "$i"
			}
			break
		done
	done
	log_i "Tweaked CPU clocks"

	[[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]] && {
		write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "1"
		log_i "Allow CPUs to use it's deepest sleep state"
	}
}

cpu_clk_mid() {
	for pl in /sys/devices/system/cpu/cpufreq/policy*/; do
		write "${pl}scaling_max_freq" "$((cpu_max_freq / 2))"
		write "${pl}user_scaling_max_freq" "$((cpu_max_freq / 2))"
		for i in 576000 652800 691200 748800 768000 787200 806400 825600 844800 852600 864000 902400 940800 960000 979200 998400 1036800 1075200 1113600 1152000 1209600 1459200 1478400 1516800 1689600 1708800 1766400; do
			[[ "$(grep "$i" "${pl}scaling_available_frequencies")" ]] && {
				write "${pl}scaling_min_freq" "$i"
				write "${pl}user_scaling_min_freq" "$i"
			}
			break
		done
	done
	log_i "Tweaked CPU clocks"

	[[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]] && {
		write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "1"
		log_i "Allow CPUs to use it's deepest sleep state"
	}
}

vm_lmk_latency() {
	sync
	write "${vm}drop_caches" "3"
	write "${vm}dirty_background_ratio" "10"
	write "${vm}dirty_ratio" "40"
	write "${vm}dirty_expire_centisecs" "3000"
	write "${vm}dirty_writeback_centisecs" "3000"
	write "${vm}page-cluster" "0"
	write "${vm}stat_interval" "10"
	write "${vm}overcommit_memory" "1"
	write "${vm}overcommit_ratio" "100"
	[[ "$total_ram" -le "6144" ]] && write "${vm}swappiness" "160"
	[[ "$total_ram" -gt "6144" ]] && [[ "$total_ram" -lt "8192" ]] && write "${vm}swappiness" "120"
	[[ "$total_ram" -gt "8192" ]] && write "${vm}swappiness" "90"
	[[ "$(cat ${vm}swappiness)" -ne "160" ]] || [[ "$(cat ${vm}swappiness)" -ne "120" ]] || [[ "$(cat ${vm}swappiness)" -ne "90" ]] && write "${vm}swappiness" "100"
	write "${vm}laptop_mode" "0"
	write "${vm}vfs_cache_pressure" "200"
	[[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	[[ ! "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "1" || [[ "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "0"
	[[ -e "${vm}swap_ratio" ]] && write "${vm}swap_ratio" "100"
	[[ -e "${vm}oom_dump_tasks" ]] && write "${vm}oom_dump_tasks" "0"
	[[ -e "${lmk}oom_reaper" ]] && write "${lmk}oom_reaper" "1"
	[[ -e "${lmk}lmk_fast_run" ]] && write "${lmk}lmk_fast_run" "0"
	[[ -e "${lmk}enable_adaptive_lmk" ]] && write "${lmk}enable_adaptive_lmk" "0"
	[[ -e "${vm}min_free_kbytes" ]] && write "${vm}min_free_kbytes" "32768"
	[[ -e "${vm}watermark_scale_factor" ]] && write "${vm}watermark_scale_factor" "$((377487360 / $total_ram_kb))"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -le "4096" ]] && write "${zram}wb_start_mins" "180"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -le "6144" ]] && write "${zram}wb_start_mins" "240"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "6144" ]] && [[ "$total_ram" -lt "8192" ]] && write "${zram}wb_start_mins" "360"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "8192" ]] && write "${zram}wb_start_mins" "480"
	log_i "Tweaked various VM / LMK parameters for a improved user-experience"
}

vm_lmk_balanced() {
	sync
	write "${vm}drop_caches" "2"
	write "${vm}dirty_background_ratio" "10"
	write "${vm}dirty_ratio" "30"
	write "${vm}dirty_expire_centisecs" "3000"
	write "${vm}dirty_writeback_centisecs" "3000"
	write "${vm}page-cluster" "0"
	write "${vm}stat_interval" "10"
	write "${vm}overcommit_memory" "1"
	write "${vm}overcommit_ratio" "100"
	[[ "$total_ram" -le "6144" ]] && write "${vm}swappiness" "160"
	[[ "$total_ram" -gt "6144" ]] && [[ "$total_ram" -lt "8192" ]] && write "${vm}swappiness" "120"
	[[ "$total_ram" -gt "8192" ]] && write "${vm}swappiness" "90"
	[[ "$(cat ${vm}swappiness)" -ne "160" ]] || [[ "$(cat ${vm}swappiness)" -ne "120" ]] || [[ "$(cat ${vm}swappiness)" -ne "90" ]] && write "${vm}swappiness" "100"
	write "${vm}laptop_mode" "0"
	write "${vm}vfs_cache_pressure" "100"
	[[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	[[ ! "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "1" || [[ "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "0"
	[[ -e "${vm}swap_ratio" ]] && write "${vm}swap_ratio" "100"
	[[ -e "${vm}oom_dump_tasks" ]] && write "${vm}oom_dump_tasks" "0"
	[[ -e "${lmk}oom_reaper" ]] && write "${lmk}oom_reaper" "1"
	[[ -e "${lmk}lmk_fast_run" ]] && write "${lmk}lmk_fast_run" "0"
	[[ -e "${lmk}enable_adaptive_lmk" ]] && write "${lmk}enable_adaptive_lmk" "0"
	[[ -e "${vm}min_free_kbytes" ]] && write "${vm}min_free_kbytes" "32768"
	[[ -e "${vm}watermark_scale_factor" ]] && write "${vm}watermark_scale_factor" "$((377487360 / $total_ram_kb))"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -le "4096" ]] && write "${zram}wb_start_mins" "180"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -le "6144" ]] && write "${zram}wb_start_mins" "240"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "6144" ]] && [[ "$total_ram" -lt "8192" ]] && write "${zram}wb_start_mins" "360"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "8192" ]] && write "${zram}wb_start_mins" "480"
	log_i "Tweaked various VM and LMK parameters for a improved user-experience"
}

vm_lmk_extreme() {
	sync
	write "${vm}drop_caches" "3"
	write "${vm}dirty_background_ratio" "5"
	write "${vm}dirty_ratio" "20"
	write "${vm}dirty_expire_centisecs" "3000"
	write "${vm}dirty_writeback_centisecs" "3000"
	write "${vm}page-cluster" "0"
	write "${vm}stat_interval" "10"
	write "${vm}overcommit_memory" "1"
	write "${vm}overcommit_ratio" "100"
	write "${vm}swappiness" "60"
	write "${vm}laptop_mode" "0"
	write "${vm}vfs_cache_pressure" "200"
	[[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	[[ ! "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "1" || [[ "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "0"
	[[ -e "${vm}swap_ratio" ]] && write "${vm}swap_ratio" "100"
	[[ -e "${vm}oom_dump_tasks" ]] && write "${vm}oom_dump_tasks" "0"
	[[ -e "${lmk}oom_reaper" ]] && write "${lmk}oom_reaper" "1"
	[[ -e "${lmk}lmk_fast_run" ]] && write "${lmk}lmk_fast_run" "0"
	[[ -e "${lmk}enable_adaptive_lmk" ]] && write "${lmk}enable_adaptive_lmk" "0"
	[[ -e "${vm}min_free_kbytes" ]] && write "${vm}min_free_kbytes" "32768"
	[[ -e "${vm}watermark_scale_factor" ]] && write "${vm}watermark_scale_factor" "$((377487360 / $total_ram_kb))"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -le "4096" ]] && write "${zram}wb_start_mins" "180"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -le "6144" ]] && write "${zram}wb_start_mins" "240"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "6144" ]] && [[ "$total_ram" -lt "8192" ]] && write "${zram}wb_start_mins" "360"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "8192" ]] && write "${zram}wb_start_mins" "480"
	log_i "Tweaked various VM and LMK parameters for a improved user-experience"
}

vm_lmk_battery() {
	sync
	write "${vm}drop_caches" "1"
	write "${vm}dirty_background_ratio" "15"
	write "${vm}dirty_ratio" "30"
	write "${vm}dirty_expire_centisecs" "500"
	write "${vm}dirty_writeback_centisecs" "3000"
	write "${vm}page-cluster" "0"
	write "${vm}stat_interval" "10"
	write "${vm}overcommit_memory" "1"
	write "${vm}overcommit_ratio" "100"
	write "${vm}swappiness" "80"
	write "${vm}laptop_mode" "0"
	write "${vm}vfs_cache_pressure" "60"
	[[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	[[ ! "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "1" || [[ "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "0"
	[[ -e "${vm}swap_ratio" ]] && write "${vm}swap_ratio" "100"
	[[ -e "${vm}oom_dump_tasks" ]] && write "${vm}oom_dump_tasks" "0"
	[[ -e "${lmk}oom_reaper" ]] && write "${lmk}oom_reaper" "1"
	[[ -e "${lmk}lmk_fast_run" ]] && write "${lmk}lmk_fast_run" "0"
	[[ -e "${lmk}enable_adaptive_lmk" ]] && write "${lmk}enable_adaptive_lmk" "0"
	[[ -e "${vm}min_free_kbytes" ]] && write "${vm}min_free_kbytes" "32768"
	[[ -e "${vm}watermark_scale_factor" ]] && write "${vm}watermark_scale_factor" "$((377487360 / $total_ram_kb))"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -le "4096" ]] && write "${zram}wb_start_mins" "180"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -le "6144" ]] && write "${zram}wb_start_mins" "240"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "6144" ]] && [[ "$total_ram" -lt "8192" ]] && write "${zram}wb_start_mins" "360"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "8192" ]] && write "${zram}wb_start_mins" "480"
	log_i "Tweaked various VM and LMK parameters for a improved user-experience"
}

vm_lmk_gaming() {
	sync
	write "${vm}drop_caches" "3"
	write "${vm}dirty_background_ratio" "2"
	write "${vm}dirty_ratio" "20"
	write "${vm}dirty_expire_centisecs" "3000"
	write "${vm}dirty_writeback_centisecs" "3000"
	write "${vm}page-cluster" "0"
	write "${vm}stat_interval" "10"
	write "${vm}overcommit_memory" "1"
	write "${vm}overcommit_ratio" "100"
	write "${vm}swappiness" "60"
	write "${vm}laptop_mode" "0"
	write "${vm}vfs_cache_pressure" "200"
	[[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	[[ ! "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "1" || [[ "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "0"
	[[ -e "${vm}swap_ratio" ]] && write "${vm}swap_ratio" "100"
	[[ -e "${vm}oom_dump_tasks" ]] && write "${vm}oom_dump_tasks" "0"
	[[ -e "${lmk}oom_reaper" ]] && write "${lmk}oom_reaper" "1"
	[[ -e "${lmk}lmk_fast_run" ]] && write "${lmk}lmk_fast_run" "0"
	[[ -e "${lmk}enable_adaptive_lmk" ]] && write "${lmk}enable_adaptive_lmk" "0"
	[[ -e "${vm}min_free_kbytes" ]] && write "${vm}min_free_kbytes" "32768"
	[[ -e "${vm}watermark_scale_factor" ]] && write "${vm}watermark_scale_factor" "$((377487360 / $total_ram_kb))"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -le "4096" ]] && write "${zram}wb_start_mins" "180"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -le "6144" ]] && write "${zram}wb_start_mins" "240"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "6144" ]] && [[ "$total_ram" -lt "8192" ]] && write "${zram}wb_start_mins" "360"
	[[ -e "${zram}wb_start_mins" ]] && [[ "$total_ram" -ge "8192" ]] && write "${zram}wb_start_mins" "480"
	log_i "Tweaked various VM and LMK parameters for a improved user-experience"
}

disable_msm_thermal() {
	[[ -d "/sys/module/msm_thermal/" ]] && {
		write "/sys/module/msm_thermal/vdd_restriction/enabled" "0"
		write "/sys/module/msm_thermal/core_control/enabled" "0"
		write "/sys/module/msm_thermal/parameters/enabled" "N"
		log_i "Disabled msm_thermal"
	}
}

enable_pewq() {
	[[ -e "/sys/module/workqueue/parameters/power_efficient" ]] && {
		write "/sys/module/workqueue/parameters/power_efficient" "Y"
		log_i "Enabled power efficient workqueue"
	}
}

disable_pewq() {
	[[ -e "/sys/module/workqueue/parameters/power_efficient" ]] && {
		write "/sys/module/workqueue/parameters/power_efficient" "N"
		log_i "Disabled power efficient workqueue"
	}
}

fix_dt2w() {
	[[ -e "/sys/touchpanel/double_tap" ]] && [[ -e "/proc/tp_gesture" ]] && {
		write "/sys/touchpanel/double_tap" "1"
		write "/proc/tp_gesture" "1"
		log_i "Fixed DT2W if broken"
	} || [[ -e "/sys/class/sec/tsp/dt2w_enable" ]] && {
		write "/sys/class/sec/tsp/dt2w_enable" "1"
		log_i "Fixed DT2W if broken"
	} || [[ -e "/proc/tp_gesture" ]] && {
		write "/proc/tp_gesture" "1"
		log_i "Fixed DT2W if broken"
	} || [[ -e "/sys/touchpanel/double_tap" ]] && {
		write "/sys/touchpanel/double_tap" "1"
		log_i "Fixed DT2W if broken"
	} || [[ -e "/proc/touchpanel/double_tap_enable" ]] && {
		write "/proc/touchpanel/double_tap_enable" "1"
		log_i "Fixed DT2W if broken"
	}
}

enable_tb() {
	[[ -e "/sys/module/msm_performance/parameters/touchboost" ]] && {
		write "/sys/module/msm_performance/parameters/touchboost" "1"
		log_i "Enabled msm_performance touch boost"
	} || [[ -e "/sys/power/pnpmgr/touch_boost" ]] && {
		write "/sys/power/pnpmgr/touch_boost" "1"
		write "/sys/power/pnpmgr/long_duration_touch_boost" "1"
		log_i "Enabled pnpmgr touch boost"
	}

	[[ -e "/proc/touchpanel/oplus_tp_limit_enable" ]] && {
		write "/proc/touchpanel/oplus_tp_limit_enable" "0"
		write "/proc/touchpanel/oplus_tp_direction" "1"
		write "/proc/touchpanel/game_switch_enable" "1"
		log_i "Enabled improved touch mode"
	}
}

disable_tb() {
	[[ -e "/sys/module/msm_performance/parameters/touchboost" ]] && {
		write "/sys/module/msm_performance/parameters/touchboost" "0"
		log_i "Disabled msm_performance touch boost"
	} || [[ -e "/sys/power/pnpmgr/touch_boost" ]] && {
		write "/sys/power/pnpmgr/touch_boost" "0"
		write "/sys/power/pnpmgr/long_duration_touch_boost" "0"
		log_i "Disabled pnpmgr touch boost"
	}

	[[ -e "/proc/touchpanel/oplus_tp_limit_enable" ]] && {
		write "/proc/touchpanel/oplus_tp_limit_enable" "0"
		write "/proc/touchpanel/oplus_tp_direction" "1"
		write "/proc/touchpanel/game_switch_enable" "0"
		log_i "Disabled improved touch mode"
	}
}

config_tcp() {
	avail_con="$(cat "${tcp}tcp_available_congestion_control")"

	for tcpcc in bbr2 bbr westwood cubic bic; do
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
	write "${tcp}tcp_slow_start_after_idle" "0"
	write "/proc/sys/net/core/netdev_max_backlog" "16384"
	log_i "Applied TCP tweaks"
}

enable_kern_batt_saver() {
	[[ -d "/sys/module/battery_saver/" ]] && {
		write "/sys/module/battery_saver/parameters/enabled" "Y"
		log_i "Enabled kernel battery saver"
	}
}

disable_kern_batt_saver() {
	[[ -d "/sys/module/battery_saver/" ]] && {
		write "/sys/module/battery_saver/parameters/enabled" "N"
		log_i "Disabled kernel battery saver"
	}
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
	log_i "Enabled LPM"
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
	log_i "Disabled LPM"
}

enable_pm2_idle_mode() {
	[[ -d "/sys/module/pm2/parameters/" ]] && {
		write "/sys/module/pm2/parameters/idle_sleep_mode" "Y"
		log_i "Enabled pm2 idle sleep mode"
	}
}

disable_pm2_idle_mode() {
	[[ -d "/sys/module/pm2/parameters/" ]] && {
		write "/sys/module/pm2/parameters/idle_sleep_mode" "N"
		log_i "Disabled pm2 idle sleep mode"
	}
}

enable_lcd_prdc() {
	[[ -e "/sys/class/lcd/panel/power_reduce" ]] && {
		write "/sys/class/lcd/panel/power_reduce" "1"
		log_i "Enabled LCD power reduce"
	}
}

disable_lcd_prdc() {
	[[ -e "/sys/class/lcd/panel/power_reduce" ]] && {
		write "/sys/class/lcd/panel/power_reduce" "0"
		log_i "Disabled LCD power reduce"
	}
}

enable_usb_fast_chrg() {
	[[ -e "/sys/kernel/fast_charge/force_fast_charge" ]] && {
		write "/sys/kernel/fast_charge/force_fast_charge" "1"
		log_i "Enabled USB 3.0 fast charging"
	}
}

enable_sam_fast_chrg() {
	[[ -e "/sys/class/sec/switch/afc_disable" ]] && {
		write "/sys/class/sec/switch/afc_disable" "0"
		log_i "Enabled fast charging on Samsung devices"
	}
}

enable_ufs_perf_mode() {
	[[ -d "/sys/class/devfreq/1d84000.ufshc/" ]] && {
		write "/sys/devices/platform/soc/1d84000.ufshc/clkscale_enable" "0"
		write "/sys/devices/platform/soc/1d84000.ufshc/hibern8_on_idle_enable" "0"
		write "/sys/devices/platform/soc/1d84000.ufshc/clkgate_enable" "0"
		log_i "Enabled UFS performance mode"
	}
}

disable_ufs_perf_mode() {
	[[ -d "/sys/class/devfreq/1d84000.ufshc/" ]] && {
		write "/sys/devices/platform/soc/1d84000.ufshc/clkscale_enable" "1"
		write "/sys/devices/platform/soc/1d84000.ufshc/hibern8_on_idle_enable" "1"
		write "/sys/devices/platform/soc/1d84000.ufshc/clkgate_enable" "1"
		log_i "Disabled UFS performance mode"
	}
}

enable_emmc_clk_scl() {
	[[ -d "/sys/class/mmc_host/mmc0/" ]] && [[ -d "/sys/class/mmc_host/mmc1/" ]] && {
		write "/sys/class/mmc_host/mmc0/clk_scaling/enable" "1"
		write "/sys/class/mmc_host/mmc1/clk_scaling/enable" "1"
	} || [[ -d "/sys/class/mmc_host/mmc0/" ]] && write "/sys/class/mmc_host/mmc0/clk_scaling/enable" "1"
	log_i "Enabled EMMC clock scaling"
}

disable_emmc_clk_scl() {
	[[ -d "/sys/class/mmc_host/mmc0/" ]] && [[ -d "/sys/class/mmc_host/mmc1/" ]] && {
		write "/sys/class/mmc_host/mmc0/clk_scaling/enable" "0"
		write "/sys/class/mmc_host/mmc1/clk_scaling/enable" "0"
	} || [[ -d "/sys/class/mmc_host/mmc0/" ]] && write "/sys/class/mmc_host/mmc0/clk_scaling/enable" "0"
	log_i "Disabled EMMC clock scaling"
}

# Disable unnecessary kernel debug/logging
disable_debug() {
	for i in debug_mask log_level* debug_level* *debug_mode enable_ramdumps edac_mc_log* enable_event_log *log_level* *log_ue* *log_ce* log_ecn_error snapshot_crashdumper seclog* compat-log *log_enabled tracing_on mballoc_debug; do
		for o in $(find /sys/ -type f -name "$i"); do
			write "$o" "0"
		done
	done
	write "/sys/module/spurious/parameters/noirqdebug" "1"
	write "/sys/kernel/debug/sde_rotator0/evtlog/enable" "0"
	write "/sys/kernel/debug/dri/0/debug/enable" "0"
	log_i "Disabled misc debugging"
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
		write "${perfmgr}tchbst/user/usrtch" "enable 0"
		log_i "Tweaked perfmgr settings"
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
		write "${perfmgr}tchbst/user/usrtch" "enable 0"
		log_i "Tweaked perfmgr settings"
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

config_fpsgo() {
	[[ -d "$fpsgo" ]] && {
		write "${fpsgo}max_freq_limit_level" "0"
		write "${fpsgo}min_freq_limit_level" "0"
		write "${fpsgo}variance" "10"
	}
	[[ -d "/sys/kernel/fpsgo/minitop/" ]] && write "/sys/kernel/fpsgo/minitop/enable" "0"
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

write_panel() { echo "$1" >>"$bbn_banner"; }

save_panel() {
	write_panel "[*] Bourbon - the essential task optimizer 
Version: 1.4.1-r7-stable
Last performed: $(date '+%Y-%m-%d %H:%M:%S')
FSCC status: $(fscc_status)
Adjshield status: $(adjshield_status)
Adjshield config file: $adj_cfg"
}

adjshield_write_cfg() { echo "$1" >>"$adj_cfg"; }

adjshield_create_default_cfg() {
	adjshield_write_cfg "# AdjShield Config File
# Prevent given packages from being killed by LMK by protecting oom_score_adj.
# List all the package names of the apps which you want to keep alive.
com.riotgames.league.wildrift
com.activision.callofduty.shooter
com.tencent.ig
com.dts.freefireth
com.dts.freefiremax
com.ngame.allstar.eu
com.pubg.newstate
com.mobile.legends
com.ea.gp.fifamobile
com.gameloft.android.ANMP.GloftA9HM
com.gameloft.android.ANMP.GloftMVHM
com.gameloft.android.ANMP.GloftM5HM
com.netease.idv.googleplay
com.titan.cd.gb
com.ea.gp.apexlegendsmobilefps
com.igg.android.omegalegends
com.netease.lztgglobal
com.gamedevltd.modernstrike
com.gamedevltd.wwh
com.edkongames.mobs
com.panzerdog.tacticool
com.camouflaj.republique
com.gaijin.xom
com.feralinteractive.gridas
com.twoheadedshark.tco
com.madfingergames.legends
com.gameinsight.gobandroid
com.criticalforceentertainment.criticalops
com.bhvr.deadbydaylight
com.axlebolt.standoff2
com.gameloft.android.ANMP.GloftINHM
com.codemasters.F1Mobile
com.miHoYo.bh3global
com.netease.sheltergp
com.roblox.client
com.supercell.brawlstars
com.miniclip.eightballpool
com.mojang.minecraftpe
com.supercell.clashroyale
com.gameloft.android.GloftDMKF
com.gameloft.android.GloftMBCF
com.miHoYo.GenshinImpact
com.garena.game.kgvn
com.pubg.krmobile
com.ea.game.pvz2_row
com.gameloft.android.GloftMOTR
com.tencent.tmgp.sgame
com.pixel.gun3d
com.tencent.iglite
com.pubg.imobile
com.playtika.wsop.gp
com.gameloft.android.GloftR19F
com.kitkagames.fallbuddies
com.gameloft.android.ANMP.GloftDMHM
com.ea.game.nfs14_row
com.zynga.starwars.hunters
com.ohbibi.fps
com.scopely.startrek
net.wargaming.wot.blitz
com.blizzard.wtcg.hearthstone
com.ea.games.r3_row
com.wb.goog.mkx
com.kabam.marvelbattle
com.pixonic.wwr
com.wb.goog.got.conquest
com.garena.game.fcsac
com.pixelfederation.ts2
com.gameloft.android.GloftNOMP
"
}

# Credits to DavidPisces @ GitHub
config_f2fs() {
	for i in ${f2fs}mmcblk*/; do
		write "${i}cp_interval" "200"
		write "${i}gc_urgent_sleep_time" "50"
		write "${i}iostat_enable" "0"
		write "${i}min_fsync_blocks" "20"
	done
	log_i "Tweaked F2FS parameters"
}

realme_gt() {
	gt=$(settings get system gt_mode_state_setting)
	[[ "$gt" == "1" ]] || [[ "$gt" == "0" ]] && [[ "$gt" != "$1" ]] && {
		[[ "$1" == "1" ]] && action='open' || action='close'
		gt_receiver='com.coloros.oppoguardelf/com.coloros.performance.GTModeBroadcastReceiver'
		[[ -n "$(pm query-receivers --brief -n "$gt_receiver" | grep "$gt_receiver")" ]] && am broadcast -a gt_mode_broadcast_intent_"$action"_action -n "$gt_receiver" -f 0x01000000 || am broadcast -a gt_mode_broadcast_intent_"$action"_action -f 0x01000000
	}
}

sched_deisolation() {
	for i in {0..7}; do
		write "/sys/devices/system/cpu/sched/set_sched_deisolation" "$i"
	done
	chmod 000 "/sys/devices/system/cpu/sched/set_sched_isolation"
}

sched_isolation() {
	for i in {0..7}; do
		write "/sys/devices/system/cpu/sched/set_sched_isolation" "$i"
	done
}

disable_mtk_thrtl() {
	[[ -e "${t_msg}market_download_limit" ]] && {
	write "${t_msg}market_download_limit" "0"
	write "${t_msg}modem_limit" "0"
	}
}

adjshield_start() {
	rm -rf "$adj_log"
	rm -rf "$bbn_log"
	rm -rf "$bbn_banner"
	# check interval: 120 seconds - Deprecated, use event driven instead
	${modpath}system/bin/adjshield -o $adj_log -c $adj_cfg &
}

adjshield_stop() { kill_svc adjshield; }

# return:status
adjshield_status() {
	[[ "$(pgrep -f "adjshield")" ]] && echo "Adjshield running. see $adj_log for details." || {
		# Error: Log file not found
		err="$(cat "$adj_log" | grep Error | head -1 | cut -d: -f2)"
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
# Only append if object isn't already on file list
fscc_list_append() { [[ ! "$fscc_file_list" == *"$1"* ]] && fscc_file_list="$fscc_file_list $1"; }

# Only append if object doesn't already exists either on pinner service to avoid unnecessary memory expenses
fscc_add_obj() {
	[[ "$sdk" -lt "24" ]] && fscc_list_append "$1" || {
		while IFS= read -r obj; do
			[[ "$1" != "$obj" ]] && fscc_list_append "$1"
		done <<<"$(dumpsys pinner | grep -E -i "$1" | awk '{print $1}')"
	}
}

# $1:package_name
# pm path -> "package:/system/product/priv-app/OPSystemUI/OPSystemUI.apk"
fscc_add_apk() { [[ "$1" != "" ]] && fscc_add_obj "$(pm path "$1" | head -1 | cut -d: -f2)"; }

# $1:package_name
fscc_add_dex() {
	[[ "$1" != "" ]] \
		&& {
			# pm path -> "package:/system/product/priv-app/OPSystemUI/OPSystemUI.apk"
			package_apk_path="$(pm path "$1" | head -1 | cut -d: -f2)"
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
	pkg_nm="$(pm resolve-activity -a "$intent_act" -c "$intent_cat" | grep packageName | head -1 | cut -d= -f2)"
	# /data/dalvik-cache/arm64/system@priv-app@OPLauncher2@OPLauncher2.apk@classes.dex 16M/31M  53.2%
	# /data/dalvik-cache/arm64/system@priv-app@OPLauncher2@OPLauncher2.apk@classes.vdex 120K/120K  100%
	# /system/priv-app/OPLauncher2/OPLauncher2.apk 14M/30M  46.1%
	fscc_add_apk "$pkg_nm"
	fscc_add_dex "$pkg_nm"
}

fscc_add_app_ime() {
	# "      packageName=com.baidu.input_yijia"
	pkg_nm="$(ime list | grep packageName | head -1 | cut -d= -f2)"
	# /data/dalvik-cache/arm/system@app@baidushurufa@baidushurufa.apk@classes.dex 5M/17M  33.1%
	# /data/dalvik-cache/arm/system@app@baidushurufa@baidushurufa.apk@classes.vdex 2M/7M  28.1%
	# /system/app/baidushurufa/baidushurufa.apk 1M/28M  5.71%
	# pin apk file in memory is not valuable
	fscc_add_dex "$pkg_nm"
}

# $1:package_name
fscc_add_apex_lib() { fscc_add_obj "$(find /apex -name "$1" | head -1)"; }

# After appending fscc_file_list
# Multiple parameters, cannot be warped by ""
fscc_start() { ${modpath}system/bin/fscache-ctrl -fdlb0 $fscc_file_list; }

fscc_stop() { kill_svc fscache-ctrl; }

# Return:status
fscc_status() {
	# Get the correct value after waiting for fscc loading files
	sleep 2
	[[ "$(pgrep -f "fscache-ctrl")" ]] && echo "Running $(cat /proc/meminfo | grep Mlocked | cut -d: -f2 | tr -d ' ') in cache." || echo "Not running."
}

# Userspace bourbon optimization
usr_bbn_opt() {
	# Input dispatcher/reader
	change_thread_nice "system_server" "Input" "-20"
	# Not important
	change_thread_nice "system_server" "Greezer|TaskSnapshot|Oom|SchedBoost" "4"
	pin_thread_on_pwr "system_server" "CachedAppOpt|Greezer|TaskSnapshot|Oom|PeriodicClean|SchedBoost|mi_analytics_up|mistat_db"
	# Speed up searching service manager
	change_task_nice "servicemanag" "-20"
	# Run KGSL/Mali workers with max priority as both are critical tasks
	change_task_nice "kgsl_worker" "-20"
	pin_proc_on_perf "kgsl_worker"
	change_task_nice "mali_jd_thread" "-20"
	change_task_nice "mali_event_thread" "-20"
	# Pin RCU tasks on perf cluster
	pin_proc_on_perf "rcu_task"
	# Pin LMKD to perf cluster as it is has the important task of reclaiming memory to the system
	pin_proc_on_perf "lmkd"
	# Pin HWC on perf cluster to reduce jitter
	pin_proc_on_perf "composer"
	# Let devfreq boost run with max priority and set it to perf cluster as it is a critical task (boosting DDR)
	change_task_nice "devfreq_boost" "-20"
	pin_proc_on_perf "devfreq_boost"
	# Pin these kthreads to the perf cluster as they also play a major role in rendering frames to the display
	# Pin only the first threads as others are non-essential
	n=80
	while [[ "$n" -lt "301" ]]; do
	pin_proc_on_perf "crtc_event:$i"
	pin_proc_on_perf "crtc_commit:$i"
	n=$((n+1))
	break
done
	pin_proc_on_perf "pp_event"
	pin_proc_on_perf "mdss_fb"
	pin_proc_on_perf "mdss_display_wake"
	pin_proc_on_perf "vsync_retire_work"
	pin_proc_on_perf "pq@"
	# Pin TS workqueues to perf cluster to reduce latency
	pin_proc_on_perf "fts_wq"
	pin_proc_on_perf "ts_workqueu"
	pin_proc_on_perf "nvt_fwu_wq"
	# Pin Samsung HyperHAL, wifi HAL and daemon to perf cluster
	pin_proc_on_perf "hyper@"
	pin_proc_on_perf "wifi@"
	pin_proc_on_perf "wlbtd"
	# Queue UFS/EMMC clock gating with max priority
	change_task_nice "ufs_clk_gating" "-20"
	change_task_nice "mmc_clk_gate" "-20"
	# Queue CVP fence request handler with max priority
	change_task_nice "thread_fence" "-20"
	# Queue cpu_boost worker with max priority for obvious reasons
	change_task_rt_ff "cpu_boost_work" "2"
	change_task_nice "cpu_boost_work" "-20"
	# Queue touchscreen related workers with max priority
	change_task_nice "speedup_resume_wq" "-20"
	change_task_nice "load_tp_fw_wq" "-20"
	change_task_nice "tcm_freq_hop" "-20"
	change_task_nice "touch_delta_wq" "-20"
	change_task_nice "tp_async" "-20"
	change_task_nice "wakeup_clk_wq" "-20"
	# Set RT priority correctly for critical tasks
	change_task_rt_ff "kgsl_worker_thread" "16"
	change_task_rt_ff "crtc_commit" "16"
	change_task_rt_ff "crtc_event" "16"
	change_task_rt_ff "pp_event" "16"
	change_task_rt_ff "rot_commitq" "5"
	change_task_rt_ff "rot_doneq" "5"
	change_task_rt_ff "rot_fenceq" "5"
	change_task_rt_ff "system_server" "2"
	change_task_rt_ff "surfaceflinger" "2"
	change_task_rt_ff "composer" "2"
	change_task_rt_ff "mali_jd_thread" "60"
	# Boost app boot process
	change_task_nice "zygote" "-20"
	# Queue VM writeback with max priority
	change_task_nice "writeback" "-20"
	# Affects IO latency/throughput
	change_task_nice "kblockd" "-20"
	# Those workqueues don't need max priority
	change_task_nice "ipawq" "0"
	change_task_nice "iparepwq" "0"
}

clear_logs() {
	# Remove logs if size is >= 1 MB
	kdbg_max_size=1000000
	sqlite_opt_max_size=1000000
	[[ "$(stat -t "$kdbg" 2>/dev/null | awk '{print $2}')" -ge "$kdbg_max_size" ]] && rm -rf "$kdbg"
	[[ "$(stat -t "/data/media/0/KTSR/sqlite_opt.log" 2>/dev/null | awk '{print $2}')" -ge "$sqlite_opt_max_size" ]] && rm -rf "/data/media/0/KTSR/sqlite_opt.log"
}

get_scrn_state() {
	scrn_state=$(dumpsys power 2>/dev/null | grep state=O | cut -d "=" -f 2)
	[[ "$scrn_state" == "" ]] && scrn_state=$(dumpsys window policy | grep screenState | awk -F '=' '{print $2}')
	[[ "$scrn_state" == "OFF" ]] && scrn_on=0 || scrn_on=1
	[[ "$scrn_state" == "SCREEN_STATE_OFF" ]] && scrn_on=0 || scrn_on=1
}

[[ "$qcom" == "true" ]] && define_gpu_pl

apply_all() {
	print_info
	stop_services
	bring_all_cores
	set_thermal_pol
	disable_mtk_thrtl
	io_"$ktsr_prof_en"
	boost_"$ktsr_prof_en"
	cpu_"$ktsr_prof_en"
	hmp_"$ktsr_prof_en"
	gpu_"$ktsr_prof_en"
	schedtune_"$ktsr_prof_en"
	sched_ft_"$ktsr_prof_en"
	sched_"$ktsr_prof_en"
	uclamp_"$ktsr_prof_en"
	vm_lmk_"$ktsr_prof_en"
	[[ "$ktsr_prof_en" == "extreme" ]] || [[ "$ktsr_prof_en" == "gaming" ]] && {
		enable_devfreq_boost
		dram_max
		disable_core_ctl
		sched_deisolation
		misc_cpu_max_pwr
		disable_pewq
		enable_tb
		disable_lpm
		disable_pm2_idle_mode
		perfmgr_default
		enable_thermal_disguise
		realme_gt 1
		enable_ufs_perf_mode
		disable_emmc_clk_scl
	} || {
		disable_devfreq_boost
		dram_default
		enable_core_ctl
		sched_isolation
		enable_ppm
		ppm_policy_default
		enable_pewq
		disable_tb
		enable_lpm
		enable_pm2_idle_mode
		disable_thermal_disguise
		realme_gt 0
		disable_ufs_perf_mode
		enable_emmc_clk_scl
	}
	[[ "$ktsr_prof_en" == "latency" ]] || [[ "$ktsr_prof_en" == "balanced" ]] && misc_cpu_default || misc_cpu_pwr_saving
	[[ "$ktsr_prof_en" == "extreme" ]] && {
		enable_ppm
		ppm_policy_max
	} || [[ "$ktsr_prof_en" == "gaming" ]] && disable_ppm
	[[ "$ktsr_prof_en" == "battery" ]] && [[ "$batt_pctg" -lt "20" ]] && cpu_clk_mid || cpu_clk_default
	[[ "$ktsr_prof_en" == "battery" ]] && {
		enable_kern_batt_saver
		enable_lcd_prdc
		perfmgr_pwr_saving
	} || {
		disable_kern_batt_saver
		disable_lcd_prdc
		perfmgr_default
	}
}

apply_all_auto() {
	print_info
	stop_services
	bring_all_cores
	set_thermal_pol
	disable_mtk_thrtl
	io_"$(getprop kingauto.prof)"
	boost_"$(getprop kingauto.prof)"
	cpu_"$(getprop kingauto.prof)"
	hmp_"$(getprop kingauto.prof)"
	gpu_"$(getprop kingauto.prof)"
	schedtune_"$(getprop kingauto.prof)"
	sched_ft_"$(getprop kingauto.prof)"
	sched_"$(getprop kingauto.prof)"
	uclamp_"$(getprop kingauto.prof)"
	vm_lmk_"$(getprop kingauto.prof)"
	[[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]] && {
		enable_devfreq_boost
		dram_max
		disable_core_ctl
		sched_deisolation
		misc_cpu_max_pwr
		disable_pewq
		enable_tb
		disable_lpm
		disable_pm2_idle_mode
		perfmgr_default
		enable_thermal_disguise
		realme_gt 1
		enable_ufs_perf_mode
		disable_emmc_clk_scl
	} || {
		disable_devfreq_boost
		dram_default
		enable_core_ctl
		sched_isolation
		enable_ppm
		ppm_policy_default
		enable_pewq
		disable_tb
		enable_lpm
		enable_pm2_idle_mode
		disable_thermal_disguise
		realme_gt 0
		disable_ufs_perf_mode
		enable_emmc_clk_scl
	}
	[[ "$(getprop kingauto.prof)" == "latency" ]] || [[ "$(getprop kingauto.prof)" == "balanced" ]] && misc_cpu_default || misc_cpu_pwr_saving
	[[ "$(getprop kingauto.prof)" == "extreme" ]] && {
		enable_ppm
		ppm_policy_max
	} || [[ "$(getprop kingauto.prof)" == "gaming" ]] && disable_ppm
	[[ "$(getprop kingauto.prof)" == "battery" ]] && [[ "$batt_pctg" -lt "20" ]] && cpu_clk_mid || cpu_clk_default
	[[ "$(getprop kingauto.prof)" == "battery" ]] && {
		enable_kern_batt_saver
		enable_lcd_prdc
		perfmgr_pwr_saving
	} || {
		disable_kern_batt_saver
		disable_lcd_prdc
		perfmgr_default
	}
}

latency() {
	init=$(date +%s)
	sync
	apply_all
	cmd thermalservice reset >/dev/null 2>&1
	log_i "Latency profile applied. Enjoy!"
	exit=$(date +%s)
	exec_time=$((exit - init))
	log_i "Spent time: $exec_time seconds."
}
automatic() {
	log_i "Applying automatic profile"
	sync
	kingauto &
	log_i "Applied automatic profile"
}
balanced() {
	init=$(date +%s)
	sync
	apply_all
	cmd thermalservice reset >/dev/null 2>&1
	log_i "Balanced profile applied. Enjoy!"
	exit=$(date +%s)
	exec_time=$((exit - init))
	log_i "Spent time: $exec_time seconds."
}
extreme() {
	init=$(date +%s)
	sync
	apply_all
	cmd thermalservice override-status 0 >/dev/null 2>&1l
	log_i "Extreme profile applied. Enjoy!"
	exit=$(date +%s)
	exec_time=$((exit - init))
	log_i "Spent time: $exec_time seconds."
}
battery() {
	init=$(date +%s)
	sync
	apply_all
	cmd thermalservice reset >/dev/null 2>&1
	log_i "Battery profile applied. Enjoy!"
	exit=$(date +%s)
	exec_time=$((exit - init))
	log_i "Spent time: $exec_time seconds."
}
gaming() {
	init=$(date +%s)
	sync
	apply_all
	cmd thermalservice override-status 0 >/dev/null 2>&1
	log_i "Gaming profile applied. Enjoy!"
	exit=$(date +%s)
	exec_time=$((exit - init))
	log_i "Spent time: $exec_time seconds."
}
