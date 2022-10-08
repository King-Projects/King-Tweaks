#!/system/bin/sh
# KTSR™ by Pedro (pedrozzz0 @ GitHub)
# Thanks to Draco (tytydraco @ GitHub), mogoroku @ GitHub, helloklf @ GitHub, chenzyadb @ CoolApk, Matt Yang (yc9559 @ CoolApk) and GR for some help
# If you wanna use the code as part of your project, please maintain the credits to it's respectives authors

# TODO: remove this
source "$modpath/libs/libcommon.sh"

#####################
# Variables
#####################
modpath="/data/adb/modules/KTSR/"
klog="/data/media/0/ktsr/ktsr.log"
kdbg="/data/media/0/ktsr/ktsr_dbg.log"
tcp="/proc/sys/net/ipv4/"
kernel="/proc/sys/kernel/"
vm="/proc/sys/vm/"
cpuset="/dev/cpuset/"
cpuctl="/dev/cpuctl/"
stune="/dev/stune/"
lmk="/sys/module/lowmemorykiller/parameters"
fs="/proc/sys/fs/"
perfmgr="/proc/perfmgr/"
one_ui=false
miui=false
samsung=false
qcom=false
exynos=false
mtk=false
ppm=false
big_little=false
lib_ver="1.5.1-master"
migt="/sys/module/migt/parameters/"
board_sensor_temp="/sys/class/thermal/thermal_message/board_sensor_temp"
zram="/sys/module/zram/parameters/"
lmk="$(pgrep -f lmkd)"
auto_prof="$(getprop kingd.prof)"
fpsgo="/sys/module/mtk_fpsgo/parameters/"
fpsgo_knl="/sys/kernel/fpsgo/"
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

# Maximum unsigned integer size in C
UINT_MAX="4294967295"

# Find GPU working directory
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

[[ -d "/sys/class/kgsl/kgsl-3d0/" ]] && {
  gpu="/sys/class/kgsl/kgsl-3d0/"
  qcom=true
  gpu_num_pl=$(cat "${gpu}num_pwrlevels")
  gpu_min_pl=$((gpu_num_pl - 1))
}

[[ ! "$qcom" == "true" ]] && [[ -d "/sys/devices/platform/gpusysfs/" ]] && {
  gpu="/sys/devices/platform/gpusysfs/"
  qcom=false
}

[[ ! "$qcom" == "true" ]] && [[ -d "/sys/class/misc/mali0/device" ]] && {
  gpu="/sys/class/misc/mali0/device/"
  qcom=false
}

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

# HZ → MHz
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
[[ "$gpu_mdl" == "" ]] && gpu_mdl=$(dumpsys SurfaceFlinger | awk '/GLES/ {print $3,$4,$5}' | tr -d ,)

# Check in which SOC we are running
[[ "$(getprop ro.boot.hardware | grep qcom)" ]] || [[ "$(getprop ro.soc.manufacturer | grep QTI)" ]] || [[ "$(getprop ro.soc.manufacturer | grep Qualcomm)" ]] || [[ "$(getprop ro.hardware | grep qcom)" ]] || [[ "$(getprop ro.vendor.qti.soc_id)" ]] || [[ "$(getprop gsm.version.ril-impl | grep Qualcomm)" ]] && qcom=true
[[ "$(getprop ro.boot.hardware | grep exynos)" ]] || [[ "$(getprop ro.board.platform | grep universal)" ]] || [[ "$(getprop ro.product.board | grep universal)" ]] && exynos=true
[[ "$(getprop ro.board.platform | grep mt)" ]] || [[ "$(getprop ro.product.board | grep mt)" ]] || [[ "$(getprop ro.hardware | grep mt)" ]] || [[ "$(getprop ro.boot.hardware | grep mt)" ]] && mtk=true

# Whether CPU uses BIG.little arch or not
for i in 1 2 3 4 5 6 7; do
  [[ -d "/sys/devices/system/cpu/cpufreq/policy0/" ]] && [[ -d "/sys/devices/system/cpu/cpufreq/policy${i}/" ]] && big_little=true
done

# Device info
# Codename
dvc_cdn=$(getprop ro.product.device)

# Device brand
dvc_brnd=$(getprop ro.product.brand)

# Max refresh rate
rr=$(dumpsys display | awk '/PhysicalDisplayInfo/{print $4}' | cut -c1-3 | tr -d .)
[[ -z "$rr" ]] && rr=$(dumpsys display | grep refreshRate | awk -F '=' '{print $6}' | cut -c1-3 | tail -n 1 | tr -d .) || rr=$(dumpsys display 2>/dev/null | grep FrameRate | awk -F '=' '{print $6}' | cut -c1-3 | tail -n 1 | tr -d .)

# Kernel info
kern_ver_name=$(uname -r)
kern_bd_dt=$(uname -v | awk '{print $5, $6, $7, $8, $9, $10}')

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
batt_hth=$(dumpsys battery | awk '/health/{print $2}')
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
batt_sts=$(dumpsys battery | awk '/status/{print $2}')
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
[[ "$batt_cpct" == "" ]] && batt_cpct=$(dumpsys batterystats | awk '/Capacity:/{print $2}' | cut -d "," -f 1)

# MA → MAh
[[ "$batt_cpct" -ge "1000000" ]] && batt_cpct=$((batt_cpct / 1000))

# Busybox version
[[ "$(command -v busybox)" ]] && bb_ver=$(busybox | awk 'NR==1{print $2}') || bb_ver="Please install busybox first"

# ROM info
# Fingerprint, keys and related stuff
rom_info=$(getprop ro.build.description | awk '{print $1,$3,$4,$5}')
[[ "$rom_info" == "" ]] && rom_info=$(getprop ro.bootimage.build.description | awk '{print $1,$3,$4,$5}')
[[ "$rom_info" == "" ]] && rom_info=$(getprop ro.system.build.description | awk '{print $1,$3,$4,$5}')

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

devfreq_boost() {
  [[ "$1" == "1" ]] && {
    for dir in /sys/class/devfreq/*/; do
      max_devfreq=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $NF}')
      max_devfreq2=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $1}')
      [[ "$max_devfreq2" -gt "$max_devfreq" ]] && max_devfreq="$max_devfreq2"
      write "${dir}min_freq" "$max_devfreq"
    done
    for i in DDR LLCC L3; do
      write "/sys/devices/system/cpu/bus_dcvs/$i/max_freq" "$UINT_MAX"
    done
    log_i "Enabled devfreq boost"
  } || [[ "$1" == "0" ]] && {
    for dir in /sys/class/devfreq/*/; do
      min_devfreq=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $1}')
      min_devfreq2=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $NF}')
      [[ "$min_devfreq2" -lt "$min_devfreq" ]] && min_devfreq="$min_devfreq2"
      write "${dir}min_freq" "$min_devfreq"
    done
    log_i "Disabled devfreq boost"
  }
}

