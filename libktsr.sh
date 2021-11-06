#!/system/bin/sh
# KTSR™ by Pedro (pedrozzz0 @ GitHub)
# Credits: Ktweak, by Draco (tytydraco @ GitHub), LSpeed, Dan (Paget69 @ XDA), mogoroku @ GitHub, vtools, by helloklf @ GitHub, Cuprum-Turbo-Adjustment, by chenzyadb @ CoolApk, qti-mem-opt & Uperf, by Matt Yang (yc9559 @ CoolApk) and Pandora's Box, by Eight (dlwlrma123 @ GitHub).
# Thanks: GR for some help
# If you wanna use it as part of your project, please maintain the credits to it's respectives authors.
# TODO: Implement a proper debug flag & cleanup some variables

###############################
# Variables
###############################
MODPATH="/data/adb/modules/KTSR/"
KLOG="/data/media/0/KTSR/KTSR.log"
KDBG="/data/media/0/KTSR/KTSR_DBG.log"
tcp="/proc/sys/net/ipv4/"
kernel="/proc/sys/kernel/"
vm="/proc/sys/vm/"
cpuset="/dev/cpuset/"
stune="/dev/stune/"
lmk="/sys/module/lowmemorykiller/"
blkio="/dev/blkio/"
cpuctl="/dev/cpuctl/"
fs="/proc/sys/fs/"
bbn_log="/data/media/0/KTSR/bourbon.log"
bbn_banner="/data/media/0/KTSR/bourbon.info"
adj_rel="${BIN_DIR}"
adj_nm="adjshield"
adj_cfg="/data/media/0/KTSR/adjshield.conf"
adj_log="/data/media/0/KTSR/adjshield.log"
perfmgr="/proc/perfmgr/"
one_ui=false
samsung=false
qcom=false
exynos=false
mtk=false
ppm=false
big_little=false
toptsdir="/dev/stune/top-app/tasks"
toptcdir="/dev/cpuset/top-app/tasks"
scrn_on=0
lib_ver="1.0.0"

# Log in white and continue (unnecessary)
kmsg() { echo -e "[$(date +%T)]: [*] $@" >>"${KLOG}"; }

kmsg1() { {
	echo -e "$@" >>"${KDBG}"
	echo -e "$@"
}; }

kmsg2() { {
	echo -e "[!] $@" >>"${KDBG}"
	echo -e "[!] $@"
}; }

kmsg3() { echo -e "$@" >>"${KLOG}"; }

# toasttext: <text content>
toast() { am start -a android.intent.action.MAIN -e toasttext "Applying ${ktsr_prof_en} profile..." -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_1() { am start -a android.intent.action.MAIN -e toasttext "${ktsr_prof_en} profile applied" -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_pt() { am start -a android.intent.action.MAIN -e toasttext "Aplicando perfil ${ktsr_prof_pt}..." -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_pt_1() { am start -a android.intent.action.MAIN -e toasttext "Perfil ${ktsr_prof_pt} aplicado" -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_tr() { am start -a android.intent.action.MAIN -e toasttext "${ktsr_prof_tr} profili uygulanıyor..." -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_tr_1() { am start -a android.intent.action.MAIN -e toasttext "${ktsr_prof_tr} profili uygulandı" -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_id() { am start -a android.intent.action.MAIN -e toasttext "Menerapkan profil ${ktsr_prof_id}..." -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_id_1() { am start -a android.intent.action.MAIN -e toasttext "Profil ${ktsr_prof_id} terpakai" -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_fr() { am start -a android.intent.action.MAIN -e toasttext "Chargement du profil ${ktsr_prof_tr}..." -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

toast_fr_1() { am start -a android.intent.action.MAIN -e toasttext "Profil ${ktsr_prof_fr} chargé" -n bellavita.toast/.MainActivity >/dev/null 2>&1; }

# write:$1 $2
write() {
	# Bail out if file does not exist
	if [[ ! -f "$1" ]]; then
		kmsg2 "$1 doesn't exist, skipping..."
		return 1
	fi

	# Make file writable in case it is not already
	chmod +rw "$1" 2>/dev/null

	# Fetch the current key value
	curval=$(cat "$1" 2>/dev/null)

	# Bail out if value is already set
	if [[ "${curval}" == "$2" ]]; then
		kmsg1 "$1 is already set to $2, skipping..."
		return 0
	fi

	# Write the new value and bail if there's an error
	if ! echo -n "$2" >"$1" 2>/dev/null; then
		kmsg2 "Failed: $1 -> $2"
		return 1
	fi

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
get_gpu_dir() {
	for gpul in /sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0/; do
		[[ -d "${gpul}" ]] && {
			gpu=${gpul}
			qcom=true
		}
	done

	for gpul1 in /sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0/; do
		[[ -d "${gpul1}" ]] && {
			gpu=${gpul1}
			qcom=true
		}
	done

	for gpul2 in /sys/devices/*.mali/; do
		[[ -d "${gpul2}" ]] && {
			gpu=${gpul2}
			qcom=false
		}
	done

	for gpul3 in /sys/devices/platform/*.gpu/; do
		[[ -d "${gpul3}" ]] && {
			gpu=${gpul3}
			qcom=false
		}
	done

	for gpul4 in /sys/devices/platform/mali-*/; do
		[[ -d "${gpul4}" ]] && {
			gpu=${gpul4}
			qcom=false
		}
	done

	for gpul5 in /sys/devices/platform/*.mali/; do
		[[ -d "${gpul5}" ]] && {
			gpu=${gpul5}
			qcom=false
		}
	done

	for gpul6 in /sys/class/misc/mali*/device/devfreq/gpufreq/; do
		[[ -d "${gpul6}" ]] && {
			gpu=${gpul6}
			qcom=false
		}
	done

	for gpul7 in /sys/class/misc/mali*/device/devfreq/*.gpu/; do
		[[ -d "${gpul7}" ]] && {
			gpu=${gpul7}
			qcom=false
		}
	done

	for gpul8 in /sys/devices/platform/*.mali/misc/mali0/; do
		[[ -d "${gpul8}" ]] && {
			gpu=${gpul8}
			qcom=false
		}
	done

	for gpul9 in /sys/devices/platform/mali.*/; do
		[[ -d "${gpul9}" ]] && {
			gpu=${gpul9}
			qcom=false
		}
	done

	for gpul10 in /sys/devices/platform/*.mali/devfreq/*.mali/subsystem/*.mali; do
		[[ -d "${gpul10}" ]] && {
			gpu=${gpul10}
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
		qcom=false

	elif [[ -d "/sys/class/misc/mali0/device" ]]; then
		gpu="/sys/class/misc/mali0/device/"
		qcom=false
	fi

	[[ -d "/sys/module/mali/parameters" ]] && {
		gpug="/sys/module/mali/parameters/"
		qcom=false
	}
	[[ -d "/sys/kernel/gpu" ]] && gpui="/sys/kernel/gpu/"
}

get_gpu_max() {
	gpu_max=${gpu_max_freq}

	if [[ "${gpu_max}" -lt "$(cat "${gpu}devfreq/available_frequencies" | awk -F ' ' '{print $NF}')" ]]; then
		gpu_max=$(cat "${gpu}devfreq/available_frequencies" | awk -F ' ' '{print $NF}')

	elif [[ "${gpu_max}" -lt "$(cat "${gpu}devfreq/available_frequencies" | awk '{print $1}')" ]]; then
		gpu_max=$(cat "${gpu}devfreq/available_frequencies" | awk '{print $1}')
	fi

	if [[ -e "${gpu}available_frequencies" ]] && [[ "${gpu_max}" -lt "$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $NF}')" ]]; then
		gpu_max=$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $NF}')

	elif [[ -e "${gpu}available_frequencies" ]] && [[ "${gpu_max}" -lt "$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $1}')" ]]; then
		gpu_max=$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $1}')

	elif [[ -e "${gpui}gpu_freq_table" ]] && [[ "${gpu_max}" -lt "$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $NF}')" ]]; then
		gpu_max=$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $NF}')

	elif [[ -e "${gpui}gpu_freq_table" ]] && [[ "${gpu_max}" -lt "$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $1}')" ]]; then
		gpu_max=$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $1}')
	fi
}

get_gpu_min() {
	gpu_min=${gpu_min_freq}

	if [[ -e "${gpu}available_frequencies" ]] && [[ "${gpu_min}" -gt "$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $1}')" ]]; then
		gpu_min=$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $1}')

	elif [[ -e "${gpu}available_frequencies" ]] && [[ "${gpu_min}" -gt "$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $NF}')" ]]; then
		gpu_min=$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $NF}')

	elif [[ -e "${gpui}gpu_freq_table" ]] && [[ "${gpu_min}" -gt "$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $1}')" ]]; then
		gpu_min=$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $1}')

	elif [[ -e "${gpui}gpu_freq_table" ]] && [[ "${gpu_min}" -gt "$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $NF}')" ]]; then
		gpu_min=$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $NF}')
	fi
}

# Fetch the CPU governor
get_cpu_gov() { cpu_gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor); }

get_gpu_gov() {
	# Fetch the GPU governor
	if [[ -e "${gpui}gpu_governor" ]]; then
		gpu_gov=$(cat "${gpui}gpu_governor")

	elif [[ -e "${gpu}governor" ]]; then
		gpu_gov=$(cat "${gpu}governor")

	elif [[ -e "${gpu}devfreq/governor" ]]; then
		gpu_gov=$(cat "${gpu}devfreq/governor")
	fi
}

define_gpu_pl() {
	# Fetch the amount of power levels from the GPU
	gpu_num_pl=$(cat "${gpu}num_pwrlevels")

	# Fetch the lower GPU power level
	gpu_min_pl=$((gpu_num_pl - 1))

	# Fetch the higher GPU power level
	gpu_max_pl=$(cat "${gpu}max_pwrlevel")
}

get_max_cpu_clk() {
	# Fetch max CPU clock
	cpu_max_freq=$(cat /sys/devices/system/cpu/cpu7/cpufreq/cpuinfo_max_freq)
	cpu_max_freq2=$(cat /sys/devices/system/cpu/cpu3/cpufreq/cpuinfo_max_freq)
	cpu_max_freq3=$(cat /sys/devices/system/cpu/cpu5/cpufreq/cpuinfo_max_freq)
	cpu_max_freq1=$(cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq)
	cpu_max_freq1_2=$(cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq)
	cpu_max_freq1_3=$(cat /sys/devices/system/cpu/cpu5/cpufreq/scaling_max_freq)

	[[ "${cpu_max_freq2}" -gt "${cpu_max_freq}" ]] && [[ "${cpu_max_freq2}" -gt "${cpu_max_freq3}" ]] && cpu_max_freq=${cpu_max_freq2}
	[[ "${cpu_max_freq3}" -gt "${cpu_max_freq}" ]] && [[ "${cpu_max_freq3}" -gt "${cpu_max_freq2}" ]] && cpu_max_freq=${cpu_max_freq3}
	[[ "${cpu_max_freq1_2}" -gt "${cpu_max_freq1}" ]] && [[ "${cpu_max_freq1_2}" -gt "${cpu_max_freq1_3}" ]] && cpu_max_freq1=${cpu_max_freq1_2}
	[[ "${cpu_max_freq1_3}" -gt "${cpu_max_freq1}" ]] && [[ "${cpu_max_freq1_3}" -gt "${cpu_max_freq1_2}" ]] && cpu_max_freq1=${cpu_max_freq1_3}
	[[ "${cpu_max_freq1}" -gt "${cpu_max_freq}" ]] && cpu_max_freq=${cpu_max_freq1}
}

get_min_cpu_clk() {
	# Fetch min CPU clock
	cpu_min_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
	cpu_min_freq2=$(cat /sys/devices/system/cpu/cpu5/cpufreq/cpuinfo_min_freq)
	cpu_min_freq1=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)
	cpu_min_freq1_2=$(cat /sys/devices/system/cpu/cpu5/cpufreq/scaling_min_freq)

	[[ "${cpu_min_freq2}" -lt "${cpu_min_freq}" ]] && cpu_min_freq=${cpu_min_freq2}
	[[ "${cpu_min_freq1_2}" -lt "${cpu_min_freq1}" ]] && cpu_min_freq1=${cpu_min_freq1_2}
	[[ "${cpu_min_freq1}" -lt "${cpu_min_freq}" ]] && cpu_min_freq=${cpu_min_freq1}
}

get_cpu_min_max_mhz() {
	# Fetch CPU min clock in MHz
	cpu_min_clk_mhz=$((cpu_min_freq / 1000))

	# Fetch CPU max clock in MHz
	cpu_max_clk_mhz=$((cpu_max_freq / 1000))
}

get_gpu_min_max() {
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
}

get_gpu_min_max_mhz() {
	# Fetch maximum & minimum GPU clock in MHz
	[[ "${gpu_max_freq}" -ge "100000" ]] && {
		gpu_max_clk_mhz=$((gpu_max_freq / 1000))
		gpu_min_clk_mhz=$((gpu_min_freq / 1000))
	}
	[[ "${gpu_max_freq}" -ge "100000000" ]] && {
		gpu_max_clk_mhz=$((gpu_max_freq / 1000000))
		gpu_min_clk_mhz=$((gpu_min_freq / 1000000))
	}
}

get_soc_mf() {
	soc_mf=$(getprop ro.soc.manufacturer)
	if [[ "${soc_mf}" == "" ]]; then
		soc_mf=$(getprop ro.boot.hardware)
	fi
}

get_soc() {
	# Fetch the device SOC
	soc=$(getprop ro.soc.model)
	[[ "${soc}" == "" ]] && soc=$(getprop ro.chipname)
	[[ "${soc}" == "" ]] && soc=$(getprop ro.board.platform)
	[[ "${soc}" == "" ]] && soc=$(getprop ro.product.board)
	[[ "${soc}" == "" ]] && soc=$(getprop ro.product.platform)
}

get_sdk() {
	# Fetch the device SDK
	sdk=$(getprop ro.build.version.sdk)
	[[ "${sdk}" == "" ]] && sdk=$(getprop ro.vendor.build.version.sdk)
	[[ "${sdk}" == "" ]] && sdk=$(getprop ro.vndk.version)
}

# Fetch the device architeture
get_arch() { arch=$(getprop ro.product.cpu.abi | awk -F "-" '{print $1}'); }

# Fetch the android version
get_andro_vs() { avs=$(getprop ro.build.version.release); }

# Fetch the device codename
get_dvc_cdn() { dvc_cdn=$(getprop ro.product.device); }

# Fetch root method
get_root() { root=$(su -v); }

is_qcom() { [[ "$(getprop ro.boot.hardware | grep qcom)" || [[ "$(getprop ro.soc.manufacturer | grep QTI)" ]] || [[ "$(getprop ro.hardware | grep qcom)" ]] || [[ "$(getprop ro.vendor.qti.soc_id)" ]] && qcom=true; }
# Detect if we're running on a exynos powered device
is_exynos() { [[ "$(getprop ro.boot.hardware | grep exynos)" ]] || [[ "$(getprop ro.board.platform | grep universal)" ]] || [[ "$(getprop ro.product.board | grep universal)" ]] && exynos=true; }

# Detect if we're running on a mediatek powered device
is_mtk() { [[ "$(getprop ro.board.platform | grep mt)" ]] || [[ "$(getprop ro.product.board | grep mt)" ]] || [[ "$(getprop ro.hardware | grep mt)" ]] || [[ "$(getprop ro.boot.hardware | grep mt)" ]] && mtk=true; }

detect_cpu_sched() {
	# Fetch the CPU scheduling type
	for cpu in $(cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_available_governors); do
		case "${cpu}" in
		*sched*) cpu_sched="EAS" ;;
		*util*) cpu_sched="EAS" ;;
		*interactive*) cpu_sched="HMP" ;;
		*) cpu_sched="Unknown" ;;
		esac
	done
}

get_kern_info() {
	# Fetch kernel name and version
	kern_ver_name=$(uname -r)
	# Fetch kernel build date
	kern_bd_dt=$(uname -v | awk '{print $5, $6, $7, $8, $9, $10}')
}

get_ram_info() { [[ "$(which busybox)" ]] && {
	total_ram=$(busybox free -m | awk '/Mem:/{print $2}')
	total_ram_kb=$(cat /proc/meminfo | awk '/kB/{print $2}' | grep [0-9] | head -n 1)
	avail_ram=$(busybox free -m | awk '/Mem:/{print $7}')
} || {
	total_ram="Please install busybox first"
	total_ram_kb="Please install busybox first"
	avail_ram="Please install busybox first"
}; }

# Fetch battery actual capacity
get_batt_pctg() { [[ -e "/sys/class/power_supply/battery/capacity" ]] && batt_pctg=$(cat /sys/class/power_supply/battery/capacity) || batt_pctg=$(dumpsys battery 2>/dev/null | awk '/level/{print $2}'); }

get_ktsr_info() {
	# Fetch build version
	bd_ver=$(grep version= "${MODPATH}module.prop" | sed "s/version=//" | awk -F "-" '{print $1}')
	# Fetch build type
	bd_rel=$(grep version= "${MODPATH}module.prop" | sed "s/version=//" | awk -F "-" '{print $2}')
	# Fetch build date
	bd_dt=$(grep build_date= "${MODPATH}module.prop" | sed "s/build_date=//")
	# Fetch build codename
	bd_cdn=$(grep version= "${MODPATH}module.prop" | sed "s/version=//" | awk -F "-" '{print $3}')
}

get_batt_tmp() {
	# Fetch battery temperature
	batt_tmp=$(dumpsys battery 2>/dev/null | awk '/temperature/{print $2}')
	[[ -e "/sys/class/power_supply/battery/temp" ]] && batt_tmp=$(cat /sys/class/power_supply/battery/temp) || [[ -e "/sys/class/power_supply/battery/batt_temp" ]] && batt_tmp=$(cat /sys/class/power_supply/battery/batt_temp)

	# Ignore the battery temperature decimal
	batt_tmp=$((batt_tmp / 10))
}

get_gpu_mdl() {
	# Fetch GPU model
	[[ "${exynos}" == "true" ]] || [[ "${mtk}" == "true" ]] && gpu_mdl=$(cat "${gpu}gpuinfo" | awk '{print $1,$2,$3}')
	[[ "${qcom}" == "true" ]] && gpu_mdl=$(cat "${gpui}gpu_model")
	[[ "${gpu_mdl}" == "" ]] && gpu_mdl=$(dumpsys SurfaceFlinger 2>/dev/null | awk '/GLES/ {print $3,$4,$5}' | tr -d ,)
}

# Fetch drivers info
get_drvs_info() { [[ "${exynos}" == "true" ]] || [[ "${mtk}" == "true" ]] && drvs_info=$(dumpsys SurfaceFlinger 2>/dev/null | awk '/GLES/ {print $4,5,$6,$7,$8,$9,$10,$11,$12,$13}') || drvs_info=$(dumpsys SurfaceFlinger 2>/dev/null | awk '/GLES/ {print $6,$7,$8,$9,$10,$11,$12,$13}' | tr -d ,); }

get_max_rr() {
	# Fetch max refresh rate
	rr=$(dumpsys display 2>/dev/null | awk '/PhysicalDisplayInfo/{print $4}' | cut -c1-3 | tr -d .)
	[[ -z "${rr}" ]] && rr=$(dumpsys display 2>/dev/null | grep refreshRate | awk -F '=' '{print $6}' | cut -c1-3 | tail -n 1 | tr -d .) || [[ -z "${rr}" ]] && rr=$(dumpsys display 2>/dev/null | grep FrameRate | awk -F '=' '{print $6}' | cut -c1-3 | tail -n 1 | tr -d .)
}

get_batt_hth() {
	# Fetch battery health
	batt_hth=$(dumpsys battery 2>/dev/null | awk '/health/{print $2}')
	[[ -e "/sys/class/power_supply/battery/health" ]] && batt_hth=$(cat /sys/class/power_supply/battery/health)
	case "${batt_hth}" in
	1) batt_hth="Unknown" ;;
	2) batt_hth="Good" ;;
	3) batt_hth="Overheat" ;;
	4) batt_hth="Dead" ;;
	5) batt_hth="OV" ;;
	6) batt_hth="UF" ;;
	7) batt_hth="Cold" ;;
	*) batt_hth=${batt_hth} ;;
	esac
}

get_batt_sts() {
	# Fetch battery status
	batt_sts=$(dumpsys battery 2>/dev/null | awk '/status/{print $2}')
	[[ -e "/sys/class/power_supply/battery/status" ]] && batt_sts=$(cat /sys/class/power_supply/battery/status)
	case "${batt_sts}" in
	1) batt_sts="Unknown" ;;
	2) batt_sts="Charging" ;;
	3) batt_sts="Discharging" ;;
	4) batt_sts="Not charging" ;;
	5) batt_sts="Full" ;;
	*) batt_sts=${batt_sts} ;;
	esac
}

get_batt_cpct() {
	batt_cpct=$(cat /sys/class/power_supply/battery/charge_full_design)
	[[ "${batt_cpct}" == "" ]] && batt_cpct=$(dumpsys batterystats 2>/dev/null | awk '/Capacity:/{print $2}' | cut -d "," -f 1)
	[[ "${batt_cpct}" -ge "1000000" ]] && batt_cpct=$((batt_cpct / 1000))
}

# Fetch busybox version
get_bb_ver() { [[ "$(which busybox)" ]] && bb_ver=$(busybox | awk 'NR==1{print $2}') || bb_ver="Please install busybox first"; }

# Fetch ROM info
get_rom_info() {
	rom_info=$(getprop ro.build.description | awk '{print $1,$3,$4,$5}')
	[[ "${rom_info}" == "" ]] && rom_info=$(getprop ro.bootimage.build.description | awk '{print $1,$3,$4,$5}')
	[[ "${rom_info}" == "" ]] && rom_info=$(getprop ro.system.build.description | awk '{print $1,$3,$4,$5}')
}

# Fetch SELinux state
get_slnx_stt() { [[ "$(cat /sys/fs/selinux/enforce)" == "1" ]] && slnx_stt="Enforcing" || slnx_stt="Permissive"; }

disable_adreno_gpu_thrtl() {
	gpu_thrtl_lvl=$(cat "${gpu}thermal_pwrlevel")
	[[ "${gpu_thrtl_lvl}" -eq "1" ]] || [[ "${gpu_thrtl_lvl}" -gt "1" ]] && gpu_calc_thrtl=$((gpu_thrtl_lvl - gpu_thrtl_lvl)) || gpu_calc_thrtl=0
}

get_gpu_load() {
	# Fetch GPU load
	if [[ -e "${gpui}gpu_busy_percentage" ]]; then
		gpu_load=$(cat "${gpui}gpu_busy_percentage" | tr -d %)

	elif [[ -e "${gpu}utilization" ]]; then
		gpu_load=$(cat "${gpu}utilization")

	elif [[ -e "/proc/mali/utilization" ]]; then
		gpu_load=$(cat /proc/mali/utilization)

	elif [[ -e "${gpu}load" ]]; then
		gpu_load=$(cat "${gpu}load" | tr -d %)

	elif [[ -e "${gpui}gpu_busy" ]]; then
		gpu_load=$(cat "${gpui}gpu_busy" | tr -d %)
	fi
}

get_nr_cores() {
	# Fetch the number of CPU cores
	nr_cores=$(cat /sys/devices/system/cpu/possible | awk -F "-" '{print $2}')
	nr_cores=$((nr_cores + 1))
}

# Fetch device brand
get_dvc_brnd() { dvc_brnd=$(getprop ro.product.brand); }

# Check if we're running on OneUI
check_one_ui() { [[ "$(getprop net.knoxscep.version)" ]] || [[ "$(getprop ril.product_code)" ]] || [[ "$(getprop ro.boot.em.model)" ]] || [[ "$(getprop net.knoxvpn.version)" ]] || [[ "$(getprop ro.securestorage.knox)" ]] || [[ "$(getprop gsm.version.ril-impl | grep Samsung)" ]] || [[ "$(getprop ro.build.PDA)" ]] && {
	one_ui=true
	samsung=true
}; }

get_bt_dvc() { bt_dvc=$(getprop ro.boot.bootdevice); }

# Fetch the amount of time since the system is running
get_uptime() { sys_uptime=$(uptime | awk '{print $3,$4}' | cut -d "," -f 1); }

get_sql_info() { [[ "$(which sqlite3)" ]] && {
	sql_ver=$(sqlite3 -version | awk '{print $1}')
	sql_bd_dt=$(sqlite3 -version | awk '{print $2,$3}')
} || {
	sql_ver="Please install SQLite3 first"
	sql_bd_dt="Please install SQLite3 first"
}; }

get_cpu_load() {
	# Calculate CPU load (50 ms)
	read -r cpu user nice system idle iowait irq softirq steal guest </proc/stat
	cpu_active_prev=$((user + system + nice + softirq + steal))
	cpu_total_prev=$((user + system + nice + softirq + steal + idle + iowait))
	usleep 50000
	read -r cpu user nice system idle iowait irq softirq steal guest </proc/stat
	cpu_active_cur=$((user + system + nice + softirq + steal))
	cpu_total_cur=$((user + system + nice + softirq + steal + idle + iowait))
	cpu_load=$((100 * (cpu_active_cur - cpu_active_prev) / (cpu_total_cur - cpu_total_prev)))
}

check_ppm_support() { [[ -d "/proc/ppm/" ]] && [[ "${mtk}" == "true" ]] && ppm=true; }

is_big_little() {
	for i in 1 2 3 4 5 6 7; do
		[[ -d "/sys/devices/system/cpu/cpufreq/policy0/" ]] && [[ -d "/sys/devices/system/cpu/cpufreq/policy${i}/" ]] && big_little=true
	done
}

enable_devfreq_boost() {
	for dir in /sys/class/devfreq/*/; do
		max_devfreq=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $NF}')
		max_devfreq2=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $1}')
		[[ "${max_devfreq2}" -gt "${max_devfreq}" ]] && max_devfreq=${max_devfreq2}
		write "${dir}min_freq" "${max_devfreq}"
	done

	kmsg "Enabled devfreq boost"
	kmsg3 ""
}

disable_devfreq_boost() {
	for dir in /sys/class/devfreq/*/; do
		min_devfreq=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $1}')
		min_devfreq2=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $NF}')
		[[ "${min_devfreq2}" -lt "${min_devfreq}" ]] && min_devfreq=${min_devfreq2}
		write "${dir}min_freq" "${min_devfreq}"
	done

	kmsg "Disabled devfreq boost"
	kmsg3 ""
}

print_info() {
	kmsg3 ""
	kmsg "General Info"

	kmsg3 ""
	kmsg3 "** Date of execution: $(date)"
	kmsg3 "** Kernel: ${kern_ver_name}"
	kmsg3 "** Kernel Build Date: ${kern_bd_dt}"
	kmsg3 "** SOC: ${soc_mf}, ${soc}"
	kmsg3 "** SDK: ${sdk}"
	kmsg3 "** Android Version: ${avs}"
	kmsg3 "** CPU Governor: ${cpu_gov}"
	kmsg3 "** CPU Load: ${cpu_load}%"
	kmsg3 "** Number of cores: ${nr_cores}"
	kmsg3 "** CPU Freq: ${cpu_min_clk_mhz}-${cpu_max_clk_mhz}MHz"
	kmsg3 "** CPU Scheduling Type: ${cpu_sched}"
	kmsg3 "** AArch: ${arch}"
	kmsg3 "** GPU Load: ${gpu_load}%"
	kmsg3 "** GPU Freq: ${gpu_min_clk_mhz}-${gpu_max_clk_mhz}MHz"
	kmsg3 "** GPU Model: ${gpu_mdl}"
	kmsg3 "** GPU Drivers Info: ${drvs_info}"
	kmsg3 "** GPU Governor: ${gpu_gov}"
	kmsg3 "** Device: ${dvc_brnd}, ${dvc_cdn}"
	kmsg3 "** ROM: ${rom_info}"
	kmsg3 "** Screen Resolution: $(wm size | awk '{print $3}' | tail -n 1)"
	kmsg3 "** Screen Density: $(wm density | awk '{print $3}' | tail -n 1) PPI"
	kmsg3 "** Refresh Rate: ${rr}HZ"
	kmsg3 "** Build Version: ${bd_ver}"
	kmsg3 "** Build Codename: ${bd_cdn}"
	kmsg3 "** Build Release: ${bd_rel}"
	kmsg3 "** Build Date: ${bd_dt}"
	kmsg3 "** Lib Version: ${lib_ver}"
	kmsg3 "** Battery Charge Level: ${batt_pctg}%"
	kmsg3 "** Battery Capacity: ${batt_cpct}mAh"
	kmsg3 "** Battery Health: ${batt_hth}"
	kmsg3 "** Battery Status: ${batt_sts}"
	kmsg3 "** Battery Temperature: ${batt_tmp}°C"
	kmsg3 "** Device RAM: ${total_ram}MB"
	kmsg3 "** Device Available RAM: ${avail_ram}MB"
	kmsg3 "** Root: ${root}"
	kmsg3 "** SQLite Version: ${sql_ver}"
	kmsg3 "** SQLite Build Date: ${sql_bd_dt}"
	kmsg3 "** System Uptime: ${sys_uptime}"
	kmsg3 "** SELinux: ${slnx_stt}"
	kmsg3 "** Busybox: ${bb_ver}"
	kmsg3 ""
	kmsg3 "** Author: Pedro | https://t.me/pedro3z0 | https://github.com/pedrozzz0"
	kmsg3 "** Telegram Channel: https://t.me/kingprojectz"
	kmsg3 "** Telegram Group: https://t.me/kingprojectzdiscussion"
	kmsg3 "** Credits to all people involved to make it possible."
	kmsg3 ""
}

stop_services() {
	# Enable / disable mpdecision, and disable few debug services
	#for v in 0 1 2 3 4; do
	#stop vendor.qti.hardware.perf@${v}.${v}-service 2>/dev/null
	#stop perf-hal-${v}-${v} 2>/dev/null
	#done
	#stop perfd 2>/dev/null
	[[ "${ktsr_prof_en}" == "battery" ]] || [[ "$(getprop kingauto.prof)" == "battery" ]] && start mpdecision 2>/dev/null || stop mpdecision 2>/dev/null
	# stop vendor.perfservice 2>/dev/null
	stop vendor.cnss_diag 2>/dev/null
	stop vendor.tcpdump 2>/dev/null
	stop charge_logger 2>/dev/null
	stop oneplus_brain_service 2>/dev/null
	[[ "${ktsr_prof_en}" == "extreme" ]] || [[ "${ktsr_prof_en}" == "gaming" ]] || [[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]] && {
		stop thermal 2>/dev/null
		stop thermald 2>/dev/null
		stop thermalservice 2>/dev/null
		stop mi_thermald 2>/dev/null
		stop thermal-engine 2>/dev/null
		stop vendor.thermal-engine 2>/dev/null
		stop thermanager 2>/dev/null
		stop thermal_manager 2>/dev/null
	} || {
		start thermal 2>/dev/null
		start thermald 2>/dev/null
		start thermalservice 2>/dev/null
		start mi_thermald 2>/dev/null
		start thermal-engine 2>/dev/null
		start vendor.thermal-engine 2>/dev/null
		start thermanager 2>/dev/null
		start thermal_manager 2>/dev/null
	}
	[[ -e "/data/system/perfd/default_values" ]] && rm -rf "/data/system/perfd/default_values"
	[[ -e "/data/vendor/perfd/default_values" ]] && rm -rf "/data/vendor/perfd/default_values"

	kmsg "Disabled few debug services"
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
	for core_ctl in /sys/devices/system/cpu/cpu*/core_ctl/; do
		[[ -e "${core_ctl}enable" ]] && write "${core_ctl}enable" "1"
		[[ -e "${core_ctl}disable" ]] && write "${core_ctl}disable" "0"
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
config_cpuset() {
	case "${soc}" in
	"msm8937")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-3,6-7"
		write "${cpuset}background/cpus" "0-1"
		write "${cpuset}system-background/cpus" "0-3"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "0-3"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"msm8952")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-3,6-7"
		write "${cpuset}background/cpus" "0-1"
		write "${cpuset}system-background/cpus" "0-3"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "0-3"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"msm8953")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-3,6-7"
		write "${cpuset}background/cpus" "0-1"
		write "${cpuset}system-background/cpus" "0-3"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "0-3"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"msm8996")
		write "${cpuset}camera-daemon/cpus" "0-3"
		write "${cpuset}foreground/cpus" "0-3"
		write "${cpuset}foreground/boost/cpus" "0-3"
		write "${cpuset}background/cpus" "0-3"
		write "${cpuset}system-background/cpus" "0-3"
		write "${cpuset}top-app/cpus" "0-3"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"msm8998")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-3,6-7"
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
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"SM8150")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-5,7"
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"mt6768")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-7"
		write "${cpuset}background/cpus" "0-1"
		write "${cpuset}system-background/cpus" "0-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "0-3"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"mt6785")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-7"
		write "${cpuset}background/cpus" "0-1"
		write "${cpuset}system-background/cpus" "0-5"
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
		write "${cpuset}foreground/cpus" "0-5,7"
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"sdm845")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-3,6-7"
		write "${cpuset}background/cpus" "0-1"
		write "${cpuset}system-background/cpus" "0-3"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "0-3"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"sm6150")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-5,7"
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"lito")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-5,7"
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"SM7250")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-5,7"
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"SM6350")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}camera-daemon-dedicated/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-5,7"
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"lahaina")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-5,7"
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "0-3"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "0-3"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"SM8350")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-5,7"
		write "${cpuset}background/cpus" "4-5"
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
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}dex2oat/cpus" "0-6"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"trinket")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-7"
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"SM6250")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-7"
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"bengal")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-7"
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"SM6115")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-7"
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"kona")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-5,7"
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"SM8250")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-5,7"
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"universal9811")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-7"
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}dexopt/cpus" "0-6"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"universal9820")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-7"
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}dexopt/cpus" "0-6"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"atoll")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-5,7"
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	"SM7125")
		write "${cpuset}camera-daemon/cpus" "0-7"
		write "${cpuset}foreground/cpus" "0-5,7"
		write "${cpuset}background/cpus" "4-5"
		write "${cpuset}system-background/cpus" "2-5"
		write "${cpuset}top-app/cpus" "0-7"
		write "${cpuset}restricted/cpus" "2-5"
		kmsg "Tweaked cpusets"
		kmsg3 ""
		;;
	esac
}