dram_boost() {
  [[ "$1" == "1" ]] && {
    for i in /sys/devices/platform/*.dvfsrc/helio-dvfsrc/; do
      ddr_opp=$(cat "${i}dvfsrc_opp_table" | head -1)
      write "${i}dvfsrc_force_vcore_dvfs_opp" "${ddr_opp:4:2}"
    done
    [[ -d "/sys/devices/platform/boot_dramboost/" ]] && write "/sys/devices/platform/boot_dramboost/dramboost/dramboost" "1"
    log_i "Enabled DRAM boost"
  } || [[ "$1" == "0" ]] && {
    for i in /sys/devices/platform/*.dvfsrc/helio-dvfsrc/; do
      write "${i}dvfsrc_force_vcore_dvfs_opp" "-1"
    done
    [[ -d "/sys/devices/platform/boot_dramboost/" ]] && write "/sys/devices/platform/boot_dramboost/dramboost/dramboost" "0"
    log_i "Disabled DRAM boost"
  }
}

# Set thermal policy to step_wise as an attempt of reducing thermal throttling
therm_pol_set() {
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
    [[ "$ktsr_prof_en" == "extreme" ]] || [[ "$ktsr_prof_en" == "game" ]] || [[ "$auto_prof" == "extreme" ]] || [[ "$auto_prof" == "game" ]] && write_lock "${t_msg}sconfig" "10" || write "${t_msg}sconfig" "0"
    log_i "Tweaked thermal policies"
  }
}

get_kd_pid() {
  [[ "$(pgrep -f kingd)" != "" ]] && echo "$(pgrep -f kingd)" || echo "[Service not running]"
}

get_god_pid() {
  [[ "$(pgrep -f gameoptd)" != "" ]] && echo "$(pgrep -f gameoptd)" || echo "[Service not running]"
}

print_info() {
  echo "General info

** Date of execution: $(date)
** Kernel: $kern_ver_name, $kern_bd_dt
** SOC: $soc_mf, $soc
** SDK: $sdk
** Android version: $avs
** Android UID: $(settings get secure android_id)
** CPU governor: $cpu_gov
** Number of CPUs: $nr_cores
** CPU freq: $cpu_min_clk_mhz-${cpu_max_clk_mhz}MHz
** CPU scheduling: $cpu_sched
** Arch: $arch
** GPU freq: $gpu_min_clk_mhz-${gpu_max_clk_mhz}MHz
** GPU model: $gpu_mdl
** GPU governor: $gpu_gov
** Device: $dvc_brnd, $dvc_cdn
** ROM: $rom_info
** Max refresh rate: ${rr}HZ
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
** Root: $root
** SQLite version: $sql_ver
** SQLite build date: $sql_bd_dt
** System uptime: $sys_uptime
** SELinux: $slnx_stt
** Busybox: $bb_ver
** KTSR PID: $$
** kingd PID: $(get_kd_pid)
** GOD PID: $(get_god_pid)

** Author: Pedro | https://t.me/pedro3z0 | https://github.com/pedrozzz0
** Telegram channel: https://t.me/kingprojectz
** Telegram group: https://t.me/kingprojectzdiscussion
** Thanks to all people involved to make this project possible
" >>"$klog"
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
  kill_svc cnss_diag
  kill_svc tcpdump
  kill_svc ipacm-diag
  kill_svc statsd
  kill_svc charge_logger
  kill_svc oneplus_brain_service
  [[ "$sdk" == "31" ]] && {
    kill_svc vendor.perfservice
    kill_svc vendor.cnss_diag
    kill_svc vendor.tcpdump
    kill_svc vendor.ipacm-diag
  }
  [[ "$miui" == "false" ]] && kill_svc mlid
  [[ -e "/data/system/perfd/default_values" ]] && rm -rf "/data/system/perfd/default_values" || [[ -e "/data/vendor/perfd/default_values" ]] && rm -rf "/data/vendor/perfd/default_values"
  [[ -e "/data/system/mcd/df" ]] && rm -rf "/data/system/mcd/df"
  [[ -e "/data/system/migt/migt" ]] && rm -rf "/data/system/migt/migt"

  log_i "Disabled few debug services and userspace daemons that may conflict with KTSR"
}

core_ctl_set() {
  [[ "$1" == "1" ]] && {
    for i in 0 2 4 6; do
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
  } || [[ "$1" == "0" ]] && {
    for core_ctl in /sys/devices/system/cpu/cpu*/core_ctl/; do
      [[ -e "${core_ctl}enable" ]] && write_lock "${core_ctl}enable" "0"
      [[ -e "${core_ctl}disable" ]] && write_lock "${core_ctl}disable" "1"
    done

    [[ -d "/sys/power/cpuhotplug/" ]] && write_lock "/sys/power/cpuhotplug/enable" "0" || [[ -d "/sys/power/cpuhotplug/" ]] && write_lock "/sys/power/cpuhotplug/enabled" "0"
    [[ -d "/sys/devices/system/cpu/cpuhotplug/" ]] && write_lock "/sys/devices/system/cpu/cpuhotplug/enabled" "0"
    [[ -d "/sys/kernel/intelli_plug/" ]] && write_lock "/sys/kernel/intelli_plug/intelli_plug_active" "0"
    [[ -d "/sys/module/blu_plug/" ]] && write_lock "/sys/module/blu_plug/parameters/enabled" "0"
    [[ -d "/sys/devices/virtual/misc/mako_hotplug_control/" ]] && write_lock "/sys/devices/virtual/misc/mako_hotplug_control/enabled" "0"
    [[ -d "/sys/module/autosmp/" ]] && write_lock "/sys/module/autosmp/parameters/enabled" "0"
    [[ -d "/sys/kernel/zen_decision/" ]] && write_lock "/sys/kernel/zen_decision/enabled" "0"
    [[ -d "/proc/hps/" ]] && write_lock "/proc/hps/enabled" "0"
    [[ -d "/sys/module/scheduler/" ]] && write_lock "/sys/module/scheduler/holders/mtk_core_ctl/parameters/policy_enable" "0"
    [[ -d "/sys/module/thermal_interface/" ]] && write_lock "/sys/module/thermal_interface/holders/mtk_core_ctl/parameters/policy_enable" "0"
    [[ -d "/sys/module/mtk_core_ctl/" ]] && write_lock "/sys/module/mtk_core_ctl/policy_enable" "0"
    [[ -d "/sys/module/cpufreq_sugov_ext/" ]] && write_lock "/sys/module/cpufreq_sugov_ext/holders/mtk_core_ctl/parameters/policy_enable" "0"
    [[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]] && write_lock "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
    [[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]] && write_lock "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
    [[ -d "/sys/module/msm_thermal/" ]] && {
      write_lock "/sys/module/msm_thermal/core_control/enabled" "0"
      write_lock "/sys/module/msm_thermal/parameters/enabled" "N"

      log_i "Disabled core control & CPU hotplug"
    }
  }

  boost_tune() {
    [[ "$ktsr_prof_en" == "latency" ]] || [[ "$auto_prof" == "latency" ]] && {
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
    } || [[ "$ktsr_prof_en" == "balanced" ]] && [[ "$auto_prof" == "balanced" ]] && {
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
    } || [[ "$ktsr_prof_en" == "extreme" ]] || [[ "$auto_prof" == "extreme" ]] && {
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
    } || [[ "$ktsr_prof_en" == "pwrsave" ]] || [[ "$auto_prof" == "pwrsave" ]] && {
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
    } || [[ "$ktsr_prof_en" == "game" ]] || [[ "$auto_prof" == "game" ]] && {
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
  }

  io_tune() {
    [[ "$ktsr_prof_en" == "latency" ]] || [[ "$auto_prof" == "latency" ]] && {
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
    } || [[ "$ktsr_prof_en" == "balanced" ]] || [[ "$auto_prof" == "balanced" ]] && {
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
    } || [[ "$ktsr_prof_en" == "extreme" ]] || [[ "$auto_prof" == "extreme" ]] && {
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
        write "${queue}nomerges" "0"
        write "${queue}rq_affinity" "2"
        write "${queue}nr_requests" "128"
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
    } || [[ "$ktsr_prof_en" == "pwrsave" ]] || [[ "$auto_prof" == "pwrsave" ]] && {
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
    } || [[ "$ktsr_prof_en" == "game" ]] || [[ "$auto_prof" == "game" ]] && {
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
        write "${queue}nomerges" "0"
        write "${queue}rq_affinity" "2"
        write "${queue}nr_requests" "128"
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
  }

  cpu_tune() {
    [[ "$ktsr_prof_en" == "latency" ]] || [[ "$auto_prof" == "latency" ]] && {
      for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
        # Available governors from the CPU
        avail_govs="$(cat "${cpu}scaling_available_governors")"

        # Attempt to set the governor in this order
        for governor in walt sched_pixel schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive; do
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
    } || [[ "$ktsr_prof_en" == "balanced" ]] || [[ "$auto_prof" == "balanced" ]] && {
      for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
        avail_govs="$(cat "${cpu}scaling_available_governors")"

        for governor in walt sched_pixel schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive; do
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
    } || [[ "$ktsr_prof_en" == "extreme" ]] || [[ "$auto_prof" == "extreme" ]] && {
      for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
        avail_govs="$(cat "${cpu}scaling_available_governors")"

        for governor in walt sched_pixel schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive; do
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
        write "$governor/iowait_boost_enable" "1"
        write "$governor/rate_limit_us" "0"
        write "$governor/hispeed_load" "75"
        write "$governor/hispeed_freq" "$cpu_max_freq"
      done

      for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d); do
        write "$governor/up_rate_limit_us" "0"
        write "$governor/down_rate_limit_us" "0"
        write "$governor/pl" "1"
        write "$governor/iowait_boost_enable" "1"
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
    } || [[ "$ktsr_prof_en" == "pwrsave" ]] || [[ "$auto_prof" == "pwrsave" ]] && {
      for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
        avail_govs="$(cat "${cpu}scaling_available_governors")"

        for governor in walt sched_pixel schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive; do
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
    } || [[ "$ktsr_prof_en" == "game" ]] || [[ "$auto_prof" == "game" ]] && {
      for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
        avail_govs="$(cat "${cpu}scaling_available_governors")"

        for governor in walt sched_pixel schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive; do
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
  }

  # 1:default 2:boost 3:pwrsave
  misc_cpu_set() {
    [[ "$1" == "1" ]] && {
      [[ -e "/proc/cpufreq/cpufreq_power_mode" ]] && write "/proc/cpufreq/cpufreq_power_mode" "0"
      [[ -e "/proc/cpufreq/cpufreq_cci_mode" ]] && write "/proc/cpufreq/cpufreq_cci_mode" "0"
      [[ -e "/proc/cpufreq/cpufreq_stress_test" ]] && write "/proc/cpufreq/cpufreq_stress_test" "0"
      [[ -e "/proc/cpufreq/cpufreq_sched_disable" ]] && write "/proc/cpufreq/cpufreq_sched_disable" "0"
      [[ -e "/sys/devices/system/cpu/perf/enable" ]] && write "/sys/devices/system/cpu/perf/enable" "0"
    } || [[ "$1" == "2" ]] && {
      [[ -e "/proc/cpufreq/cpufreq_power_mode" ]] && write "/proc/cpufreq/cpufreq_power_mode" "3"
      [[ -e "/proc/cpufreq/cpufreq_cci_mode" ]] && write "/proc/cpufreq/cpufreq_cci_mode" "1"
      [[ -e "/proc/cpufreq/cpufreq_stress_test" ]] && write "/proc/cpufreq/cpufreq_stress_test" "1"
      [[ -e "/proc/cpufreq/cpufreq_sched_disable" ]] && write "/proc/cpufreq/cpufreq_sched_disable" "0"
      [[ -e "/sys/devices/system/cpu/perf/enable" ]] && write "/sys/devices/system/cpu/perf/enable" "1"
    } || [[ "$1" == "3" ]] && {
      [[ -e "/proc/cpufreq/cpufreq_power_mode" ]] && write "/proc/cpufreq/cpufreq_power_mode" "1"
      [[ -e "/proc/cpufreq/cpufreq_cci_mode" ]] && write "/proc/cpufreq/cpufreq_cci_mode" "0"
      [[ -e "/proc/cpufreq/cpufreq_stress_test" ]] && write "/proc/cpufreq/cpufreq_stress_test" "0"
      [[ -e "/proc/cpufreq/cpufreq_sched_disable" ]] && write "/proc/cpufreq/cpufreq_sched_disable" "0"
      [[ -e "/sys/devices/system/cpu/perf/enable" ]] && write "/sys/devices/system/cpu/perf/enable" "0"
    }
  }

  bring_all_cores() {
    for i in 0 1 2 3 4 5 6 7; do
      write "/sys/devices/system/cpu/cpu$i/online" "1"
    done
  }

  ppm() {
    [[ "$ppm" == "true" ]] && [[ "$1" == "1" ]] && {
      write "/proc/ppm/enabled" "1"
      log_i "Tweaked CPU parameters"
    } || [[ "$ppm" == "true" ]] && [[ "$1" == "0" ]] && {
      write_lock "/proc/ppm/enabled" "0"
      log_i "Tweaked CPU parameters"
    }
  }

  hmp_tune() {
    [[ -d "/sys/kernel/hmp/" ]] && [[ "$ktsr_prof_en" == "balanced" ]] || [[ "$auto_prof" == "balanced" ]] && {
      write "/sys/kernel/hmp/boost" "0"
      write "/sys/kernel/hmp/down_compensation_enabled" "1"
      write "/sys/kernel/hmp/family_boost" "0"
      write "/sys/kernel/hmp/semiboost" "0"
      write "/sys/kernel/hmp/up_threshold" "524"
      write "/sys/kernel/hmp/down_threshold" "214"
      log_i "Tweaked HMP parameters"
    } || [[ -d "/sys/kernel/hmp/" ]] && [[ "$ktsr_prof_en" == "extreme" ]] || [[ "$auto_prof" == "extreme" ]] && {
      write "/sys/kernel/hmp/boost" "1"
      write "/sys/kernel/hmp/down_compensation_enabled" "1"
      write "/sys/kernel/hmp/family_boost" "1"
      write "/sys/kernel/hmp/semiboost" "1"
      write "/sys/kernel/hmp/up_threshold" "430"
      write "/sys/kernel/hmp/down_threshold" "150"
      log_i "Tweaked HMP parameters"
    } || [[ -d "/sys/kernel/hmp/" ]] && [[ "$ktsr_prof_en" == "pwrsave" ]] || [[ "$auto_prof" == "pwrsave" ]] && {
      write "/sys/kernel/hmp/boost" "0"
      write "/sys/kernel/hmp/down_compensation_enabled" "1"
      write "/sys/kernel/hmp/family_boost" "0"
      write "/sys/kernel/hmp/semiboost" "0"
      write "/sys/kernel/hmp/up_threshold" "700"
      write "/sys/kernel/hmp/down_threshold" "256"
      log_i "Tweaked HMP parameters"
    } || [[ -d "/sys/kernel/hmp/" ]] && [[ "$ktsr_prof_en" == "game" ]] || [[ "$auto_prof" == "game" ]] && {
      write "/sys/kernel/hmp/boost" "1"
      write "/sys/kernel/hmp/down_compensation_enabled" "1"
      write "/sys/kernel/hmp/family_boost" "1"
      write "/sys/kernel/hmp/semiboost" "1"
      write "/sys/kernel/hmp/up_threshold" "430"
      write "/sys/kernel/hmp/down_threshold" "150"
      log_i "Tweaked HMP parameters"
    }
  }

  gpu_tune() {
    [[ "$ktsr_prof_en" == "latency" ]] || [[ "$auto_prof" == "latency" ]] && {
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
        write "${gpu}thermal_pwrlevel" "0"
        write "${gpu}devfreq/adrenoboost" "0"
        write "${gpu}bus_split" "0"
        write "${gpu}devfreq/max_freq" "$gpu_max_freq"
        write "${gpu}devfreq/min_freq" "$gpu_min_freq"
        write "${gpu}min_pwrlevel" "$((gpu_min_pl - 2))"
        write "${gpu}force_no_nap" "0"
        write "${gpu}force_bus_on" "0"
        write "${gpu}force_clk_on" "0"
        write "${gpu}force_rail_on" "0"
        write "${gpu}popp" "0"
        write "${gpu}idle_timer" "80"
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
        write "/proc/mali/always_on" "0"
      }

      [[ -d "/proc/gpufreqv2/" ]] && write "/proc/gpufreqv2/fix_target_opp_index" "-1"

      [[ -d "/sys/module/sspm_v3/" ]] && write "/sys/module/sspm_v3/holders/ged/parameters/is_GED_KPI_enabled" "1"

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
    } || [[ "$ktsr_prof_en" == "balanced" ]] || [[ "$auto_prof" == "balanced" ]] && {
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
        write "${gpu}thermal_pwrlevel" "0"
        write "${gpu}devfreq/adrenoboost" "0"
        write "${gpu}bus_split" "1"
        write "${gpu}devfreq/max_freq" "$gpu_max_freq"
        write "${gpu}devfreq/min_freq" "$gpu_min_freq"
        write "${gpu}min_pwrlevel" "$gpu_min_pl"
        write "${gpu}force_no_nap" "0"
        write "${gpu}force_bus_on" "0"
        write "${gpu}force_clk_on" "0"
        write "${gpu}force_rail_on" "0"
        write "${gpu}popp" "0"
        write "${gpu}idle_timer" "80"
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
        write "/proc/mali/always_on" "0"
      }

      [[ -d "/proc/gpufreqv2/" ]] && write "/proc/gpufreqv2/fix_target_opp_index" "-1"

      [[ -d "/sys/module/sspm_v3/" ]] && write "/sys/module/sspm_v3/holders/ged/parameters/is_GED_KPI_enabled" "1"

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
    } || [[ "$ktsr_prof_en" == "extreme" ]] || [[ "$auto_prof" == "extreme" ]] && {
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
        write "${gpu}thermal_pwrlevel" "0"
        write "${gpu}devfreq/adrenoboost" "0"
        write "${gpu}bus_split" "0"
        write "${gpu}devfreq/max_freq" "$gpu_max_freq"
        write "${gpu}devfreq/min_freq" "$gpu_min_freq"
        write "${gpu}min_pwrlevel" "3"
        write "${gpu}force_no_nap" "0"
        write "${gpu}force_bus_on" "0"
        write "${gpu}force_clk_on" "0"
        write "${gpu}force_rail_on" "0"
        write "${gpu}popp" "0"
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
        write "/sys/kernel/ged/hal/timer_base_dvfs_margin" "28"
        write "/sys/kernel/ged/hal/dvfs_margin_value" "28"
        write "/sys/kernel/ged/hal/dcs_mode" "0"
      }

      [[ -d "/proc/mali/" ]] && {
        write "/proc/mali/dvfs_enable" "1"
        write "/proc/mali/always_on" "0"
      }

      [[ -d "/proc/gpufreqv2/" ]] && write "/proc/gpufreqv2/fix_target_opp_index" "-1"

      [[ -d "/sys/module/sspm_v3/" ]] && write "/sys/module/sspm_v3/holders/ged/parameters/is_GED_KPI_enabled" "1"

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
    } || [[ "$ktsr_prof_en" == "pwrsave" ]] || [[ "$auto_prof" == "pwrsave" ]] && {
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
        write "${gpu}thermal_pwrlevel" "0"
        write "${gpu}devfreq/adrenoboost" "0"
        write "${gpu}bus_split" "1"
        write "${gpu}devfreq/max_freq" "$gpu_max_freq"
        write "${gpu}devfreq/min_freq" "$gpu_min_freq"
        write "${gpu}min_pwrlevel" "$gpu_min_pl"
        write "${gpu}force_no_nap" "0"
        write "${gpu}force_bus_on" "0"
        write "${gpu}force_clk_on" "0"
        write "${gpu}force_rail_on" "0"
        write "${gpu}popp" "0"
        write "${gpu}idle_timer" "80"
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
        write "/sys/kernel/ged/hal/timer_base_dvfs_margin" "17"
        write "/sys/kernel/ged/hal/dvfs_margin_value" "17"
        write "/sys/kernel/ged/hal/dcs_mode" "0"
      }

      [[ -d "/proc/mali/" ]] && {
        write "/proc/mali/dvfs_enable" "1"
        write "/proc/mali/always_on" "0"
      }

      [[ -d "/proc/gpufreqv2/" ]] && write "/proc/gpufreqv2/fix_target_opp_index" "-1"

      [[ -d "/sys/module/sspm_v3/" ]] && write "/sys/module/sspm_v3/holders/ged/parameters/is_GED_KPI_enabled" "1"

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
    } || [[ "$ktsr_prof_en" == "game" ]] || [[ "$auto_prof" == "game" ]] && {
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
        write "${gpu}thermal_pwrlevel" "0"
        write "${gpu}devfreq/adrenoboost" "0"
        write "${gpu}bus_split" "0"
        write "${gpu}devfreq/max_freq" "$gpu_max_freq"
        write "${gpu}devfreq/min_freq" "$gpu_max"
        write "${gpu}min_pwrlevel" "0"
        write "${gpu}force_no_nap" "1"
        write "${gpu}force_bus_on" "1"
        write "${gpu}force_clk_on" "1"
        write "${gpu}force_rail_on" "1"
        write "${gpu}popp" "0"
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
        write "/sys/kernel/ged/hal/timer_base_dvfs_margin" "30"
        write "/sys/kernel/ged/hal/dvfs_margin_value" "30"
        write "/sys/kernel/ged/hal/dcs_mode" "0"
      }

      [[ -d "/proc/mali/" ]] && {
        write "/proc/mali/dvfs_enable" "0"
        write "/proc/mali/always_on" "1"
      }

      [[ -d "/proc/gpufreqv2/" ]] && write "/proc/gpufreqv2/fix_target_opp_index" "-1"

      [[ -d "/sys/module/sspm_v3/" ]] && write "/sys/module/sspm_v3/holders/ged/parameters/is_GED_KPI_enabled" "1"

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

  schedtune_tune() {
    [[ -d "$stune" ]] && [[ "$ktsr_prof_en" == "latency" ]] || [[ "$auto_prof" == "latency" ]] && {
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
    } || [[ -d "$stune" ]] && [[ "$ktsr_prof_en" == "balanced" ]] || [[ "$auto_prof" == "balanced" ]] && {
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
    } || [[ -d "$stune" ]] && [[ "$ktsr_prof_en" == "extreme" ]] || [[ "$auto_prof" == "extreme" ]] && {
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
    } || [[ -d "$stune" ]] && [[ "$ktsr_prof_en" == "pwrsave" ]] || [[ "$auto_prof" == "pwrsave" ]] && {
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
    } || [[ -d "$stune" ]] && [[ "$ktsr_prof_en" == "game" ]] || [[ "$auto_prof" == "game" ]] && {
      write "${stune}background/schedtune.boost" "0"
      write "${stune}background/schedtune.prefer_idle" "0"
      write "${stune}background/schedtune.sched_boost" "0"
      write "${stune}background/schedtune.sched_boost_no_override" "1"
      write "${stune}background/schedtune.prefer_perf" "0"
      write "${stune}background/schedtune.util_est_en" "0"
      write "${stune}background/schedtune.ontime_en" "0"
      write "${stune}background/schedtune.prefer_high_cap" "0"
      write "${stune}foreground/schedtune.boost" "40"
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
      write "${stune}top-app/schedtune.boost" "60"
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

  uclamp_tune() {
    [[ -e "${cpuctl}top-app/cpu.uclamp.max" ]] && [[ "$ktsr_prof_en" == "latency" ]] || [[ "$auto_prof" == "latency" ]] && {
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
    } || [[ -e "${cpuctl}top-app/cpu.uclamp.max" ]] && [[ "$ktsr_prof_en" == "balanced" ]] && {
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
    } || [[ -e "${cpuctl}top-app/cpu.uclamp.max" ]] && [[ "$ktsr_prof_en" == "extreme" ]] || [[ "$auto_prof" == "extreme" ]] && {
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
    } || [[ -e "${cpuctl}top-app/cpu.uclamp.max" ]] && [[ "$ktsr_prof_en" == "pwrsave" ]] || [[ "$auto_prof" == "pwrsave" ]] && {
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
    } || [[ -e "${cpuctl}top-app/cpu.uclamp.max" ]] && [[ "$ktsr_prof_en" == "game" ]] || [[ "$auto_prof" == "game" ]] && {
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

  sched_feat_tune() {
    [[ -e "/sys/kernel/debug/sched_features" ]] && [[ "$ktsr_prof_en" == "latency" ]] || [[ "$auto_prof" == "latency" ]] && {
      write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
      write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
      write "/sys/kernel/debug/sched_features" "ENERGY_AWARE"
      log_i "Tweaked scheduler features"
    }
  } || [[ "$ktsr_prof_en" == "balanced" ]] || [[ "$auto_prof" == "balanced" ]] && {
    [[ -e "/sys/kernel/debug/sched_features" ]] && {
      write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
      write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
      write "/sys/kernel/debug/sched_features" "ENERGY_AWARE"
      log_i "Tweaked scheduler features"
    }
  } || [[ "$ktsr_prof_en" == "extreme" ]] && {
    [[ -e "/sys/kernel/debug/sched_features" ]] && {
      write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
      write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
      write "/sys/kernel/debug/sched_features" "NO_ENERGY_AWARE"
      log_i "Tweaked scheduler features"
    }
  } || [[ "$ktsr_prof_en" == "pwrsave" ]] || [[ "$auto_prof" == "pwrsave" ]] && {
    [[ -e "/sys/kernel/debug/sched_features" ]] && {
      write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
      write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
      write "/sys/kernel/debug/sched_features" "ENERGY_AWARE"
      log_i "Tweaked scheduler features"
    }
  } || [[ "$ktsr_prof_en" == "game" ]] || [[ "$auto_prof" == "game" ]] && {
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

  sched_tune() {
    [[ "$ktsr_prof_en" == "latency" ]] || [[ "$auto_prof" == "latency" ]] && {
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
      [[ -e "${kernel}sched_conservative_pl" ]] && write "${kernel}sched_conservative_pl" "0"
      [[ -e "/sys/devices/system/cpu/sched/sched_boost" ]] && write "/sys/devices/system/cpu/sched/sched_boost" "0"
      [[ -e "/sys/kernel/ems/eff_mode" ]] && write "/sys/kernel/ems/eff_mode" "0"
      [[ -e "/sys/module/opchain/parameters/chain_on" ]] && write "/sys/module/opchain/parameters/chain_on" "0"
      [[ -e "${kernel}sched_initial_task_util" ]] && write "${kernel}sched_initial_task_util" "0"
      [[ -d "/sys/module/memplus_core/" ]] && write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
      [[ -d "/sys/kernel/debug/" ]] && {
        write "/sys/kernel/debug/debug_enabled" "N"
        write "/sys/kernel/debug/msm_cvp/disable_thermal_mitigation" "N"
        write "/sys/kernel/debug/msm_vidc/disable_thermal_mitigation" "N"
        write "/sys/kernel/debug/msm_vidc/fw_low_power_mode" "0"
      }
      write "/sys/kernel/mi_reclaim/enable" "0"
      write "/sys/kernel/rcu_expedited" "0"
      write "/sys/kernel/rcu_normal" "1"
      write "/sys/devices/system/cpu/sched/hint_enable" "0"
      write "${kernel}slide_boost_enabled" "0"
      write "${kernel}launcher_boost_enabled" "0"
      write "/sys/kernel/tracing/events/sched/sched_boost_cpu" "0"
      for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
        [[ -e "$bcl_md" ]] && write "$bcl_md" "0"
      done
      write "/proc/sys/dev/tty/ldisc_autoload" "0"
      write_lock "${kernel}sched_force_lb_enable" "0"
      write "/sys/power/pm_freeze_timeout" "1000"

      log_i "Tweaked various kernel parameters to a better overall performance"
    } || [[ "$ktsr_prof_en" == "balanced" ]] || [[ "$auto_prof" == "balanced" ]] && {
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
      [[ -e "${kernel}sched_conservative_pl" ]] && write "${kernel}sched_conservative_pl" "0"
      [[ -e "/sys/devices/system/cpu/sched/sched_boost" ]] && write "/sys/devices/system/cpu/sched/sched_boost" "0"
      [[ -e "/sys/kernel/ems/eff_mode" ]] && write "/sys/kernel/ems/eff_mode" "0"
      [[ -e "/sys/module/opchain/parameters/chain_on" ]] && write "/sys/module/opchain/parameters/chain_on" "0"
      [[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]] && write "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
      [[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]] && write "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
      [[ -e "${kernel}sched_initial_task_util" ]] && write "${kernel}sched_initial_task_util" "0"
      [[ -d "/sys/module/memplus_core/" ]] && write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
      [[ -d "/sys/kernel/debug/" ]] && {
        write "/sys/kernel/debug/debug_enabled" "N"
        write "/sys/kernel/debug/msm_cvp/disable_thermal_mitigation" "N"
        write "/sys/kernel/debug/msm_vidc/disable_thermal_mitigation" "N"
        write "/sys/kernel/debug/msm_vidc/fw_low_power_mode" "1"
      }
      write "/sys/kernel/mi_reclaim/enable" "0"
      write "/sys/kernel/rcu_expedited" "0"
      write "/sys/kernel/rcu_normal" "1"
      write "/sys/devices/system/cpu/sched/hint_enable" "0"
      write "${kernel}slide_boost_enabled" "0"
      write "${kernel}launcher_boost_enabled" "0"
      write "/sys/kernel/tracing/events/sched/sched_boost_cpu" "0"
      for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
        [[ -e "$bcl_md" ]] && write "$bcl_md" "0"
      done
      write "/proc/sys/dev/tty/ldisc_autoload" "0"
      write_lock "${kernel}sched_force_lb_enable" "0"
      write "/sys/power/pm_freeze_timeout" "2000"

      log_i "Tweaked various kernel parameters to a better overall performance"
    } || [[ "$king_prof_en" == "extreme" ]] || [[ "$auto_prof" == "extreme" ]] && {
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
      [[ -e "${kernel}sched_conservative_pl" ]] && write "${kernel}sched_conservative_pl" "0"
      [[ -e "/sys/devices/system/cpu/sched/sched_boost" ]] && write "/sys/devices/system/cpu/sched/sched_boost" "0"
      [[ -e "/sys/kernel/ems/eff_mode" ]] && write "/sys/kernel/ems/eff_mode" "0"
      [[ -e "/sys/module/opchain/parameters/chain_on" ]] && write "/sys/module/opchain/parameters/chain_on" "0"
      [[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]] && write "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
      [[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]] && write "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
      [[ -e "${kernel}sched_initial_task_util" ]] && write "${kernel}sched_initial_task_util" "0"
      [[ -d "/sys/module/memplus_core/" ]] && write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
      [[ -d "/sys/kernel/debug/" ]] && {
        write "/sys/kernel/debug/debug_enabled" "N"
        write "/sys/kernel/debug/msm_cvp/disable_thermal_mitigation" "Y"
        write "/sys/kernel/debug/msm_vidc/disable_thermal_mitigation" "Y"
        write "/sys/kernel/debug/msm_vidc/fw_low_power_mode" "0"
      }
      write "/sys/kernel/mi_reclaim/enable" "0"
      write "/sys/kernel/rcu_expedited" "0"
      write "/sys/kernel/rcu_normal" "1"
      write "/sys/devices/system/cpu/sched/hint_enable" "0"
      write "${kernel}slide_boost_enabled" "0"
      write "${kernel}launcher_boost_enabled" "0"
      write "/sys/kernel/tracing/events/sched/sched_boost_cpu" "0"
      for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
        [[ -e "$bcl_md" ]] && write "$bcl_md" "0"
      done
      write "/proc/sys/dev/tty/ldisc_autoload" "0"
      write_lock "${kernel}sched_force_lb_enable" "0"
      write "/sys/power/pm_freeze_timeout" "1000"

      log_i "Tweaked various kernel parameters to a better overall performance"
    } || [[ "$ktsr_prof_en" == "pwrsave" ]] || [[ "$auto_prof" == "pwrsave" ]] && {
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
      [[ -e "${kernel}sched_conservative_pl" ]] && write "${kernel}sched_conservative_pl" "1"
      [[ -e "/sys/devices/system/cpu/sched/sched_boost" ]] && write "/sys/devices/system/cpu/sched/sched_boost" "0"
      [[ -e "/sys/kernel/ems/eff_mode" ]] && write "/sys/kernel/ems/eff_mode" "0"
      [[ -e "/sys/module/opchain/parameters/chain_on" ]] && write "/sys/module/opchain/parameters/chain_on" "0"
      [[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]] && write "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
      [[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]] && write "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
      [[ -e "${kernel}sched_initial_task_util" ]] && write "${kernel}sched_initial_task_util" "0"
      [[ -d "/sys/module/memplus_core/" ]] && write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
      [[ -d "/sys/kernel/debug/" ]] && {
        write "/sys/kernel/debug/debug_enabled" "N"
        write "/sys/kernel/debug/msm_cvp/disable_thermal_mitigation" "N"
        write "/sys/kernel/debug/msm_vidc/disable_thermal_mitigation" "N"
        write "/sys/kernel/debug/msm_vidc/fw_low_power_mode" "1"
      }
      write "/sys/kernel/mi_reclaim/enable" "0"
      write "/sys/kernel/rcu_expedited" "0"
      write "/sys/kernel/rcu_normal" "1"
      write "/sys/devices/system/cpu/sched/hint_enable" "0"
      write "${kernel}slide_boost_enabled" "0"
      write "${kernel}launcher_boost_enabled" "0"
      write "/sys/kernel/tracing/events/sched/sched_boost_cpu" "0"
      for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
        [[ -e "$bcl_md" ]] && write "$bcl_md" "0"
      done
      write "/proc/sys/dev/tty/ldisc_autoload" "0"
      write_lock "${kernel}sched_force_lb_enable" "0"
      write "/sys/power/pm_freeze_timeout" "5000"

      log_i "Tweaked various kernel parameters to a better overall performance"
    } || [[ "$ktsr_prof_en" == "game" ]] || [[ "$auto_prof" == "game" ]] && {
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
      [[ -e "${kernel}sched_conservative_pl" ]] && write "${kernel}sched_conservative_pl" "0"
      [[ -e "/sys/devices/system/cpu/sched/sched_boost" ]] && write "/sys/devices/system/cpu/sched/sched_boost" "0"
      [[ -e "/sys/kernel/ems/eff_mode" ]] && write "/sys/kernel/ems/eff_mode" "0"
      [[ -e "/sys/module/opchain/parameters/chain_on" ]] && write "/sys/module/opchain/parameters/chain_on" "0"
      [[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]] && write "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
      [[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]] && write "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
      [[ -e "${kernel}sched_initial_task_util" ]] && write "${kernel}sched_initial_task_util" "0"
      [[ -d "/sys/module/memplus_core/" ]] && write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
      [[ -d "/sys/kernel/debug/" ]] && {
        write "/sys/kernel/debug/debug_enabled" "N"
        write "/sys/kernel/debug/msm_cvp/disable_thermal_mitigation" "Y"
        write "/sys/kernel/debug/msm_vidc/disable_thermal_mitigation" "Y"
        write "/sys/kernel/debug/msm_vidc/fw_low_power_mode" "0"
      }
      write "/sys/kernel/mi_reclaim/enable" "0"
      write "/sys/kernel/rcu_expedited" "0"
      write "/sys/kernel/rcu_normal" "1"
      write "/sys/devices/system/cpu/sched/hint_enable" "0"
      write "${kernel}slide_boost_enabled" "0"
      write "${kernel}launcher_boost_enabled" "0"
      write "/sys/kernel/tracing/events/sched/sched_boost_cpu" "0"
      for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
        [[ -e "$bcl_md" ]] && write "$bcl_md" "0"
      done
      write "/proc/sys/dev/tty/ldisc_autoload" "0"
      write_lock "${kernel}sched_force_lb_enable" "0"
      write "/sys/power/pm_freeze_timeout" "1000"

      log_i "Tweaked various kernel parameters to a better overall performance"
    }
  }

  fp_boost() {
    [[ -d "/sys/kernel/fp_boost/" ]] && [[ "$1" == "1" ]] && {
      write "/sys/kernel/fp_boost/enabled" "1"
      log_i "Enabled fingerprint boost"
    } || [[ -d "/sys/kernel/fp_boost/" ]] && [[ "$1" == "0" ]] && {
      write "/sys/kernel/fp_boost/enabled" "0"
      log_i "Disabled fingerprint boost"
    }
  }

  # 1:default 2:boost
  ppm_policy_set() {
    [[ "$ppm" == "true" ]] && [[ "$1" == "1" ]] && {
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
    } || [[ "$ppm" == "true" ]] && [[ "$1" == "2" ]] && {
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
  # 1:default 2:mid
  cpu_clk_set() {
    [[ "$1" == "1" ]] && {
      for pl in /sys/devices/system/cpu/cpufreq/policy*/; do
        write "${pl}scaling_max_freq" "$cpu_max_freq"
        write "${pl}user_scaling_max_freq" "$cpu_max_freq"
        for i in 576000 652800 691200 710400 748800 768000 787200 806400 825600 844800 852600 864000 902400 940800 960000 979200 998400 1036800 1075200 1113600 1152000 1209600 1459200 1478400 1516800 1689600 1708800 1766400; do
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
    } || [[ "$1" == "2" ]] && {
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
  }

  vm_lmk_tune() {
    [[ "$ktsr_prof_en" == "latency" ]] || [[ "$auto_prof" == "latency" ]] && {
      sync
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
      write "${vm}vfs_cache_pressure" "200"
      [[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
      [[ "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "0"
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
	  write "/sys/kernel/mm/lru_gen/min_ttl_ms" "1000"

      log_i "Tweaked various VM / LMK parameters for a improved user-experience"
    } || [[ "$ktsr_prof_en" == "balanced" ]] || [[ "$auto_prof" == "balanced" ]] && {
      sync
      write "${vm}dirty_background_ratio" "5"
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
      [[ "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "0"
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
	  write "/sys/kernel/mm/lru_gen/min_ttl_ms" "1000"

      log_i "Tweaked various VM and LMK parameters for a improved user-experience"
    } || [[ "$ktsr_prof_en" == "extreme" ]] || [[ "$auto_prof" == "extreme" ]] && {
      sync
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
      write "${vm}vfs_cache_pressure" "150"
      [[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
      [[ "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "0"
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
	  write "/sys/kernel/mm/lru_gen/min_ttl_ms" "1000"

      log_i "Tweaked various VM and LMK parameters for a improved user-experience"
    } || [[ "$ktsr_prof_en" == "pwrsave" ]] || [[ "$auto_prof" == "pwrsave" ]] && {
      sync
      write "${vm}dirty_background_ratio" "15"
      write "${vm}dirty_ratio" "30"
      write "${vm}dirty_expire_centisecs" "500"
      write "${vm}dirty_writeback_centisecs" "3000"
      write "${vm}page-cluster" "0"
      write "${vm}stat_interval" "10"
      write "${vm}overcommit_memory" "1"
      write "${vm}overcommit_ratio" "100"
      write "${vm}swappiness" "60"
      write "${vm}laptop_mode" "0"
      write "${vm}vfs_cache_pressure" "50"
      [[ -d "/sys/module/process_reclaim/" ]] && write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
      [[ "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "0"
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
	  write "/sys/kernel/mm/lru_gen/min_ttl_ms" "1000"

      log_i "Tweaked various VM and LMK parameters for a improved user-experience"
    } || [[ "$ktsr_prof_en" == "game" ]] || [[ "$auto_prof" == "game" ]] && {
      sync
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
      [[ "$lmk" ]] && [[ -e "${vm}reap_mem_on_sigkill" ]] && write "${vm}reap_mem_on_sigkill" "0"
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
	  write "/sys/kernel/mm/lru_gen/min_ttl_ms" "1000"

      log_i "Tweaked various VM and LMK parameters for a improved user-experience"
    }
  }

  pewq() {
    [[ -e "/sys/module/workqueue/parameters/power_efficient" ]] && [[ "$1" == "1" ]] && {
      write "/sys/module/workqueue/parameters/power_efficient" "Y"
      log_i "Enabled power efficient workqueue"
    } || [[ -e "/sys/module/workqueue/parameters/power_efficient" ]] && [[ "$1" == "0" ]] && {
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

  touchboost() {
    [[ -e "/proc/touchpanel/oplus_tp_limit_enable" ]] && [[ "$1" == "1" ]] && {
      write "/proc/touchpanel/oplus_tp_limit_enable" "0"
      write "/proc/touchpanel/oplus_tp_direction" "1"
      write "/proc/touchpanel/game_switch_enable" "1"
      log_i "Enabled improved touch mode"
    } || [[ -e "/proc/touchpanel/oplus_tp_limit_enable" ]] && [[ "$1" == "0" ]] && {
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

  kern_pwrsave() {
    [[ -d "/sys/module/battery_saver/" ]] && [[ "$1" == "1" ]] && {
      write "/sys/module/battery_saver/parameters/enabled" "Y"
      log_i "Enabled kernel battery saver"
    } || [[ -d "/sys/module/battery_saver/" ]] && [[ "$1" == "0" ]] && {
      write "/sys/module/battery_saver/parameters/enabled" "N"
      log_i "Disabled kernel battery saver"
    }
  }

  lpm() {
    [[ "$1" == "1" ]] && {
      for lpm in /sys/module/lpm_levels/system/*/*/*/; do
        [[ -d "/sys/module/lpm_levels/" ]] && {
          write "/sys/module/lpm_levels/parameters/lpm_prediction" "N"
          write "/sys/module/lpm_levels/parameters/lpm_ipi_prediction" "N"
          write "/sys/module/lpm_levels/parameters/bias_hyst" "2"
          write "/sys/module/lpm_levels/parameters/sleep_disabled" "N"
          write "${lpm}idle_enabled" "Y"
          write "${lpm}suspend_enabled" "Y"
        }
      done
      log_i "Enabled LPM"
    } || [[ "$1" == "0" ]] && {
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
  }

  pm2_idle_mode() {
    [[ -d "/sys/module/pm2/parameters/" ]] && [[ "$1" == "1" ]] && {
      write "/sys/module/pm2/parameters/idle_sleep_mode" "Y"
      log_i "Enabled pm2 idle sleep mode"
    } || [[ -d "/sys/module/pm2/parameters/" ]] && [[ "$1" == "0" ]] && {
      write "/sys/module/pm2/parameters/idle_sleep_mode" "N"
      log_i "Disabled pm2 idle sleep mode"
    }
  }

  lcd_prdc() {
    [[ -e "/sys/class/lcd/panel/power_reduce" ]] && [[ "$1" == "1" ]] && {
      write "/sys/class/lcd/panel/power_reduce" "1"
      log_i "Enabled LCD power reduce"
    } || [[ -e "/sys/class/lcd/panel/power_reduce" ]] && [[ "$1" == "0" ]] && {
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

  ufs_perf_mode() {
    [[ -d "/sys/class/devfreq/1d84000.ufshc/" ]] && [[ "$1" == "1" ]] && {
      write "/sys/devices/platform/soc/1d84000.ufshc/clkscale_enable" "0"
      write "/sys/devices/platform/soc/1d84000.ufshc/hibern8_on_idle_enable" "0"
      write "/sys/devices/platform/soc/1d84000.ufshc/clkgate_enable" "0"
      log_i "Disabled UFS performance mode"
    }
  } || [[ -d "/sys/class/devfreq/1d84000.ufshc/" ]] && [[ "$1" == "0" ]] && {
    write "/sys/devices/platform/soc/1d84000.ufshc/clkscale_enable" "1"
    write "/sys/devices/platform/soc/1d84000.ufshc/hibern8_on_idle_enable" "1"
    write "/sys/devices/platform/soc/1d84000.ufshc/clkgate_enable" "1"
    log_i "Enabled UFS performance mode"
  }
}

emmc_clk_scl() {
  [[ -d "/sys/class/mmc_host/mmc0/" ]] && [[ -d "/sys/class/mmc_host/mmc1/" ]] && [[ "$1" == "1" ]] && {
    write "/sys/class/mmc_host/mmc0/clk_scaling/enable" "1"
    write "/sys/class/mmc_host/mmc1/clk_scaling/enable" "1"

	log_i "Enabled EMMC clock scaling"
  } || [[ -d "/sys/class/mmc_host/mmc0/" ]] && [[ "$1" == "1" ]] && {
    write "/sys/class/mmc_host/mmc0/clk_scaling/enable" "1"
    
	log_i "Enabled EMMC clock scaling"
  } || [[ -d "/sys/class/mmc_host/mmc0/" ]] && [[ -d "/sys/class/mmc_host/mmc1/" ]] && [[ "$1" == "0" ]] && {
    write "/sys/class/mmc_host/mmc0/clk_scaling/enable" "0"
    write "/sys/class/mmc_host/mmc1/clk_scaling/enable" "0"

	log_i "Disabled EMMC clock scaling"
  } || [[ -d "/sys/class/mmc_host/mmc0/" ]] && [[ "$1" == "0" ]] && {
    write "/sys/class/mmc_host/mmc0/clk_scaling/enable" "0"
   
	log_i "Disabled EMMC clock scaling"
  }
}

# Disable unnecessary kernel debugging
disable_debug() {
  for i in debug_mask log_level* debug_level* *debug_mode enable_ramdumps edac_mc_log* enable_event_log *log_level* *log_ue* *log_ce* log_ecn_error snapshot_crashdumper seclog* compat-log *log_enabled tracing_on mballoc_debug; do
    for o in $(find /sys/ -type f -name "$i"); do
      write "$o" "0"
    done
  done
  write "/sys/module/spurious/parameters/noirqdebug" "1"
  write "/sys/kernel/debug/sde_rotator0/evtlog/enable" "0"
  write "/sys/kernel/debug/dri/0/debug/enable" "0"

  log_i "Disabled misc debugging for reduced overhead"
}

perfmgr() {
  [[ -d "${perfmgr}boost_ctrl/eas_ctrl/" ]] && [[ "$1" == "pwrsave" ]] && {
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
  } || [[ -d "${perfmgr}boost_ctrl/eas_ctrl/" ]] && [[ "$1" == "default" ]] && {
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

migt() {
  [[ -d "$migt" ]] && [[ "$1" == "1" ]] && {
    write "${migt}migt_freq" "0:0 1:0 2:0 3:0 4:0 5:0 6:0 7:0"
    write "${migt}glk_freq_limit_start" "0"
    write "${migt}glk_freq_limit_walt" "0"
    write "${migt}glk_maxfreq" "0 0 0"
    write "${migt}migt_ceiling_freq" "0 0 0"
    write "${migt}glk_disable" "1"
    settings put secure speed_mode_enable 1
  } || [[ -d "$migt" ]] && [[ "$1" == "0" ]] && {
    write "${migt}migt_freq" "0:$UINT_MAX 1:$UINT_MAX 2:$UINT_MAX 3:$UINT_MAX 4:$UINT_MAX 5:$UINT_MAX 6:$UINT_MAX 7:$UINT_MAX"
    write "${migt}glk_freq_limit_start" "0"
    write "${migt}glk_freq_limit_walt" "0"
    write "${migt}glk_maxfreq" "$UINT_MAX $UINT_MAX $UINT_MAX"
    write "${migt}migt_ceiling_freq" "0 0 0"
    write "${migt}glk_disable" "0"
    settings put secure speed_mode_enable 0
  }
}

config_fpsgo() {
  [[ -d "$fpsgo" ]] && {
    write "${fpsgo}max_freq_limit_level" "0"
    write "${fpsgo}min_freq_limit_level" "0"
    write "${fpsgo}variance" "10"
    write "${fpsgo}boost_affinity" "0"
  }
  [[ -d "${fpsgo_knl}minitop/" ]] && write "${fpsgo_knl}minitop/enable" "0"
}

thermal_disguise() {
  [[ "$1" == "1" ]] && {
    chmod 644 "$board_sensor_temp" 2>/dev/null
    pm enable com.xiaomi.gamecenter.sdk.service/.PidService >/dev/null 2>&1 &
  } || {
    disable_migt
    write "$board_sensor_temp" "36000"
    chmod 000 "$board_sensor_temp" 2>/dev/null
    pm clear com.xiaomi.gamecenter.sdk.service >/dev/null 2>&1 &
    pm disable com.xiaomi.gamecenter.sdk.service/.PidService >/dev/null 2>&1 &
  }
}

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

sched_isolation() {
  [[ "$1" == "1" ]] && {
    for i in 0 1 2 3 4 5 6 7; do
      write "/sys/devices/system/cpu/sched/set_sched_isolation" "$i"
    done
  } || [[ "$1" == "0" ]] && {
    for i in 0 1 2 3 4 5 6 7; do
      write "/sys/devices/system/cpu/sched/set_sched_deisolation" "$i"
    done
    chmod 000 "/sys/devices/system/cpu/sched/set_sched_isolation"
  }
}

disable_mtk_thrtl() {
  [[ -e "${t_msg}market_download_limit" ]] && {
    write "${t_msg}market_download_limit" "0"
    write "${t_msg}modem_limit" "0"
  }
}

# Userspace bourbon optimization
bbn_opt() {
  # Input dispatcher/reader
  change_thread_nice "system_server" "Input" "-20"
  # Render threads should have all cores
  pin_thread_on_all "$launcher_pkg" "RenderThread|GLThread" "ff"
  pin_thread_on_pwr "$launcher_pkg" "GPU completion|HWC release|hwui|FramePolicy|ScrollPolicy|ged-swd" "0f"
  # Speed up searching service manager
  change_task_nice "servicemanag" "-20"
  # Not important
  pin_thread_on_pwr "system_server" "VoiceReporter|TaskSnapshot|Greezer|CachedApp|SystemPressure|SensorService|[Mm]emory"
  pin_thread_on_pwr "ndroid.systemui" "mi_analytics_up"
  # khugepaged takes care of memory management, but it's not that performance-critical, so pin it in the little cluster.
  pin_thread_on_pwr "khugepaged"
  # Run KGSL/Mali workers with max priority as both are critical tasks
  change_task_nice "kgsl_worker" "-20"
  pin_proc_on_perf "kgsl_worker"
  change_task_nice "mali_jd_thread" "-20"
  change_task_rt "mali_jd_thread" "50"
  change_task_nice "mali_event_thread" "-20"
  # Pin HWC on perf cluster to reduce jitter
  pin_proc_on_perf "composer"
  # Let SF use all cores
  pin_proc_on_all "surfaceflinger"
  # Devfreq boost should run with max priority and into the perf cluster as it is a critical task (boosting DDR)
  # Don't run it with RT_MAX_PRIO - 1 though
  change_task_nice "devfreq_boost" "-20"
  pin_proc_on_perf "devfreq_boost"
  change_task_rt "devfreq_boost" "50"
  # Pin these kthreads to the perf cluster as they also play a major role in rendering frames to the display
  # Pin only the first threads as others are non-critical
  n=80
  while [[ "$n" -lt "301" ]]; do
    pin_proc_on_perf "crtc_event:$i"
    pin_proc_on_perf "crtc_commit:$i"
    n=$((n + 1))
    break
  done
  pin_proc_on_perf "pp_event"
  pin_proc_on_perf "mdss_fb"
  pin_proc_on_perf "mdss_disp_wake"
  pin_proc_on_perf "vsync_retire_work"
  pin_proc_on_perf "pq@"
  # Improve I/O performance by pinning the block daemon into the perf cluster
  pin_proc_on_perf "kblockd"
  # Pin TS workqueues to perf cluster to reduce latency
  pin_proc_on_perf "fts_wq"
  pin_proc_on_perf "nvt_ts_workqueu"
  change_task_rt "nvt_ts_workqueu" "50"
  change_task_rt "fts_wq" "50"
  # Pin Samsung HyperHAL to perf cluster
  pin_proc_on_perf "hyper@"
  # Queue UFS/EMMC clock gating with max priority
  change_task_nice "ufs_clk_gating" "-20"
  change_task_nice "mmc_clk_gate" "-20"
  # Queue CVP fence request handler with max priority
  change_task_nice "thread_fence" "-20"
  # Queue CPU boost worker with max priority for obvious reasons
  change_task_rt "cpu_boost_work" "2"
  change_task_nice "cpu_boost_work" "-20"
  # Queue touchscreen related workers with max priority
  change_task_nice "speedup_resume_wq" "-20"
  change_task_nice "load_tp_fw_wq" "-20"
  change_task_nice "tcm_freq_hop" "-20"
  change_task_nice "touch_delta_wq" "-20"
  change_task_nice "tp_async" "-20"
  change_task_nice "wakeup_clk_wq" "-20"
  # Set RT priority correctly for critical tasks
  change_task_rt "kgsl_worker_thread" "6"
  change_task_rt "crtc_commit" "16"
  change_task_rt "crtc_event" "16"
  change_task_rt "pp_event" "16"
  change_task_rt "rot_commitq_" "5"
  change_task_rt "rot_doneq_" "5"
  change_task_rt "rot_fenceq_" "5"
  change_task_rt "system_server" "2"
  change_task_rt "surfaceflinger" "2"
  change_task_rt "composer" "2"
  # Boost app boot process
  change_task_nice "zygote" "-20"
  # Queue VM writeback with max priority
  change_task_nice "writeback" "-20"
  # Affects IO latency/throughput
  change_task_nice "kblockd" "-20"
  # System thread
  change_task_nice "system" "-20"
  # Those workqueues don't need any priority
  change_task_nice "ipawq" "0"
  change_task_nice "iparepwq" "0"
  change_task_nice "wlan_logging_th" "10"
  # Give cryptd, khugepaged as much CPU time as possible
  change_task_nice "cryptd" "-20"
  change_task_nice "khugepaged" "-20"
}

# Remove logs if size is >= 1 MB
clear_logs() {
  kdbg_max_size=1000000
  sqlite_opt_max_size=1000000
  [[ "$(stat -t "$kdbg" 2>/dev/null | awk '{print $2}')" -ge "$kdbg_max_size" ]] && rm -rf "$kdbg"
  [[ "$(stat -t "/data/media/0/KTSR/sqlite_opt.log" 2>/dev/null | awk '{print $2}')" -ge "$sqlite_opt_max_size" ]] && rm -rf "/data/media/0/KTSR/sqlite_opt.log"
}

apply_all() {
  print_info
  stop_services
  bring_all_cores
  thermal_pol_set
  disable_mtk_thrtl
  io_tune
  boost_tune
  cpu_tune
  hmp_tune
  gpu_tune
  schedtune_tune
  sched_ft_tune
  sched_tune
  uclamp_tune
  vm_lmk_tune
  [[ "$ktsr_prof_en" == "extreme" ]] || [[ "$ktsr_prof_en" == "game" ]] || [[ "$auto_prof" == "extreme" ]] || [[ "$auto_prof" == "game" ]] && {
    devfreq_boost 1
    dram_boost 1
    core_ctl_set 0
    sched_isolation 0
    misc_cpu_tune 3
    pewq 0
    touchboost 1
    lpm 0
    pm2_idle_mode 0
    perfmgr default
    thermal_disguise 1
    realme_gt 1
    ufs_perf_mode 1
    emmc_clk_scl 0
  } || {
    devfreq_boost 0
    dram_boost 0
    core_ctl_set 1
    sched_isolation 1
    ppm 1
    ppm_policy_set 1
    enable_pewq 1
    touchboost 0
    lpm 1
    pm2_idle_mode 1
    thermal_disguise 0
    realme_gt 0
    ufs_perf_mode 0
    emmc_clk_scl 1
  }
  [[ "$ktsr_prof_en" == "latency" ]] || [[ "$ktsr_prof_en" == "balanced" ]] || [[ "$auto_prof" == "latency" ]] || [[ "$auto_prof" == "balanced" ]] && misc_cpu_set 1 || [[ "$ktsr_prof_en" == "extreme" ]] || [[ "$ktsr_prof_en" == "game" ]] || [[ "$auto_prof" == "extreme" ]] || [[ "$auto_prof" == "game" ]] && misc_cpu_set 2 || misc_cpu_set 3
  [[ "$ktsr_prof_en" == "extreme" ]] || [[ "$auto_prof" == "extreme" ]] && {
    ppm 1
    ppm_policy_set 2
  } || [[ "$ktsr_prof_en" == "game" ]] || [[ "$auto_prof" == "game" ]] && ppm 0
  [[ "$ktsr_prof_en" == "pwrsave" ]] && [[ "$batt_pctg" -lt "20" ]] || [[ "$auto_prof" == "pwrsave" ]] && [[ "$batt_pctg" -lt "20" ]] && cpu_clk_set 2 || cpu_clk_set 1
  [[ "$ktsr_prof_en" == "pwrsave" ]] || [[ "$auto_prof" == "pwrsave" ]] && {
    kern_batt_saver 1
    lcd_prdc 1
    perfmgr pwrsave
  } || {
    kern_batt_saver 0
    lcd_prdc 0
    perfmgr default
  }
}

apply_prof() {
  init=$(date +%s)
  sync
  kill_svc kingd
  setprop kingd.prof null
  apply_all
  log_i "$ktsr_prof_en profile applied. Enjoy!"
  exit=$(date +%s)
  exec_time=$((exit - init))
  log_i "Spent time: $exec_time seconds."
}
automatic() {
  log_i "Applying automatic profile"
  sync
  kingd &
  log_i "Applied automatic profile"
}