boost_latency() {
	if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]; then
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "15"
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1000"
		kmsg "Tweaked dynamic stune boost"
		kmsg3 ""
	fi

	if [[ -d "/sys/module/cpu_boost/" ]]; then
		write "/sys/module/cpu_boost/parameters/input_boost_ms" "156"
		write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_powerkey_input" "Y"
		write "/sys/module/cpu_boost/parameters/powerkey_input_boost_ms" "750"
		kmsg "Tweaked CAF CPU input boost"
		kmsg3 ""

	elif [[ -d "/sys/module/cpu_input_boost/" ]]; then
		write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "156"
		kmsg "Tweaked CPU input boost"
		kmsg3 ""
	fi
}

boost_balanced() {
	if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]; then
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "10"
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1000"
		kmsg "Tweaked dynamic stune boost"
		kmsg3 ""
	fi

	if [[ -d "/sys/module/cpu_boost/" ]]; then
		write "/sys/module/cpu_boost/parameters/input_boost_ms" "100"
		write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_powerkey_input" "Y"
		write "/sys/module/cpu_boost/parameters/powerkey_input_boost_ms" "750"
		kmsg "Tweaked CAF CPU input boost"
		kmsg3 ""

	elif [[ -d "/sys/module/cpu_input_boost/" ]]; then
		write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "100"
		kmsg "Tweaked CPU input boost"
		kmsg3 ""
	fi
}

boost_extreme() {
	if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]; then
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "50"
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1000"
		kmsg "Tweaked dynamic stune boost"
		kmsg3 ""
	fi

	if [[ -d "/sys/module/cpu_boost/" ]]; then
		write "/sys/module/cpu_boost/parameters/input_boost_ms" "0"
		write "/sys/module/cpu_boost/parameters/input_boost_enabled" "0"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_powerkey_input" "N"
		write "/sys/module/cpu_boost/parameters/powerkey_input_boost_ms" "0"
		kmsg "Tweaked CAF CPU input boost"
		kmsg3 ""

	elif [[ -d "/sys/module/cpu_input_boost/" ]]; then
		write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "0"
		kmsg "Tweaked CPU input boost"
		kmsg3 ""
	fi
}

boost_battery() {
	if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]; then
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "1"
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1000"
		kmsg "Tweaked dynamic stune boost"
		kmsg3 ""
	fi

	if [[ -e "/sys/module/cpu_boost/parameters/" ]]; then
		write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
		write "/sys/module/cpu_boost/parameters/input_boost_ms" "64"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_powerkey_input" "Y"
		write "/sys/module/cpu_boost/parameters/powerkey_input_boost_ms" "750"
		kmsg "Tweaked CAF CPU input boost"
		kmsg3 ""
	fi

	if [[ -e "/sys/module/cpu_input_boost/parameters/" ]]; then
		write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "64"
		kmsg "Tweaked CPU input boost"
		kmsg3 ""
	fi
}

boost_gaming() {
	if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]; then
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "50"
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1000"
		kmsg "Tweaked dynamic stune boost"
		kmsg3 ""
	fi

	if [[ -d "/sys/module/cpu_boost/" ]]; then
		write "/sys/module/cpu_boost/parameters/input_boost_ms" "0"
		write "/sys/module/cpu_boost/parameters/input_boost_enabled" "0"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_powerkey_input" "0"
		write "/sys/module/cpu_boost/parameters/powerkey_input_boost_ms" "0"
		kmsg "Tweaked CAF CPU input boost"
		kmsg3 ""

	elif [[ -d "/sys/module/cpu_input_boost/" ]]; then
		write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "0"
		kmsg "Tweaked CPU input boost"
		kmsg3 ""
	fi
}

io_latency() {
	# I/O Scheduler tweaks
	for queue in /sys/block/*/queue/; do
		# Fetch the available schedulers from the block
		avail_scheds="$(cat "${queue}scheduler")"

		# Select the first scheduler available
		for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
			[[ "${avail_scheds}" == *"$sched"* ]] && write "${queue}scheduler" "${sched}"
			break
		done

		write "${queue}add_random" "0"
		write "${queue}iostats" "0"
		write "${queue}rotational" "0"
		write "${queue}read_ahead_kb" "32"
		write "${queue}nomerges" "0"
		write "${queue}rq_affinity" "2"
		write "${queue}nr_requests" "32"
	done

	kmsg "Tweaked I/O scheduler"
	kmsg3 ""
}

io_balanced() {
	for queue in /sys/block/*/queue/; do
		avail_scheds="$(cat "${queue}scheduler")"

		for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
			[[ "${avail_scheds}" == *"$sched"* ]] && write "${queue}scheduler" "${sched}"
			break
		done

		write "${queue}add_random" "0"
		write "${queue}iostats" "0"
		write "${queue}rotational" "0"
		write "${queue}read_ahead_kb" "64"
		write "${queue}nomerges" "0"
		write "${queue}rq_affinity" "1"
		write "${queue}nr_requests" "128"
	done

	kmsg "Tweaked I/O scheduler"
	kmsg3 ""
}

io_extreme() {
	for queue in /sys/block/*/queue/; do
		avail_scheds="$(cat "${queue}scheduler")"

		for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid anxiety mq-deadline deadline cfq noop none; do
			[[ "${avail_scheds}" == *"$sched"* ]] && "${queue}scheduler" "${sched}"
			break
		done

		write "${queue}add_random" "0"
		write "${queue}iostats" "0"
		write "${queue}rotational" "0"
		write "${queue}read_ahead_kb" "512"
		write "${queue}nomerges" "2"
		write "${queue}rq_affinity" "2"
		write "${queue}nr_requests" "256"
	done

	kmsg "Tweaked I/O scheduler"
	kmsg3 ""
}

io_battery() {
	for queue in /sys/block/*/queue/; do
		avail_scheds="$(cat "${queue}scheduler")"

		for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
			[[ "${avail_scheds}" == *"$sched"* ]] && "${queue}scheduler" "${sched}"
			break
		done

		write "${queue}add_random" "0"
		write "${queue}iostats" "0"
		write "${queue}rotational" "0"
		write "${queue}read_ahead_kb" "64"
		write "${queue}nomerges" "0"
		write "${queue}rq_affinity" "0"
		write "${queue}nr_requests" "512"
	done

	kmsg "Tweaked I/O scheduler"
	kmsg3 ""
}

io_gaming() {
	for queue in /sys/block/*/queue/; do
		avail_scheds="$(cat "${queue}scheduler")"

		for sched in sio fiops bfq-sq bfq-mq bfq tripndroid maple zen anxiety mq-deadline deadline cfq noop none; do
			[[ "${avail_scheds}" == *"$sched"* ]] && write "${queue}scheduler" "${sched}"
			break
		done

		write "${queue}add_random" "0"
		write "${queue}iostats" "0"
		write "${queue}rotational" "0"
		write "${queue}read_ahead_kb" "512"
		write "${queue}nomerges" "2"
		write "${queue}rq_affinity" "2"
		write "${queue}nr_requests" "256"
	done

	kmsg "Tweaked I/O scheduler"
	kmsg3 ""
}

cpu_latency() {
	# CPU tweaks
	for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
		# Fetch the available governors from the CPU
		avail_govs="$(cat "${cpu}/scaling_available_governors")"

		# Attempt to set the governor in this order
		for governor in sched_pixel schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive; do
			# Once a matching governor is found, set it and break for this CPU
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${cpu}scaling_governor" "${governor}"
				break
			fi
		done
	done

	# Apply governor specific tunables for schedutil, or it's modifications
	for governor in $(find /sys/devices/system/cpu/ -name *util* -type d); do
		write "${governor}/up_rate_limit_us" "0"
		write "${governor}/down_rate_limit_us" "0"
		write "${governor}/pl" "1"
		write "${governor}/iowait_boost_enable" "1"
		write "${governor}/rate_limit_us" "0"
		write "${governor}/hispeed_load" "85"
		write "${governor}/hispeed_freq" "${cpu_max_freq}"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d); do
		write "${governor}/up_rate_limit_us" "0"
		write "${governor}/down_rate_limit_us" "0"
		write "${governor}/pl" "1"
		write "${governor}/iowait_boost_enable" "1"
		write "${governor}/rate_limit_us" "0"
		write "${governor}/hispeed_load" "85"
		write "${governor}/hispeed_freq" "${cpu_max_freq}"
	done

	# Apply governor specific tunables for interactive
	for governor in $(find /sys/devices/system/cpu/ -name *interactive* -type d); do
		write "${governor}/timer_rate" "0"
		write "${governor}/boost" "0"
		write "${governor}/io_is_busy" "1"
		write "${governor}/timer_slack" "0"
		write "${governor}/input_boost" "0"
		write "${governor}/use_migration_notif" "0"
		write "${governor}/ignore_hispeed_on_notif" "1"
		write "${governor}/use_sched_load" "1"
		write "${governor}/fastlane" "1"
		write "${governor}/fast_ramp_down" "0"
		write "${governor}/sampling_rate" "0"
		write "${governor}/sampling_rate_min" "0"
		write "${governor}/min_sample_time" "0"
		write "${governor}/go_hispeed_load" "85"
		write "${governor}/hispeed_freq" "${cpu_max_freq}"
	done
}

cpu_balanced() {
	for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
		avail_govs="$(cat "${cpu}scaling_available_governors")"

		for governor in sched_pixel schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${cpu}scaling_governor" "${governor}"
				break
			fi
		done
	done

	for governor in $(find /sys/devices/system/cpu/ -name *util* -type d); do
		write "${governor}/up_rate_limit_us" "500"
		write "${governor}/down_rate_limit_us" "20000"
		write "${governor}/pl" "1"
		write "${governor}/iowait_boost_enable" "0"
		write "${governor}/rate_limit_us" "20000"
		write "${governor}/hispeed_load" "89"
		write "${governor}/hispeed_freq" "${cpu_max_freq}"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d); do
		write "${governor}/up_rate_limit_us" "500"
		write "${governor}/down_rate_limit_us" "20000"
		write "${governor}/pl" "1"
		write "${governor}/iowait_boost_enable" "0"
		write "${governor}/rate_limit_us" "20000"
		write "${governor}/hispeed_load" "89"
		write "${governor}/hispeed_freq" "${cpu_max_freq}"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *interactive* -type d); do
		write "${governor}/timer_rate" "20000"
		write "${governor}/boost" "0"
		write "${governor}/io_is_busy" "1"
		write "${governor}/timer_slack" "2000"
		write "${governor}/input_boost" "0"
		write "${governor}/use_migration_notif" "0"
		write "${governor}/ignore_hispeed_on_notif" "1"
		write "${governor}/use_sched_load" "1"
		write "${governor}/boostpulse" "0"
		write "${governor}/fastlane" "1"
		write "${governor}/fast_ramp_down" "0"
		write "${governor}/sampling_rate" "20000"
		write "${governor}/sampling_rate_min" "20000"
		write "${governor}/min_sample_time" "20000"
		write "${governor}/go_hispeed_load" "80"
		write "${governor}/hispeed_freq" "${cpu_max_freq}"
	done
}

cpu_extreme() {
	for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
		avail_govs="$(cat "${cpu}scaling_available_governors")"

		for governor in performance sched_pixel schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${cpu}scaling_governor" "${governor}"
				break
			fi
		done
	done

	for governor in $(find /sys/devices/system/cpu/ -name *util* -type d); do
		write "${governor}/up_rate_limit_us" "0"
		write "${governor}/down_rate_limit_us" "0"
		write "${governor}/pl" "1"
		write "${governor}/iowait_boost_enable" "1"
		write "${governor}/rate_limit_us" "0"
		write "${governor}/hispeed_load" "99"
		write "${governor}/hispeed_freq" "${cpu_max_freq}"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d); do
		write "${governor}/up_rate_limit_us" "0"
		write "${governor}/down_rate_limit_us" "0"
		write "${governor}/pl" "1"
		write "${governor}/iowait_boost_enable" "1"
		write "${governor}/rate_limit_us" "0"
		write "${governor}/hispeed_load" "99"
		write "${governor}/hispeed_freq" "${cpu_max_freq}"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *interactive* -type d); do
		write "${governor}/timer_rate" "0"
		write "${governor}/boost" "0"
		write "${governor}/io_is_busy" "1"
		write "${governor}/timer_slack" "0"
		write "${governor}/input_boost" "0"
		write "${governor}/use_migration_notif" "0"
		write "${governor}/ignore_hispeed_on_notif" "1"
		write "${governor}/use_sched_load" "1"
		write "${governor}/fastlane" "1"
		write "${governor}/fast_ramp_down" "0"
		write "${governor}/sampling_rate" "0"
		write "${governor}/sampling_rate_min" "0"
		write "${governor}/min_sample_time" "0"
		write "${governor}/go_hispeed_load" "99"
		write "${governor}/hispeed_freq" "${cpu_max_freq}"
	done
}

cpu_battery() {
	for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
		avail_govs="$(cat "${cpu}scaling_available_governors")"

		for governor in sched_pixel schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${cpu}scaling_governor" "${governor}"
				break
			fi
		done
	done

	for governor in $(find /sys/devices/system/cpu/ -name *util* -type d); do
		write "${governor}/up_rate_limit_us" "4500"
		write "${governor}/down_rate_limit_us" "16000"
		write "${governor}/pl" "1"
		write "${governor}/iowait_boost_enable" "0"
		write "${governor}/rate_limit_us" "16000"
		write "${governor}/hispeed_load" "99"
		write "${governor}/hispeed_freq" "${cpu_max_freq}"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d); do
		write "${governor}/up_rate_limit_us" "4500"
		write "${governor}/down_rate_limit_us" "16000"
		write "${governor}/pl" "1"
		write "${governor}/iowait_boost_enable" "0"
		write "${governor}/rate_limit_us" "16000"
		write "${governor}/hispeed_load" "99"
		write "${governor}/hispeed_freq" "${cpu_max_freq}"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *interactive* -type d); do
		write "${governor}/timer_rate" "16000"
		write "${governor}/boost" "0"
		write "${governor}/io_is_busy" "1"
		write "${governor}/timer_slack" "4000"
		write "${governor}/input_boost" "0"
		write "${governor}/use_migration_notif" "0"
		write "${governor}/ignore_hispeed_on_notif" "1"
		write "${governor}/use_sched_load" "1"
		write "${governor}/boostpulse" "0"
		write "${governor}/fastlane" "1"
		write "${governor}/fast_ramp_down" "1"
		write "${governor}/sampling_rate" "16000"
		write "${governor}/sampling_rate_min" "20000"
		write "${governor}/min_sample_time" "20000"
		write "${governor}/go_hispeed_load" "99"
		write "${governor}/hispeed_freq" "${cpu_max_freq}"
	done
}

cpu_gaming() {
	for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
		avail_govs="$(cat "${cpu}scaling_available_governors")"

		for governor in performance sched_pixel schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${cpu}scaling_governor" "${governor}"
				break
			fi
		done
	done

	for governor in $(find /sys/devices/system/cpu/ -name *util* -type d); do
		write "${governor}/up_rate_limit_us" "0"
		write "${governor}/down_rate_limit_us" "0"
		write "${governor}/pl" "1"
		write "${governor}/iowait_boost_enable" "1"
		write "${governor}/rate_limit_us" "0"
		write "${governor}/hispeed_load" "99"
		write "${governor}/hispeed_freq" "${cpu_max_freq}"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d); do
		write "${governor}/up_rate_limit_us" "0"
		write "${governor}/down_rate_limit_us" "0"
		write "${governor}/pl" "1"
		write "${governor}/iowait_boost_enable" "1"
		write "${governor}/rate_limit_us" "0"
		write "${governor}/hispeed_load" "99"
		write "${governor}/hispeed_freq" "${cpu_max_freq}"
	done

	for governor in $(find /sys/devices/system/cpu/ -name *interactive* -type d); do
		write "${governor}/timer_rate" "0"
		write "${governor}/boost" "0"
		write "${governor}/io_is_busy" "1"
		write "${governor}/timer_slack" "0"
		write "${governor}/input_boost" "0"
		write "${governor}/use_migration_notif" "0"
		write "${governor}/ignore_hispeed_on_notif" "1"
		write "${governor}/use_sched_load" "1"
		write "${governor}/fastlane" "1"
		write "${governor}/fast_ramp_down" "0"
		write "${governor}/sampling_rate" "0"
		write "${governor}/sampling_rate_min" "0"
		write "${governor}/min_sample_time" "0"
		write "${governor}/go_hispeed_load" "99"
		write "${governor}/hispeed_freq" "${cpu_max_freq}"
	done
}

misc_cpu_default() {
	[[ -e "/proc/cpufreq/cpufreq_power_mode" ]] && write "/proc/cpufreq/cpufreq_power_mode" "0"
	[[ -e "/proc/cpufreq/cpufreq_cci_mode" ]] && write "/proc/cpufreq/cpufreq_cci_mode" "0"
	[[ -e "/proc/cpufreq/cpufreq_stress_test" ]] && write "/proc/cpufreq/cpufreq_stress_test" "0"
	[[ -e "/proc/cpufreq/cpufreq_sched_disable" ]] && write "/proc/cpufreq/cpufreq_sched_disable" "0"
}

misc_cpu_max_pwr() {
	[[ -e "/proc/cpufreq/cpufreq_power_mode" ]] && write "/proc/cpufreq/cpufreq_power_mode" "3"
	[[ -e "/proc/cpufreq/cpufreq_cci_mode" ]] && write "/proc/cpufreq/cpufreq_cci_mode" "1"
	[[ -e "/proc/cpufreq/cpufreq_stress_test" ]] && write "/proc/cpufreq/cpufreq_stress_test" "1"
	[[ -e "/proc/cpufreq/cpufreq_sched_disable" ]] && write "/proc/cpufreq/cpufreq_sched_disable" "0"
}

misc_cpu_pwr_saving() {
	[[ -e "/proc/cpufreq/cpufreq_power_mode" ]] && write "/proc/cpufreq/cpufreq_power_mode" "1"
	[[ -e "/proc/cpufreq/cpufreq_cci_mode" ]] && write "/proc/cpufreq/cpufreq_cci_mode" "0"
	[[ -e "/proc/cpufreq/cpufreq_stress_test" ]] && write "/proc/cpufreq/cpufreq_stress_test" "0"
	[[ -e "/proc/cpufreq/cpufreq_sched_disable" ]] && write "/proc/cpufreq/cpufreq_sched_disable" "0"
}

bring_all_cores() {
	for i in 0 1 2 3 4 5 6 7 8 9; do
		write "/sys/devices/system/cpu/cpu$i/online" "1"
	done
}

enable_ppm() {
	[[ "${ppm}" == "true" ]] && write "/proc/ppm/enabled" "1"
	kmsg "Tweaked CPU parameters"
	kmsg3 ""
}

disable_ppm() {
	[[ "${ppm}" == "true" ]] && write "/proc/ppm/enabled" "0"
	kmsg "Tweaked CPU parameters"
	kmsg3 ""
}

hmp_balanced() {
	if [[ -d "/sys/kernel/hmp/" ]]; then
		write "/sys/kernel/hmp/boost" "0"
		write "/sys/kernel/hmp/down_compensation_enabled" "1"
		write "/sys/kernel/hmp/family_boost" "0"
		write "/sys/kernel/hmp/semiboost" "0"
		write "/sys/kernel/hmp/up_threshold" "658"
		write "/sys/kernel/hmp/down_threshold" "256"
		kmsg "Tweaked HMP parameters"
		kmsg3 ""
	fi
}

hmp_extreme() {
	if [[ -d "/sys/kernel/hmp/" ]]; then
		write "/sys/kernel/hmp/boost" "1"
		write "/sys/kernel/hmp/down_compensation_enabled" "1"
		write "/sys/kernel/hmp/family_boost" "1"
		write "/sys/kernel/hmp/semiboost" "1"
		write "/sys/kernel/hmp/up_threshold" "500"
		write "/sys/kernel/hmp/down_threshold" "150"
		kmsg "Tweaked HMP parameters"
		kmsg3 ""
	fi
}

hmp_battery() {
	if [[ -d "/sys/kernel/hmp/" ]]; then
		write "/sys/kernel/hmp/boost" "0"
		write "/sys/kernel/hmp/down_compensation_enabled" "1"
		write "/sys/kernel/hmp/family_boost" "0"
		write "/sys/kernel/hmp/semiboost" "0"
		write "/sys/kernel/hmp/up_threshold" "789"
		write "/sys/kernel/hmp/down_threshold" "303"
		kmsg "Tweaked HMP parameters"
		kmsg3 ""
	fi
}

hmp_gaming() {
	if [[ -d "/sys/kernel/hmp/" ]]; then
		write "/sys/kernel/hmp/boost" "1"
		write "/sys/kernel/hmp/down_compensation_enabled" "1"
		write "/sys/kernel/hmp/family_boost" "1"
		write "/sys/kernel/hmp/semiboost" "1"
		write "/sys/kernel/hmp/up_threshold" "400"
		write "/sys/kernel/hmp/down_threshold" "125"
		kmsg "Tweaked HMP parameters"
		kmsg3 ""
	fi
}

gpu_latency() {
	# GPU tweaks

	if [[ "${qcom}" == "true" ]]; then
		# Fetch the available governors from the GPU
		avail_govs="$(cat "${gpu}devfreq/available_governors")"

		# Attempt to set the governor in this order
		for governor in msm-adreno-tz simple_ondemand ondemand; do
			# Once a matching governor is found, set it and break
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${gpu}devfreq/governor" "${governor}"
				break
			fi
		done

	elif [[ "${exynos}" == "true" ]]; then
		avail_govs="$(cat "${gpui}gpu_available_governor")"

		for governor in Interactive Dynamic Static ondemand; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "${governor}"
				break
			fi
		done

	elif [[ "${mtk}" == "true" ]]; then
		avail_govs="$(cat "${gpu}available_governors")"

		for governor in Interactive Dynamic Static ondemand; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "${governor}"
				break
			fi
		done
	fi

	if [[ "${qcom}" == "true" ]]; then
		write "${gpu}throttling" "1"
		write "${gpu}thermal_pwrlevel" "${gpu_calc_thrtl}"
		write "${gpu}devfreq/adrenoboost" "0"
		write "${gpu}force_no_nap" "0"
		write "${gpu}bus_split" "0"
		write "${gpu}devfreq/max_freq" "${gpu_max_freq}"
		write "${gpu}devfreq/min_freq" "${gpu_min_freq}"
		write "${gpu}min_pwrlevel" "$((gpu_min_pl - 2))"
		write "${gpu}force_bus_on" "0"
		write "${gpu}force_clk_on" "0"
		write "${gpu}force_rail_on" "0"
		write "${gpu}idle_timer" "100"
		write "${gpu}pwrnap" "1"
		write "${gpu}pwrscale" "1"
	elif [[ "${qcom}" == "false" ]]; then
		[[ "${one_ui}" == "false" ]] && write "${gpu}dvfs" "1"
		write "${gpui}gpu_max_clock" "${gpu_max_freq}"
		write "${gpui}gpu_min_clock" "${gpu_min}"
		write "${gpu}highspeed_clock" "${gpu_max_freq}"
		write "${gpu}highspeed_load" "80"
		write "${gpu}highspeed_delay" "0"
		write "${gpu}power_policy" "always_on"
		write "${gpui}boost" "0"
		write "${gpu}cl_boost_disable" "0"
		write "${gpug}mali_touch_boost_level" "0"
		write "${gpu}max_freq" "${gpu_max_freq}"
		write "${gpu}min_freq" "${gpu_min}"
		write "${gpu}tmu" "1"
		write "${gpu}devfreq/gpufreq/max_freq" "${gpu_max_freq}"
		write "${gpu}devfreq/gpufreq/min_freq" "${gpu_min}"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync" "1"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_upthreshold" "60"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_downdifferential" "40"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold" "50"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential" "30"
	fi

	if [[ -d "/sys/module/ged/" ]]; then
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
		write "/sys/module/ged/parameters/ged_smart_boost" "0"
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
	fi

	if [[ -d "/proc/gpufreq/" ]]; then
		write "/proc/gpufreq/gpufreq_opp_stress_test" "0"
		write "/proc/gpufreq/gpufreq_input_boost" "0"
		write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_oc_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "0"
	fi

	# Tweak some other mali parameters
	if [[ -d "/proc/mali/" ]]; then
		[[ "${one_ui}" == "false" ]] && write "/proc/mali/dvfs_enable" "1"
		write "/proc/mali/always_on" "1"
	fi

	[[ -d "/sys/module/pvrsrvkm/" ]] && write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"

	if [[ -d "/sys/module/simple_gpu_algorithm/parameters/" ]]; then
		write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "1"
		write "/sys/module/simple_gpu_algorithm/parameters/default_laziness" "2"
		write "/sys/module/simple_gpu_algorithm/parameters/ramp_up_threshold" "2500"
		kmsg "Enabled and tweaked SGPU algorithm"
		kmsg3 ""
	fi

	if [[ -d "/sys/module/adreno_idler/" ]]; then
		write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
		kmsg "Disabled adreno idler"
		kmsg3 ""
	fi

	kmsg "Tweaked GPU parameters"
	kmsg3 ""
}

gpu_balanced() {
	if [[ "${qcom}" == "true" ]]; then
		avail_govs="$(cat "${gpu}devfreq/available_governors")"

		for governor in msm-adreno-tz simple_ondemand ondemand; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${gpu}devfreq/governor" "${governor}"
				break
			fi
		done

	elif [[ "${exynos}" == "true" ]]; then
		avail_govs="$(cat "${gpui}gpu_available_governor")"

		for governor in Interactive Dynamic Static ondemand; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "${governor}"
				break
			fi
		done

	elif [[ "${mtk}" == "true" ]]; then
		avail_govs="$(cat "${gpu}available_governors")"

		for governor in Interactive Dynamic Static ondemand; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "${governor}"
				break
			fi
		done
	fi

	if [[ "${qcom}" == "true" ]]; then
		write "${gpu}throttling" "1"
		write "${gpu}thermal_pwrlevel" "${gpu_calc_thrtl}"
		write "${gpu}devfreq/adrenoboost" "0"
		write "${gpu}force_no_nap" "0"
		write "${gpu}bus_split" "1"
		write "${gpu}devfreq/max_freq" "${gpu_max_freq}"
		write "${gpu}devfreq/min_freq" "${gpu_min_freq}"
		write "${gpu}min_pwrlevel" "$((gpu_min_pl - 1))"
		write "${gpu}force_bus_on" "0"
		write "${gpu}force_clk_on" "0"
		write "${gpu}force_rail_on" "0"
		write "${gpu}idle_timer" "80"
		write "${gpu}pwrnap" "1"
		write "${gpu}pwrscale" "1"
	elif [[ "${qcom}" == "false" ]]; then
		[[ "${one_ui}" == "false" ]] && write "${gpu}dvfs" "1"
		write "${gpui}gpu_max_clock" "${gpu_max_freq}"
		write "${gpui}gpu_min_clock" "${gpu_min}"
		write "${gpu}highspeed_clock" "${gpu_max_freq}"
		write "${gpu}highspeed_load" "86"
		write "${gpu}highspeed_delay" "0"
		write "${gpu}power_policy" "always_on"
		write "${gpu}boost" "0"
		write "${gpu}cl_boost_disable" "0"
		write "${gpug}mali_touch_boost_level" "0"
		write "${gpu}max_freq" "${gpu_max_freq}"
		write "${gpu}min_freq" "${gpu_min}"
		write "${gpu}tmu" "1"
		write "${gpu}devfreq/gpufreq/max_freq" "${gpu_max_freq}"
		write "${gpu}devfreq/gpufreq/min_freq" "${gpu_min}"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync" "1"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_upthreshold" "70"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_downdifferential" "45"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold" "65"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential" "40"
	fi

	if [[ -d "/sys/module/ged/" ]]; then
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
	fi

	if [[ -d "/proc/gpufreq/" ]]; then
		write "/proc/gpufreq/gpufreq_opp_stress_test" "0"
		write "/proc/gpufreq/gpufreq_opp_freq" "0"
		write "/proc/gpufreq/gpufreq_input_boost" "0"
		write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_oc_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "0"
	fi

	if [[ -d "/proc/mali/" ]]; then
		[[ "${one_ui}" == "false" ]] && write "/proc/mali/dvfs_enable" "1"
		write "/proc/mali/always_on" "1"
	fi

	[[ -d "/sys/module/pvrsrvkm/" ]] && write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"

	if [[ -d "/sys/module/simple_gpu_algorithm/parameters/" ]]; then
		write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "1"
		write "/sys/module/simple_gpu_algorithm/parameters/default_laziness" "3"
		write "/sys/module/simple_gpu_algorithm/parameters/ramp_up_threshold" "3500"
		kmsg "Enabled and tweaked SGPU algorithm"
		kmsg3 ""
	fi

	if [[ -d "/sys/module/adreno_idler" ]]; then
		write "/sys/module/adreno_idler/parameters/adreno_idler_active" "Y"
		write "/sys/module/adreno_idler/parameters/adreno_idler_idleworkload" "5000"
		write "/sys/module/adreno_idler/parameters/adreno_idler_downdifferential" "35"
		write "/sys/module/adreno_idler/parameters/adreno_idler_idlewait" "25"
		kmsg "Enabled and tweaked adreno idler"
		kmsg3 ""
	fi

	kmsg "Tweaked GPU parameters"
	kmsg3 ""
}

gpu_extreme() {
	if [[ "${qcom}" == "true" ]]; then
		avail_govs="$(cat "${gpu}devfreq/available_governors")"

		for governor in msm-adreno-tz simple_ondemand ondemand; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${gpu}devfreq/governor" "${governor}"
				break
			fi
		done

	elif [[ "${exynos}" == "true" ]]; then
		avail_govs="$(cat "${gpui}gpu_available_governor")"

		for governor in Booster Interactive Dynamic Static ondemand; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "${governor}"
				break
			fi
		done

	elif [[ "${mtk}" == "true" ]]; then
		avail_govs="$(cat "${gpu}available_governors")"

		for governor in Booster Interactive Dynamic Static ondemand; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "${governor}"
				break
			fi
		done
	fi

	if [[ "${qcom}" == "true" ]]; then
		write "${gpu}throttling" "0"
		write "${gpu}thermal_pwrlevel" "${gpu_calc_thrtl}"
		write "${gpu}devfreq/adrenoboost" "2"
		write "${gpu}force_no_nap" "0"
		write "${gpu}bus_split" "0"
		write "${gpu}devfreq/max_freq" "${gpu_max_freq}"
		write "${gpu}devfreq/min_freq" "${gpu_min_freq}"
		write "${gpu}default_pwrlevel" "${gpu_max_pl}"
		write "${gpu}force_bus_on" "1"
		write "${gpu}force_clk_on" "1"
		write "${gpu}force_rail_on" "1"
		write "${gpu}idle_timer" "10000"
		write "${gpu}pwrnap" "1"
		write "${gpu}pwrscale" "1"
	elif [[ "${qcom}" == "false" ]]; then
		[[ "${one_ui}" == "false" ]] && write "${gpu}dvfs" "1"
		write "${gpui}gpu_max_clock" "${gpu_max_freq}"
		write "${gpui}gpu_min_clock" "${gpu_min}"
		write "${gpu}highspeed_clock" "${gpu_max_freq}"
		write "${gpu}highspeed_load" "76"
		write "${gpu}highspeed_delay" "0"
		write "${gpu}power_policy" "always_on"
		write "${gpui}boost" "0"
		write "${gpu}cl_boost_disable" "0"
		write "${gpug}mali_touch_boost_level" "0"
		write "${gpu}max_freq" "${gpu_max_freq}"
		write "${gpu}min_freq" "${gpu_min}"
		write "${gpu}tmu" "0"
		write "${gpu}devfreq/gpufreq/max_freq" "${gpu_max_freq}"
		write "${gpu}devfreq/gpufreq/min_freq" "${gpu_min}"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync" "0"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_upthreshold" "40"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_downdifferential" "20"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold" "30"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential" "10"
	fi

	if [[ -d "/sys/module/ged/" ]]; then
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
		write "/sys/module/ged/parameters/ged_monitor_3D_fence_disable" "0"
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
	fi

	if [[ -d "/proc/gpufreq/" ]]; then
		write "/proc/gpufreq/gpufreq_opp_stress_test" "1"
		write "/proc/gpufreq/gpufreq_opp_freq" "0"
		write "/proc/gpufreq/gpufreq_input_boost" "0"
		write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "1"
		write "/proc/gpufreq/gpufreq_limited_oc_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "1"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "1"
	fi

	if [[ -d "/proc/mali/" ]]; then
		[[ "${one_ui}" == "false" ]] && write "/proc/mali/dvfs_enable" "1"
		write "/proc/mali/always_on" "1"
	fi

	[[ -d "/sys/module/pvrsrvkm/" ]] && write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"

	if [[ -d "/sys/module/simple_gpu_algorithm/" ]]; then
		write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "0"
		kmsg "Disabled SGPU algorithm"
		kmsg3 ""
	fi

	if [[ -d "/sys/module/adreno_idler/" ]]; then
		write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
		kmsg "Disabled adreno idler"
		kmsg3 ""
	fi

	kmsg "Tweaked GPU parameters"
	kmsg3 ""
}

gpu_battery() {
	if [[ "${qcom}" == "true" ]]; then
		avail_govs="$(cat "${gpu}devfreq/available_governors")"

		for governor in msm-adreno-tz simple_ondemand ondemand; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${gpu}devfreq/governor" "${governor}"
				break
			fi
		done

	elif [[ "${exynos}" == "true" ]]; then
		avail_govs="$(cat "${gpui}gpu_available_governor")"

		for governor in Interactive mali_ondemand ondemand Dynamic Static; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "${governor}"
				break
			fi
		done

	elif [[ "${mtk}" == "true" ]]; then
		avail_govs="$(cat "${gpu}available_governors")"

		for governor in Interactive mali_ondemand ondemand Dynamic Static; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "${governor}"
				break
			fi
		done
	fi

	if [[ "${qcom}" == "true" ]]; then
		write "${gpu}throttling" "1"
		write "${gpu}thermal_pwrlevel" "${gpu_calc_thrtl}"
		write "${gpu}devfreq/adrenoboost" "0"
		write "${gpu}force_no_nap" "0"
		write "${gpu}bus_split" "1"
		write "${gpu}devfreq/max_freq" "${gpu_max_freq}"
		write "${gpu}devfreq/min_freq" "${gpu_min_freq}"
		write "${gpu}min_pwrlevel" "${gpu_min_pl}"
		write "${gpu}force_bus_on" "0"
		write "${gpu}force_clk_on" "0"
		write "${gpu}force_rail_on" "0"
		write "${gpu}idle_timer" "39"
		write "${gpu}pwrnap" "1"
		write "${gpu}pwrscale" "1"
	elif [[ "${qcom}" == "false" ]]; then
		[[ "${one_ui}" == "false" ]] && write "${gpu}dvfs" "1"
		write "${gpui}gpu_max_clock" "${gpu_max_freq}"
		write "${gpui}gpu_min_clock" "${gpu_min}"
		write "${gpu}highspeed_clock" "${gpu_max_freq}"
		write "${gpu}highspeed_load" "95"
		write "${gpu}highspeed_delay" "0"
		write "${gpu}power_policy" "coarse_demand"
		write "${gpu}cl_boost_disable" "1"
		write "${gpui}boost" "0"
		write "${gpug}mali_touch_boost_level" "0"
		write "${gpu}max_freq" "${gpu_max_freq}"
		write "${gpu}min_freq" "${gpu_min}"
		write "${gpu}tmu" "1"
		write "${gpu}devfreq/gpufreq/max_freq" "${gpu_max_freq}"
		write "${gpu}devfreq/gpufreq/min_freq" "${gpu_min}"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync" "1"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_upthreshold" "85"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_downdifferential" "65"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold" "75"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential" "55"
	fi

	if [[ -d "/sys/module/ged/" ]]; then
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
	fi

	if [[ -d "/proc/gpufreq/" ]]; then
		write "/proc/gpufreq/gpufreq_opp_stress_test" "0"
		write "/proc/gpufreq/gpufreq_opp_freq" "0"
		write "/proc/gpufreq/gpufreq_input_boost" "0"
		write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_oc_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "0"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "0"
	fi

	if [[ -d "/proc/mali/" ]]; then
		[[ "${one_ui}" == "false" ]] && write "/proc/mali/dvfs_enable" "1"
		write "/proc/mali/always_on" "0"
	fi

	[[ -d "/sys/module/pvrsrvkm/" ]] && write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"

	if [[ -d "/sys/module/simple_gpu_algorithm/" ]]; then
		write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "1"
		write "/sys/module/simple_gpu_algorithm/parameters/default_laziness" "4"
		write "/sys/module/simple_gpu_algorithm/parameters/ramp_up_threshold" "5000"
		kmsg "Enabled and tweaked SGPU algorithm"
		kmsg3 ""
	fi

	if [[ -d "/sys/module/adreno_idler/" ]]; then
		write "/sys/module/adreno_idler/parameters/adreno_idler_active" "Y"
		write "/sys/module/adreno_idler/parameters/adreno_idler_idleworkload" "10000"
		write "/sys/module/adreno_idler/parameters/adreno_idler_downdifferential" "45"
		write "/sys/module/adreno_idler/parameters/adreno_idler_idlewait" "15"
		kmsg "Enabled and tweaked adreno idler algorithm"
		kmsg3 ""
	fi

	kmsg "Tweaked GPU parameters"
	kmsg3 ""
}

gpu_gaming() {
	if [[ "${qcom}" == "true" ]]; then
		avail_govs="$(cat "${gpu}devfreq/available_governors")"

		for governor in performance msm-adreno-tz simple_ondemand ondemand; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${gpu}devfreq/governor" "${governor}"
				break
			fi
		done

	elif [[ "${exynos}" == "true" ]]; then
		avail_govs="$(cat "${gpui}gpu_available_governor")"

		for governor in Booster Interactive Dynamic Static ondemand; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "${governor}"
				break
			fi
		done

	elif [[ "${mtk}" == "true" ]]; then
		avail_govs="$(cat "${gpu}available_governors")"

		for governor in Booster Interactive Dynamic Static ondemand; do
			if [[ "${avail_govs}" == *"$governor"* ]]; then
				write "${gpui}gpu_governor" "${governor}"
				break
			fi
		done
	fi

	if [[ "${qcom}" == "true" ]]; then
		write "${gpu}throttling" "0"
		write "${gpu}thermal_pwrlevel" "${gpu_calc_thrtl}"
		write "${gpu}devfreq/adrenoboost" "0"
		write "${gpu}force_no_nap" "1"
		write "${gpu}bus_split" "0"
		write "${gpu}devfreq/max_freq" "${gpu_max_freq}"
		write "${gpu}devfreq/min_freq" "${gpu_max}"
		write "${gpu}min_pwrlevel" "${gpu_max_pl}"
		write "${gpu}force_bus_on" "1"
		write "${gpu}force_clk_on" "1"
		write "${gpu}force_rail_on" "1"
		write "${gpu}idle_timer" "1000000"
		write "${gpu}pwrnap" "0"
		write "${gpu}pwrscale" "0"
	elif [[ "${qcom}" == "false" ]]; then
		[[ "${one_ui}" == "false" ]] && write "${gpu}dvfs" "0"
		write "${gpui}gpu_max_clock" "${gpu_max_freq}"
		write "${gpui}gpu_min_clock" "${gpu_max}"
		write "${gpu}highspeed_clock" "${gpu_max_freq}"
		write "${gpu}highspeed_load" "76"
		write "${gpu}highspeed_delay" "0"
		write "${gpu}power_policy" "always_on"
		write "${gpui}boost" "0"
		write "${gpu}cl_boost_disable" "0"
		write "${gpug}mali_touch_boost_level" "0"
		write "${gpu}max_freq" "${gpu_max_freq}"
		write "${gpu}min_freq" "${gpu_max}"
		write "${gpu}tmu" "0"
		write "${gpu}devfreq/gpufreq/max_freq" "${gpu_max_freq}"
		write "${gpu}devfreq/gpufreq/min_freq" "${gpu_max}"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync" "0"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_upthreshold" "35"
		write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_downdifferential" "15"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold" "25"
		write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential" "10"
	fi

	if [[ -d "/sys/module/ged/" ]]; then
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
		write "/sys/module/ged/parameters/ged_monitor_3D_fence_disable" "0"
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
	fi

	if [[ -d "/proc/gpufreq/" ]]; then
		write "/proc/gpufreq/gpufreq_opp_stress_test" "1"
		write "/proc/gpufreq/gpufreq_opp_freq" "${gpu_max}"
		write "/proc/gpufreq/gpufreq_input_boost" "0"
		write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "1"
		write "/proc/gpufreq/gpufreq_limited_oc_ignore" "1"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "1"
		write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "1"
	fi

	if [[ -d "/proc/mali/" ]]; then
		[[ "${one_ui}" == "false" ]] && write "/proc/mali/dvfs_enable" "0"
		write "/proc/mali/always_on" "1"
	fi

	[[ -d "/sys/module/pvrsrvkm/" ]] && write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"

	if [[ -e "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" ]]; then
		write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "0"
		kmsg "Disabled SGPU algorithm"
		kmsg3 ""
	fi

	if [[ -d "/sys/module/adreno_idler/" ]]; then
		write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
		kmsg "Disabled adreno idler"
		kmsg3 ""
	fi

	kmsg "Tweaked GPU parameters"
	kmsg3 ""
}

disable_crypto_tests() {
	if [[ -e "/sys/module/cryptomgr/parameters/notests" ]]; then
		write "/sys/module/cryptomgr/parameters/notests" "Y"
		kmsg "Disabled cryptography tests"
		kmsg3 ""
	fi
}

disable_spd_freqs() {
	if [[ -e "/sys/module/exynos_acme/parameters/enable_suspend_freqs" ]]; then
		write "/sys/module/exynos_acme/parameters/enable_suspend_freqs" "N"
		kmsg "Disabled suspend frequencies"
		kmsg3 ""
	fi
}

config_pwr_spd() {
	if [[ -e "/sys/kernel/power_suspend/power_suspend_mode" ]]; then
		write "/sys/kernel/power_suspend/power_suspend_mode" "3"
		kmsg "Tweaked power suspend mode"
		kmsg3 ""
	fi
}

schedtune_latency() {
	if [[ -d "${stune}" ]]; then
		write "${stune}background/schedtune.boost" "0"
		write "${stune}background/schedtune.prefer_idle" "0"
		write "${stune}background/schedtune.sched_boost" "0"
		write "${stune}background/schedtune.sched_boost_no_override" "1"
		write "${stune}background/schedtune.prefer_perf" "0"
		write "${stune}background/schedtune.util_est_en" "0"
		write "${stune}background/schedtune.ontime_en" "0"
		write "${stune}background/schedtune.prefer_high_cap" "0"

		write "${stune}foreground/schedtune.boost" "0"
		write "${stune}foreground/schedtune.prefer_idle" "0"
		write "${stune}foreground/schedtune.sched_boost" "0"
		write "${stune}foreground/schedtune.sched_boost_no_override" "1"
		write "${stune}foreground/schedtune.prefer_perf" "0"
		write "${stune}foreground/schedtune.util_est_en" "0"
		write "${stune}foreground/schedtune.ontime_en" "0"
		write "${stune}foreground/schedtune.prefer_high_cap" "0"

		write "${stune}nnapi-hal/schedtune.boost" "0"
		write "${stune}nnapi-hal/schedtune.prefer_idle" "0"
		write "${stune}nnapi-hal/schedtune.sched_boost" "0"
		write "${stune}nnapi-hal/schedtune.sched_boost_no_override" "1"
		write "${stune}nnapi-hal/schedtune.prefer_perf" "0"
		write "${stune}nnapi-hal/schedtune.util_est_en" "0"
		write "${stune}nnapi-hal/schedtune.ontime_en" "0"
		write "${stune}nnapi-hal/schedtune.prefer_high_cap" "0"

		write "${stune}rt/schedtune.boost" "0"
		write "${stune}rt/schedtune.prefer_idle" "0"
		write "${stune}rt/schedtune.sched_boost" "0"
		write "${stune}rt/schedtune.sched_boost_no_override" "1"
		write "${stune}rt/schedtune.prefer_perf" "0"
		write "${stune}rt/schedtune.util_est_en" "0"
		write "${stune}rt/schedtune.ontime_en" "0"
		write "${stune}rt/schedtune.prefer_high_cap" "0"

		write "${stune}camera-daemon/schedtune.boost" "0"
		write "${stune}camera-daemon/schedtune.prefer_idle" "1"
		write "${stune}camera-daemon/schedtune.sched_boost" "0"
		write "${stune}camera-daemon/schedtune.sched_boost_no_override" "1"
		write "${stune}camera-daemon/schedtune.prefer_perf" "0"
		write "${stune}camera-daemon/schedtune.util_est_en" "0"
		write "${stune}camera-daemon/schedtune.ontime_en" "0"
		write "${stune}camera-daemon/schedtune.prefer_high_cap" "0"

		write "${stune}top-app/schedtune.boost" "15"
		write "${stune}top-app/schedtune.prefer_idle" "1"
		write "${stune}top-app/schedtune.sched_boost" "0"
		write "${stune}top-app/schedtune.sched_boost_no_override" "1"
		write "${stune}top-app/schedtune.prefer_perf" "1"
		write "${stune}top-app/schedtune.util_est_en" "1"
		write "${stune}top-app/schedtune.ontime_en" "1"
		write "${stune}top-app/schedtune.prefer_high_cap" "0"

		write "${stune}schedtune.boost" "0"
		write "${stune}schedtune.prefer_idle" "0"
		write "${stune}schedtune.sched_boost" "0"
		write "${stune}schedtune.sched_boost_no_override" "0"
		write "${stune}schedtune.prefer_perf" "0"
		write "${stune}schedtune.util_est_en" "0"
		write "${stune}schedtune.ontime_en" "0"
		write "${stune}schedtune.prefer_high_cap" "0"

		kmsg "Tweaked schedtune settings"
		kmsg3 ""
	fi
}

schedtune_balanced() {
	if [[ -d "${stune}" ]]; then
		write "${stune}background/schedtune.boost" "0"
		write "${stune}background/schedtune.prefer_idle" "0"
		write "${stune}background/schedtune.sched_boost" "0"
		write "${stune}background/schedtune.sched_boost_no_override" "1"
		write "${stune}background/schedtune.prefer_perf" "0"
		write "${stune}background/schedtune.util_est_en" "0"
		write "${stune}background/schedtune.ontime_en" "0"
		write "${stune}background/schedtune.prefer_high_cap" "0"

		write "${stune}foreground/schedtune.boost" "0"
		write "${stune}foreground/schedtune.prefer_idle" "0"
		write "${stune}foreground/schedtune.sched_boost" "0"
		write "${stune}foreground/schedtune.sched_boost_no_override" "1"
		write "${stune}foreground/schedtune.prefer_perf" "0"
		write "${stune}foreground/schedtune.util_est_en" "0"
		write "${stune}foreground/schedtune.ontime_en" "0"
		write "${stune}foreground/schedtune.prefer_high_cap" "0"

		write "${stune}nnapi-hal/schedtune.boost" "0"
		write "${stune}nnapi-hal/schedtune.prefer_idle" "0"
		write "${stune}nnapi-hal/schedtune.sched_boost" "0"
		write "${stune}nnapi-hal/schedtune.sched_boost_no_override" "1"
		write "${stune}nnapi-hal/schedtune.prefer_perf" "0"
		write "${stune}nnapi-hal/schedtune.util_est_en" "0"
		write "${stune}nnapi-hal/schedtune.ontime_en" "0"
		write "${stune}nnapi-hal/schedtune.prefer_high_cap" "0"

		write "${stune}rt/schedtune.boost" "0"
		write "${stune}rt/schedtune.prefer_idle" "0"
		write "${stune}rt/schedtune.sched_boost" "0"
		write "${stune}rt/schedtune.sched_boost_no_override" "1"
		write "${stune}rt/schedtune.prefer_perf" "0"
		write "${stune}rt/schedtune.util_est_en" "0"
		write "${stune}rt/schedtune.ontime_en" "0"
		write "${stune}rt/schedtune.prefer_high_cap" "0"

		write "${stune}camera-daemon/schedtune.boost" "0"
		write "${stune}camera-daemon/schedtune.prefer_idle" "1"
		write "${stune}camera-daemon/schedtune.sched_boost" "0"
		write "${stune}camera-daemon/schedtune.sched_boost_no_override" "1"
		write "${stune}camera-daemon/schedtune.prefer_perf" "0"
		write "${stune}camera-daemon/schedtune.util_est_en" "0"
		write "${stune}camera-daemon/schedtune.ontime_en" "0"
		write "${stune}camera-daemon/schedtune.prefer_high_cap" "0"

		write "${stune}top-app/schedtune.boost" "10"
		write "${stune}top-app/schedtune.prefer_idle" "1"
		write "${stune}top-app/schedtune.sched_boost" "0"
		write "${stune}top-app/schedtune.sched_boost_no_override" "1"
		write "${stune}top-app/schedtune.prefer_perf" "1"
		write "${stune}top-app/schedtune.util_est_en" "1"
		write "${stune}top-app/schedtune.ontime_en" "1"
		write "${stune}top-app/schedtune.prefer_high_cap" "0"

		write "${stune}schedtune.boost" "0"
		write "${stune}schedtune.prefer_idle" "0"
		write "${stune}schedtune.sched_boost" "0"
		write "${stune}schedtune.sched_boost_no_override" "0"
		write "${stune}schedtune.prefer_perf" "0"
		write "${stune}schedtune.util_est_en" "0"
		write "${stune}schedtune.ontime_en" "0"
		write "${stune}schedtune.prefer_high_cap" "0"

		kmsg "Tweaked schedtune settings"
		kmsg3 ""
	fi
}

schedtune_extreme() {
	if [[ -d "${stune}" ]]; then
		write "${stune}background/schedtune.boost" "0"
		write "${stune}background/schedtune.prefer_idle" "0"
		write "${stune}background/schedtune.sched_boost" "0"
		write "${stune}background/schedtune.sched_boost_no_override" "1"
		write "${stune}background/schedtune.prefer_perf" "0"
		write "${stune}background/schedtune.util_est_en" "0"
		write "${stune}background/schedtune.ontime_en" "0"
		write "${stune}background/schedtune.prefer_high_cap" "0"

		write "${stune}foreground/schedtune.boost" "50"
		write "${stune}foreground/schedtune.prefer_idle" "1"
		write "${stune}foreground/schedtune.sched_boost" "15"
		write "${stune}foreground/schedtune.sched_boost_no_override" "1"
		write "${stune}foreground/schedtune.prefer_perf" "1"
		write "${stune}foreground/schedtune.util_est_en" "1"
		write "${stune}foreground/schedtune.ontime_en" "1"
		write "${stune}foreground/schedtune.prefer_high_cap" "1"

		write "${stune}nnapi-hal/schedtune.boost" "0"
		write "${stune}nnapi-hal/schedtune.prefer_idle" "0"
		write "${stune}nnapi-hal/schedtune.sched_boost" "0"
		write "${stune}nnapi-hal/schedtune.sched_boost_no_override" "1"
		write "${stune}nnapi-hal/schedtune.prefer_perf" "0"
		write "${stune}nnapi-hal/schedtune.util_est_en" "0"
		write "${stune}nnapi-hal/schedtune.ontime_en" "0"
		write "${stune}nnapi-hal/schedtune.prefer_high_cap" "0"

		write "${stune}rt/schedtune.boost" "0"
		write "${stune}rt/schedtune.prefer_idle" "0"
		write "${stune}rt/schedtune.sched_boost" "0"
		write "${stune}rt/schedtune.sched_boost_no_override" "1"
		write "${stune}rt/schedtune.prefer_perf" "0"
		write "${stune}rt/schedtune.util_est_en" "0"
		write "${stune}rt/schedtune.ontime_en" "0"
		write "${stune}rt/schedtune.prefer_high_cap" "0"

		write "${stune}camera-daemon/schedtune.boost" "0"
		write "${stune}camera-daemon/schedtune.prefer_idle" "1"
		write "${stune}camera-daemon/schedtune.sched_boost" "0"
		write "${stune}camera-daemon/schedtune.sched_boost_no_override" "1"
		write "${stune}camera-daemon/schedtune.prefer_perf" "0"
		write "${stune}camera-daemon/schedtune.util_est_en" "0"
		write "${stune}camera-daemon/schedtune.ontime_en" "0"
		write "${stune}camera-daemon/schedtune.prefer_high_cap" "1"

		write "${stune}top-app/schedtune.boost" "50"
		write "${stune}top-app/schedtune.prefer_idle" "1"
		write "${stune}top-app/schedtune.sched_boost" "15"
		write "${stune}top-app/schedtune.sched_boost_no_override" "1"
		write "${stune}top-app/schedtune.prefer_perf" "1"
		write "${stune}top-app/schedtune.util_est_en" "1"
		write "${stune}top-app/schedtune.ontime_en" "1"
		write "${stune}top-app/schedtune.prefer_high_cap" "1"

		write "${stune}schedtune.boost" "0"
		write "${stune}schedtune.prefer_idle" "0"
		write "${stune}schedtune.sched_boost" "0"
		write "${stune}schedtune.sched_boost_no_override" "0"
		write "${stune}schedtune.prefer_perf" "0"
		write "${stune}schedtune.util_est_en" "0"
		write "${stune}schedtune.ontime_en" "0"
		write "${stune}schedtune.prefer_high_cap" "0"

		kmsg "Tweaked schedtune settings"
		kmsg3 ""
	fi
}

schedtune_battery() {
	if [[ -d "${stune}" ]]; then
		write "${stune}background/schedtune.boost" "0"
		write "${stune}background/schedtune.prefer_idle" "0"
		write "${stune}background/schedtune.sched_boost" "0"
		write "${stune}background/schedtune.sched_boost_no_override" "1"
		write "${stune}background/schedtune.prefer_perf" "0"
		write "${stune}background/schedtune.util_est_en" "0"
		write "${stune}background/schedtune.ontime_en" "0"
		write "${stune}background/schedtune.prefer_high_cap" "0"

		write "${stune}foreground/schedtune.boost" "0"
		write "${stune}foreground/schedtune.prefer_idle" "0"
		write "${stune}foreground/schedtune.sched_boost" "0"
		write "${stune}foreground/schedtune.sched_boost_no_override" "1"
		write "${stune}foreground/schedtune.prefer_perf" "0"
		write "${stune}foreground/schedtune.util_est_en" "0"
		write "${stune}foreground/schedtune.ontime_en" "0"
		write "${stune}foreground/schedtune.prefer_high_cap" "0"

		write "${stune}nnapi-hal/schedtune.boost" "0"
		write "${stune}nnapi-hal/schedtune.prefer_idle" "0"
		write "${stune}nnapi-hal/schedtune.sched_boost" "0"
		write "${stune}nnapi-hal/schedtune.sched_boost_no_override" "1"
		write "${stune}nnapi-hal/schedtune.prefer_perf" "0"
		write "${stune}nnapi-hal/schedtune.util_est_en" "0"
		write "${stune}nnapi-hal/schedtune.ontime_en" "0"
		write "${stune}nnapi-hal/schedtune.prefer_high_cap" "0"

		write "${stune}rt/schedtune.boost" "0"
		write "${stune}rt/schedtune.prefer_idle" "0"
		write "${stune}rt/schedtune.sched_boost" "0"
		write "${stune}rt/schedtune.sched_boost_no_override" "1"
		write "${stune}rt/schedtune.prefer_perf" "0"
		write "${stune}rt/schedtune.util_est_en" "0"
		write "${stune}rt/schedtune.ontime_en" "0"
		write "${stune}rt/schedtune.prefer_high_cap" "0"

		write "${stune}camera-daemon/schedtune.boost" "0"
		write "${stune}camera-daemon/schedtune.prefer_idle" "1"
		write "${stune}camera-daemon/schedtune.sched_boost" "0"
		write "${stune}camera-daemon/schedtune.sched_boost_no_override" "1"
		write "${stune}camera-daemon/schedtune.prefer_perf" "0"
		write "${stune}camera-daemon/schedtune.util_est_en" "0"
		write "${stune}camera-daemon/schedtune.ontime_en" "0"
		write "${stune}camera-daemon/schedtune.prefer_high_cap" "0"

		write "${stune}top-app/schedtune.boost" "0"
		write "${stune}top-app/schedtune.prefer_idle" "1"
		write "${stune}top-app/schedtune.sched_boost" "0"
		write "${stune}top-app/schedtune.sched_boost_no_override" "1"
		write "${stune}top-app/schedtune.prefer_perf" "1"
		write "${stune}top-app/schedtune.util_est_en" "1"
		write "${stune}top-app/schedtune.ontime_en" "1"
		write "${stune}top-app/schedtune.prefer_high_cap" "0"

		write "${stune}schedtune.boost" "0"
		write "${stune}schedtune.prefer_idle" "0"
		write "${stune}schedtune.sched_boost" "0"
		write "${stune}schedtune.sched_boost_no_override" "0"
		write "${stune}schedtune.prefer_perf" "0"
		write "${stune}schedtune.util_est_en" "0"
		write "${stune}schedtune.ontime_en" "0"
		write "${stune}schedtune.prefer_high_cap" "0"

		kmsg "Tweaked schedtune settings"
		kmsg3 ""
	fi
}

schedtune_gaming() {
	if [[ -d "${stune}" ]]; then
		write "${stune}background/schedtune.boost" "0"
		write "${stune}background/schedtune.prefer_idle" "0"
		write "${stune}background/schedtune.sched_boost" "0"
		write "${stune}background/schedtune.sched_boost_no_override" "1"
		write "${stune}background/schedtune.prefer_perf" "0"
		write "${stune}background/schedtune.util_est_en" "0"
		write "${stune}background/schedtune.ontime_en" "0"
		write "${stune}background/schedtune.prefer_high_cap" "0"

		write "${stune}foreground/schedtune.boost" "50"
		write "${stune}foreground/schedtune.prefer_idle" "1"
		write "${stune}foreground/schedtune.sched_boost" "15"
		write "${stune}foreground/schedtune.sched_boost_no_override" "1"
		write "${stune}foreground/schedtune.prefer_perf" "0"
		write "${stune}foreground/schedtune.util_est_en" "1"
		write "${stune}foreground/schedtune.ontime_en" "1"
		write "${stune}foreground/schedtune.prefer_high_cap" "1"

		write "${stune}nnapi-hal/schedtune.boost" "0"
		write "${stune}nnapi-hal/schedtune.prefer_idle" "0"
		write "${stune}nnapi-hal/schedtune.sched_boost" "0"
		write "${stune}nnapi-hal/schedtune.sched_boost_no_override" "1"
		write "${stune}nnapi-hal/schedtune.prefer_perf" "0"
		write "${stune}nnapi-hal/schedtune.util_est_en" "0"
		write "${stune}nnapi-hal/schedtune.ontime_en" "0"
		write "${stune}nnapi-hal/schedtune.prefer_high_cap" "0"

		write "${stune}rt/schedtune.boost" "0"
		write "${stune}rt/schedtune.prefer_idle" "0"
		write "${stune}rt/schedtune.sched_boost" "0"
		write "${stune}rt/schedtune.prefer_perf" "0"
		write "${stune}rt/schedtune.util_est_en" "0"
		write "${stune}rt/schedtune.ontime_en" "0"
		write "${stune}rt/schedtune.prefer_high_cap" "0"

		write "${stune}camera-daemon/schedtune.boost" "0"
		write "${stune}camera-daemon/schedtune.prefer_idle" "1"
		write "${stune}camera-daemon/schedtune.sched_boost" "0"
		write "${stune}camera-daemon/schedtune.sched_boost_no_override" "1"
		write "${stune}camera-daemon/schedtune.prefer_perf" "0"
		write "${stune}camera-daemon/schedtune.util_est_en" "0"
		write "${stune}camera-daemon/schedtune.ontime_en" "0"
		write "${stune}camera-daemon/schedtune.prefer_high_cap" "0"

		write "${stune}top-app/schedtune.boost" "50"
		write "${stune}top-app/schedtune.prefer_idle" "1"
		write "${stune}top-app/schedtune.sched_boost" "15"
		write "${stune}top-app/schedtune.sched_boost_no_override" "1"
		write "${stune}top-app/schedtune.prefer_perf" "1"
		write "${stune}top-app/schedtune.util_est_en" "1"
		write "${stune}top-app/schedtune.ontime_en" "1"
		write "${stune}top-app/schedtune.prefer_high_cap" "1"

		write "${stune}schedtune.boost" "0"
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
	fi
}

uclamp_latency() {
	if [[ -e "${cpuctl}top-app/cpu.uclamp.max" ]]; then
		write "${kernel}sched_util_clamp_min" "0"
		write "${kernel}sched_util_clamp_max" "100"

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
	fi
}

uclamp_balanced() {
	if [[ -e "${cpuctl}top-app/cpu.uclamp.max" ]]; then
		write "${kernel}sched_util_clamp_min" "0"
		write "${kernel}sched_util_clamp_max" "100"

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
	fi
}

uclamp_extreme() {
	if [[ -e "${cpuctl}top-app/cpu.uclamp.max" ]]; then
		write "${kernel}sched_util_clamp_min" "0"
		write "${kernel}sched_util_clamp_max" "100"

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
	fi
}

uclamp_battery() {
	if [[ -e "${cpuctl}top-app/cpu.uclamp.max" ]]; then
		write "${kernel}sched_util_clamp_min" "0"
		write "${kernel}sched_util_clamp_max" "100"

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
	fi
}

uclamp_gaming() {
	if [[ -e "${cpuctl}top-app/cpu.uclamp.max" ]]; then
		sysctl -w kernel.sched_util_clamp_min_rt_default=96
		sysctl -w kernel.sched_util_clamp_min=192

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
	fi
}

config_blkio() {
	# Block tweaks
	if [[ -d "${blkio}" ]]; then
		write "${blkio}blkio.weight" "1000"
		write "${blkio}background/blkio.weight" "200"
		write "${blkio}blkio.group_idle" "0"
		write "${blkio}background/blkio.group_idle" "0"
		kmsg "Tweaked blkio"
		kmsg3 ""
	fi
}

config_fs() {
	# Raise inotify limit, disable the notification of files / directories changes
	if [[ -d "${fs}" ]]; then
		write "${fs}dir-notify-enable" "0"
		write "${fs}lease-break-time" "15"
		write "${fs}leases-enable" "1"
		write "${fs}file-max" "2097152"
		write "${fs}inotify/max_queued_events" "131072"
		write "${fs}inotify/max_user_watches" "131072"
		write "${fs}inotify/max_user_instances" "1024"
		kmsg "Tweaked FS"
		kmsg3 ""
	fi
}

config_dyn_fsync() {
	if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]; then
		write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
		kmsg "Enabled dynamic fsync"
		kmsg3 ""
	fi
}

sched_ft_latency() {
	# Scheduler features
	if [[ -e "/sys/kernel/debug/sched_features" ]]; then
		write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
		write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
		kmsg "Tweaked scheduler features"
		kmsg3 ""
	fi
}

sched_ft_balanced() {
	if [[ -e "/sys/kernel/debug/sched_features" ]]; then
		write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
		write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
		kmsg "Tweaked scheduler features"
		kmsg3 ""
	fi
}

sched_ft_extreme() {
	if [[ -e "/sys/kernel/debug/sched_features" ]]; then
		write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
		write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
		kmsg "Tweaked scheduler features"
		kmsg3 ""
	fi
}

sched_ft_battery() {
	if [[ -e "/sys/kernel/debug/sched_features" ]]; then
		write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
		write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
		kmsg "Tweaked scheduler features"
		kmsg3 ""
	fi
}

sched_ft_gaming() {
	if [[ -e "/sys/kernel/debug/sched_features" ]]; then
		write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
		write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
		kmsg "Tweaked scheduler features"
		kmsg3 ""
	fi
}

disable_crc() {
	if [[ -e "/sys/module/mmc_core/parameters/use_spi_crc" ]]; then
		write "/sys/module/mmc_core/parameters/use_spi_crc" "N"
		kmsg "Disabled MMC CRC"
		kmsg3 ""

	elif [[ -e "/sys/module/mmc_core/parameters/removable" ]]; then
		write "/sys/module/mmc_core/parameters/removable" "N"
		kmsg "Disabled MMC CRC"
		kmsg3 ""

	elif [[ -e "/sys/module/mmc_core/parameters/crc" ]]; then
		write "/sys/module/mmc_core/parameters/crc" "N"
		kmsg "Disabled MMC CRC"
		kmsg3 ""
	fi
}

sched_latency() {
	# Tweak kernel settings to improve overall performance
	[[ -e "${kernel}sched_child_runs_first" ]] && write "${kernel}sched_child_runs_first" "1"
	[[ -e "${kernel}perf_cpu_time_max_percent" ]] && write "${kernel}perf_cpu_time_max_percent" "3"
	[[ -e "${kernel}sched_autogroup_enabled" ]] && write "${kernel}sched_autogroup_enabled" "1"
	[[ -e "/sys/devices/soc/${bt_dvc}/clkscale_enable" ]] && write "/sys/devices/soc/${bt_dvc}/clkscale_enable" "1"
	[[ -e "/sys/devices/soc/${bt_dvc}/clkgate_enable" ]] && write "/sys/devices/soc/${bt_dvc}/clkgate_enable" "1"
	write "${kernel}sched_tunable_scaling" "0"
	[[ -e "${kernel}sched_latency_ns" ]] && write "${kernel}sched_latency_ns" "${sched_period_latency}"
	[[ -e "${kernel}sched_min_granularity_ns" ]] && write "${kernel}sched_min_granularity_ns" "$((sched_period_latency / sched_tasks_latency))"
	[[ -e "${kernel}sched_wakeup_granularity_ns" ]] && write "${kernel}sched_wakeup_granularity_ns" "$((sched_period_latency / sched_tasks_latency))"
	[[ -e "${kernel}sched_migration_cost_ns" ]] && write "${kernel}sched_migration_cost_ns" "200000"
	[[ -e "/proc/perfmgr/boost_ctrl/eas_ctrl/m_sched_migrate_cost_n" ]] && write "/proc/perfmgr/boost_ctrl/eas_ctrl/m_sched_migrate_cost_n" "200000"
	[[ -e "${kernel}sched_min_task_util_for_colocation" ]] && write "${kernel}sched_min_task_util_for_colocation" "0"
	[[ -e "${kernel}sched_min_task_util_for_boost" ]] && write "${kernel}sched_min_task_util_for_boost" "0"
	write "${kernel}sched_nr_migrate" "4"
	write "${kernel}sched_schedstats" "0"
	[[ -e "${kernel}sched_cstate_aware" ]] && write "${kernel}sched_cstate_aware" "1"
	write "${kernel}printk_devkmsg" "off"
	[[ -e "${kernel}timer_migration" ]] && write "${kernel}timer_migration" "0"
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
	for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
		[[ -e "${bcl_md}" ]] && write "${bcl_md}" "0"
	done
	write "/proc/sys/dev/tty/ldisc_autoload" "0"

	kmsg "Tweaked various kernel parameters"
	kmsg3 ""
}

sched_balanced() {
	[[ -e "${kernel}sched_child_runs_first" ]] && write "${kernel}sched_child_runs_first" "1"
	[[ -e "${kernel}perf_cpu_time_max_percent" ]] && write "${kernel}perf_cpu_time_max_percent" "15"
	[[ -e "${kernel}sched_autogroup_enabled" ]] && write "${kernel}sched_autogroup_enabled" "1"
	[[ -e "/sys/devices/soc/${bt_dvc}/clkscale_enable" ]] && write "/sys/devices/soc/${bt_dvc}/clkscale_enable" "1"
	[[ -e "/sys/devices/soc/${bt_dvc}/clkgate_enable" ]] && .write "/sys/devices/soc/${bt_dvc}/clkgate_enable" "1"
	write "${kernel}sched_tunable_scaling" "0"
	[[ -e "${kernel}sched_latency_ns" ]] && write "${kernel}sched_latency_ns" "${sched_period_balance}"
	[[ -e "${kernel}sched_min_granularity_ns" ]] && write "${kernel}sched_min_granularity_ns" "$((sched_period_balance / sched_tasks_balance))"
	[[ -e "${kernel}sched_wakeup_granularity_ns" ]] && write "${kernel}sched_wakeup_granularity_ns" "$((sched_period_balance / 2))"
	[[ -e "${kernel}sched_migration_cost_ns" ]] && write "${kernel}sched_migration_cost_ns" "200000"
	[[ -e "/proc/perfmgr/boost_ctrl/eas_ctrl/m_sched_migrate_cost_n" ]] && write "/proc/perfmgr/boost_ctrl/eas_ctrl/m_sched_migrate_cost_n" "200000"
	[[ -e "${kernel}sched_min_task_util_for_colocation" ]] && write "${kernel}sched_min_task_util_for_colocation" "0"
	[[ -e "${kernel}sched_min_task_util_for_boost" ]] && write "${kernel}sched_min_task_util_for_boost" "0"
	write "${kernel}sched_nr_migrate" "32"
	write "${kernel}sched_schedstats" "0"
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
	# Set memory sleep mode to deep
	[[ -e "/sys/power/mem_sleep" ]] && write "/sys/power/mem_sleep" "s2idle"
	[[ -e "${kernel}sched_conservative_pl" ]] && write "${kernel}sched_conservative_pl" "0"
	[[ -e "/sys/devices/system/cpu/sched/sched_boost" ]] && write "/sys/devices/system/cpu/sched/sched_boost" "0"
	[[ -e "/sys/kernel/ems/eff_mode" ]] && write "/sys/kernel/ems/eff_mode" "0"
	[[ -e "/sys/module/opchain/parameters/chain_on" ]] && write "/sys/module/opchain/parameters/chain_on" "0"
	[[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]] && write "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
	[[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]] && write "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
	[[ -e "${kernel}sched_initial_task_util" ]] && write "${kernel}sched_initial_task_util" "0"
	[[ -d "/sys/module/memplus_core/" ]] && write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
	for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
		[[ -e "${bcl_md}" ]] && write "${bcl_md}" "0"
	done
	write "/proc/sys/dev/tty/ldisc_autoload" "0"

	kmsg "Tweaked various kernel parameters"
	kmsg3 ""
}

sched_extreme() {
	[[ -e "${kernel}sched_child_runs_first" ]] && write "${kernel}sched_child_runs_first" "0"
	[[ -e "${kernel}perf_cpu_time_max_percent" ]] && write "${kernel}perf_cpu_time_max_percent" "25"
	[[ -e "${kernel}sched_autogroup_enabled" ]] && write "${kernel}sched_autogroup_enabled" "0"
	[[ -e "/sys/devices/soc/${bt_dvc}/clkscale_enable" ]] && write "/sys/devices/soc/${bt_dvc}/clkscale_enable" "0"
	[[ -e "/sys/devices/soc/${bt_dvc}/clkgate_enable" ]] && write "/sys/devices/soc/${bt_dvc}/clkgate_enable" "0"
	write "${kernel}sched_tunable_scaling" "0"
	[[ -e "${kernel}sched_latency_ns" ]] && write "${kernel}sched_latency_ns" "${sched_period_throughput}"
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
	[[ -e "${kernel}sched_boost" ]] && write "${kernel}sched_boost" "1"
	[[ -e "/sys/devices/system/cpu/eas/enable" ]] && [[ "${mtk}" == "true" ]] && write "/sys/devices/system/cpu/eas/enable" "2" || write "/sys/devices/system/cpu/eas/enable" "1"
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
	[[ -e "/sys/devices/system/cpu/sched/sched_boost" ]] && write "/sys/devices/system/cpu/sched/sched_boost" "1"
	[[ -e "/sys/kernel/ems/eff_mode" ]] && write "/sys/kernel/ems/eff_mode" "0"
	[[ -e "/sys/module/opchain/parameters/chain_on" ]] && write "/sys/module/opchain/parameters/chain_on" "0"
	[[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]] && write "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
	[[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]] && write "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
	[[ -e "${kernel}sched_initial_task_util" ]] && write "${kernel}sched_initial_task_util" "0"
	[[ -d "/sys/module/memplus_core/" ]] && write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
	for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
		[[ -e "${bcl_md}" ]] && write "${bcl_md}" "0"
	done
	write "/proc/sys/dev/tty/ldisc_autoload" "0"

	kmsg "Tweaked various kernel parameters"
	kmsg3 ""
}

sched_battery() {
	[[ -e "${kernel}sched_child_runs_first" ]] && write "${kernel}sched_child_runs_first" "0"
	[[ -e "${kernel}perf_cpu_time_max_percent" ]] && write "${kernel}perf_cpu_time_max_percent" "0"
	[[ -e "${kernel}sched_autogroup_enabled" ]] && write "${kernel}sched_autogroup_enabled" "1"
	[[ -e "/sys/devices/soc/${bt_dvc}/clkscale_enable" ]] && write "/sys/devices/soc/${bt_dvc}/clkscale_enable" "1"
	[[ -e "/sys/devices/soc/${bt_dvc}/clkgate_enable" ]] && write "/sys/devices/soc/${bt_dvc}/clkgate_enable" "1"
	write "${kernel}sched_tunable_scaling" "0"
	[[ -e "${kernel}sched_latency_ns" ]] && write "${kernel}sched_latency_ns" "${sched_period_battery}"
	[[ -e "${kernel}sched_min_granularity_ns" ]] && write "${kernel}sched_min_granularity_ns" "$((sched_period_battery / sched_tasks_battery))"
	[[ -e "${kernel}sched_wakeup_granularity_ns" ]] && write "${kernel}sched_wakeup_granularity_ns" "$((sched_period_battery / 2))"
	[[ -e "${kernel}sched_migration_cost_ns" ]] && write "${kernel}sched_migration_cost_ns" "200000"
	[[ -e "/proc/perfmgr/boost_ctrl/eas_ctrl/m_sched_migrate_cost_n" ]] && write "/proc/perfmgr/boost_ctrl/eas_ctrl/m_sched_migrate_cost_n" "200000"
	[[ -e "${kernel}sched_min_task_util_for_colocation" ]] && write "${kernel}sched_min_task_util_for_colocation" "0"
	[[ -e "${kernel}sched_min_task_util_for_boost" ]] && write "${kernel}sched_min_task_util_for_boost" "0"
	write "${kernel}sched_nr_migrate" "256"
	write "${kernel}sched_schedstats" "0"
	[[ -e "${kernel}sched_cstate_aware" ]] && write "${kernel}sched_cstate_aware" "1"
	write "${kernel}printk_devkmsg" "off"
	[[ -e "${kernel}timer_migration" ]] && write "${kernel}timer_migration" "1"
	[[ -e "${kernel}sched_boost" ]] && write "${kernel}sched_boost" "0"
	[[ -e "/sys/devices/system/cpu/eas/enable" ]] && write "/sys/devices/system/cpu/eas/enable" "1"
	[[ -e "${kernel}sched_walt_rotate_big_tasks" ]] && write "${kernel}sched_walt_rotate_big_tasks" "1"
	[[ -e "${kernel}sched_prefer_sync_wakee_to_waker" ]] && write "${kernel}sched_prefer_sync_wakee_to_waker" "1"
	[[ -e "${kernel}sched_boost_top_app" ]] && write "${kernel}sched_boost_top_app" "1"
	[[ -e "${kernel}sched_init_task_load" ]] && write "${kernel}sched_init_task_load" "15"
	[[ -e "${kernel}sched_migration_fixup" ]] && write "${kernel}sched_migration_fixup" "0"
	[[ -e "${kernel}sched_energy_aware" ]] && write "${kernel}sched_energy_aware" "1"
	[[ -e "${kernel}hung_task_timeout_secs" ]] && write "${kernel}hung_task_timeout_secs" "0"
	[[ -e "${kernel}sysrq" ]] && write "${kernel}sysrq" "0"
	[[ -e "/sys/power/mem_sleep" ]] && write "/sys/power/mem_sleep" "deep"
	[[ -e "${kernel}sched_conservative_pl" ]] && write "${kernel}sched_conservative_pl" "1"
	[[ -e "/sys/devices/system/cpu/sched/sched_boost" ]] && write "/sys/devices/system/cpu/sched/sched_boost" "0"
	[[ -e "/sys/kernel/ems/eff_mode" ]] && write "/sys/kernel/ems/eff_mode" "0"
	[[ -e "/sys/module/opchain/parameters/chain_on" ]] && write "/sys/module/opchain/parameters/chain_on" "0"
	[[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]] && write "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
	[[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]] && write "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
	[[ -e "${kernel}sched_initial_task_util" ]] && write "${kernel}sched_initial_task_util" "0"
	[[ -d "/sys/module/memplus_core/" ]] && write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
	for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
		[[ -e "${bcl_md}" ]] && write "${bcl_md}" "0"
	done
	write "/proc/sys/dev/tty/ldisc_autoload" "0"

	kmsg "Tweaked various kernel parameters"
	kmsg3 ""
}

sched_gaming() {
	[[ -e "${kernel}sched_child_runs_first" ]] && write "${kernel}sched_child_runs_first" "0"
	[[ -e "${kernel}perf_cpu_time_max_percent" ]] && write "${kernel}perf_cpu_time_max_percent" "25"
	[[ -e "${kernel}sched_autogroup_enabled" ]] && write "${kernel}sched_autogroup_enabled" "0"
	[[ -e "/sys/devices/soc/${bt_dvc}/clkscale_enable" ]] && write "/sys/devices/soc/${bt_dvc}/clkscale_enable" "0"
	[[ -e "/sys/devices/soc/${bt_dvc}/clkgate_enable" ]] && write "/sys/devices/soc/${bt_dvc}/clkgate_enable" "0"
	write "${kernel}sched_tunable_scaling" "0"
	[[ -e "${kernel}sched_latency_ns" ]] && write "${kernel}sched_latency_ns" "${sched_period_throughput}"
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
	[[ -e "${kernel}sched_boost" ]] && write "${kernel}sched_boost" "1"
	[[ -e "/sys/devices/system/cpu/eas/enable" ]] && [[ "${mtk}" == "true" ]] && write "/sys/devices/system/cpu/eas/enable" "2" || write "/sys/devices/system/cpu/eas/enable" "1"
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
	[[ -e "/sys/devices/system/cpu/sched/sched_boost" ]] && write "/sys/devices/system/cpu/sched/sched_boost" "1"
	[[ -e "/sys/kernel/ems/eff_mode" ]] && write "/sys/kernel/ems/eff_mode" "0"
	[[ -e "/sys/module/opchain/parameters/chain_on" ]] && write "/sys/module/opchain/parameters/chain_on" "0"
	[[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]] && write "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
	[[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]] && write "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
	[[ -e "${kernel}sched_initial_task_util" ]] && write "${kernel}sched_initial_task_util" "0"
	[[ -d "/sys/module/memplus_core/" ]] && write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
	for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
		[[ -e "${bcl_md}" ]] && write "${bcl_md}" "0"
	done
	write "/proc/sys/dev/tty/ldisc_autoload" "0"

	kmsg "Tweaked various kernel parameters"
	kmsg3 ""
}

enable_kvb() {
	if [[ -e "/sys/module/acpuclock_krait/parameters/boost" ]]; then
		write "/sys/module/acpuclock_krait/parameters/boost" "Y"
		kmsg "Enabled krait voltage boost"
		kmsg3 ""
	fi
}

disable_kvb() {
	if [[ -e "/sys/module/acpuclock_krait/parameters/boost" ]]; then
		write "/sys/module/acpuclock_krait/parameters/boost" "N"
		kmsg "Disabled krait voltage boost"
		kmsg3 ""
	fi
}

enable_fp_boost() {
	if [[ -e "/sys/kernel/fp_boost/enabled" ]]; then
		write "/sys/kernel/fp_boost/enabled" "1"
		kmsg "Enabled fingerprint boost"
		kmsg3 ""
	fi
}

disable_fp_boost() {
	if [[ -e "/sys/kernel/fp_boost/enabled" ]]; then
		write "/sys/kernel/fp_boost/enabled" "0"
		kmsg "Disabled fingerprint boost"
		kmsg3 ""
	fi
}

# Credits to helloklf again
ufs_default() {
	if [[ -d "/sys/class/devfreq/1d84000.ufshc/" ]]; then
		write "/sys/class/devfreq/1d84000.ufshc/max_freq" "300000000"
		write "/sys/devices/platform/soc/1d84000.ufshc/clkscale_enable" "1"
		write "/sys/devices/platform/soc/1d84000.ufshc/clkgate_enable" "1"
		kmsg "Tweaked UFS"
		kmsg3 ""
	fi
}

ufs_max() {
	if [[ -d "/sys/class/devfreq/1d84000.ufshc/" ]]; then
		write "/sys/class/devfreq/1d84000.ufshc/max_freq" "300000000"
		write "/sys/devices/platform/soc/1d84000.ufshc/clkscale_enable" "0"
		write "/sys/devices/platform/soc/1d84000.ufshc/clkgate_enable" "0"
		kmsg "Tweaked UFS"
		kmsg3 ""
	fi
}

ufs_pwr_saving() {
	if [[ -d "/sys/class/devfreq/1d84000.ufshc/" ]]; then
		write "/sys/class/devfreq/1d84000.ufshc/max_freq" "75000000"
		write "/sys/devices/platform/soc/1d84000.ufshc/clkscale_enable" "1"
		write "/sys/devices/platform/soc/1d84000.ufshc/clkgate_enable" "1"
		kmsg "Tweaked UFS"
		kmsg3 ""
	fi
}

ppm_policy_default() {
	if [[ "${ppm}" == "true" ]]; then
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
	fi
}

ppm_policy_max() {
	if [[ "${ppm}" == "true" ]]; then
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
	fi
}

cpu_clk_min() {
	# Set min efficient CPU clock
	for pl in /sys/devices/system/cpu/cpufreq/policy*/; do
		for i in 576000 614400 633600 652800 748800 768000 787200 806400 825600 864000 902400 998400 1113600; do
			[[ "$(grep ${i} ${pl}scaling_available_frequencies)" ]] && write ${pl}scaling_min_freq ${i}
		done
	done
}

cpu_clk_default() {
	# Set max CPU clock
	for cpus in /sys/devices/system/cpu/cpufreq/policy*/; do
		if [[ -e "${cpus}scaling_max_freq" ]]; then
			write "${cpus}scaling_max_freq" "${cpu_max_freq}"
			write "${cpus}user_scaling_max_freq" "${cpu_max_freq}"
		fi
	done

	for cpus in /sys/devices/system/cpu/cpu*/cpufreq/; do
		if [[ -e "${cpus}scaling_max_freq" ]]; then
			write "${cpus}scaling_max_freq" "${cpu_max_freq}"
			write "${cpus}user_scaling_max_freq" "${cpu_max_freq}"
		fi
	done

	kmsg "Tweaked CPU clocks"
	kmsg3 ""

	if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]]; then
		write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "1"
		kmsg "Allow CPUs to use it's deepest sleep state"
		kmsg3 ""
	fi
}

cpu_clk_max() {
	# Set min & max CPU clock
	for cpus in /sys/devices/system/cpu/cpufreq/policy*/; do
		if [[ -e "${cpus}scaling_min_freq" ]]; then
			write "${cpus}scaling_min_freq" "${cpu_max_freq}"
			write "${cpus}scaling_max_freq" "${cpu_max_freq}"
			write "${cpus}user_scaling_min_freq" "${cpu_max_freq}"
			write "${cpus}user_scaling_max_freq" "${cpu_max_freq}"
		fi
	done

	for cpus in /sys/devices/system/cpu/cpu*/cpufreq/; do
		if [[ -e "${cpus}scaling_min_freq" ]]; then
			write "${cpus}scaling_min_freq" "${cpu_max_freq}"
			write "${cpus}scaling_max_freq" "${cpu_max_freq}"
			write "${cpus}user_scaling_min_freq" "${cpu_max_freq}"
			write "${cpus}user_scaling_max_freq" "${cpu_max_freq}"
		fi
	done

	kmsg "Tweaked CPU clocks"
	kmsg3 ""

	if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]]; then
		write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "0"
		kmsg "Don't allow CPUs to use it's deepest sleep state"
		kmsg3 ""
	fi
}

vm_lmk_latency() {
	[[ "${total_ram_kb}" -gt "8388608" ]] && {
		minfree="25600,38400,51200,64000,256000,307200"
		efk="204800"
	}
	[[ "${total_ram_kb}" -le "8388608" ]] && {
		minfree="25600,38400,51200,64000,153600,179200"
		efk="128000"
	}
	[[ "${total_ram_kb}" -le "6291456" ]] && {
		minfree="25600,38400,51200,64000,102400,128000"
		efk="102400"
	}
	[[ "${total_ram_kb}" -le "4197304" ]] && {
		minfree="12800,19200,25600,32000,76800,102400"
		efk="76800"
	}
	[[ "${total_ram_kb}" -le "3145728" ]] && {
		minfree="12800,19200,25600,32000,51200,76800"
		efk="51200"
	}
	[[ "${total_ram_kb}" -le "2098652" ]] && {
		minfree="12800,19200,25600,32000,38400,51200"
		efk="25600"
	}
	[[ "${total_ram_kb}" -le "1049326" ]] && {
		minfree="5120,10240,12800,15360,25600,38400"
		efk="19200"
	}
	# Always sync before dropping caches
	sync
	# VM settings to improve overall user experience and performance
	write "${vm}drop_caches" "3"
	write "${vm}dirty_background_ratio" "3"
	write "${vm}dirty_ratio" "30"
	write "${vm}dirty_expire_centisecs" "5000"
	write "${vm}dirty_writeback_centisecs" "5000"
	write "${vm}page-cluster" "0"
	write "${vm}stat_interval" "60"
	# Use SSWAP on samsung devices if it do not have more than 4 GB RAM
	[[ "${samsung}" == "true" ]] && [[ "${total_ram}" -lt "4000" ]] && write "${vm}swappiness" "150" || write "${vm}swappiness" "100"
	write "${vm}laptop_mode" "0"
	write "${vm}vfs_cache_pressure" "200"
	write "${vm}watermark_scale_factor" "1"
	[[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	[[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "1"
	[[ -e "${vm}swap_ratio" ]] && write "${vm}swap_ratio" "100"
	[[ -e "${vm}oom_dump_tasks" ]] && write "${vm}oom_dump_tasks" "0"
	[[ -e "${lmk}parameters/minfree" ]] && write "${lmk}parameters/minfree" "${minfree}"
	[[ -e "${lmk}parameters/oom_reaper" ]] && write "${lmk}parameters/oom_reaper" "1"
	[[ -e "${lmk}parameters/lmk_fast_run" ]] && write "${lmk}parameters/lmk_fast_run" "1"
	[[ -e "${lmk}parameters/enable_adaptive_lmk" ]] && write "${lmk}parameters/enable_adaptive_lmk" "1"
	[[ -e "${vm}extra_free_kbytes" ]] && write "${vm}extra_free_kbytes" "${efk}"
	[[ -e "${lmk}parameters/cost" ]] && write "${lmk}parameters/cost" "4096"

	kmsg "Tweaked various VM / LMK parameters for a improved user-experience"
	kmsg3 ""
}

vm_lmk_balanced() {
	[[ "${total_ram_kb}" -gt "8388608" ]] && {
		minfree="25600,38400,51200,64000,256000,307200"
		efk="204800"
	}
	[[ "${total_ram_kb}" -le "8388608" ]] && {
		minfree="25600,38400,51200,64000,153600,179200"
		efk="128000"
	}
	[[ "${total_ram_kb}" -le "6291456" ]] && {
		minfree="25600,38400,51200,64000,102400,128000"
		efk="102400"
	}
	[[ "${total_ram_kb}" -le "4197304" ]] && {
		minfree="12800,19200,25600,32000,76800,102400"
		efk="76800"
	}
	[[ "${total_ram_kb}" -le "3145728" ]] && {
		minfree="12800,19200,25600,32000,51200,76800"
		efk="51200"
	}
	[[ "${total_ram_kb}" -le "2098652" ]] && {
		minfree="12800,19200,25600,32000,38400,51200"
		efk="25600"
	}
	[[ "${total_ram_kb}" -le "1049326" ]] && {
		minfree="5120,10240,12800,15360,25600,38400"
		efk="19200"
	}
	sync
	write "${vm}drop_caches" "2"
	write "${vm}dirty_background_ratio" "5"
	write "${vm}dirty_ratio" "30"
	write "${vm}dirty_expire_centisecs" "3000"
	write "${vm}dirty_writeback_centisecs" "3000"
	write "${vm}page-cluster" "0"
	write "${vm}stat_interval" "60"
	[[ "${samsung}" == "true" ]] && [[ "${total_ram}" -lt "4000" ]] && write "${vm}swappiness" "150" || write "${vm}swappiness" "100"
	write "${vm}laptop_mode" "0"
	write "${vm}vfs_cache_pressure" "100"
	write "${vm}watermark_scale_factor" "1"
	[[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	[[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "1"
	[[ -e "${vm}swap_ratio" ]] && write "${vm}swap_ratio" "100"
	[[ -e "${vm}oom_dump_tasks" ]] && write "${vm}oom_dump_tasks" "0"
	[[ -e "${lmk}parameters/minfree" ]] && write "${lmk}parameters/minfree" "${minfree}"
	[[ -e "${lmk}parameters/oom_reaper" ]] && write "${lmk}parameters/oom_reaper" "1"
	[[ -e "${lmk}parameters/lmk_fast_run" ]] && write "${lmk}parameters/lmk_fast_run" "1"
	[[ -e "${lmk}parameters/enable_adaptive_lmk" ]] && write "${lmk}parameters/enable_adaptive_lmk" "1"
	[[ -e "${vm}extra_free_kbytes" ]] && write "${vm}extra_free_kbytes" "${efk}"
	[[ -e "${lmk}parameters/cost" ]] && write "${lmk}parameters/cost" "4096"

	kmsg "Tweaked various VM and LMK parameters for a improved user-experience"
	kmsg3 ""
}

vm_lmk_extreme() {
	[[ "${total_ram_kb}" -gt "8388608" ]] && {
		minfree="25600,38400,51200,64000,256000,307200"
		efk="204800"
	}
	[[ "${total_ram_kb}" -le "8388608" ]] && {
		minfree="25600,38400,51200,64000,153600,179200"
		efk="128000"
	}
	[[ "${total_ram_kb}" -le "6291456" ]] && {
		minfree="25600,38400,51200,64000,102400,128000"
		efk="102400"
	}
	[[ "${total_ram_kb}" -le "4197304" ]] && {
		minfree="12800,19200,25600,32000,76800,102400"
		efk="76800"
	}
	[[ "${total_ram_kb}" -le "3145728" ]] && {
		minfree="12800,19200,25600,32000,51200,76800"
		efk="51200"
	}
	[[ "${total_ram_kb}" -le "2098652" ]] && {
		minfree="12800,19200,25600,32000,38400,51200"
		efk="25600"
	}
	[[ "${total_ram_kb}" -le "1049326" ]] && {
		minfree="5120,10240,12800,15360,25600,38400"
		efk="19200"
	}
	sync
	write "${vm}drop_caches" "3"
	write "${vm}dirty_background_ratio" "15"
	write "${vm}dirty_ratio" "30"
	write "${vm}dirty_expire_centisecs" "3000"
	write "${vm}dirty_writeback_centisecs" "3000"
	write "${vm}page-cluster" "0"
	write "${vm}stat_interval" "60"
	[[ "${samsung}" == "true" ]] && [[ "${total_ram}" -lt "4000" ]] && write "${vm}swappiness" "150" || write "${vm}swappiness" "100"
	write "${vm}laptop_mode" "0"
	write "${vm}vfs_cache_pressure" "75"
	write "${vm}watermark_scale_factor" "1"
	[[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	[[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "1"
	[[ -e "${vm}swap_ratio" ]] && write "${vm}swap_ratio" "100"
	[[ -e "${vm}oom_dump_tasks" ]] && write "${vm}oom_dump_tasks" "0"
	[[ -e "${lmk}parameters/minfree" ]] && write "${lmk}parameters/minfree" "${minfree}"
	[[ -e "${lmk}parameters/oom_reaper" ]] && write "${lmk}parameters/oom_reaper" "1"
	[[ -e "${lmk}parameters/lmk_fast_run" ]] && write "${lmk}parameters/lmk_fast_run" "1"
	[[ -e "${lmk}parameters/enable_adaptive_lmk" ]] && write "${lmk}parameters/enable_adaptive_lmk" "1"
	[[ -e "${vm}extra_free_kbytes" ]] && write "${vm}extra_free_kbytes" "${efk}"
	[[ -e "${lmk}parameters/cost" ]] && write "${lmk}parameters/cost" "4096"

	kmsg "Tweaked various VM and LMK parameters for a improved user-experience"
	kmsg3 ""
}

vm_lmk_battery() {
	[[ "${total_ram_kb}" -gt "8388608" ]] && {
		minfree="25600,38400,51200,64000,256000,307200"
		efk="204800"
	}
	[[ "${total_ram_kb}" -le "8388608" ]] && {
		minfree="25600,38400,51200,64000,153600,179200"
		efk="128000"
	}
	[[ "${total_ram_kb}" -le "6291456" ]] && {
		minfree="25600,38400,51200,64000,102400,128000"
		efk="102400"
	}
	[[ "${total_ram_kb}" -le "4197304" ]] && {
		minfree="12800,19200,25600,32000,76800,102400"
		efk="76800"
	}
	[[ "${total_ram_kb}" -le "3145728" ]] && {
		minfree="12800,19200,25600,32000,51200,76800"
		efk="51200"
	}
	[[ "${total_ram_kb}" -le "2098652" ]] && {
		minfree="12800,19200,25600,32000,38400,51200"
		efk="25600"
	}
	[[ "${total_ram_kb}" -le "1049326" ]] && {
		minfree="5120,10240,12800,15360,25600,38400"
		efk="19200"
	}
	sync
	write "${vm}drop_caches" "1"
	write "${vm}dirty_background_ratio" "2"
	write "${vm}dirty_ratio" "5"
	write "${vm}dirty_expire_centisecs" "500"
	write "${vm}dirty_writeback_centisecs" "500"
	write "${vm}page-cluster" "0"
	write "${vm}stat_interval" "60"
	[[ "${samsung}" == "true" ]] && [[ "${total_ram}" -lt "4000" ]] && write "${vm}swappiness" "150" || write "${vm}swappiness" "100"
	write "${vm}laptop_mode" "0"
	write "${vm}vfs_cache_pressure" "100"
	write "${vm}watermark_scale_factor" "1"
	[[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	[[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "1"
	[[ -e "${vm}swap_ratio" ]] && write "${vm}swap_ratio" "100"
	[[ -e "${vm}oom_dump_tasks" ]] && write "${vm}oom_dump_tasks" "0"
	[[ -e "${lmk}parameters/minfree" ]] && write "${lmk}parameters/minfree" "${minfree}"
	[[ -e "${lmk}parameters/oom_reaper" ]] && write "${lmk}parameters/oom_reaper" "1"
	[[ -e "${lmk}parameters/lmk_fast_run" ]] && write "${lmk}parameters/lmk_fast_run" "1"
	[[ -e "${lmk}parameters/enable_adaptive_lmk" ]] && write "${lmk}parameters/enable_adaptive_lmk" "1"
	[[ -e "${vm}extra_free_kbytes" ]] && write "${vm}extra_free_kbytes" "${efk}"
	[[ -e "${lmk}parameters/cost" ]] && write "${lmk}parameters/cost" "4096"

	kmsg "Tweaked various VM and LMK parameters for a improved user-experience"
	kmsg3 ""
}

vm_lmk_gaming() {
	[[ "${total_ram_kb}" -gt "8388608" ]] && {
		minfree="25600,38400,51200,64000,256000,307200"
		efk="204800"
	}
	[[ "${total_ram_kb}" -le "8388608" ]] && {
		minfree="25600,38400,51200,64000,153600,179200"
		efk="128000"
	}
	[[ "${total_ram_kb}" -le "6291456" ]] && {
		minfree="25600,38400,51200,64000,102400,128000"
		efk="102400"
	}
	[[ "${total_ram_kb}" -le "4197304" ]] && {
		minfree="12800,19200,25600,32000,76800,102400"
		efk="76800"
	}
	[[ "${total_ram_kb}" -le "3145728" ]] && {
		minfree="12800,19200,25600,32000,51200,76800"
		efk="51200"
	}
	[[ "${total_ram_kb}" -le "2098652" ]] && {
		minfree="12800,19200,25600,32000,38400,51200"
		efk="25600"
	}
	[[ "${total_ram_kb}" -le "1049326" ]] && {
		minfree="5120,10240,12800,15360,25600,38400"
		efk="19200"
	}
	sync
	write "${vm}drop_caches" "3"
	write "${vm}dirty_background_ratio" "15"
	write "${vm}dirty_ratio" "30"
	write "${vm}dirty_expire_centisecs" "3000"
	write "${vm}dirty_writeback_centisecs" "3000"
	write "${vm}page-cluster" "0"
	write "${vm}stat_interval" "60"
	[[ "${samsung}" == "true" ]] && [[ "${total_ram}" -lt "4000" ]] && write "${vm}swappiness" "150" || write "${vm}swappiness" "100"
	write "${vm}laptop_mode" "0"
	write "${vm}vfs_cache_pressure" "75"
	write "${vm}watermark_scale_factor" "1"
	[[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	[[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "1"
	[[ -e "${vm}swap_ratio" ]] && write "${vm}swap_ratio" "100"
	[[ -e "${vm}oom_dump_tasks" ]] && write "${vm}oom_dump_tasks" "0"
	[[ -e "${lmk}parameters/minfree" ]] && write "${lmk}parameters/minfree" "${minfree}"
	[[ -e "${lmk}parameters/oom_reaper" ]] && write "${lmk}parameters/oom_reaper" "1"
	[[ -e "${lmk}parameters/lmk_fast_run" ]] && write "${lmk}parameters/lmk_fast_run" "1"
	[[ -e "${lmk}parameters/enable_adaptive_lmk" ]] && write "${lmk}parameters/enable_adaptive_lmk" "1"
	[[ -e "${vm}extra_free_kbytes" ]] && write "${vm}extra_free_kbytes" "${efk}"
	[[ -e "${lmk}parameters/cost" ]] && write "${lmk}parameters/cost" "4096"

	kmsg "Tweaked various VM and LMK parameters for a improved user-experience"
	kmsg3 ""
}

disable_msm_thermal() {
	if [[ -d "/sys/module/msm_thermal/" ]]; then
		write "/sys/module/msm_thermal/vdd_restriction/enabled" "0"
		write "/sys/module/msm_thermal/core_control/enabled" "0"
		write "/sys/module/msm_thermal/parameters/enabled" "N"
		kmsg "Disabled msm_thermal"
		kmsg3 ""
	fi
}

enable_pewq() {
	if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]; then
		write "/sys/module/workqueue/parameters/power_efficient" "Y"
		kmsg "Enabled power efficient workqueue"
		kmsg3 ""
	fi
}

disable_pewq() {
	if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]; then
		write "/sys/module/workqueue/parameters/power_efficient" "N"
		kmsg "Disabled power efficient workqueue"
		kmsg3 ""
	fi
}

enable_mcps() {
	if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]; then
		write "/sys/devices/system/cpu/sched_mc_power_savings" "2"
		kmsg "Enabled scheduler multi-core power-saving"
		kmsg3 ""
	fi
}

disable_mcps() {
	if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]; then
		write "/sys/devices/system/cpu/sched_mc_power_savings" "0"
		kmsg "Disabled scheduler multi-core power-saving"
		kmsg3 ""
	fi
}

fix_dt2w() {
	if [[ -e "/sys/touchpanel/double_tap" ]] && [[ -e "/proc/tp_gesture" ]]; then
		write "/sys/touchpanel/double_tap" "1"
		write "/proc/tp_gesture" "1"
		kmsg "Fixed DT2W if broken"
		kmsg3 ""

	elif [[ -e "/sys/class/sec/tsp/dt2w_enable" ]]; then
		write "/sys/class/sec/tsp/dt2w_enable" "1"
		kmsg "Fixed DT2W if broken"
		kmsg3 ""

	elif [[ -e "/proc/tp_gesture" ]]; then
		write "/proc/tp_gesture" "1"
		kmsg "Fixed DT2W if broken"
		kmsg3 ""

	elif [[ -e "/sys/touchpanel/double_tap" ]]; then
		write "/sys/touchpanel/double_tap" "1"
		kmsg "Fixed DT2W if broken"
		kmsg3 ""
	fi
}

enable_tb() {
	if [[ -e "/sys/module/msm_performance/parameters/touchboost" ]]; then
		write "/sys/module/msm_performance/parameters/touchboost" "1"
		kmsg "Enabled msm_performance touch boost"
		kmsg3 ""

	elif [[ -e "/sys/power/pnpmgr/touch_boost" ]]; then
		write "/sys/power/pnpmgr/touch_boost" "1"
		write "/sys/power/pnpmgr/long_duration_touch_boost" "1"
		kmsg "Enabled pnpmgr touch boost"
		kmsg3 ""
	fi
}

disable_tb() {
	if [[ -e "/sys/module/msm_performance/parameters/touchboost" ]]; then
		write "/sys/module/msm_performance/parameters/touchboost" "0"
		kmsg "Disabled msm_performance touch boost"
		kmsg3 ""

	elif [[ -e "/sys/power/pnpmgr/touch_boost" ]]; then
		write "/sys/power/pnpmgr/touch_boost" "0"
		write "/sys/power/pnpmgr/long_duration_touch_boost" "0"
		kmsg "Disabled pnpmgr touch boost"
		kmsg3 ""
	fi
}

config_tcp() {
	# Fetch the available TCP congestion control
	avail_con="$(cat "${tcp}tcp_available_congestion_control")"

	# Attempt to set the TCP congestion control in this order
	for tcpcc in bbr2 bbr westwood cubic bic; do
		# Once a matching TCP congestion control is found, set it and break
		[[ "${avail_con}" == *"${tcpcc}"* ]] && write "${tcp}tcp_congestion_control" "${tcpcc}"
		break
	done

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
	# Increase rmem_max and wmem_max values to 4M
	write "/proc/sys/net/core/wmem_max" "16777216"
	write "/proc/sys/net/core/rmem_max" "16777216"
	# Distribute load between CPUs, at cost of some delay on timestamps
	write "/proc/sys/net/core/netdev_tstamp_prequeue" "0"

	kmsg "Applied TCP tweaks"
	kmsg3 ""
}

enable_kern_batt_saver() {
	if [[ -d "/sys/module/battery_saver/" ]]; then
		write "/sys/module/battery_saver/parameters/enabled" "Y"
		kmsg "Enabled kernel battery saver"
		kmsg3 ""
	fi
}

disable_kern_batt_saver() {
	if [[ -d "/sys/module/battery_saver/" ]]; then
		write "/sys/module/battery_saver/parameters/enabled" "N"
		kmsg "Disabled kernel battery saver"
		kmsg3 ""
	fi
}

enable_hp_snd() {
	for hpm in /sys/module/snd_soc_wcd*/; do
		if [[ -d "${hpm}" ]]; then
			write "${hpm}parameters/high_perf_mode" "1"
			kmsg "Enabled high performance audio"
			kmsg3 ""
			break
		fi
	done
}

disable_hp_snd() {
	for hpm in /sys/module/snd_soc_wcd*/; do
		if [[ -d "${hpm}" ]]; then
			write "${hpm}parameters/high_perf_mode" "0"
			kmsg "Disabled high performance audio"
			kmsg3 ""
			break
		fi
	done
}

enable_lpm() {
	for lpm in /sys/module/lpm_levels/system/*/*/*/; do
		if [[ -d "/sys/module/lpm_levels/" ]]; then
			write "/sys/module/lpm_levels/parameters/lpm_prediction" "Y"
			write "/sys/module/lpm_levels/parameters/lpm_ipi_prediction" "Y"
			write "/sys/module/lpm_levels/parameters/sleep_disabled" "N"
			write "${lpm}idle_enabled" "Y"
			write "${lpm}suspend_enabled" "Y"
		fi
	done

	kmsg "Enabled LPM"
	kmsg3 ""
}

disable_lpm() {
	for lpm in /sys/module/lpm_levels/system/*/*/*/; do
		if [[ -d "/sys/module/lpm_levels/" ]]; then
			write "/sys/module/lpm_levels/parameters/lpm_prediction" "N"
			write "/sys/module/lpm_levels/parameters/lpm_ipi_prediction" "N"
			write "/sys/module/lpm_levels/parameters/sleep_disabled" "Y"
			write "${lpm}idle_enabled" "N"
			write "${lpm}suspend_enabled" "N"
		fi
	done

	kmsg "Disabled LPM"
	kmsg3 ""
}

enable_pm2_idle_mode() {
	if [[ -e "/sys/module/pm2/parameters/idle_sleep_mode" ]]; then
		write "/sys/module/pm2/parameters/idle_sleep_mode" "Y"
		kmsg "Enabled pm2 idle sleep mode"
		kmsg3 ""
	fi
}

disable_pm2_idle_mode() {
	if [[ -e "/sys/module/pm2/parameters/idle_sleep_mode" ]]; then
		write "/sys/module/pm2/parameters/idle_sleep_mode" "N"
		kmsg "Disabled pm2 idle sleep mode"
		kmsg3 ""
	fi
}

enable_lcd_prdc() {
	if [[ -e "/sys/class/lcd/panel/power_reduce" ]]; then
		write "/sys/class/lcd/panel/power_reduce" "1"
		kmsg "Enabled LCD power reduce"
		kmsg3 ""
	fi
}

disable_lcd_prdc() {
	if [[ -e "/sys/class/lcd/panel/power_reduce" ]]; then
		write "/sys/class/lcd/panel/power_reduce" "0"
		kmsg "Disabled LCD power reduce"
		kmsg3 ""
	fi
}

enable_usb_fast_chrg() {
	if [[ -e "/sys/kernel/fast_charge/force_fast_charge" ]]; then
		write "/sys/kernel/fast_charge/force_fast_charge" "1"
		kmsg "Enabled USB 3.0 fast charging"
		kmsg3 ""
	fi
}

enable_sam_fast_chrg() {
	if [[ -e "/sys/class/sec/switch/afc_disable" ]]; then
		write "/sys/class/sec/switch/afc_disable" "0"
		kmsg "Enabled fast charging on Samsung devices"
		kmsg3 ""
	fi
}

emmc_clk_sclg_balanced() {
	if [[ -d "/sys/class/mmc_host/mmc0/" ]] && [[ -d "/sys/class/mmc_host/mmc1/" ]]; then
		write "/sys/class/mmc_host/mmc0/clk_scaling/enable" "1"
		write "/sys/class/mmc_host/mmc0/clk_scaling/up_threshold" "25"
		write "/sys/class/mmc_host/mmc0/clk_scaling/down_threshold" "5"
		write "/sys/class/mmc_host/mmc1/clk_scaling/enable" "1"
		write "/sys/class/mmc_host/mmc1/clk_scaling/up_threshold" "25"
		write "/sys/class/mmc_host/mmc1/clk_scaling/down_threshold" "5"

	elif [[ -d "/sys/class/mmc_host/mmc0/" ]]; then
		write "/sys/class/mmc_host/mmc0/clk_scaling/enable" "1"
		write "/sys/class/mmc_host/mmc0/clk_scaling/up_threshold" "25"
		write "/sys/class/mmc_host/mmc0/clk_scaling/down_threshold" "5"
	fi
}

emmc_clk_sclg_pwr_saving() {
	if [[ -d "/sys/class/mmc_host/mmc0/" ]] && [[ -d "/sys/class/mmc_host/mmc1/" ]]; then
		write "/sys/class/mmc_host/mmc0/clk_scaling/enable" "1"
		write "/sys/class/mmc_host/mmc0/clk_scaling/up_threshold" "40"
		write "/sys/class/mmc_host/mmc0/clk_scaling/down_threshold" "10"
		write "/sys/class/mmc_host/mmc1/clk_scaling/enable" "1"
		write "/sys/class/mmc_host/mmc1/clk_scaling/up_threshold" "40"
		write "/sys/class/mmc_host/mmc1/clk_scaling/down_threshold" "10"

	elif [[ -d "/sys/class/mmc_host/mmc0/" ]]; then
		write "/sys/class/mmc_host/mmc0/clk_scaling/enable" "1"
		write "/sys/class/mmc_host/mmc0/clk_scaling/up_threshold" "40"
		write "/sys/class/mmc_host/mmc0/clk_scaling/down_threshold" "10"
	fi
}

disable_emmc_clk_sclg() {
	[[ -d "/sys/class/mmc_host/mmc0/" ]] && [[ -d "/sys/class/mmc_host/mmc1/" ]] && {
		write "/sys/class/mmc_host/mmc0/clk_scaling/enable" "0"
		write "/sys/class/mmc_host/mmc1/clk_scaling/enable" "0"
	}
	[[ -d "/sys/class/mmc_host/mmc0/" ]] && write "/sys/class/mmc_host/mmc0/clk_scaling/enable" "0"
}

disable_debug() {
	# Disable debugging / logging
	for i in edac_mc_log* enable_event_log log_level* *log_ue* *log_ce* log_ecn_error snapshot_crashdumper seclog*; do
		for o in $(find /sys/ -type f -name "${i}"); do
			write "${o}" "0"
		done
	done

	kmsg "Disabled misc debugging"
	kmsg3 ""
}

perfmgr_default() {
	if [[ -d "${perfmgr}boost_ctrl/eas_ctrl/" ]]; then
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
	fi
}

perfmgr_pwr_saving() {
	if [[ -d "${perfmgr}boost_ctrl/eas_ctrl/" ]]; then
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
	fi
}

# $1:content
write_panel() { echo "$1" >>"${bbn_banner}"; }

save_panel() {
	write_panel "[*] Bourbon - the essential process optimizer 
Version: 1.2.6-r3
Last performed: $(date '+%Y-%m-%d %H:%M:%S')
Adjshield status: $(adjshield_status)
Adjshield config file: ${adj_cfg}"
}

# $1:str
adjshield_write_cfg() { echo "$1" >>"${adj_cfg}"; }

adjshield_create_default_cfg() {
	adjshield_write_cfg "# AdjShield Config File"
	adjshield_write_cfg "# Prevent given packages from being killed by LMK by protecting oom_score_adj"
	adjshield_write_cfg "# List all the package names of the apps which you want to keep alive."
	adjshield_write_cfg "com.riotgames.league.wildrift"
	adjshield_write_cfg "com.activision.callofduty.shooter"
	adjshield_write_cfg "com.mobile.legends"
	adjshield_write_cfg "com.tencent.ig"
}

adjshield_start() {
	# clear logs
	rm -rf "${adj_log}"
	rm -rf "${bbn_log}"
	rm -rf "${bbn_banner}"
	# check interval: 120 seconds - Deprecated, use event driven instead
	${MODPATH}system/bin/adjshield -o "${adj_log}" -c "${adj_cfg}" &
}

adjshield_stop() { killall -9 "${adj_nm}" 2>/dev/null; }

# return:status
adjshield_status() {
	if [[ "$(ps -A | grep "${adj_nm}")" != "" ]]; then
		echo "Adjshield running. see ${adj_log} for details."
	else
		# "Error: Log file not found"
		err="$(cat "${adj_log}" | grep Error | head -n 1 | cut -d: -f2)"
		[[ "${err}" != "" ]] && echo "Not running. ${err}." || echo "Not running. Unknown reason."
	fi
}

# $1:task_name $2:cgroup_name $3:"cpuset"/"stune"
change_task_cgroup() {
	for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/${temp_pid}/task/"); do
			comm="$(cat /proc/${temp_pid}/task/${temp_tid}/comm)"
			echo "${temp_tid}" >"/dev/$3/$2/tasks"
		done
	done
}

# $1:process_name $2:cgroup_name $3:"cpuset"/"stune"
change_proc_cgroup() {
	for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
		comm="$(cat /proc/${temp_pid}/comm)"
		echo "${temp_pid}" >"/dev/$3/$2/cgroup.procs"
	done
}

# $1:task_name $2:thread_name $3:cgroup_name $4:"cpuset"/"stune"
change_thread_cgroup() {
	for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			comm="$(cat /proc/${temp_pid}/task/${temp_tid}/comm)"
			[[ "$(echo ${comm} | grep -i -E "$2")" != "" ]] && echo "${temp_tid}" >"/dev/$4/$3/tasks"
		done
	done
}

# $1:task_name $2:cgroup_name $3:"cpuset"/"stune"
change_main_thread_cgroup() {
	for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
		comm="$(cat /proc/${temp_pid}/comm)"
		echo "${temp_pid}" >"/dev/$3/$2/tasks"
	done
}

# $1:task_name $2:hex_mask(0x00000003 is CPU0 and CPU1)
change_task_affinity() {
	for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/${temp_pid}/task/"); do
			comm="$(cat /proc/${temp_pid}/task/${temp_tid}/comm)"
			taskset -p "$2" "${temp_tid}" >>"${bbn_log}"
		done
	done
}

# $1:task_name $2:thread_name $3:hex_mask(0x00000003 is CPU0 and CPU1)
change_thread_affinity() {
	for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/${temp_pid}/task/"); do
			comm="$(cat /proc/${temp_pid}/task/${temp_tid}/comm)"
			[[ "$(echo ${comm} | grep -i -E "$2")" != "" ]] && taskset -p "$3" "${temp_tid}" >>"${bbn_log}"
		done
	done
}

# $1:task_name $2:nice(relative to 120)
change_task_nice() {
	for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/${temp_pid}/task/"); do
			renice -n +40 -p "${temp_tid}"
			renice -n -19 -p "${temp_tid}"
			renice -n "$2" -p "${temp_tid}"
		done
	done
}

# $1:task_name $2:thread_name $3:nice(relative to 120)
change_thread_nice() {
	for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/${temp_pid}/task/"); do
			comm="$(cat /proc/${temp_pid}/task/${temp_tid}/comm)"
			[[ "$(echo ${comm} | grep -i -E "$2")" != "" ]] && renice -n +40 -p "${temp_tid}" && renice -n -19 -p "${temp_tid}" && renice -n "$3" -p "${temp_tid}"
		done
	done
}

# $1:task_name $2:priority(99-x, 1<=x<=99)
change_task_rt() {
	for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/${temp_pid}/task/"); do
			comm="$(cat /proc/${temp_pid}/task/${temp_tid}/comm)"
			chrt -f -p "$2" "${temp_tid}" >>"${bbn_log}"
		done
	done
}

# $1:task_name $2:thread_name $3:priority(99-x, 1<=x<=99)
change_thread_rt() {
	for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/${temp_pid}/task/"); do
			comm="$(cat /proc/${temp_pid}/task/${temp_tid}/comm)"
			[[ "$(echo ${comm} | grep -i -E "$2")" != "" ]] && chrt -f -p "$3" "${temp_tid}" >>"${bbn_log}"
		done
	done
}

# $1:task_name
change_task_high_prio() { change_task_nice "$1" "-19"; } # audio thread nice => -19

# $1:task_name $2:thread_name
change_thread_high_prio() { change_thread_nice "$1" "$2" "-19"; }

# $1:task_name $2:thread_name
unpin_thread() { change_thread_cgroup "$1" "$2" "" "cpuset"; }

# $1:task_name $2:thread_name
pin_thread_on_pwr() { change_thread_cgroup "$1" "$2" "background" "cpuset"; }

# $1:task_name $2:thread_name
pin_thread_on_mid() {
	change_thread_cgroup "$1" "$2" "foreground" "cpuset"
	change_thread_affinity "$1" "$2" "7f"
}

# $1:task_name $2:thread_name
pin_thread_on_perf() {
	unpin_thread "$1" "$2"
	change_thread_affinity "$1" "$2" "f0"
}

# $1:task_name
unpin_proc() { change_task_cgroup "$1" "" "cpuset"; }

# $1:task_name
pin_proc_on_pwr() { change_task_cgroup "$1" "background" "cpuset"; }

# $1:task_name
pin_proc_on_mid() {
	unpin_proc "$1"
	change_task_affinity "$1" "7f"
}

# $1:task_name
pin_proc_on_perf() {
	unpin_proc "$1"
	change_task_affinity "$1" "f0"
}

rebuild_process_scan_cache() {
	# avoid matching grep itself
	# ps -Ao pid,args | grep kswapd
	# 150 [kswapd0]
	# 16490 grep kswapd
	ps_ret="$(ps -Ao pid,args)"
}

cgroup_bbn_opt() {
	# Reduce perf cluster wakeup
	# Daemons
	pin_proc_on_pwr "crtc_commit|crtc_event|pp_event|msm_irqbalance|netd|mdnsd|analytics"
	pin_proc_on_pwr "imsdaemon|cnss-daemon|qadaemon|qseecomd|time_daemon|ATFWD-daemon|ims_rtp_daemon|qcrilNrd"
	# Hardware services, eg. android.hardware.sensors
	pin_proc_on_pwr "android.hardware.bluetooth"
	pin_proc_on_pwr "android.hardware.gnss"
	pin_proc_on_pwr "android.hardware.health"
	pin_proc_on_pwr "android.hardware.thermal"
	pin_proc_on_pwr "android.hardware.wifi"
	pin_proc_on_pwr "android.hardware.keymaster"
	pin_proc_on_pwr "vendor.qti.hardware.qseecom"
	pin_proc_on_pwr "android.hardware.sensors"
	pin_proc_on_pwr "sensorservice"
	# com.android.providers.media.module controlled by bourbon
	pin_proc_on_pwr "android.process.media"
	# com.miui.securitycenter & com.miui.securityadd
	pin_proc_on_pwr "miui\.security"
	# system_server controlled by bourbon
	change_proc_cgroup "system_server" "" "cpuset"
	# Input dispatcher
	change_thread_high_prio "system_server" "input"
	# Not important
	pin_thread_on_pwr "system_server" "Miui|Connect|Network|Wifi|backup|Sync|Observer|Power|Sensor|batterystats"
	pin_thread_on_pwr "system_server" "Thread-|pool-|Jit|CachedAppOpt|Greezer|TaskSnapshot|Oom"
	change_thread_nice "system_server" "Greezer|TaskSnapshot|Oom" "4"
	# speed up searching service binder
	change_task_cgroup "servicemanag" "top-app" "cpuset"
	# Pevent display service from being preempted by normal tasks
	unpin_proc "\.hardware\.display"
	change_task_affinity "\.hardware\.display" "7f"
	change_task_rt "\.hardware\.display" "2"
	# let UX related Binders run with top-app
	change_thread_cgroup "\.hardware\.display" "^Binder" "top-app" "cpuset"
	change_thread_cgroup "\.hardware\.display" "^HwBinder" "top-app" "cpuset"
	change_thread_cgroup "\.hwcomposer" "^Binder" "top-app" "cpuset"
	change_thread_cgroup "\.hwcomposer" "^HwBinder" "top-app" "cpuset"
	change_thread_cgroup "\.hardware\.composer" "^Binder" "top-app" "cpuset"
	change_thread_cgroup "\.hardware\.composer" "^HwBinder" "top-app" "cpuset"
	# boost app boot process, zygote--com.xxxx.xxx
	# usap nicing isn't necessary as it is already set to the max nice possible (-20) by default
	unpin_proc "zygote|usap"
	change_task_nice "zygote" "-20"
}

clear_logs() {
	# Remove debug log if size is >= 1 MB
	kdbg_max_size=1000000
	# Do the same to sqlite opt log
	sqlite_opt_max_size=1000000
	[[ "$(stat -t "${KDBG}" 2>/dev/null | awk '{print $2}')" -ge "${kdbg_max_size}" ]] && rm -rf "${KDBG}"
	[[ "$(stat -t /data/media/0/KTSR/sqlite_opt.log 2>/dev/null | awk '{print $2}')" -ge "${sqlite_opt_max_size}" ]] && rm -rf "/data/media/0/KTSR/sqlite_opt.log"
}

# Get screen state (ON | OFF)
get_scrn_state() {
	scrn_state=$(dumpsys power 2>/dev/null | grep state=O | cut -d "=" -f 2)
	[[ "${scrn_state}" == "ON" ]] && scrn_on=1
}

get_all() {
	get_gpu_dir
	is_qcom
	[[ "${qcom}" != "true" ]] && is_mtk
	[[ "${mtk}" != "true" ]] && [[ "${qcom}" != "true" ]] && is_exynos
	[[ "${qcom}" != "true" ]] && [[ "${exynos}" != "true" ]] && check_ppm_support
	[[ "${qcom}" == "true" ]] && define_gpu_pl
	get_gpu_max
	get_gpu_min
	get_cpu_gov
	get_gpu_gov
	get_max_cpu_clk
	get_min_cpu_clk
	get_cpu_min_max_mhz
	get_gpu_min_max
	get_gpu_min_max_mhz
	get_soc_mf
	get_soc
	get_sdk
	get_arch
	get_andro_vs
	get_dvc_cdn
	get_root
	detect_cpu_sched
	get_kern_info
	get_ram_info
	get_batt_pctg
	get_ktsr_info
	get_batt_tmp
	get_gpu_mdl
	get_drvs_info
	get_max_rr
	get_batt_hth
	get_batt_sts
	get_batt_cpct
	get_bb_ver
	get_rom_info
	get_slnx_stt
	[[ "${qcom}" == "true" ]] && disable_adreno_gpu_thrtl
	get_gpu_load
	get_nr_cores
	get_dvc_brnd
	check_one_ui
	get_bt_dvc
	get_uptime
	get_sql_info
	is_big_little
	get_cpu_load
}

apply_all() {
	print_info
	stop_services
	[[ "${ktsr_prof_en}" == "extreme" ]] || [[ "${ktsr_prof_en}" == "gaming" ]] && enable_devfreq_boost || disable_devfreq_boost
	[[ "${ktsr_prof_en}" == "balanced" ]] || [[ "${ktsr_prof_en}" == "battery" ]] && enable_core_ctl || disable_core_ctl
	config_cpuset
	boost_${ktsr_prof_en}
	io_${ktsr_prof_en}
	cpu_${ktsr_prof_en}
	[[ "${ktsr_prof_en}" == "extreme" ]] || [[ "${ktsr_prof_en}" == "gaming" ]] && enable_kvb || disable_kvb
	bring_all_cores
	[[ "${ktsr_prof_en}" == "latency" ]] || [[ "${ktsr_prof_en}" == "balanced" ]] && misc_cpu_default
	[[ "${ktsr_prof_en}" == "battery" ]] && misc_cpu_pwr_saving || misc_cpu_max_pwr
	[[ "${ktsr_prof_en}" != "gaming" ]] && enable_ppm || disable_ppm
	[[ "${ktsr_prof_en}" == "latency" ]] || [[ "${ktsr_prof_en}" == "balanced" ]] || [[ "${ktsr_prof_en}" == "battery" ]] && ppm_policy_default
	[[ "${ktsr_prof_en}" == "extreme" ]] && ppm_policy_max
	[[ "${ktsr_prof_en}" != "extreme" ]] && [[ "${ktsr_prof_en}" != "latency" ]] && [[ "${ktsr_prof_en}" != "gaming" ]] && {
		cpu_clk_min
		cpu_clk_default
	} || cpu_clk_max
	hmp_${ktsr_prof_en}
	gpu_${ktsr_prof_en}
	schedtune_${ktsr_prof_en}
	sched_ft_${ktsr_prof_en}
	disable_crc
	sched_${ktsr_prof_en}
	[[ "${ktsr_prof_en}" == "extreme" ]] || [[ "${ktsr_prof_en}" == "gaming" ]] && disable_fp_boost || enable_fp_boost
	uclamp_${ktsr_prof_en}
	config_blkio
	config_fs
	config_dyn_fsync
	[[ "${ktsr_prof_en}" == "balanced" ]] || [[ "${ktsr_prof_en}" == "latency" ]] && ufs_default
	[[ "${ktsr_prof_en}" == "extreme" ]] || [[ "${ktsr_prof_en}" == "gaming" ]] && ufs_max || ufs_pwr_saving
	vm_lmk_${ktsr_prof_en}
	disable_msm_thermal
	[[ "${ktsr_prof_en}" == "balanced" ]] || [[ "${ktsr_prof_en}" == "battery" ]] && enable_pewq || disable_pewq
	[[ "${ktsr_prof_en}" == "battery" ]] && enable_mcps || disable_mcps
	fix_dt2w
	disable_tb
	config_tcp
	[[ "${ktsr_prof_en}" == "battery" ]] && enable_kern_batt_saver || disable_kern_batt_saver
	[[ "${ktsr_prof_en}" == "battery" ]] || [[ "${ktsr_prof_en}" == "balanced" ]] || [[ "${ktsr_prof_en}" == "latency" ]] && enable_lpm || disable_lpm
	[[ "${ktsr_prof_en}" != "extreme" ]] && [[ "${ktsr_prof_en}" != "gaming" ]] && enable_pm2_idle_mode || disable_pm2_idle_mode
	[[ "${ktsr_prof_en}" == "battery" ]] && enable_lcd_prdc || disable_lcd_prdc
	enable_usb_fast_chrg
	enable_sam_fast_chrg
	disable_spd_freqs
	config_pwr_spd
	[[ "${ktsr_prof_en}" == "balanced" ]] && emmc_clk_sclg_balanced
	[[ "${ktsr_prof_en}" == "battery" ]] && emmc_clk_sclg_pwr_saving
	[[ "${ktsr_prof_en}" == "extreme" ]] || [[ "${ktsr_prof_en}" == "gaming" ]] && disable_emmc_clk_sclg
	disable_debug
	[[ "${ktsr_prof_en}" != "battery" ]] && perfmgr_default || perfmgr_pwr_saving
}

apply_all_auto() {
	print_info
	stop_services
	[[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]] && enable_devfreq_boost || disable_devfreq_boost
	[[ "$(getprop kingauto.prof)" == "balanced" ]] || [[ "$(getprop kingauto.prof)" == "battery" ]] && enable_core_ctl || disable_core_ctl
	config_cpuset
	boost_$(getprop kingauto.prof)
	io_$(getprop kingauto.prof)
	cpu_$(getprop kingauto.prof)
	[[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]] && enable_kvb || disable_kvb
	bring_all_cores
	[[ "$(getprop kingauto.prof)" == "latency" ]] || [[ "$(getprop kingauto.prof)" == "balanced" ]] && misc_cpu_default
	[[ "$(getprop kingauto.prof)" == "battery" ]] && misc_cpu_pwr_saving || misc_cpu_max_pwr
	[[ "$(getprop kingauto.prof)" != "gaming" ]] && enable_ppm || disable_ppm
	[[ "$(getprop kingauto.prof)" == "latency" ]] || [[ "$(getprop kingauto.prof)" == "balanced" ]] || [[ "$(getprop kingauto.prof)" == "battery" ]] && ppm_policy_default
	[[ "$(getprop kingauto.prof)" == "extreme" ]] && ppm_policy_max
	[[ "$(getprop kingauto.prof)" != "extreme" ]] && [[ "$(getprop kingauto.prof)" != "latency" ]] && [[ "$(getprop kingauto.prof)" != "gaming" ]] && {
		cpu_clk_min
		cpu_clk_default
	} || cpu_clk_max
	hmp_$(getprop kingauto.prof)
	gpu_$(getprop kingauto.prof)
	schedtune_$(getprop kingauto.prof)
	sched_ft_$(getprop kingauto.prof)
	disable_crc
	sched_$(getprop kingauto.prof)
	[[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]] && disable_fp_boost || enable_fp_boost
	uclamp_$(getprop kingauto.prof)
	config_blkio
	config_fs
	config_dyn_fsync
	[[ "$(getprop kingauto.prof)" == "balanced" ]] || [[ "$(getprop kingauto.prof)" == "latency" ]] && ufs_default
	[[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]] && ufs_max || ufs_pwr_saving
	vm_lmk_$(getprop kingauto.prof)
	disable_msm_thermal
	[[ "$(getprop kingauto.prof)" == "balanced" ]] || [[ "$(getprop kingauto.prof)" == "battery" ]] && enable_pewq || disable_pewq
	[[ "$(getprop kingauto.prof)" == "battery" ]] && enable_mcps || disable_mcps
	fix_dt2w
	disable_tb
	config_tcp
	[[ "$(getprop kingauto.prof)" == "battery" ]] && enable_kern_batt_saver || disable_kern_batt_saver
	[[ "$(getprop kingauto.prof)" == "battery" ]] || [[ "$(getprop kingauto.prof)" == "balanced" ]] || [[ "$(getprop kingauto.prof)" == "latency" ]] && enable_lpm || disable_lpm
	[[ "$(getprop kingauto.prof)" != "extreme" ]] && [[ "$(getprop kingauto.prof)" != "gaming" ]] && enable_pm2_idle_mode || disable_pm2_idle_mode
	[[ "$(getprop kingauto.prof)" == "battery" ]] && enable_lcd_prdc || disable_lcd_prdc
	enable_usb_fast_chrg
	enable_sam_fast_chrg
	disable_spd_freqs
	config_pwr_spd
	[[ "$(getprop kingauto.prof)" == "balanced" ]] && emmc_clk_sclg_balanced
	[[ "$(getprop kingauto.prof)" == "battery" ]] && emmc_clk_sclg_pwr_saving
	[[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]] && disable_emmc_clk_sclg
	disable_debug
	[[ "$(getprop kingauto.prof)" != "battery" ]] && perfmgr_default || perfmgr_pwr_saving
}

latency() {
	init=$(date +%s)
	sync
	get_all
	apply_all
	cmd power set-adaptive-power-saver-enabled true 2>/dev/null
	cmd power set-fixed-performance-mode-enabled false 2>/dev/null
	cmd thermalservice reset 2>/dev/null

	kmsg "Latency profile applied. Enjoy!"
	kmsg3 ""
	exit=$(date +%s)

	exec_time=$((exit - init))
	kmsg "Spent time: $exec_time seconds."
}
automatic() {
	kmsg3 ""
	kmsg "Applying automatic profile"
	sync
	kingauto &

	kmsg "Applied automatic profile"
	kmsg3 ""
}
balanced() {
	init=$(date +%s)
	sync
	get_all
	apply_all
	cmd power set-adaptive-power-saver-enabled true 2>/dev/null
	cmd power set-fixed-performance-mode-enabled false 2>/dev/null
	cmd thermalservice reset 2>/dev/null

	kmsg "Balanced profile applied. Enjoy!"
	kmsg3 ""
	exit=$(date +%s)

	exec_time=$((exit - init))
	kmsg "Spent time: $exec_time seconds."
}
extreme() {
	init=$(date +%s)
	sync
	get_all
	apply_all
	cmd power set-adaptive-power-saver-enabled false 2>/dev/null
	cmd power set-fixed-performance-mode-enabled true 2>/dev/null
	cmd thermalservice override-status 0 2>/dev/null

	kmsg "Extreme profile applied. Enjoy!"
	kmsg3 ""
	exit=$(date +%s)

	exec_time=$((exit - init))
	kmsg "Spent time: $exec_time seconds."
}
battery() {
	init=$(date +%s)
	sync
	get_all
	apply_all
	cmd power set-adaptive-power-saver-enabled true 2>/dev/null
	cmd power set-fixed-performance-mode-enabled false 2>/dev/null
	cmd thermalservice reset 2>/dev/null

	kmsg "Battery profile applied. Enjoy!"
	kmsg3 ""
	exit=$(date +%s)

	exec_time=$((exit - init))
	kmsg "Spent time: $exec_time seconds."
}
gaming() {
	init=$(date +%s)
	sync
	get_all
	apply_all
	cmd power set-adaptive-power-saver-enabled false 2>/dev/null
	cmd power set-fixed-performance-mode-enabled true 2>/dev/null
	cmd thermalservice override-status 0 2>/dev/null

	kmsg "Gaming profile applied. Enjoy!"
	kmsg3 ""
	exit=$(date +%s)

	exec_time=$((exit - init))
	kmsg "Spent time: $exec_time seconds."
}
