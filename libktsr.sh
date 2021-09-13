#!/system/bin/sh
# KTSR by Pedro (pedrozzz0 @ GitHub)
# Credits: Ktweak, by Draco (tytydraco @ GitHub), LSpeed, Dan (Paget69 @ XDA), mogoroku @ GitHub, vtools, by helloklf @ GitHub, Cuprum-Turbo-Adjustment, by chenzyadb @ CoolApk, qti-mem-opt & Uperf, by Matt Yang (yc9559 @ CoolApk) and Pandora's Box, by Eight (dlwlrma123 @ GitHub).
# Thanks: GR for some help
# If you wanna use it as part of your project, please maintain the credits to it's respectives authors.

MODPATH="/data/adb/modules/KTSR/"

KLOG="/data/media/0/KTSR/KTSR.log"

KDBG="/data/media/0/KTSR/KTSR_DBG.log"

# Log in white and continue (unnecessary)
kmsg(){
	echo -e "[*] $@" >> "${KLOG}"
}

kmsg1(){
	echo -e "$@" >> "${KDBG}"
	echo -e "$@"
}

kmsg2(){
	echo -e "[!] $@" >> "${KDBG}"
	echo -e "[!] $@"
}

kmsg3(){
	echo -e "$@" >> "${KLOG}"
}

toast(){
	am start -a android.intent.action.MAIN -e toasttext "Applying ${ktsr_prof_en} profile..." -n bellavita.toast/.MainActivity >/dev/null 2>&1
}
	
toast_1(){
	am start -a android.intent.action.MAIN -e toasttext "${ktsr_prof_en} profile applied" -n bellavita.toast/.MainActivity >/dev/null 2>&1
}

toast_pt(){
	am start -a android.intent.action.MAIN -e toasttext "Aplicando perfil ${ktsr_prof_pt}..." -n bellavita.toast/.MainActivity >/dev/null 2>&1
}

toast_pt_1(){
	am start -a android.intent.action.MAIN -e toasttext "Perfil ${ktsr_prof_pt} aplicado" -n bellavita.toast/.MainActivity >/dev/null 2>&1
}

toast_tr(){
	am start -a android.intent.action.MAIN -e toasttext "${ktsr_prof_tr} profili uygulanıyor..." -n bellavita.toast/.MainActivity >/dev/null 2>&1
}

toast_tr_1(){
	am start -a android.intent.action.MAIN -e toasttext "${ktsr_prof_tr} profili uygulandı" -n bellavita.toast/.MainActivity >/dev/null 2>&1
}

toast_in(){
	am start -a android.intent.action.MAIN -e toasttext "Menerapkan profil ${ktsr_prof_in}..." -n bellavita.toast/.MainActivity >/dev/null 2>&1
}

toast_in_1(){
	am start -a android.intent.action.MAIN -e toasttext "Profil ${ktsr_prof_in} terpakai" -n bellavita.toast/.MainActivity >/dev/null 2>&1
}

toast_fr(){
	am start -a android.intent.action.MAIN -e toasttext "Chargement du profil ${ktsr_prof_tr}..." -n bellavita.toast/.MainActivity >/dev/null 2>&1
}

toast_fr_1(){
	am start -a android.intent.action.MAIN -e toasttext "Profil ${ktsr_prof_fr} chargé" -n bellavita.toast/.MainActivity >/dev/null 2>&1
}

write(){
	# Bail out if file does not exist
	if [[ ! -f "$1" ]]; then
	    kmsg2 "$1 doesn't exist, skipping..."
        return 1
    fi

    # Make file readable and writable in case it is not already
	chmod +rw "$1" 2>/dev/null

	# Fetch the current key value
    curval=$(cat "$1" 2>/dev/null)
	
	# Bail out if value is already set
	if [[ "${curval}" == "$2" ]]; then
	    kmsg1 "$1 is already set to $2, skipping..."
	    return 0
	fi

	# Write the new value and bail if there's an error
	if ! echo -n "$2" > "$1" 2>/dev/null
    then
	    kmsg2 "Failed: $1 -> $2"
		return 1
	fi
	
	# Log the success
	kmsg1 "$1 $curval -> $2"
}

lock(){
	# Bail out if file does not exist
	if [[ ! -f "$1" ]]; then
	    kmsg2 "$1 doesn't exist, skipping..."
        return 1
    fi

	# Lock the node and bail out if there's an error
	if ! chmod 000 "$1" 2>/dev/null
    then
	    kmsg2 "Lock: $1 failed"
		return 1
	fi
	
	# Log the success
	kmsg1 "Lock: $1"
	
    chmod 000 "$1" 2>/dev/null
}

lock_value(){
    # Bail out if file does not exist
	if [[ ! -f "$1" ]]; then
	    kmsg2 "$1 doesn't exist, skipping..."
        return 1
    fi

    # Make file readable and writable in case it is not already
	chmod +rw "$1" 2>/dev/null

	# Fetch the current key value
    curval=$(cat "$1" 2>/dev/null)

	# Write the new value and bail if there's an error
	if ! echo -n "$2" > "$1" 2>/dev/null
    then
	    kmsg2 "Failed: $1 -> $2"
		return 1
	fi
	
	# Log the success
	kmsg1 "Lock: $1 & $curval -> $2"
	
    chmod 000 "$1" 2>/dev/null
}

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

# Fetch GPU directories
get_gpu_dir(){
for gpul in /sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0/
  do
    if [[ -d "${gpul}" ]]; then
        gpu=${gpul}
        qcom=true
    fi
done
    
     for gpul1 in /sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0/
     do
       if [[ -d "${gpul1}" ]]; then
           gpu=${gpul1}
           qcom=true
       fi
   done
       
      for gpul2 in /sys/devices/*.mali/
      do
        if [[ -d "${gpul2}" ]]; then
            gpu=${gpul2}
            qcom=false
        fi
    done
         
       for gpul3 in /sys/devices/platform/*.gpu/
       do
         if [[ -d "${gpul3}" ]]; then
             gpu=${gpul3}
             qcom=false
         fi
     done
       
         for gpul4 in /sys/devices/platform/mali-*/
         do
           if [[ -d "${gpul4}" ]]; then
               gpu=${gpul4}
               qcom=false
           fi
       done
           
           for gpul5 in /sys/devices/platform/*.mali/
           do
             if [[ -d "${gpul5}" ]]; then
                 gpu=${gpul5}
                 qcom=false
             fi
         done
                 
             for gpul6 in /sys/class/misc/mali*/device/devfreq/gpufreq/
             do
               if [[ -d "${gpul6}" ]]; then
                   gpu=${gpul6}
                   qcom=false
               fi
           done
             
              for gpul7 in /sys/class/misc/mali*/device/devfreq/*.gpu/
              do
                if [[ -d "${gpul7}" ]]; then
                    gpu=${gpul7}
                    qcom=false
                fi
            done

               for gpul8 in /sys/devices/platform/*.mali/misc/mali0/
               do
                 if [[ -d "${gpul8}" ]]; then
                     gpu=${gpul8}
                     qcom=false
                 fi
             done
             
             for gpul9 in /sys/devices/platform/mali.*/
             do
               if [[ -d "${gpul9}" ]]; then
                   gpu=${gpul9}
                   qcom=false
               fi
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
		
               if [[ -d "/sys/module/mali/parameters" ]]; then
                   gpug="/sys/module/mali/parameters/"
                   qcom=false
               fi
		
               if [[ -d "/sys/kernel/gpu" ]]; then
                   gpui="/sys/kernel/gpu/"
               fi
}

get_gpu_max(){
gpu_max=$(cat "${gpu}devfreq/available_frequencies" | awk -F ' ' '{print $NF}')

if [[ "${gpu_max}" -lt "${gpu_max_freq}" ]]; then
    gpu_max=$(cat "${gpu}devfreq/available_frequencies" | awk -v var="$gpu_num_pl" '{print $var}')
    
elif [[ "${gpu_max}" -lt "${gpu_max_freq}" ]]; then
      gpu_max=$(cat "${gpu}devfreq/available_frequencies" | awk '{print $1}')
               
elif [[ "${gpu_max}" -lt "${gpu_max_freq}" ]]; then
      gpu_max=${gpu_max_freq}
fi

if [[ -e "${gpu}available_frequencies" ]]; then
    gpu_max2=$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $NF}')
    
elif [[ "${gpu_max2}" -lt "${gpu_max_freq}" ]]; then
      gpu_max2=$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $1}')
    
elif [[ -e "${gpui}gpu_freq_table" ]]; then
      gpu_max2=$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $NF}')

elif [[ "${gpu_max2}" -lt "${gpu_max_freq}" ]]; then
      gpu_max2=$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $1}')
fi
}

get_gpu_min(){
if [[ -e "${gpu}available_frequencies" ]]; then
    gpu_min=$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $1}')

elif [[ "${gpu_min}" -gt "${gpu_min_freq}" ]]; then
      gpu_min=$(cat "${gpu}available_frequencies" | awk -F ' ' '{print $NF}')

elif [[ -e "${gpui}gpu_freq_table" ]]; then
      gpu_min=$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $1}')

elif [[ "${gpu_min}" -gt "${gpu_min_freq}" ]]; then
      gpu_min=$(cat "${gpui}gpu_freq_table" | awk -F ' ' '{print $NF}')
fi
}

get_cpu_gov(){
# Fetch the CPU governor    
cpu_gov=$(chmod +r /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor && cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor && chmod -r /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
}

get_gpu_gov(){
# Fetch the GPU governor
if [[ -e "${gpui}gpu_governor" ]]; then
    gpu_gov=$(chmod +r "${gpui}gpu_governor" && cat "${gpui}gpu_governor" && chmod -r "${gpui}gpu_governor")
    
elif [[ -e "${gpu}governor" ]]; then
      gpu_gov=$(chmod +r "${gpu}governor" && cat "${gpu}governor" && chmod -r "${gpu}governor")
    
elif [[ -e "${gpu}devfreq/governor" ]]; then
      gpu_gov=$(chmod +r "${gpu}devfreq/governor" && cat "${gpu}devfreq/governor" && chmod -r "${gpu}devfreq/governor")
fi
}

check_qcom(){
# Check if qcom string is null, then define it as false
if [[ -z "${qcom}" ]]; then
    qcom=false
fi
}

define_gpu_pl(){
# Fetch the amount of power levels from the GPU
gpu_num_pl=$(cat "${gpu}num_pwrlevels")

# Fetch the lower GPU power level
gpu_min_pl=$(cat "${gpu}min_pwrlevel")

# Fetch the higher GPU power level
gpu_max_pl=$(cat "${gpu}max_pwrlevel")
}

get_max_cpu_clk(){
# Fetch max CPU clock
cpu_max_freq=$(chmod +r /sys/devices/system/cpu/cpu7/cpufreq/cpuinfo_max_freq && cat /sys/devices/system/cpu/cpu7/cpufreq/cpuinfo_max_freq)
cpu_max_freq2=$(chmod +r /sys/devices/system/cpu/cpu3/cpufreq/cpuinfo_max_freq && cat /sys/devices/system/cpu/cpu3/cpufreq/cpuinfo_max_freq && chmod -r /sys/devices/system/cpu/cpu3/cpufreq/cpuinfo_max_freq)
cpu_max_freq3=$(chmod +r /sys/devices/system/cpu/cpu5/cpufreq/cpuinfo_max_freq && cat /sys/devices/system/cpu/cpu5/cpufreq/cpuinfo_max_freq && chmod -r /sys/devices/system/cpu/cpu5/cpufreq/cpuinfo_max_freq)

if [[ "${cpu_max_freq2}" -gt "${cpu_max_freq}" ]] && [[ "${cpu_max_freq2}" -gt "${cpu_max_freq3}" ]]; then
    cpu_max_freq=${cpu_max_freq2}

elif [[ "${cpu_max_freq3}" -gt "${cpu_max_freq}" ]] && [[ "${cpu_max_freq3}" -gt "${cpu_max_freq2}" ]]; then
      cpu_max_freq=${cpu_max_freq3}
fi
}

get_min_cpu_clk(){
# Fetch min CPU clock
cpu_min_freq=$(chmod +r /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq && cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq && chmod -r /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
cpu_min_freq2=$(chmod +r /sys/devices/system/cpu/cpu5/cpufreq/cpuinfo_min_freq && cat /sys/devices/system/cpu/cpu5/cpufreq/cpuinfo_min_freq && chmod -r /sys/devices/system/cpu/cpu5/cpufreq/cpuinfo_min_freq)

if [[ "${cpu_min_freq2}" -lt "${cpu_min_freq}" ]]; then
    cpu_min_freq=${cpu_min_freq2}
fi
}

get_cpu_min_max_mhz(){
# Fetch CPU min clock in MHz
cpu_min_clk_mhz=$((cpu_min_freq / 1000))

# Fetch CPU max clock in MHz
cpu_max_clk_mhz=$((cpu_max_freq / 1000))
}

get_gpu_min_max(){
# Fetch maximum GPU frequency (gpu_max & gpu_max2 does almost the same thing)
if [[ -e "${gpu}max_gpuclk" ]]; then
    gpu_max_freq=$(cat "${gpu}max_gpuclk")

elif [[ -e "${gpu}max_clock" ]]; then
      gpu_max_freq=$(chmod +r "${gpu}max_clock" && cat "${gpu}max_clock" && chmod -r "${gpu}max_clock")

elif [[ -e "/proc/gpufreq/gpufreq_opp_dump" ]]; then
      gpu_max_freq=$(cat /proc/gpufreq/gpufreq_opp_dump | awk '{print $4}' | cut -f1 -d "," | head -n 1)
      mtk=true
fi

# Fetch minimum GPU frequency (gpumin also does almost the same thing)
if [[ -e "${gpu}min_clock_mhz" ]]; then
    gpu_min_freq=$(cat "${gpu}min_clock_mhz")
    gpu_min_freq=$((gpu_min_freq * 1000000))

elif [[ -e "${gpu}min_clock" ]]; then
      gpu_min_freq=$(chmod +r && cat "${gpu}min_clock" && chmod -r "${gpu}max_clock")

elif [[ -e "/proc/gpufreq/gpufreq_opp_dump" ]]; then
      gpu_min_freq=$(cat /proc/gpufreq/gpufreq_opp_dump | tail -1 | awk '{print $4}' | cut -f1 -d ",")
fi
}

get_gpu_min_max_mhz(){
# Fetch maximum & minimum GPU clock in MHz
if [[ "${gpu_max_freq}" -ge "100000" ]]; then
    gpu_max_clk_mhz=$((gpu_max_freq / 1000)); gpu_min_clk_mhz=$((gpu_min_freq / 1000))
fi

if [[ "${gpu_max_freq}" -ge "100000000" ]]; then
    gpu_max_clk_mhz=$((gpu_max_freq / 1000000)); gpu_min_clk_mhz=$((gpu_min_freq / 1000000))
fi
}

get_soc_mf(){
# Fetch the SOC manufacturer
soc_mf=$(getprop ro.boot.hardware)
}

get_soc(){
# Fetch the device SOC
soc=$(getprop ro.board.platform)

if [[ "${soc}" == "" ]]; then
    soc=$(getprop ro.product.board)
elif [[ "${soc}" == "" ]]; then
      soc=$(getprop ro.product.platform)
elif [[ "${soc}" == "" ]]; then
      soc=$(getprop ro.chipname)
fi
}

get_sdk(){
# Fetch the device SDK              
sdk=$(getprop ro.build.version.sdk)

if [[ "${sdk}" == "" ]]; then
    sdk=$(getprop ro.vendor.build.version.sdk)

elif [[ "${sdk}" == "" ]]; then
      sdk=$(getprop ro.vndk.version)
fi
}

get_arch(){
# Fetch the device architeture
arch=$(getprop ro.product.cpu.abi | awk -F "-" '{print $1}')
}

get_andro_vs(){
# Fetch the android version
avs=$(getprop ro.build.version.release)
}

get_dvc_cdn(){
# Fetch the device codename
dvc_cdn=$(getprop ro.product.device)
}

get_root(){
# Fetch root method
root=$(su -v)
}

is_exynos(){
# Detect if we're running on a exynos powered device
if [[ "$(getprop ro.boot.hardware | grep exynos)" ]] || [[ "$(getprop ro.board.platform | grep universal)" ]] || [[ "$(getprop ro.product.board | grep universal)" ]]; then
    exynos=true
    mtk=false
    qcom=false
else
    exynos=false
fi
}

is_mtk(){ 
# Detect if we're running on a mediatek powered device              
if [[ "$(getprop ro.board.platform | grep mt)" ]] || [[ "$(getprop ro.product.board | grep mt)" ]] || [[ "$(getprop ro.hardware | grep mt)" ]] || [[ "$(getprop ro.boot.hardware | grep mt)" ]]; then
    mtk=true
    exynos=false
    qcom=false
else
    mtk=false
fi
}

detect_cpu_sched(){
# Fetch the CPU scheduling type
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do
  if [[ "$(grep sched "${cpu}scaling_available_governors")" ]]; then
      cpu_sched=EAS

  elif [[ "$(grep util "${cpu}scaling_available_governors")" ]]; then
        cpu_sched=EAS

  elif [[ "$(grep interactive "${cpu}scaling_available_governors")" ]]; then
        cpu_sched=HMP
  else
      cpu_sched=Unknown
  fi
done
}

get_kern_info(){
# Fetch kernel name and version
kern_ver_name=$(uname -r)
# Fetch kernel build date
kern_bd_dt=$(uname -v | awk '{print $5, $6, $7, $8, $9, $10}')
}

get_ram_info(){
if [[ "$(which busybox)" ]]; then
    # Fetch the total amount of memory RAM
    total_ram=$(busybox free -m | awk '/Mem:/{print $2}')
    # Fetch the amount of available RAM
    avail_ram=$(busybox free -m | awk '/Mem:/{print $7}')
else
    total_ram="N/A (Install busybox first)"
    avail_ram="N/A (Install busybox first)"
fi
}

get_batt_pctg(){               
# Fetch battery actual capacity
if [[ -e "/sys/class/power_supply/battery/capacity" ]]; then
    batt_pctg=$(cat /sys/class/power_supply/battery/capacity)             
else
    batt_pctg=$(dumpsys battery 2>/dev/null | awk '/level/{print $2}')
fi
}

get_ktsr_info(){
# Fetch version
bd_ver=$(grep version= "${MODPATH}module.prop" | sed "s/version=//" | awk -F "-" '{print $1}')
# Fetch build type
bd_rel=$(grep version= "${MODPATH}module.prop" | sed "s/version=//" | awk -F "-" '{print $2}')
# Fetch build date
bd_dt=$(grep build_date= "${MODPATH}module.prop" | sed "s/build_date=//")
# Fetch build codename
bd_cdn=$(grep version= "${MODPATH}module.prop" | sed "s/version=//" | awk -F "-" '{print $3}')
}

get_batt_tmp(){
# Fetch battery temperature
if [[ -e "/sys/class/power_supply/battery/temp" ]]; then
    batt_tmp=$(cat /sys/class/power_supply/battery/temp)

elif [[ -e "/sys/class/power_supply/battery/batt_temp" ]]; then 
      batt_tmp=$(cat /sys/class/power_supply/battery/batt_temp)
else 
    batt_tmp=$(dumpsys battery 2>/dev/null | awk '/temperature/{print $2}')
fi
# Ignore the battery temperature decimal
batt_tmp=$((batt_tmp / 10))
}

get_gpu_mdl(){
# Fetch GPU model
if [[ "${exynos}" == "true" ]] || [[ "${mtk}" == "true" ]]; then
    gpu_mdl=$(cat "${gpu}gpuinfo" | awk '{print $1,$2,$3}')

elif [[ "${qcom}" == "true" ]]; then
      gpu_mdl=$(cat "${gpui}gpu_model")
      
elif [[ "${gpu_mdl}" == "" ]]; then
      gpu_mdl=$(dumpsys SurfaceFlinger 2>/dev/null | awk '/GLES/ {print $3,$4,$5}' | tr -d ,)
fi
}

get_drvs_info(){
# Fetch drivers info
if [[ "${exynos}" == "true" ]] || [[ "${mtk}" == "true" ]]; then
    drvs_info=$(dumpsys SurfaceFlinger 2>/dev/null | awk '/GLES/ {print $4,5,$6,$7,$8,$9,$10,$11,$12,$13}')
else
    drvs_info=$(dumpsys SurfaceFlinger 2>/dev/null | awk '/GLES/ {print $6,$7,$8,$9,$10,$11,$12,$13}' | tr -d ,)
fi
}

get_max_rr(){
# Fetch max refresh rate
rr=$(dumpsys display 2>/dev/null | awk '/PhysicalDisplayInfo/{print $4}' | cut -c1-3 | tr -d .)

if [[ -z "${rr}" ]]; then
    rr=$(dumpsys display 2>/dev/null | grep refreshRate | awk -F '=' '{print $6}' | cut -c1-3 | tail -n 1 | tr -d .)

elif [[ -z "${rr}" ]]; then
      rr=$(dumpsys display 2>/dev/null | grep FrameRate | awk -F '=' '{print $6}' | cut -c1-3 | tail -n 1 | tr -d .)
fi
}

get_batt_hth(){
# Fetch battery health
if [[ -e "/sys/class/power_supply/battery/health" ]]; then
    batt_hth=$(cat /sys/class/power_supply/battery/health)
else
    batt_hth=$(dumpsys battery 2>/dev/null | awk '/health/{print $2}')
fi

if [[ "${batt_hth}" == "1" ]]; then
    batt_hth=Unknown

elif [[ "${batt_hth}" == "2" ]]; then
      batt_hth=Good

elif [[ "${batt_hth}" == "3" ]]; then
      batt_hth=Overheat

elif [[ "${batt_hth}" == "4" ]]; then
      batt_hth=Dead

elif [[ "${batt_hth}" == "5" ]]; then
      batt_hth=OV

elif [[ "${batt_hth}" == "6" ]]; then
      batt_hth=UF

elif [[ "${batt_hth}" == "7" ]]; then
      batt_hth=Cold               
else
    batt_hth=$batt_hth
fi
}

get_batt_sts(){
# Fetch battery status
if [[ -e "/sys/class/power_supply/battery/status" ]]; then
    batt_sts=$(cat /sys/class/power_supply/battery/status)
else
    batt_sts=$(dumpsys battery 2>/dev/null | awk '/status/{print $2}')
fi

if [[ "${batt_sts}" == "1" ]]; then
    batt_sts=Unknown

elif [[ "${batt_sts}" == "2" ]]; then
      batt_sts=Charging

elif [[ "${batt_sts}" == "3" ]]; then
      batt_sts=Discharging

elif [[ "${batt_sts}" == "4" ]]; then
      batt_sts=Not charging

elif [[ "${batt_sts}" == "5" ]]; then
      batt_sts=Full
else
    batt_sts=${batt_sts}
fi
}

get_batt_cpct(){
batt_cpct=$(cat /sys/class/power_supply/battery/charge_full_design)

if [[ "${batt_cpct}" == "" ]]; then
    batt_cpct=$(dumpsys batterystats 2>/dev/null | awk '/Capacity:/{print $2}' | cut -d "," -f 1)
fi
               
if [[ "${batt_cpct}" -ge "1000000" ]]; then
    batt_cpct=$((batt_cpct / 1000))
fi
}

get_bb_ver(){
# Fetch busybox version
if [[ "$(which busybox)" ]]; then
    bb_ver=$(busybox | awk 'NR==1{print $2}')
else
    bb_ver="N/A"
fi
}

get_rom_info(){
# Fetch ROM info
rom_info=$(getprop ro.build.description | awk '{print $1,$3,$4,$5}')

if [[ "${rom_info}" == "" ]]; then
    rom_info=$(getprop ro.bootimage.build.description | awk '{print $1,$3,$4,$5}')
elif [[ "${rom_info}" == "" ]]; then
      rom_info=$(getprop ro.system.build.description | awk '{print $1,$3,$4,$5}')
fi
}

get_slnx_stt(){
# Fetch SELinux state
if [[ "$(cat /sys/fs/selinux/enforce)" == "1" ]]; then
    slnx_stt=Enforcing
else
    slnx_stt=Permissive
fi
}

setup_adreno_gpu_thrtl(){
gpu_thrtl_lvl=$(cat "${gpu}thermal_pwrlevel")

# Disable the GPU thermal throttling clock restriction
if [[ "${gpu_thrtl_lvl}" -eq "1" ]] || [[ "${gpu_thrtl_lvl}" -gt "1" ]]; then
    gpu_calc_thrtl=$((gpu_thrtl_lvl - gpu_thrtl_lvl))
else
    gpu_calc_thrtl=0
fi
}

get_gpu_load(){
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

get_nr_cores(){
# Fetch the number of CPU cores
nr_cores=$(cat /sys/devices/system/cpu/possible | awk -F "-" '{print $2}')
               
nr_cores=$((nr_cores + 1))
               
if [[ "${nr_cores}" -eq "0" ]]; then
    nr_cores=1
fi
}

get_dvc_brnd(){
# Fetch device brand
dvc_brnd=$(getprop ro.product.brand)
}

check_one_ui(){
# Check if we're running on OneUI
if [[ "$(getprop net.knoxscep.version)" ]] || [[ "$(getprop ril.product_code)" ]] || [[ "$(getprop ro.boot.em.model)" ]] || [[ "$(getprop net.knoxvpn.version)" ]] || [[ "$(getprop ro.securestorage.knox)" ]] || [[ "$(getprop gsm.version.ril-impl | grep Samsung)" ]] || [[ "$(getprop ro.build.PDA)" ]]; then
    one_ui=true
    samsung=true
else
    one_ui=false
    samsung=false
fi
}
               
get_bt_dvc(){
bt_dvc=$(getprop ro.boot.bootdevice)
}

get_uptime(){
# Fetch the amount of time since the system is running
sys_uptime=$(uptime | awk '{print $3,$4}' | cut -d "," -f 1)
}

get_sql_info(){
if [[ "$(which sqlite3)" ]]; then
    # Fetch SQLite version
    sql_ver=$(sqlite3 -version | awk '{print $1}')

    # Fetch SQLite build date
    sql_bd_dt=$(sqlite3 -version | awk '{print $2,$3}')
else
    sql_ver="N/A"
    sql_bd_dt="N/A"
fi
}

get_cpu_load(){
# Calculate CPU load (50 ms)
read -r cpu user nice system idle iowait irq softirq steal guest< /proc/stat

cpu_active_prev=$((user+system+nice+softirq+steal))
cpu_total_prev=$((user+system+nice+softirq+steal+idle+iowait))

usleep 50000

read -r cpu user nice system idle iowait irq softirq steal guest< /proc/stat

cpu_active_cur=$((user+system+nice+softirq+steal))
cpu_total_cur=$((user+system+nice+softirq+steal+idle+iowait))

cpu_load=$((100*( cpu_active_cur-cpu_active_prev ) / (cpu_total_cur-cpu_total_prev) ))
}

check_ppm_support(){
if [[ -d "/proc/ppm/" ]] && [[ "${mtk}" == "true" ]]; then
    ppm=true
else
    ppm=false
fi
}

enable_devfreq_boost(){
for dir in /sys/class/devfreq/*/; do
     max_devfreq=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $NF}')
     max_devfreq2=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $1}')
     if [[ "$max_devfreq2" -gt "${max_devfreq}" ]]; then
         max_devfreq=${max_devfreq2}
     fi
     lock_value "${dir}min_freq" "$max_devfreq"
done

kmsg "Enabled devfreq boost"
kmsg3 ""
}

disable_devfreq_boost(){
for dir in /sys/class/devfreq/*/; do
     min_devfreq=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $1}')
     min_devfreq2=$(cat "${dir}available_frequencies" | awk -F ' ' '{print $NF}')
     if [[ "${min_devfreq2}" -lt "${min_devfreq}" ]]; then
         min_devfreq=${min_devfreq2}
     fi
     write "${dir}min_freq" "${min_devfreq}"
done

kmsg "Disabled devfreq boost"
kmsg3 ""
}

is_big_little(){
for i in 1 2 3 4 5 6 7; do 
    if [[ -d "/sys/devices/system/cpu/cpufreq/policy0/" ]] && [[ -d "/sys/devices/system/cpu/cpufreq/policy${i}/" ]]; then
        big_little=true
    else
        big_little=false
    fi
done
}

print_info(){
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
kmsg3 "** CPU Load: $cpu_load %"
kmsg3 "** Number of cores: ${nr_cores}"
kmsg3 "** CPU Freq: ${cpu_min_clk_mhz}-${cpu_max_clk_mhz} MHz"
kmsg3 "** CPU Scheduling Type: ${cpu_sched}"                                                                               
kmsg3 "** AArch: ${arch}"        
kmsg3 "** GPU Load: ${gpu_load}%"
kmsg3 "** GPU Freq: ${gpu_min_clk_mhz}-${gpu_max_clk_mhz} MHz"
kmsg3 "** GPU Model: ${gpu_mdl}"                                                                                         
kmsg3 "** GPU Drivers Info: $drvs_info"                                                                                  
kmsg3 "** GPU Governor: $gpu_gov"                                                                                  
kmsg3 "** Device: ${dvc_brnd}, ${dvc_cdn}"                                                                                                
kmsg3 "** ROM: ${rom_info}"                 
kmsg3 "** Screen Resolution: $(wm size | awk '{print $3}' | tail -n 1)"
kmsg3 "** Screen Density: $(wm density | awk '{print $3}' | tail -n 1) PPI"
kmsg3 "** Refresh Rate: $rr HZ"                                         
kmsg3 "** Build Version: ${bd_ver}"                                                                                     
kmsg3 "** Build Codename: ${bd_cdn}"                                                                                   
kmsg3 "** Build Release: ${bd_rel}"                                                                                         
kmsg3 "** Build Date: ${bd_dt}"                                                                                          
kmsg3 "** Battery Charge Level: $batt_pctg %"  
kmsg3 "** Battery Capacity: $batt_cpct mAh"
kmsg3 "** Battery Health: ${batt_hth}"                                                                                     
kmsg3 "** Battery Status: ${batt_sts}"                                                                                     
kmsg3 "** Battery Temperature: $batt_tmp °C"                                                                               
kmsg3 "** Device RAM: $total_ram MB"                                                                                     
kmsg3 "** Device Available RAM: $avail_ram MB"
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

stop_services(){
# Disable perfd, mpdecision and few debug services
stop perfd 2>/dev/null
if [[ "${ktsr_prof_en}" == "battery" ]] || [[ "$(getprop kingauto.prof)" == "battery" ]]; then
    start mpdecision 2>/dev/null
else
    stop mpdecision 2>/dev/null
fi
# stop vendor.perfservice 2>/dev/null
stop vendor.cnss_diag 2>/dev/null
stop vendor.tcpdump 2>/dev/null
stop statsd 2>/dev/null
stop charge_logger 2>/dev/null
stop oneplus_brain_service 2>/dev/null

if [[ -e "/data/system/perfd/default_values" ]]; then
    rm -rf "/data/system/perfd/default_values"

elif [[ -e "/data/vendor/perfd/default_values" ]]; then
      rm -rf "/data/vendor/perfd/default_values"
fi

kmsg "Disabled perfd, mpdecision and few debug services"
kmsg3 ""
}

thermal_default(){
# Configure thermal profile
if [[ -e "/sys/class/thermal/thermal_message" ]]; then
    write "/sys/class/thermal/thermal_message/sconfig" "0"
    kmsg "Tweaked thermal profile"
    kmsg3 ""
fi
}

thermal_dynamic(){
if [[ -e "/sys/class/thermal/thermal_message" ]]; then
    write "/sys/class/thermal/thermal_message/sconfig" "10"
    kmsg "Tweaked thermal profile"
    kmsg3 ""
fi
}

disable_core_ctl(){
for core_ctl in /sys/devices/system/cpu/cpu*/core_ctl/
do
  if [[ -e "${core_ctl}enable" ]]; then
      lock_value "${core_ctl}enable" "0"

  elif [[ -e "${core_ctl}disable" ]]; then
        lock_value "${core_ctl}disable" "1"
  fi
done

if [[ -e "/sys/power/cpuhotplug/enable" ]]; then
    lock_value "/sys/power/cpuhotplug/enable" "0"

elif [[ -e "/sys/power/cpuhotplug/enabled" ]]; then
      lock_value "/sys/power/cpuhotplug/enabled" "0"

elif [[ -e "/sys/devices/system/cpu/cpuhotplug/enabled" ]]; then
      lock_value "/sys/devices/system/cpu/cpuhotplug/enabled" "0"
fi

if [[ -e "/sys/kernel/intelli_plug" ]]; then
    lock_value "/sys/kernel/intelli_plug/intelli_plug_active" "0"
fi

if [[ -e "/sys/module/blu_plug" ]]; then
    lock_value "/sys/module/blu_plug/parameters/enabled" "0"
fi

if [[ -e "/sys/devices/virtual/misc/mako_hotplug_control" ]]; then
    lock_value "/sys/devices/virtual/misc/mako_hotplug_control/enabled" "0"
fi

if [[ -e "/sys/module/autosmp" ]]; then
    lock_value "/sys/module/autosmp/parameters/enabled" "0"
fi
 
if [[ -e "/sys/kernel/zen_decision" ]]; then
    lock_value "/sys/kernel/zen_decision/enabled" "0"
fi

if [[ -e "/proc/hps" ]]; then
    lock_value "/proc/hps/enabled" "0"
fi

kmsg "Disabled core control & CPU hotplug"
kmsg3 ""
}

enable_core_ctl(){
for core_ctl in /sys/devices/system/cpu/cpu*/core_ctl/
do
  if [[ -e "${core_ctl}enable" ]]; then
      lock_value "${core_ctl}enable" "1"

  elif [[ -e "${core_ctl}disable" ]]; then
        lock_value "${core_ctl}disable" "0"
  fi
done

if [[ -e "/sys/power/cpuhotplug/enable" ]]; then
    lock_value "/sys/power/cpuhotplug/enable" "1"

elif [[ -e "/sys/power/cpuhotplug/enabled" ]]; then
      lock_value "/sys/power/cpuhotplug/enabled" "1"

elif [[ -e "/sys/devices/system/cpu/cpuhotplug/enabled" ]]; then
      lock_value "/sys/devices/system/cpu/cpuhotplug/enabled" "1"
fi

if [[ -e "/sys/kernel/intelli_plug" ]]; then
    lock_value "/sys/kernel/intelli_plug/intelli_plug_active" "1"
fi

if [[ -e "/sys/module/blu_plug" ]]; then
    lock_value "/sys/module/blu_plug/parameters/enabled" "1"
fi

if [[ -e "/sys/devices/virtual/misc/mako_hotplug_control" ]]; then
    lock_value "/sys/devices/virtual/misc/mako_hotplug_control/enabled" "1"
fi

if [[ -e "/sys/module/autosmp" ]]; then
    lock_value "/sys/module/autosmp/parameters/enabled" "1"
fi
 
if [[ -e "/sys/kernel/zen_decision" ]]; then
    lock_value "/sys/kernel/zen_decision/enabled" "1"
fi

if [[ -e "/proc/hps" ]]; then
    lock_value "/proc/hps/enabled" "1"
fi

kmsg "Enabled core control & CPU hotplug"
kmsg3 ""
}

# Some of these are based from @helloklf (GitHub) vtools, credits to him.
config_cpuset(){
if [[ "${soc}" == "msm8937" ]]; then
    write "${cpuset}camera-daemon/cpus" "0-6"
    write "${cpuset}foreground/cpus" "0-6"
    write "${cpuset}foreground/boost/cpus" "0-6"
    write "${cpuset}background/cpus" "0-1"
    write "${cpuset}system-background/cpus" "0-3"
    write "${cpuset}top-app/cpus" "0-7"
    write "${cpuset}restricted/cpus" "0-3"
    kmsg "Tweaked cpusets"
    kmsg3 ""

elif [[ "${soc}" == "msm8952" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-6"
      write "${cpuset}foreground/cpus" "0-6"
      write "${cpuset}foreground/boost/cpus" "0-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "0-3"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}restricted/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""
    
elif [[ "${soc}" == "msm8953" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-6"
      write "${cpuset}foreground/cpus" "0-6"
      write "${cpuset}foreground/boost/cpus" "0-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "0-3"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}restricted/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""
    
elif [[ "${soc}" == "msm8996" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-2"
      write "${cpuset}foreground/cpus" "0-2"
      write "${cpuset}foreground/boost/cpus" "0-2"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "0-2"
      write "${cpuset}top-app/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""
    
elif [[ "${soc}" == "msm8998" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-6"
      write "${cpuset}foreground/cpus" "0-6"
      write "${cpuset}foreground/boost/cpus" "0-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "0-3"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}restricted/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""
    
elif [[ "${soc}" == "msmnile" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-3"
      write "${cpuset}foreground/cpus" "0-3,5-6"
      write "${cpuset}foreground/boost/cpus" "0-3,5-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "0-3"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}restricted/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""
    
elif [[ "${soc}" == "mt6768" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-6"
      write "${cpuset}foreground/cpus" "0-6"
      write "${cpuset}foreground/boost/cpus" "0-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "0-3"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}restricted/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""

elif [[ "${soc}" == "mt6785" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-6"
      write "${cpuset}foreground/cpus" "0-6"
      write "${cpuset}foreground/boost/cpus" "0-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "0-3"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}top-app/boost/cpus" "0-7"
      write "${cpuset}restricted/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""

elif [[ "${soc}" == "mt6873" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-6"
      write "${cpuset}foreground/cpus" "0-6"
      write "${cpuset}foreground/boost/cpus" "0-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "0-3"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}restricted/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""
    
elif [[ "${soc}" == "mt6885" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-6"
      write "${cpuset}foreground/cpus" "0-6"
      write "${cpuset}foreground/boost/cpus" "0-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "0-3"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}restricted/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""
    
elif [[ "${soc}" == "sdm710" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-6"
      write "${cpuset}foreground/cpus" "0-3,5-6"
      write "${cpuset}foreground/boost/cpus" "0-3,5-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "0-3"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}restricted/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""
    
elif [[ "${soc}" == "sdm845" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-3"
      write "${cpuset}foreground/cpus" "0-3,5-6"
      write "${cpuset}foreground/boost/cpus" "0-3,5-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "0-3"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}restricted/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""
      
elif [[ "${soc}" == "sm6150" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-6"
      write "${cpuset}foreground/cpus" "0-3,5-6"
      write "${cpuset}foreground/boost/cpus" "0-3,5-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "0-3"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}restricted/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""
    
elif [[ "${soc}" == "lito" ]]; then
	  write "${cpuset}camera-daemon/cpus" "0-3"
      write "${cpuset}camera-daemon-dedicated/cpus" "0-3"
      write "${cpuset}foreground/cpus" "0-6"
      write "${cpuset}foreground/boost/cpus" "0-6"
      write "${cpuset}background/cpus" "4-5"
      write "${cpuset}system-background/cpus" "2-5"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}restricted/cpus" "2-5"
      kmsg "Tweaked cpusets"
      kmsg3 ""
    
elif [[ "${soc}" == "lahaina" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-3"
      write "${cpuset}foreground/cpus" "0-3,5-6"
      write "${cpuset}foreground/boost/cpus" "0-3,5-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "0-3"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}restricted/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""
    
elif [[ "${soc}" == "exynos5" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-6"
      write "${cpuset}foreground/cpus" "0-6"
      write "${cpuset}foreground/boost/cpus" "0-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "2-5"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}dex2oat/cpus" "0-3,5-6"
      write "${cpuset}restricted/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""
    
elif [[ "${soc}" == "trinket" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-6"
      write "${cpuset}foreground/cpus" "0-3,5-6"
      write "${cpuset}foreground/boost/cpus" "0-3,5-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "0-3"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}restricted/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""
    
elif [[ "${soc}" == "kona" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-3"
      write "${cpuset}foreground/cpus" "0-3,5-6"
      write "${cpuset}foreground/boost/cpus" "0-3,5-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "0-3"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}restricted/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""
    
elif [[ "${soc}" == "universal9811" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-6"
      write "${cpuset}foreground/cpus" "0-6"
      write "${cpuset}foreground/boost/cpus" "0-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "2-5"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}dexopt/cpus" "0-3,5-6"
      write "${cpuset}restricted/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""

elif [[ "${soc}" == "universal9820" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-6"
      write "${cpuset}foreground/cpus" "0-6"
      write "${cpuset}foreground/boost/cpus" "0-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "2-5"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}dexopt/cpus" "0-3,5-6"
      write "${cpuset}restricted/cpus" "0-3"
      kmsg "Tweaked cpusets"
      kmsg3 ""

elif [[ "${soc}" == "atoll" ]]; then
      write "${cpuset}camera-daemon/cpus" "0-6"
      write "${cpuset}foreground/cpus" "0-6"
      write "${cpuset}foreground/boost/cpus" "0-6"
      write "${cpuset}background/cpus" "0-1"
      write "${cpuset}system-background/cpus" "2-5"
      write "${cpuset}top-app/cpus" "0-7"
      write "${cpuset}restricted/cpus" "2-5"
      kmsg "Tweaked cpusets"
      kmsg3 ""
fi
}

boost_latency(){
if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]; then
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "10"
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1000"
    kmsg "Tweaked dynamic stune boost"
    kmsg3 ""
fi

if [[ -d "/sys/module/cpu_boost/" ]]; then
    write "/sys/module/cpu_boost/parameters/input_boost_ms" "130"
    write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
    write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "1"
    kmsg "Tweaked CAF CPU input boost"
    kmsg3 ""

elif [[ -d "/sys/module/cpu_input_boost/" ]]; then
    write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "130"
    kmsg "Tweaked CPU input boost"
    kmsg3 ""
fi
}

boost_balanced(){
if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]; then
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "5"
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1000"
    kmsg "Tweaked dynamic stune boost"
    kmsg3 ""
fi

if [[ -d "/sys/module/cpu_boost/" ]]; then
    write "/sys/module/cpu_boost/parameters/input_boost_ms" "100"
    write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
    write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "1"
    kmsg "Tweaked CAF CPU input boost"
    kmsg3 ""

elif [[ -d "/sys/module/cpu_input_boost/" ]]; then
    write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "100"
    kmsg "Tweaked CPU input boost"
    kmsg3 ""
fi
}

boost_extreme(){
if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]; then
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "50"
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1000"
    kmsg "Tweaked dynamic stune boost"
    kmsg3 ""
fi


if [[ -d "/sys/module/cpu_boost/" ]]; then
    write "/sys/module/cpu_boost/parameters/input_boost_ms" "250"
    write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
    write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "1"
    kmsg "Tweaked CAF CPU input boost"
    kmsg3 ""

elif [[ -d "/sys/module/cpu_input_boost/" ]]; then
    write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "250"
    kmsg "Tweaked CPU input boost"
    kmsg3 ""
fi
}

boost_battery(){
if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]; then
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "1"
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1000"
    kmsg "Tweaked dynamic stune boost"
    kmsg3 ""
fi

if [[ -e "/sys/module/cpu_boost/parameters/" ]]; then
    write "/sys/module/cpu_boost/parameters/input_boost_ms" "64"
    write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
    write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "1"
    kmsg "Tweaked CAF CPU input boost"
    kmsg3 ""
fi

if [[ -e "/sys/module/cpu_input_boost/parameters/" ]]; then
    write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "64"
    kmsg "Tweaked CPU input boost"
    kmsg3 ""
fi
}

boost_gaming(){
if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]; then
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "50"
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1000"
    kmsg "Tweaked dynamic stune boost"
    kmsg3 ""
fi

if [[ -d "/sys/module/cpu_boost/" ]]; then
    write "/sys/module/cpu_boost/parameters/input_boost_ms" "250"
    write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
    write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "1"
    kmsg "Tweaked CAF CPU input boost"
    kmsg3 ""

elif [[ -d "/sys/module/cpu_input_boost/" ]]; then
    write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "250"
    kmsg "Tweaked CPU input boost"
    kmsg3 ""
fi
}

io_latency(){
# I/O Scheduler tweaks
for queue in /sys/block/*/queue/
do
  # Fetch the available schedulers from the block
  avail_scheds="$(cat "${queue}scheduler")"

    # Select the first scheduler available
	for sched in tripndroid fiops maple bfq-sq bfq-mq bfq zen sio anxiety cfq noop none
	do
	  if [[ "${avail_scheds}" == *"$sched"* ]]; then
		  write "${queue}scheduler" "$sched"
        break
      fi
  done
	
     write "${queue}add_random" "0"
     write "${queue}iostats" "0"
     write "${queue}rotational" "0"
     write "${queue}read_ahead_kb" "32"
     write "${queue}nomerges" "0"
     write "${queue}rq_affinity" "2"
     write "${queue}nr_requests" "16"
done

kmsg "Tweaked I/O scheduler"
kmsg3 ""
}

io_balanced(){
for queue in /sys/block/*/queue/
do
  avail_scheds="$(cat "${queue}scheduler")"

	for sched in tripndroid fiops maple bfq-sq bfq-mq bfq zen sio anxiety cfq noop none
	do
		if [[ "$avail_scheds" == *"$sched"* ]]; then
			write "${queue}scheduler" "$sched"
	      break
		fi
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

io_extreme(){
for queue in /sys/block/*/queue/
do
  avail_scheds="$(cat "${queue}scheduler")"

	for sched in tripndroid fiops maple bfq-sq bfq-mq bfq cfq noop none
	do
		if [[ "${avail_scheds}" == *"$sched"* ]]; then
			write "${queue}scheduler" "$sched"
	      break
		fi
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

io_battery(){
for queue in /sys/block/*/queue/
do
  avail_scheds="$(cat "${queue}scheduler")"

	for sched in tripndroid fiops maple bfq-sq bfq-mq bfq zen sio anxiety cfq noop none
	do
		if [[ "${avail_scheds}" == *"$sched"* ]]; then
			write "${queue}scheduler" "$sched"
		  break
		fi
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

io_gaming(){
for queue in /sys/block/*/queue/
do
  avail_scheds="$(cat "${queue}scheduler")"

	for sched in tripndroid fiops maple bfq-sq bfq-mq bfq zen sio anxiety cfq noop none
	do
	  if [[ "${avail_scheds}" == *"$sched"* ]]; then
		  write "${queue}scheduler" "$sched"
		break
	  fi
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

cpu_latency(){
# CPU tweaks
for cpu in /sys/devices/system/cpu/cpu*/cpufreq
do
	# Fetch the available governors from the CPU
	avail_govs="$(cat "${cpu}/scaling_available_governors")"

	# Attempt to set the governor in this order
	for governor in schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive
	do
		# Once a matching governor is found, set it and break for this CPU
		if [[ "${avail_govs}" == *"$governor"* ]]; then
			lock_value "${cpu}scaling_governor" "$governor"
		  break
		fi
	done
done

# Apply governor specific tunables for schedutil, or it's modifications
for governor in $(find /sys/devices/system/cpu/ -name *util* -type d)
do
    write "${governor}/up_rate_limit_us" "1000"
    write "${governor}/down_rate_limit_us" "1000"
    write "${governor}/pl" "1"
    write "${governor}/iowait_boost_enable" "1"
    write "${governor}/rate_limit_us" "5000"
    write "${governor}/hispeed_load" "89"
    write "${governor}/hispeed_freq" "$cpu_max_freq"
done

for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d)
do
    write "${governor}/up_rate_limit_us" "1000"
    write "${governor}/down_rate_limit_us" "1000"
    write "${governor}/pl" "1"
    write "${governor}/iowait_boost_enable" "1"
    write "${governor}/rate_limit_us" "5000"
    write "${governor}/hispeed_load" "89"
    write "${governor}/hispeed_freq" "$cpu_max_freq"
done

# Apply governor specific tunables for interactive
for governor in $(find /sys/devices/system/cpu/ -name *interactive* -type d)
do
    write "${governor}/timer_rate" "1000"
    write "${governor}/boost" "0"
    write "${governor}/io_is_busy" "1"
    write "${governor}/timer_slack" "1000"
    write "${governor}/input_boost" "0"
    write "${governor}/use_migration_notif" "0" 
    write "${governor}/ignore_hispeed_on_notif" "1"
    write "${governor}/use_sched_load" "1"
    write "${governor}/fastlane" "1"
    write "${governor}/fast_ramp_down" "0"
    write "${governor}/sampling_rate" "1000"
    write "${governor}/sampling_rate_min" "5000"
    write "${governor}/min_sample_time" "5000"
    write "${governor}/go_hispeed_load" "89"
    write "${governor}/hispeed_freq" "$cpu_max_freq"
done
}

cpu_balanced(){
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do
  avail_govs="$(cat "${cpu}scaling_available_governors")"

	for governor in schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive
	do
	  if [[ "${avail_govs}" == *"$governor"* ]]; then
		  lock_value "${cpu}scaling_governor" "$governor"
		break
	  fi
  done
done

for governor in $(find /sys/devices/system/cpu/ -name *util* -type d)
do
     write "${governor}/up_rate_limit_us" "500"
     write "${governor}/down_rate_limit_us" "20000"
     write "${governor}/pl" "1"
     write "${governor}/iowait_boost_enable" "1"
     write "${governor}/rate_limit_us" "20000"
     write "${governor}/hispeed_load" "80"
     write "${governor}/hispeed_freq" "$cpu_max_freq"
done

for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d)
do
     write "${governor}/up_rate_limit_us" "500"
     write "${governor}/down_rate_limit_us" "20000"
     write "${governor}/pl" "1"
     write "${governor}/iowait_boost_enable" "1"
     write "${governor}/rate_limit_us" "20000"
     write "${governor}/hispeed_load" "80"
     write "${governor}/hispeed_freq" "$cpu_max_freq"
done

for governor in $(find /sys/devices/system/cpu/ -name *interactive* -type d)
do
     write "${governor}/timer_rate" "10000"
     write "${governor}/boost" "0"
     write "${governor}/io_is_busy" "1"
     write "${governor}/timer_slack" "20000"
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
     write "${governor}/hispeed_freq" "$cpu_max_freq"
done
}

cpu_extreme(){
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do
  avail_govs="$(cat "${cpu}scaling_available_governors")"

	for governor in schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive
	do
	  if [[ "${avail_govs}" == *"$governor"* ]]; then
		  lock_value "${cpu}scaling_governor" "$governor"
	    break
	  fi
  done
done

for governor in $(find /sys/devices/system/cpu/ -name *util* -type d)
do
     write "${governor}/up_rate_limit_us" "0"
     write "${governor}/down_rate_limit_us" "0"
     write "${governor}/pl" "1"
     write "${governor}/iowait_boost_enable" "1"
     write "${governor}/rate_limit_us" "0"
     write "${governor}/hispeed_load" "65"
     write "${governor}/hispeed_freq" "$cpu_max_freq"
done

for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d)
do
     write "${governor}/up_rate_limit_us" "0"
     write "${governor}/down_rate_limit_us" "0"
     write "${governor}/pl" "1"
     write "${governor}/iowait_boost_enable" "1"
     write "${governor}/rate_limit_us" "0"
     write "${governor}/hispeed_load" "65"
     write "${governor}/hispeed_freq" "$cpu_max_freq"
done

for governor in $(find /sys/devices/system/cpu/ -name *interactive* -type d)
do
     write "${governor}/timer_rate" "0"
     write "${governor}/boost" "1"
     write "${governor}/io_is_busy" "1"
     write "${governor}/timer_slack" "0"
     write "${governor}/input_boost" "1"
     write "${governor}/use_migration_notif" "0"
     write "${governor}/ignore_hispeed_on_notif" "1"
     write "${governor}/use_sched_load" "1"
     write "${governor}/fastlane" "1"
     write "${governor}/fast_ramp_down" "0"
     write "${governor}/sampling_rate" "0"
     write "${governor}/sampling_rate_min" "0"
     write "${governor}/min_sample_time" "0"
     write "${governor}/go_hispeed_load" "65"
     write "${governor}/hispeed_freq" "$cpu_max_freq"
done
}

cpu_battery(){
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do
  avail_govs="$(cat "${cpu}scaling_available_governors")"

	for governor in schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive
	do
	  if [[ "$avail_govs" == *"$governor"* ]]; then
		  lock_value "${cpu}scaling_governor" "$governor"
		break
      fi
  done
done

for governor in $(find /sys/devices/system/cpu/ -name *util* -type d)
do
     write "${governor}/up_rate_limit_us" "46000"
     write "${governor}/down_rate_limit_us" "24000"
     write "${governor}/pl" "1"
     write "${governor}/iowait_boost_enable" "0"
     write "${governor}/rate_limit_us" "46000"
     write "${governor}/hispeed_load" "99"
     write "${governor}/hispeed_freq" "$cpu_max_freq"
done

for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d)
do
     write "${governor}/up_rate_limit_us" "46000"
     write "${governor}/down_rate_limit_us" "24000"
     write "${governor}/pl" "1"
     write "${governor}/iowait_boost_enable" "0"
     write "${governor}/rate_limit_us" "46000"
     write "{$governor}/hispeed_load" "99"
     write "${governor}/hispeed_freq" "$cpu_max_freq"
done

for governor in $(find /sys/devices/system/cpu/ -name *interactive* -type d)
do
     write "${governor}/timer_rate" "46000"
     write "${governor}/boost" "0"
     write "${governor}/io_is_busy" "1"
     write "${governor}/timer_slack" "46000"
     write "${governor}/input_boost" "0"
     write "${governor}/use_migration_notif" "0" 
     write "${governor}/ignore_hispeed_on_notif" "1"
     write "${governor}/use_sched_load" "1"
     write "${governor}/boostpulse" "0"
     write "${governor}/fastlane" "1"
     write "${governor}/fast_ramp_down" "1"
     write "${governor}/sampling_rate" "46000"
     write "${governor}/sampling_rate_min" "46000"
     write "${governor}/min_sample_time" "46000"
     write "${governor}/go_hispeed_load" "99"
     write "${governor}/hispeed_freq" "$cpu_max_freq"
done
}

cpu_gaming(){
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do
  avail_govs="$(cat "${cpu}scaling_available_governors")"

	for governor in schedutil ts_schedutil pixel_schedutil blu_schedutil helix_schedutil Runutil electroutil smurfutil smurfutil_flex pixel_smurfutil alucardsched darknesssched pwrutilx interactive
	do
	  if [[ "${avail_govs}" == *"$governor"* ]]; then
		  lock_value "${cpu}scaling_governor" "$governor"
		break
      fi
  done
done

for governor in $(find /sys/devices/system/cpu/ -name *util* -type d)
do
      write "${governor}/up_rate_limit_us" "0"
      write "${governor}/down_rate_limit_us" "0"
      write "${governor}/pl" "1"
      write "${governor}/iowait_boost_enable" "1"
      write "${governor}/rate_limit_us" "0"
      write "${governor}/hispeed_load" "65"
      write "${governor}/hispeed_freq" "$cpu_max_freq"
done

for governor in $(find /sys/devices/system/cpu/ -name *sched* -type d)
do
     write "${governor}/up_rate_limit_us" "0"
     write "${governor}/down_rate_limit_us" "0"
     write "${governor}/pl" "1"
     write "${governor}/iowait_boost_enable" "1"
     write "${governor}/rate_limit_us" "0"
     write "${governor}/hispeed_load" "65"
     write "${governor}/hispeed_freq" "$cpu_max_freq"
done

for governor in $(find /sys/devices/system/cpu/ -name *interactive* -type d)
do
     write "${governor}/timer_rate" "0"
     write "${governor}/boost" "1"
     write "${governor}/io_is_busy" "1"
     write "${governor}/timer_slack" "0"
     write "${governor}/input_boost" "1"
     write "${governor}/use_migration_notif" "0"
     write "${governor}/ignore_hispeed_on_notif" "1"
     write "${governor}/use_sched_load" "1"
     write "${governor}/fastlane" "1"
     write "${governor}/fast_ramp_down" "0"
     write "${governor}/sampling_rate" "0"
     write "${governor}/sampling_rate_min" "0"
     write "${governor}/min_sample_time" "0"
     write "${governor}/go_hispeed_load" "65"
     write "${governor}/hispeed_freq" "$cpu_max_freq"
done
}

misc_cpu_default(){
if [[ -e "/proc/cpufreq/cpufreq_power_mode" ]]; then
    write "/proc/cpufreq/cpufreq_power_mode" "0"
fi

if [[ -e "/proc/cpufreq/cpufreq_cci_mode" ]]; then
    write "/proc/cpufreq/cpufreq_cci_mode" "0"
fi

if [[ -e "/proc/cpufreq/cpufreq_stress_test" ]]; then
    write "/proc/cpufreq/cpufreq_stress_test" "0"
fi

if [[ -e "/proc/cpufreq/cpufreq_sched_disable" ]]; then
    write "/proc/cpufreq/cpufreq_sched_disable" "0"
fi
}

misc_cpu_max_pwr(){
if [[ -e "/proc/cpufreq/cpufreq_power_mode" ]]; then
    write "/proc/cpufreq/cpufreq_power_mode" "3"
fi

if [[ -e "/proc/cpufreq/cpufreq_cci_mode" ]]; then
    write "/proc/cpufreq/cpufreq_cci_mode" "1"
fi

if [[ -e "/proc/cpufreq/cpufreq_stress_test" ]]; then
    write "/proc/cpufreq/cpufreq_stress_test" "1"
fi

if [[ -e "/proc/cpufreq/cpufreq_sched_disable" ]]; then
    write "/proc/cpufreq/cpufreq_sched_disable" "0"
fi
}

misc_cpu_pwr_saving(){
if [[ -e "/proc/cpufreq/cpufreq_power_mode" ]]; then
    write "/proc/cpufreq/cpufreq_power_mode" "1"
fi

if [[ -e "/proc/cpufreq/cpufreq_cci_mode" ]]; then
    write "/proc/cpufreq/cpufreq_cci_mode" "0"
fi

if [[ -e "/proc/cpufreq/cpufreq_stress_test" ]]; then
    write "/proc/cpufreq/cpufreq_stress_test" "0"
fi

if [[ -e "/proc/cpufreq/cpufreq_sched_disable" ]]; then
    write "/proc/cpufreq/cpufreq_sched_disable" "0"
fi
}

bring_all_cores(){
for i in 0 1 2 3 4 5 6 7 8 9; do
     write "/sys/devices/system/cpu/cpu$i/online" "1"
done
}

enable_ppm(){
[[ "${ppm}" == "true" ]] && write "/proc/ppm/enabled" "1"
kmsg "Tweaked CPU parameters"
kmsg3 ""
}

disable_ppm(){
[[ "${ppm}" == "true" ]] && write "/proc/ppm/enabled" "0"
kmsg "Tweaked CPU parameters"
kmsg3 ""
}

hmp_balanced(){
if [[ -d "/sys/kernel/hmp/" ]]; then
    write "/sys/kernel/hmp/boost" "0"
    write "/sys/kernel/hmp/down_compensation_enabled" "1"
    write "/sys/kernel/hmp/family_boost" "0"
    write "/sys/kernel/hmp/semiboost" "0"
    write "/sys/kernel/hmp/up_threshold" "575"
    write "/sys/kernel/hmp/down_threshold" "256"
    kmsg "Tweaked HMP parameters"
    kmsg3 ""
fi
}

hmp_extreme(){
if [[ -d "/sys/kernel/hmp/" ]]; then
    write "/sys/kernel/hmp/boost" "1"
    write "/sys/kernel/hmp/down_compensation_enabled" "1"
    write "/sys/kernel/hmp/family_boost" "1"
    write "/sys/kernel/hmp/semiboost" "1"
    write "/sys/kernel/hmp/up_threshold" "500"
    write "/sys/kernel/hmp/down_threshold" "180"
    kmsg "Tweaked HMP parameters"
    kmsg3 ""
fi
}

hmp_battery(){
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

hmp_gaming(){
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

gpu_latency(){
# GPU tweaks

    if [[ "${qcom}" == "true" ]]; then
        # Fetch the available governors from the GPU
	    avail_govs="$(cat "${gpu}devfreq/available_governors")"

	    # Attempt to set the governor in this order
	    for governor in msm-adreno-tz simple_ondemand ondemand
	    do
		  # Once a matching governor is found, set it and break
		  if [[ "${avail_govs}" == *"$governor"* ]]; then
			  lock_value "${gpu}devfreq/governor" "$governor"
		    break
		  fi
	  done
	
    elif [[ "${exynos}" == "true" ]]; then
	      avail_govs="$(cat "${gpui}gpu_available_governor")"

	      for governor in Interactive Dynamic Static ondemand
	      do
		    if [[ "${avail_govs}" == *"$governor"* ]]; then
			    lock_value "${gpui}gpu_governor" "$governor"
			  break
		    fi
	    done
	
	elif [[ "${mtk}" == "true" ]]; then
	      avail_govs="$(cat "${gpu}available_governors")"

	      for governor in Interactive Dynamic Static ondemand
	      do
		    if [[ "${avail_govs}" == *"$governor"* ]]; then
			    lock_value "${gpu}governor" "$governor"
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
    write "${gpu}default_pwrlevel" "$((gpu_min_pl - 2))"
    write "${gpu}force_bus_on" "0"
    write "${gpu}force_clk_on" "0"
    write "${gpu}force_rail_on" "0"
    write "${gpu}idle_timer" "150"
    write "${gpu}pwrnap" "1"
elif [[ "${qcom}" == "false" ]]; then
      [[ "${one_ui}" == "false" ]] && write "${gpu}dvfs" "1"
       write "${gpui}gpu_max_clock" "${gpu_max_freq}"
       write "${gpui}gpu_min_clock" "${gpu_min}"
       write "${gpu}highspeed_clock" "${gpu_max_freq}"
       write "${gpu}highspeed_load" "80"
       write "${gpu}highspeed_delay" "0"
       write "${gpu}power_policy" "always_on"
       write "${gpui}boost" "0"
       write "${gpug}mali_touch_boost_level" "0"
       write "${gpu}max_freq" "${gpu_max_freq}"
       write "${gpu}min_freq" "${gpu_min_freq}"
       write "${gpu}devfreq/gpufreq/mali_ondemand/vsync" "1"
       write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_upthreshold" "60"
       write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_downdifferential" "40"
       write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold" "50"
       write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential" "30"
fi

if [[ -d "/sys/modules/ged/" ]]; then
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

if [[ -d "/sys/module/pvrsrvkm/parameters/" ]]; then
    write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"
fi

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

gpu_balanced(){
	if [[ "${qcom}" == "true" ]]; then
	    avail_govs="$(cat "${gpu}devfreq/available_governors")"

	    for governor in msm-adreno-tz simple_ondemand ondemand
	    do
		  if [[ "$avail_govs" == *"$governor"* ]]
		  then
			  lock_value "${gpu}devfreq/governor" "$governor"
			  break
		    fi
	    done
	
    elif [[ "${exynos}" == "true" ]]; then
	      avail_govs="$(cat "${gpui}gpu_available_governor")"

	      for governor in Interactive Dynamic Static ondemand
	      do
		    if [[ "$avail_govs" == *"$governor"* ]]; then
			    lock_value "${gpui}gpu_governor" "$governor"
			    break
		      fi
	      done
	
	elif [[ "${mtk}" == "true" ]]; then
	      avail_govs="$(cat "${gpu}available_governors")"

	      for governor in Interactive Dynamic Static ondemand
	      do
		    if [[ "$avail_govs" == *"$governor"* ]]
		    then
			    lock_value "${gpu}governor" "$governor"
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
    write "${gpu}default_pwrlevel" "$((gpu_min_pl - 1))"
    write "${gpu}force_bus_on" "0"
    write "${gpu}force_clk_on" "0"
    write "${gpu}force_rail_on" "0"
    write "${gpu}idle_timer" "100"
    write "${gpu}pwrnap" "1"
elif [[ "${qcom}" == "false" ]]; then
      [[ "${one_ui}" == "false" ]] && write "${gpu}dvfs" "1"
       lock_value "${gpui}gpu_max_clock" "${gpu_max_freq}"
       lock_value "${gpui}gpu_min_clock" "${gpu_min}"
       write "${gpu}highspeed_clock" "${gpu_max_freq}"
       write "${gpu}highspeed_load" "86"
       write "${gpu}highspeed_delay" "0"
       write "${gpu}power_policy" "always_on"
       write "${gpui}boost" "0"
       write "${gpug}mali_touch_boost_level" "0"
       write "${gpu}max_freq" "${gpu_max_freq}"
       write "${gpu}min_freq" "${gpu_min_freq}"
       write "${gpu}devfreq/gpufreq/mali_ondemand/vsync" "1"
       write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_upthreshold" "70"
       write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_downdifferential" "45"
       write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold" "65"
       write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential" "40"
fi

if [[ -d "/sys/modules/ged/" ]]; then
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

if [[ -e "/sys/module/pvrsrvkm/parameters/" ]]; then
    write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"
fi

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

gpu_extreme(){
    if [[ "${qcom}" == "true" ]]; then
        # Fetch the available governors from the GPU
	    avail_govs="$(cat "${gpu}devfreq/available_governors")"

	    # Attempt to set the governor in this order
	    for governor in msm-adreno-tz simple_ondemand ondemand
	    do
		  # Once a matching governor is found, set it and break
		  if [[ "${avail_govs}" == *"$governor"* ]]; then
			  lock_value "${gpu}devfreq/governor" "$governor"
			break
		  fi
	  done
	
    elif [[ "${exynos}" == "true" ]]; then
	      avail_govs="$(cat "${gpui}gpu_available_governor")"

	      for governor in Booster Interactive Dynamic Static ondemand
	      do
		    if [[ "${avail_govs}" == *"$governor"* ]]; then
			    lock_value "${gpui}gpu_governor" "$governor"
			  break
		    fi
	    done
	
	elif [[ "${mtk}" == "true" ]]; then
	      avail_govs="$(cat "${gpu}available_governors")"

	      for governor in Booster Interactive Dynamic Static ondemand
	      do
		    if [[ "${avail_govs}" == *"$governor"* ]]; then
			    lock_value "${gpu}governor" "$governor"
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
    write "${gpu}default_pwrlevel" "0"
    write "${gpu}force_bus_on" "0"
    write "${gpu}force_clk_on" "1"
    write "${gpu}force_rail_on" "1"
    write "${gpu}idle_timer" "1000"
    write "${gpu}pwrnap" "1"
elif [[ "${qcom}" == "false" ]]; then
      [[ "${one_ui}" == "false" ]] && write "${gpu}dvfs" "1"
       write "${gpui}gpu_max_clock" "${gpu_max_freq}"
       write "${gpui}gpu_min_clock" "${gpu_min}"
       write "${gpu}highspeed_clock" "${gpu_max_freq}"
       write "${gpu}highspeed_load" "76"
       write "${gpu}highspeed_delay" "0"
       write "${gpu}power_policy" "always_on"
       write "${gpu}cl_boost_disable" "0"
       write "${gpui}boost" "0"
       write "${gpug}mali_touch_boost_level" "1"
       write "${gpu}max_freq" "${gpu_max_freq}"
       write "${gpu}min_freq" "${gpu_min_freq}"
       write "${gpu}devfreq/gpufreq/mali_ondemand/vsync" "0"
       write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_upthreshold" "40"
       write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_downdifferential" "20"
       write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold" "30"
       write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential" "10"
fi

if [[ -d "/sys/modules/ged/" ]]; then
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
    write "/proc/gpufreq/gpufreq_opp_freq" "$gpu_max_freq"
    write "/proc/gpufreq/gpufreq_input_boost" "1"
    write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "1"
    write "/proc/gpufreq/gpufreq_limited_oc_ignore" "0"
    write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "1"
    write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "1"
fi

if [[ -d "/proc/mali/" ]]; then
     [[ "${one_ui}" == "false" ]] && write "/proc/mali/dvfs_enable" "1"
     write "/proc/mali/always_on" "1"
fi

if [[ -e "/sys/module/pvrsrvkm/" ]]; then
    write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"
fi

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

gpu_battery(){
    if [[ "${qcom}" == "true" ]]; then
	    avail_govs="$(cat "${gpu}devfreq/available_governors")"
	    
	    for governor in msm-adreno-tz simple_ondemand ondemand
	    do
		  if [[ "${avail_govs}" == *"$governor"* ]]; then
			  lock_value "${gpu}devfreq/governor" "$governor"
		    break
		  fi
	  done
	
    elif [[ "${exynos}" == "true" ]]; then
	      avail_govs="$(cat "${gpui}gpu_available_governor")"

	      for governor in Interactive mali_ondemand ondemand Dynamic Static
	      do
		    if [[ "${avail_govs}" == *"$governor"* ]]; then
			    lock_value "${gpui}gpu_governor" "$governor"
			  break
		    fi
	    done
	
	elif [[ "${mtk}" == "true" ]]; then
	      avail_govs="$(cat "${gpu}available_governors")"

	      for governor in Interactive mali_ondemand ondemand Dynamic Static
	      do
		    if [[ "${avail_govs}" == *"$governor"* ]]; then
			    lock_value "${gpu}governor" "$governor"
			  break
	        fi
        done
      fi

if [[ "${qcom}" == "true" ]]; then
    write "${gpu}throttling" "1"
    write "${gpu}thermal_pwrlevel" "1"
    write "${gpu}devfreq/adrenoboost" "0"
    write "${gpu}force_no_nap" "0"
    write "${gpu}bus_split" "1"
    write "${gpu}devfreq/min_freq" "${gpu_min_freq}"
    write "${gpu}default_pwrlevel" "${gpu_min_pl}"
    write "${gpu}force_bus_on" "0"
    write "${gpu}force_clk_on" "0"
    write "${gpu}force_rail_on" "0"
    write "${gpu}idle_timer" "39"
    write "${gpu}pwrnap" "1"
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
       write "${gpu}min_freq" "${gpu_min_freq}"
       write "${gpu}devfreq/gpufreq/mali_ondemand/vsync" "1"
       write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_upthreshold" "85"
       write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_downdifferential" "65"
       write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold" "75"
       write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential" "55"
fi

if [[ -d "/sys/modules/ged/" ]]; then
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

if [[ -e "/sys/module/pvrsrvkm/" ]]; then
    write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"
fi

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

gpu_gaming(){
	if [[ "${qcom}" == "true" ]]; then
        # Fetch the available governors from the GPU
	    avail_govs="$(cat "${gpu}devfreq/available_governors")"

	    # Attempt to set the governor in this order
	    for governor in msm-adreno-tz simple_ondemand ondemand
	    do
		  # Once a matching governor is found, set it and break
		  if [[ "${avail_govs}" == *"$governor"* ]]
		  then
			  lock_value "${gpu}devfreq/governor" "$governor"
			break
		  fi
	  done
	
    elif [[ "${exynos}" == "true" ]]; then
	      avail_govs="$(cat "${gpui}gpu_available_governor")"

	      for governor in Booster Interactive Dynamic Static ondemand
	      do
		    if [[ "${avail_govs}" == *"$governor"* ]]; then
			    lock_value "${gpui}gpu_governor" "$governor"
			  break
		    fi
	    done
	
	elif [[ "${mtk}" == "true" ]]; then
	      avail_govs="$(cat "${gpu}available_governors")"

	      for governor in Booster Interactive Dynamic Static ondemand
	      do
		    if [[ "${avail_govs}" == *"$governor"* ]]; then
			    lock_value "${gpu}governor" "$governor"
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
    lock_value "${gpu}devfreq/max_freq" "${gpu_max_freq}"
    lock_value "${gpu}devfreq/min_freq" "${gpu_max}"
    write "${gpu}default_pwrlevel" "${gpu_max_pl}"
    write "${gpu}force_bus_on" "1"
    write "${gpu}force_clk_on" "1"
    write "${gpu}force_rail_on" "1"
    write "${gpu}idle_timer" "1000000"
    write "${gpu}pwrnap" "0"
elif [[ "${qcom}" == "false" ]]; then
      [[ "${one_ui}" == "false" ]] && write "${gpu}dvfs" "0"
       lock_value "${gpui}gpu_max_clock" "${gpu_max_freq}"
       lock_value "${gpui}gpu_min_clock" "${gpu_max2}"
       write "${gpu}highspeed_clock" "${gpu_max_freq}"
       write "${gpu}highspeed_load" "76"
       write "${gpu}highspeed_delay" "0"
       write "${gpu}power_policy" "always_on"
       write "${gpu}cl_boost_disable" "0"
       write "${gpui}boost" "1"
       write "${gpug}mali_touch_boost_level" "1"
       lock_value "${gpu}devfreq/gpufreq/max_freq" "${gpu_max_freq}"
       lock_value "${gpu}devfreq/gpufreq/min_freq" "${gpu_max_freq}"
       write "${gpu}devfreq/gpufreq/mali_ondemand/vsync" "0"
       write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_upthreshold" "35"
       write "${gpu}devfreq/gpufreq/mali_ondemand/vsync_downdifferential" "15"
       write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold" "25"
       write "${gpu}devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential" "10"
fi

if [[ -d "/sys/modules/ged/" ]]; then
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
    write "/sys/module/ged/parameters/gpu_dvfs_enable" "0"
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
    write "/proc/gpufreq/gpufreq_opp_stress_test" "1"
    write "/proc/gpufreq/gpufreq_opp_freq" "${gpu_max2}"
    write "/proc/gpufreq/gpufreq_input_boost" "1"
    write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "1"
    write "/proc/gpufreq/gpufreq_limited_oc_ignore" "1"
    write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "1"
    write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "1"
fi

if [[ -d "/proc/mali/" ]]; then
     [[ "${one_ui}" == "false" ]] && write "/proc/mali/dvfs_enable" "0"
     write "/proc/mali/always_on" "1"
fi

if [[ -e "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" ]]; then
    write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "0"
fi

if [[ -e "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" ]]; then
    write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "0"
    kmsg "Disabled SGPU algorithm"
    kmsg3 ""
fi

if [[ -d "/sys/module/adreno_idler" ]]; then
    write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
    kmsg "Disabled adreno idler"
    kmsg3 ""
fi

kmsg "Tweaked GPU parameters"
kmsg3 ""
}

disable_crypto_tests(){
if [[ -e "/sys/module/cryptomgr/parameters/notests" ]]; then
    write "/sys/module/cryptomgr/parameters/notests" "Y"
    kmsg "Disabled cryptography tests"
    kmsg3 ""
fi
}

disable_spd_freqs(){
if [[ -e "/sys/module/exynos_acme/parameters/enable_suspend_freqs" ]]; then
    write "/sys/module/exynos_acme/parameters/enable_suspend_freqs" "N"
    kmsg "Disabled suspend frequencies"
    kmsg3 ""
fi
}

config_pwr_spd(){
if [[ -e "/sys/kernel/power_suspend/power_suspend_mode" ]]; then
    write "/sys/kernel/power_suspend/power_suspend_mode" "3"
    kmsg "Tweaked power suspend mode"
    kmsg3 ""
fi
}

schedtune_latency(){
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

schedtune_balanced(){
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
    
    write "${stune}top-app/schedtune.boost" "5"
    write "${stune}top-app/schedtune.prefer_idle" "1"
    write "${stune}top-app/schedtune.sched_boost" "0"
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

schedtune_extreme(){
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

schedtune_battery(){
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
    
    write "${stune}top-app/schedtune.boost" "1"
    write "${stune}top-app/schedtune.prefer_idle" "1"
    write "${stune}top-app/schedtune.sched_boost" "0"
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

schedtune_gaming(){
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

uclamp_latency(){
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

uclamp_balanced(){
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

uclamp_extreme(){
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

uclamp_battery(){
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

uclamp_gaming(){
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

config_blkio(){
# Block tweaks
if [[ -d "${blkio}" ]]; then
    write "${blkio}blkio.weight" "1000"
    write "${blkio}background/blkio.weight" "200"
    write "${blkio}blkio.group_idle" "2000"
    write "${blkio}background/blkio.group_idle" "0"
    kmsg "Tweaked blkio"
    kmsg3 ""
fi
}

config_fs(){
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

config_dyn_fsync(){
if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]; then
    write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
    kmsg "Enabled dynamic fsync"
    kmsg3 ""
fi
}

sched_ft_latency(){
# Scheduler features
if [[ -e "/sys/kernel/debug/sched_features" ]]; then
    write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
    write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
    kmsg "Tweaked scheduler features"
    kmsg3 ""
fi
}

sched_ft_balanced(){
if [[ -e "/sys/kernel/debug/sched_features" ]]; then
    write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
    write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
    kmsg "Tweaked scheduler features"
    kmsg3 ""
fi
}

sched_ft_extreme(){
if [[ -e "/sys/kernel/debug/sched_features" ]]; then
    write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
    write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
    kmsg "Tweaked scheduler features"
    kmsg3 ""
fi
}

sched_ft_battery(){
if [[ -e "/sys/kernel/debug/sched_features" ]]; then
    write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
    write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
    kmsg "Tweaked scheduler features"
    kmsg3 ""
fi
}

sched_ft_gaming(){
if [[ -e "/sys/kernel/debug/sched_features" ]]; then
    write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
    write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
    kmsg "Tweaked scheduler features"
    kmsg3 ""
fi
}

disable_crc(){
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

sched_latency(){
# Tweak kernel settings to improve overall performance
if [[ -e "${kernel}sched_child_runs_first" ]]; then
    write "${kernel}sched_child_runs_first" "1"
fi
if [[ -e "${kernel}perf_cpu_time_max_percent" ]]; then
    write "${kernel}perf_cpu_time_max_percent" "4"
fi
if [[ -e "${kernel}sched_autogroup_enabled" ]]; then
    write "${kernel}sched_autogroup_enabled" "1"
fi
if [[ -e "/sys/devices/soc/${bt_dvc}/clkscale_enable" ]]; then
    write "/sys/devices/soc/${bt_dvc}/clkscale_enable" "1"
fi
if [[ -e "/sys/devices/soc/${bt_dvc}/clkgate_enable" ]]; then
    write "/sys/devices/soc/${bt_dvc}/clkgate_enable" "1"
fi
lock_value "${kernel}sched_tunable_scaling" "0"
if [[ -e "${kernel}sched_latency_ns" ]]; then
    write "${kernel}sched_latency_ns" "200000"
fi
if [[ -e "${kernel}sched_min_granularity_ns" ]]; then
    write "${kernel}sched_min_granularity_ns" "1250000"
fi
if [[ -e "${kernel}sched_wakeup_granularity_ns" ]]; then
    write "${kernel}sched_wakeup_granularity_ns" "2000000"
fi
if [[ -e "${kernel}sched_migration_cost_ns" ]]; then
    write "${kernel}sched_migration_cost_ns" "200000"
fi
if [[ -e "${kernel}sched_min_task_util_for_colocation" ]]; then
    write "${kernel}sched_min_task_util_for_colocation" "0"
fi
if [[ -e "${kernel}sched_min_task_util_for_boost" ]]; then
    write "${kernel}sched_min_task_util_for_boost" "0"
fi
write "${kernel}sched_nr_migrate" "4"
write "${kernel}sched_schedstats" "0"
if [[ -e "${kernel}sched_cstate_aware" ]]; then
    write "${kernel}sched_cstate_aware" "1"
fi
write "${kernel}printk_devkmsg" "off"
if [[ -e "${kernel}timer_migration" ]]; then
    write "${kernel}timer_migration" "0"
fi
if [[ -e "/sys/devices/system/cpu/eas/enable" ]]; then
    write "/sys/devices/system/cpu/eas/enable" "1"
fi
if [[ -e "${kernel}sched_walt_rotate_big_tasks" ]]; then
    write "${kernel}sched_walt_rotate_big_tasks" "1"
fi
if [[ -e "${kernel}sched_prefer_sync_wakee_to_waker" ]]; then
    write "${kernel}sched_prefer_sync_wakee_to_waker" "1"
fi
if [[ -e "${kernel}sched_boost_top_app" ]]; then
    write "${kernel}sched_boost_top_app" "1"
fi
if [[ -e "${kernel}sched_init_task_load" ]]; then
    write "${kernel}sched_init_task_load" "25"
fi
if [[ -e "${kernel}sched_migration_fixup" ]]; then
    lock_value "${kernel}sched_migration_fixup" "0"
fi
if [[ -e "${kernel}sched_energy_aware" ]]; then
    write "${kernel}sched_energy_aware" "1"
fi
if [[ -e "${kernel}hung_task_timeout_secs" ]]; then
    write "${kernel}hung_task_timeout_secs" "0"
fi
# We do not need it on android, and also is disabled by default on redhat for security purposes
if [[ -e "${kernel}sysrq" ]]; then
    write "${kernel}sysrq" "0"
fi
# Set memory sleep mode to s2idle 
if [[ -e "/sys/power/mem_sleep" ]]; then
    write "/sys/power/mem_sleep" "s2idle"
fi
if [[ -e "${kernel}sched_conservative_pl" ]]; then
    write "${kernel}sched_conservative_pl" "0"
fi
if [[ -e "/sys/devices/system/cpu/sched/sched_boost" ]]; then
    write "/sys/devices/system/cpu/sched/sched_boost" "0"
fi
if [[ -e "/sys/kernel/ems/eff_mode" ]]; then
    lock_value "/sys/kernel/ems/eff_mode" "0"
fi
if [[ -e "/sys/module/opchain/parameters/chain_on" ]]; then
    lock_value "/sys/module/opchain/parameters/chain_on" "0"
fi
if [[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]]; then
    lock_value "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
fi
if [[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]]; then
    lock_value "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
fi
if [[ -e "${kernel}sched_is_big_little" ]] && [[ "${big_little}" == "true" ]]; then
    write "${kernel}sched_is_big_little" "1" 
elif [[ -e "${kernel}sched_is_big_little" ]]; then
      write "${kernel}sched_is_big_little" "0"
fi
if [[ -e "${kernel}sched_sync_hint_enable" ]] && [[ "${big_little}" == "true" ]]; then
    write "${kernel}sched_sync_hint_enable" "0"
elif [[ -e "${kernel}sched_sync_hint_enable" ]]; then
      write "${kernel}sched_sync_hint_enable" "1"
fi
if [[ -e "${kernel}sched_initial_task_util" ]]; then
    write "${kernel}sched_initial_task_util" "0"
fi
# Disable ram-boost relying memplus prefetcher, use traditional swapping
if [[ -d "/sys/module/memplus_core/" ]]; then
    lock_value "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
fi
for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
    lock_value "${bcl_md}" "0"
done
write "/proc/sys/dev/tty/ldisc_autoload" "0"

kmsg "Tweaked various kernel parameters"
kmsg3 ""
}

sched_balanced(){
if [[ -e "${kernel}sched_child_runs_first" ]]; then
    write "${kernel}sched_child_runs_first" "1"
fi
if [[ -e "${kernel}perf_cpu_time_max_percent" ]]; then
    write "${kernel}perf_cpu_time_max_percent" "6"
fi
if [[ -e "${kernel}sched_autogroup_enabled" ]]; then
    write "${kernel}sched_autogroup_enabled" "1"
fi
if [[ -e "/sys/devices/soc/${bt_dvc}/clkscale_enable" ]]; then
    write "/sys/devices/soc/${bt_dvc}/clkscale_enable" "1"
fi
if [[ -e "/sys/devices/soc/${bt_dvc}/clkgate_enable" ]]; then
    write "/sys/devices/soc/${bt_dvc}/clkgate_enable" "1"
fi
lock_value "${kernel}sched_tunable_scaling" "0"
if [[ -e "${kernel}sched_latency_ns" ]]; then
    write "${kernel}sched_latency_ns" "${SCHED_PERIOD_BALANCE}"
fi
if [[ -e "${kernel}sched_min_granularity_ns" ]]; then
    write "${kernel}sched_min_granularity_ns" "$((SCHED_PERIOD_BALANCE / SCHED_TASKS_BALANCE))"
fi
if [[ -e "${kernel}sched_wakeup_granularity_ns" ]]; then
    write "${kernel}sched_wakeup_granularity_ns" "$((SCHED_PERIOD_BALANCE / 2))"
fi
if [[ -e "${kernel}sched_migration_cost_ns" ]]; then
    write "${kernel}sched_migration_cost_ns" "200000"
fi
if [[ -e "${kernel}sched_min_task_util_for_colocation" ]]; then
    write "${kernel}sched_min_task_util_for_colocation" "0"
fi
if [[ -e "${kernel}sched_min_task_util_for_boost" ]]; then
    write "${kernel}sched_min_task_util_for_boost" "0"
fi
write "${kernel}sched_nr_migrate" "32"
write "${kernel}sched_schedstats" "0"
if [[ -e "${kernel}sched_cstate_aware" ]]; then
    write "${kernel}sched_cstate_aware" "1"
fi
write "${kernel}printk_devkmsg" "off"
if [[ -e "${kernel}timer_migration" ]]; then
    write "${kernel}timer_migration" "0"
fi
if [[ -e "${kernel}sched_boost" ]]; then
    write "${kernel}sched_boost" "0"
fi
if [[ -e "/sys/devices/system/cpu/eas/enable" ]]; then
    write "/sys/devices/system/cpu/eas/enable" "1"
fi
if [[ -e "${kernel}sched_walt_rotate_big_tasks" ]]; then
    write "${kernel}sched_walt_rotate_big_tasks" "1"
fi
if [[ -e "${kernel}sched_prefer_sync_wakee_to_waker" ]]; then
    write "${kernel}sched_prefer_sync_wakee_to_waker" "1"
fi
if [[ -e "${kernel}sched_boost_top_app" ]]; then
    write "${kernel}sched_boost_top_app" "1"
fi
if [[ -e "${kernel}sched_init_task_load" ]]; then
    write "${kernel}sched_init_task_load" "20"
fi
if [[ -e "${kernel}sched_migration_fixup" ]]; then
    lock_value "${kernel}sched_migration_fixup" "0"
fi
if [[ -e "${kernel}sched_energy_aware" ]]; then
    write "${kernel}sched_energy_aware" "1"
fi
if [[ -e "${kernel}hung_task_timeout_secs" ]]; then
    write "${kernel}hung_task_timeout_secs" "0"
fi
if [[ -e "${kernel}sysrq" ]]; then
    write "${kernel}sysrq" "0"
fi
# Set memory sleep mode to deep
if [[ -e "/sys/power/mem_sleep" ]]; then
    write "/sys/power/mem_sleep" "s2idle"
fi
if [[ -e "${kernel}sched_conservative_pl" ]]; then
    write "${kernel}sched_conservative_pl" "0"
fi
if [[ -e "/sys/devices/system/cpu/sched/sched_boost" ]]; then
    write "/sys/devices/system/cpu/sched/sched_boost" "0"
fi
if [[ -e "/sys/kernel/ems/eff_mode" ]]; then
    lock_value "/sys/kernel/ems/eff_mode" "0"
fi
if [[ -e "/sys/module/opchain/parameters/chain_on" ]]; then
    lock_value "/sys/module/opchain/parameters/chain_on" "0"
fi
if [[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]]; then
    lock_value "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
fi
if [[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]]; then
    lock_value "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
fi
if [[ -e "${kernel}sched_is_big_little" ]] && [[ "${big_little}" == "true" ]]; then
    write "${kernel}sched_is_big_little" "1" 
elif [[ -e "${kernel}sched_is_big_little" ]]; then
      write "${kernel}sched_is_big_little" "0"
fi
if [[ -e "${kernel}sched_sync_hint_enable" ]] && [[ "${big_little}" == "true" ]]; then
    write "${kernel}sched_sync_hint_enable" "0"
elif [[ -e "${kernel}sched_sync_hint_enable" ]]; then
      write "${kernel}sched_sync_hint_enable" "1"
fi
if [[ -e "${kernel}sched_initial_task_util" ]]; then
    write "${kernel}sched_initial_task_util" "0"
fi
if [[ -d "/sys/module/memplus_core/" ]]; then
    write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
fi
for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
    lock_value "${bcl_md}" "0"
done
write "/proc/sys/dev/tty/ldisc_autoload" "0"

kmsg "Tweaked various kernel parameters"
kmsg3 ""
}

sched_extreme(){
if [[ -e "${kernel}sched_child_runs_first" ]]; then
    write "${kernel}sched_child_runs_first" "0"
fi
if [[ -e "${kernel}perf_cpu_time_max_percent" ]]; then
    write "${kernel}perf_cpu_time_max_percent" "25"
fi
if [[ -e "${kernel}sched_autogroup_enabled" ]]; then
    write "${kernel}sched_autogroup_enabled" "0"
fi
if [[ -e "/sys/devices/soc/${bt_dvc}/clkscale_enable" ]]; then
    write "/sys/devices/soc/${bt_dvc}/clkscale_enable" "0"
fi
if [[ -e "/sys/devices/soc/${bt_dvc}/clkgate_enable" ]]; then
    write "/sys/devices/soc/${bt_dvc}/clkgate_enable" "0"
fi
lock_value "${kernel}sched_tunable_scaling" "0"
if [[ -e "${kernel}sched_latency_ns" ]]; then
    write "${kernel}sched_latency_ns" "${SCHED_PERIOD_THROUGHPUT}"
fi
if [[ -e "${kernel}sched_min_granularity_ns" ]]; then
    write "${kernel}sched_min_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / SCHED_TASKS_THROUGHPUT))"
fi
if [[ -e "${kernel}sched_wakeup_granularity_ns" ]]; then
    write "${kernel}sched_wakeup_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / 2))"
fi
if [[ -e "${kernel}sched_migration_cost_ns" ]]; then
    write "${kernel}sched_migration_cost_ns" "0"
fi
if [[ -e "${kernel}sched_min_task_util_for_colocation" ]]; then
    write "${kernel}sched_min_task_util_for_colocation" "0"
fi
if [[ -e "${kernel}sched_min_task_util_for_boost" ]]; then
    write "${kernel}sched_min_task_util_for_boost" "0"
fi
write "${kernel}sched_nr_migrate" "128"
write "${kernel}sched_schedstats" "0"
if [[ -e "${kernel}sched_cstate_aware" ]]; then
    write "${kernel}sched_cstate_aware" "1"
fi
write "${kernel}printk_devkmsg" "off"
if [[ -e "${kernel}timer_migration" ]]; then
    write "${kernel}timer_migration" "0"
fi
if [[ -e "${kernel}sched_boost" ]]; then
    lock_value "${kernel}sched_boost" "1"
fi
if [[ -e "/sys/devices/system/cpu/eas/enable" ]] && [[ "${mtk}" == "true" ]]; then
    write "/sys/devices/system/cpu/eas/enable" "2"
else
    write "/sys/devices/system/cpu/eas/enable" "1"
fi
if [[ -e "${kernel}sched_walt_rotate_big_tasks" ]]; then
    write "${kernel}sched_walt_rotate_big_tasks" "1"
fi
if [[ -e "${kernel}sched_prefer_sync_wakee_to_waker" ]]; then
    write "${kernel}sched_prefer_sync_wakee_to_waker" "1"
fi
if [[ -e "${kernel}sched_boost_top_app" ]]; then
    write "${kernel}sched_boost_top_app" "1"
fi
if [[ -e "${kernel}sched_init_task_load" ]]; then
    write "${kernel}sched_init_task_load" "30"
fi
if [[ -e "${kernel}sched_migration_fixup" ]]; then
    lock_value "${kernel}sched_migration_fixup" "0"
fi
if [[ -e "${kernel}sched_energy_aware" ]]; then
    write "${kernel}sched_energy_aware" "1"
fi
if [[ -e "${kernel}hung_task_timeout_secs" ]]; then
    write "${kernel}hung_task_timeout_secs" "0"
fi
if [[ -e "${kernel}sysrq" ]]; then
    write "${kernel}sysrq" "0"
fi
if [[ -e "/sys/power/mem_sleep" ]]; then
    write "/sys/power/mem_sleep" "s2idle"
fi
if [[ -e "${kernel}sched_conservative_pl" ]]; then
    write "${kernel}sched_conservative_pl" "0"
fi
if [[ -e "/sys/devices/system/cpu/sched/sched_boost" ]]; then
    lock_value "/sys/devices/system/cpu/sched/sched_boost" "1"
fi
if [[ -e "/sys/kernel/ems/eff_mode" ]]; then
    lock_value "/sys/kernel/ems/eff_mode" "0"
fi
if [[ -e "/sys/module/opchain/parameters/chain_on" ]]; then
    lock_value "/sys/module/opchain/parameters/chain_on" "0"
fi
if [[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]]; then
    lock_value "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
fi
if [[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]]; then
    lock_value "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
fi
if [[ -e "${kernel}sched_is_big_little" ]] && [[ "${big_little}" == "true" ]]; then
    write "${kernel}sched_is_big_little" "1" 
elif [[ -e "${kernel}sched_is_big_little" ]]; then
      write "${kernel}sched_is_big_little" "0"
fi
if [[ -e "${kernel}sched_sync_hint_enable" ]] && [[ "${big_little}" == "true" ]]; then
    write "${kernel}sched_sync_hint_enable" "0"
elif [[ -e "${kernel}sched_sync_hint_enable" ]]; then
      write "${kernel}sched_sync_hint_enable" "1"
fi
if [[ -e "${kernel}sched_initial_task_util" ]]; then
    write "${kernel}sched_initial_task_util" "0"
fi
if [[ -d "/sys/module/memplus_core/" ]]; then
    write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
fi
for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
    lock_value "${bcl_md}" "0"
done
write "/proc/sys/dev/tty/ldisc_autoload" "0"

kmsg "Tweaked various kernel parameters"
kmsg3 ""
}

sched_battery(){
if [[ -e "${kernel}sched_child_runs_first" ]]; then
    write "${kernel}sched_child_runs_first" "0"
fi
if [[ -e "${kernel}perf_cpu_time_max_percent" ]]; then
    write "${kernel}perf_cpu_time_max_percent" "3"
fi
if [[ -e "${kernel}sched_autogroup_enabled" ]]; then
    write "${kernel}sched_autogroup_enabled" "1"
fi
if [[ -e "/sys/devices/soc/${bt_dvc}/clkscale_enable" ]]; then
    write "/sys/devices/soc/${bt_dvc}/clkscale_enable" "1"
fi
if [[ -e "/sys/devices/soc/${bt_dvc}/clkgate_enable" ]]; then
    write "/sys/devices/soc/${bt_dvc}/clkgate_enable" "1"
fi
lock_value "${kernel}sched_tunable_scaling" "0"
if [[ -e "${kernel}sched_latency_ns" ]]; then
    write "${kernel}sched_latency_ns" "${SCHED_PERIOD_BATTERY}"
fi
if [[ -e "${kernel}sched_min_granularity_ns" ]]; then
    write "${kernel}sched_min_granularity_ns" "$((SCHED_PERIOD_BATTERY / SCHED_TASKS_BATTERY))"
fi
if [[ -e "${kernel}sched_wakeup_granularity_ns" ]]; then
    write "${kernel}sched_wakeup_granularity_ns" "$((SCHED_PERIOD_BATTERY / 2))"
fi
if [[ -e "${kernel}sched_migration_cost_ns" ]]; then
    write "${kernel}sched_migration_cost_ns" "200000"
fi
if [[ -e "${kernel}sched_min_task_util_for_colocation" ]]; then
    write "${kernel}sched_min_task_util_for_colocation" "0"
fi
if [[ -e "${kernel}sched_min_task_util_for_boost" ]]; then
    write "${kernel}sched_min_task_util_for_boost" "0"
fi
write "${kernel}sched_nr_migrate" "192"
write "${kernel}sched_schedstats" "0"
if [[ -e "${kernel}sched_cstate_aware" ]]; then
    write "${kernel}sched_cstate_aware" "1"
fi
write "${kernel}printk_devkmsg" "off"
if [[ -e "${kernel}timer_migration" ]]; then
    write "${kernel}timer_migration" "1"
fi
if [[ -e "${kernel}sched_boost" ]]; then
    write "${kernel}sched_boost" "0"
fi
if [[ -e "/sys/devices/system/cpu/eas/enable" ]]; then
    write "/sys/devices/system/cpu/eas/enable" "1"
fi
if [[ -e "${kernel}sched_walt_rotate_big_tasks" ]]; then
    write "${kernel}sched_walt_rotate_big_tasks" "1"
fi
if [[ -e "${kernel}sched_prefer_sync_wakee_to_waker" ]]; then
    write "${kernel}sched_prefer_sync_wakee_to_waker" "1"
fi
if [[ -e "${kernel}sched_boost_top_app" ]]; then
    write "${kernel}sched_boost_top_app" "1"
fi
if [[ -e "${kernel}sched_init_task_load" ]]; then
    write "${kernel}sched_init_task_load" "15"
fi
if [[ -e "${kernel}sched_migration_fixup" ]]; then
    lock_value "${kernel}sched_migration_fixup" "0"
fi
if [[ -e "${kernel}sched_energy_aware" ]]; then
    write "${kernel}sched_energy_aware" "1"
fi
if [[ -e "${kernel}hung_task_timeout_secs" ]]; then
    write "${kernel}hung_task_timeout_secs" "0"
fi
if [[ -e "${kernel}sysrq" ]]; then
    write "${kernel}sysrq" "0"
fi
if [[ -e "/sys/power/mem_sleep" ]]; then
    write "/sys/power/mem_sleep" "deep"
fi
if [[ -e "${kernel}sched_conservative_pl" ]]; then
    write "${kernel}sched_conservative_pl" "1"
fi
if [[ -e "/sys/devices/system/cpu/sched/sched_boost" ]]; then
    write "/sys/devices/system/cpu/sched/sched_boost" "0"
fi
if [[ -e "/sys/kernel/ems/eff_mode" ]]; then
    lock_value "/sys/kernel/ems/eff_mode" "0"
fi
if [[ -e "/sys/module/opchain/parameters/chain_on" ]]; then
    lock_value "/sys/module/opchain/parameters/chain_on" "0"
fi
if [[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]]; then
    lock_value "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
fi
if [[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]]; then
    lock_value "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
fi
if [[ -e "${kernel}sched_is_big_little" ]] && [[ "${big_little}" == "true" ]]; then
    write "${kernel}sched_is_big_little" "1" 
elif [[ -e "${kernel}sched_is_big_little" ]]; then
      write "${kernel}sched_is_big_little" "0"
fi
if [[ -e "${kernel}sched_sync_hint_enable" ]] && [[ "${big_little}" == "true" ]]; then
    write "${kernel}sched_sync_hint_enable" "0"
elif [[ -e "${kernel}sched_sync_hint_enable" ]]; then
      write "${kernel}sched_sync_hint_enable" "1"
fi
if [[ -e "${kernel}sched_initial_task_util" ]]; then
    write "${kernel}sched_initial_task_util" "0"
fi
if [[ -d "/sys/module/memplus_core/" ]]; then
    write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
fi
for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
    lock_value "${bcl_md}" "0"
done
write "/proc/sys/dev/tty/ldisc_autoload" "0"

kmsg "Tweaked various kernel parameters"
kmsg3 ""
}

sched_gaming(){
if [[ -e "${kernel}sched_child_runs_first" ]]; then
    write "${kernel}sched_child_runs_first" "0"
fi
if [[ -e "${kernel}perf_cpu_time_max_percent" ]]; then
    write "${kernel}perf_cpu_time_max_percent" "25"
fi
if [[ -e "${kernel}sched_autogroup_enabled" ]]; then
    write "${kernel}sched_autogroup_enabled" "0"
fi
if [[ -e "/sys/devices/soc/${bt_dvc}/clkscale_enable" ]]; then
    write "/sys/devices/soc/${bt_dvc}/clkscale_enable" "0"
fi
if [[ -e "/sys/devices/soc/${bt_dvc}/clkgate_enable" ]]; then
    write "/sys/devices/soc/${bt_dvc}/clkgate_enable" "0"
fi
lock_value "${kernel}sched_tunable_scaling" "0"
if [[ -e "${kernel}sched_latency_ns" ]]; then
    write "${kernel}sched_latency_ns" "${SCHED_PERIOD_THROUGHPUT}"
fi
if [[ -e "${kernel}sched_min_granularity_ns" ]]; then
    write "${kernel}sched_min_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / SCHED_TASKS_THROUGHPUT))"
fi
if [[ -e "${kernel}sched_wakeup_granularity_ns" ]]; then
    write "${kernel}sched_wakeup_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / 2))"
fi
if [[ -e "${kernel}sched_migration_cost_ns" ]]; then
    write "${kernel}sched_migration_cost_ns" "0"
fi
if [[ -e "${kernel}sched_min_task_util_for_colocation" ]]; then
    write "${kernel}sched_min_task_util_for_colocation" "0"
fi
if [[ -e "${kernel}sched_min_task_util_for_boost" ]]; then
    write "${kernel}sched_min_task_util_for_boost" "0"
fi
write "${kernel}sched_nr_migrate" "128"
write "${kernel}sched_schedstats" "0"
if [[ -e "${kernel}sched_cstate_aware" ]]; then
    write "${kernel}sched_cstate_aware" "1"
fi
write "${kernel}printk_devkmsg" "off"
if [[ -e "${kernel}timer_migration" ]]; then
    write "${kernel}timer_migration" "0"
fi
if [[ -e "${kernel}sched_boost" ]]; then
    lock_value "${kernel}sched_boost" "1"
fi
if [[ -e "/sys/devices/system/cpu/eas/enable" ]] && [[ "${mtk}" == "true" ]]; then
    write "/sys/devices/system/cpu/eas/enable" "2"
else
    write "/sys/devices/system/cpu/eas/enable" "1"
fi
if [[ -e "${kernel}sched_walt_rotate_big_tasks" ]]; then
    write "${kernel}sched_walt_rotate_big_tasks" "1"
fi
if [[ -e "${kernel}sched_prefer_sync_wakee_to_waker" ]]; then
    write "${kernel}sched_prefer_sync_wakee_to_waker" "1"
fi
if [[ -e "${kernel}sched_boost_top_app" ]]; then
    write "${kernel}sched_boost_top_app" "1"
fi
if [[ -e "${kernel}sched_init_task_load" ]]; then
    write "${kernel}sched_init_task_load" "30"
fi
if [[ -e "${kernel}sched_migration_fixup" ]]; then
    lock_value "${kernel}sched_migration_fixup" "0"
fi
if [[ -e "${kernel}sched_energy_aware" ]]; then
    write "${kernel}sched_energy_aware" "1"
fi
if [[ -e "${kernel}hung_task_timeout_secs" ]]; then
    write "${kernel}hung_task_timeout_secs" "0"
fi
if [[ -e "${kernel}sysrq" ]]; then
    write "${kernel}sysrq" "0"
fi
if [[ -e "/sys/power/mem_sleep" ]]; then
    write "/sys/power/mem_sleep" "s2idle"
fi
if [[ -e "${kernel}sched_conservative_pl" ]]; then
    write "${kernel}sched_conservative_pl" "0"
fi
if [[ -e "/sys/devices/system/cpu/sched/sched_boost" ]]; then
    lock_value "/sys/devices/system/cpu/sched/sched_boost" "1"
fi
if [[ -e "/sys/kernel/ems/eff_mode" ]]; then
    lock_value "/sys/kernel/ems/eff_mode" "0"
fi
if [[ -e "/sys/module/opchain/parameters/chain_on" ]]; then
    lock_value "/sys/module/opchain/parameters/chain_on" "0"
fi
if [[ -e "/sys/module/mt_hotplug_mechanism/parameters/g_enable" ]]; then
    lock_value "/sys/module/mt_hotplug_mechanism/parameters/g_enable" "0"
fi
if [[ -e "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" ]]; then
    lock_value "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1"
fi
if [[ -e "${kernel}sched_is_big_little" ]] && [[ "${big_little}" == "true" ]]; then
    write "${kernel}sched_is_big_little" "1" 
elif [[ -e "${kernel}sched_is_big_little" ]]; then
      write "${kernel}sched_is_big_little" "0"
fi
if [[ -e "${kernel}sched_sync_hint_enable" ]] && [[ "${big_little}" == "true" ]]; then
    write "${kernel}sched_sync_hint_enable" "0"
elif [[ -e "${kernel}sched_sync_hint_enable" ]]; then
      write "${kernel}sched_sync_hint_enable" "1"
fi
if [[ -e "${kernel}sched_initial_task_util" ]]; then
    write "${kernel}sched_initial_task_util" "0"
fi
if [[ -d "/sys/module/memplus_core/" ]]; then
    write "/sys/module/memplus_core/parameters/memory_plus_enabled" "0"
fi
for bcl_md in /sys/devices/soc*/qcom,bcl.*/mode; do
    lock_value "${bcl_md}" "0"
done
write "/proc/sys/dev/tty/ldisc_autoload" "0"

kmsg "Tweaked various kernel parameters"
kmsg3 ""
}

enable_kvb(){
if [[ -e "/sys/module/acpuclock_krait/parameters/boost" ]]; then
    write "/sys/module/acpuclock_krait/parameters/boost" "Y"
    kmsg "Enabled krait voltage boost"
    kmsg3 ""
fi
}

disable_kvb(){
if [[ -e "/sys/module/acpuclock_krait/parameters/boost" ]]; then
    write "/sys/module/acpuclock_krait/parameters/boost" "N"
    kmsg "Disabled krait voltage boost"
    kmsg3 ""
fi
}

enable_fp_boost(){
if [[ -e "/sys/kernel/fp_boost/enabled" ]]; then
    write "/sys/kernel/fp_boost/enabled" "1"
    kmsg "Enabled fingerprint boost"
    kmsg3 ""
fi
}

# Credits to helloklf again
ufs_default(){
if [[ -d "/sys/class/devfreq/1d84000.ufshc/" ]]; then
    write "/sys/class/devfreq/1d84000.ufshc/max_freq" "300000000"
    kmsg "Tweaked UFS"
    kmsg3 ""
fi
}

ufs_pwr_saving(){
if [[ -d "/sys/class/devfreq/1d84000.ufshc/" ]]; then
    lock_value "/sys/class/devfreq/1d84000.ufshc/max_freq" "75000000"
    kmsg "Tweaked UFS"
    kmsg3 ""
fi
}

ppm_policy_default(){
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

ppm_policy_max(){
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

cpu_clk_default(){
# Set min and max clocks
for cpus in /sys/devices/system/cpu/cpufreq/policy*/
do
  if [[ -e "${cpus}scaling_min_freq" ]]; then
      write "${cpus}scaling_min_freq" "$cpu_min_freq"
      write "${cpus}scaling_max_freq" "$cpu_max_freq"
      write "${cpus}user_scaling_min_freq" "$cpu_min_freq"
      write "${cpus}user_scaling_min_freq" "$cpu_max_freq"
  fi
done

for cpus in /sys/devices/system/cpu/cpu*/cpufreq/
do
  if [[ -e "${cpus}scaling_min_freq" ]]; then
      write "${cpus}scaling_min_freq" "$cpu_min_freq"
      write "${cpus}scaling_max_freq" "$cpu_max_freq"
      write "${cpus}user_scaling_min_freq" "$cpu_min_freq"
      write "${cpus}user_scaling_max_freq" "$cpu_max_freq"
  fi
done

kmsg "Tweaked CPU clocks"
kmsg3 ""

if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]]; then
    write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "1"
    kmsg "Allowed CPUs to use it's deepest sleep state"
    kmsg3 ""
fi
}

cpu_clk_max(){
# Set min and max clocks
for cpus in /sys/devices/system/cpu/cpufreq/policy*/
do
  if [[ -e "${cpus}scaling_min_freq" ]]; then
      lock_value "${cpus}scaling_min_freq" "$cpu_max_freq"
      lock_value "${cpus}scaling_max_freq" "$cpu_max_freq"
      lock_value "${cpus}user_scaling_min_freq" "$cpu_max_freq"
      lock_value "${cpus}user_scaling_max_freq" "$cpu_max_freq"
  fi
done

for cpus in /sys/devices/system/cpu/cpu*/cpufreq/
do
  if [[ -e "${cpus}scaling_min_freq" ]]; then
      lock_value "${cpus}scaling_min_freq" "$cpu_max_freq"
      lock_value "${cpus}scaling_max_freq" "$cpu_max_freq"
      lock_value "${cpus}user_scaling_min_freq" "$cpu_max_freq"
      lock_value "${cpus}user_scaling_max_freq" "$cpu_max_freq"
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

vm_lmk_latency(){
# Credits to Paget96 for this also
fr=$(((total_ram * 2 / 100) * 1024 / 4))
bg=$(((total_ram * 3 / 100) * 1024 / 4))
et=$(((total_ram * 4 / 100) * 1024 / 4))
mr=$(((total_ram * 6 / 100) * 1024 / 4))
cd=$(((total_ram * 7 / 100) * 1024 / 4))
ab=$(((total_ram * 9 / 100) * 1024 / 4))

efr=$((mfr * 16 / 5))

mfr=$((total_ram * 6 / 5))

if [[ "${efr}" -le "18432" ]]; then
    efr=18432
fi

if [[ "${mfr}" -le "3072" ]]; then
    mfr=3072
fi

# always sync before dropping caches
sync

# VM settings to improve overall user experience and performance
write "${vm}drop_caches" "3"
write "${vm}dirty_background_ratio" "10"
write "${vm}dirty_ratio" "25"
write "${vm}dirty_expire_centisecs" "4500"
write "${vm}dirty_writeback_centisecs" "5000"
write "${vm}page-cluster" "0"
write "${vm}stat_interval" "60"
write "${vm}extfrag_threshold" "750"
# Use SSWAP on samsung devices if it do not have more than 4 GB RAM
if [[ "${samsung}" == "true" ]] && [[ "${total_ram}" -lt "4096" ]]; then
    lock_value "${vm}swappiness" "150"
else
    lock_value "${vm}swappiness" "100"
fi
write "${vm}laptop_mode" "0"
write "${vm}vfs_cache_pressure" "200"
lock_value "${vm}watermark_scale_factor" "30"
if [[ -e "/sys/module/process_reclaim/parameters/enable_process_reclaim" ]]; then
    write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
fi
if [[ -e "${vm}reap_mem_on_sigkill" ]]; then
    write "${vm}reap_mem_on_sigkill" "1"
fi
if [[ -e "${vm}swap_ratio" ]]; then
    write "${vm}swap_ratio" "100"
fi
if [[ -e "${vm}oom_dump_tasks" ]]; then
    write "${vm}oom_dump_tasks" "0"
fi

# Tune lmk_minfree
if [[ -e "${lmk}parameters/minfree" ]]; then
    write "${lmk}parameters/minfree" "$fr,$bg,$et,$mr,$cd,$ab"
fi

# Enable oom_reaper
if [[ -e "${lmk}parameters/oom_reaper" ]]; then
    write "${lmk}parameters/oom_reaper" "1"
fi
	
# Disable lmk_fast_run
if [[ -e "${lmk}parameters/lmk_fast_run" ]]; then
    write "${lmk}parameters/lmk_fast_run" "0"
fi

# Disable adaptive_lmk
if [[ -e "${lmk}parameters/enable_adaptive_lmk" ]]; then
    write "${lmk}parameters/enable_adaptive_lmk" "0"
fi

# Tune vm_min_free_kbytes
if [[ -e "${vm}min_free_kbytes" ]]; then
    write "${vm}min_free_kbytes" "$mfr"
fi
  
# Tune vm_extra_free_kbytes
if [[ -e "${vm}extra_free_kbytes" ]]; then
    write "${vm}extra_free_kbytes" "$efr"
fi

# Huge shrinker (LMK) calling interval
if [[ -e "${lmk}parameters/cost" ]]; then
    lock_value "${lmk}parameters/cost" "4096"
fi

kmsg "Tweaked various VM / LMK parameters for a improved user-experience"
kmsg3 ""
}

vm_lmk_balanced(){
fr=$(((total_ram * 3 / 2 / 100) * 1024 / 4))
bg=$(((total_ram * 4 / 100) * 1024 / 4))
et=$(((total_ram * 5 / 100) * 1024 / 4))
mr=$(((total_ram * 6 / 100) * 1024 / 4))
cd=$(((total_ram * 8 / 100) * 1024 / 4))
ab=$(((total_ram * 10 / 100) * 1024 / 4))

mfr=$((total_ram * 7 / 5))

efr=$((mfr * 16 / 5))

if [[ "${mfr}" -le "3072" ]]; then
    mfr=3072
fi

if [[ "${efr}" -le "18432" ]]; then
    efr=18432
fi

sync

write "${vm}drop_caches" "2"
write "${vm}dirty_background_ratio" "10"
write "${vm}dirty_ratio" "25"
write "${vm}dirty_expire_centisecs" "3000"
write "${vm}dirty_writeback_centisecs" "4000"
write "${vm}page-cluster" "0"
write "${vm}stat_interval" "60"
write "${vm}extfrag_threshold" "750"
if [[ "${samsung}" == "true" ]] && [[ "${total_ram}" -lt "4096" ]]; then
    lock_value "${vm}swappiness" "150"
else
    lock_value "${vm}swappiness" "100"
fi
write "${vm}laptop_mode" "0"
write "${vm}vfs_cache_pressure" "100"
lock_value "${vm}watermark_scale_factor" "30"
if [[ -e "/sys/module/process_reclaim/parameters/enable_process_reclaim" ]]; then
    write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
fi
if [[ -e "${vm}reap_mem_on_sigkill" ]]; then
    write "${vm}reap_mem_on_sigkill" "1"
fi
if [[ -e "${vm}swap_ratio" ]]; then
    write "${vm}swap_ratio" "100"
fi
if [[ -e "${vm}oom_dump_tasks" ]]; then
    write "${vm}oom_dump_tasks" "0"
fi

if [[ -e "${lmk}parameters/minfree" ]]; then
    write "${lmk}parameters/minfree" "$fr,$bg,$et,$mr,$cd,$ab"
fi

if [[ -e "${lmk}parameters/oom_reaper" ]]; then
    write "${lmk}parameters/oom_reaper" "1"
fi
	
if [[ -e "${lmk}parameters/lmk_fast_run" ]]; then
    write "${lmk}parameters/lmk_fast_run" "1"
fi

if [[ -e "${lmk}parameters/enable_adaptive_lmk" ]]; then
    write "${lmk}parameters/enable_adaptive_lmk" "0"
fi

if [[ -e "${vm}min_free_kbytes" ]]; then
    write "${vm}min_free_kbytes" "$mfr"
fi

if [[ -e "${lmk}parameters/cost" ]]; then
    lock_value "${lmk}parameters/cost" "4096"
fi

kmsg "Tweaked various VM and LMK parameters for a improved user-experience"
kmsg3 ""
}

vm_lmk_extreme(){
fr=$(((total_ram * 3 / 100) * 1024 / 4))
bg=$(((total_ram * 5 / 100) * 1024 / 4))
et=$(((total_ram * 7 / 100) * 1024 / 4))
mr=$(((total_ram * 9 / 100) * 1024 / 4))
cd=$(((total_ram * 11 / 100) * 1024 / 4))
ab=$(((total_ram * 13 / 100) * 1024 / 4))

mfr=$((total_ram * 9 / 5))

efr=$((mfr * 16 / 5))

if [[ "${efr}" -le "18432" ]]; then
    efr=18432
fi

if [[ "${mfr}" -le "3072" ]]; then
    mfr=3072
fi

sync

write "${vm}drop_caches" "3"
write "${vm}dirty_background_ratio" "10"
write "${vm}dirty_ratio" "30"
write "${vm}dirty_expire_centisecs" "4000"
write "${vm}dirty_writeback_centisecs" "5000"
write "${vm}page-cluster" "0"
write "${vm}stat_interval" "60"
write "${vm}extfrag_threshold" "750"
if [[ "${samsung}" == "true" ]] && [[ "${total_ram}" -lt "4096" ]]; then
    lock_value "${vm}swappiness" "150"
else
    lock_value "${vm}swappiness" "100"
fi
write "${vm}laptop_mode" "0"
write "${vm}vfs_cache_pressure" "150"
lock_value "${vm}watermark_scale_factor" "30"
if [[ -e "/sys/module/process_reclaim/parameters/enable_process_reclaim" ]]; then
    write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
fi
if [[ -e "${vm}reap_mem_on_sigkill" ]]; then
    write "${vm}reap_mem_on_sigkill" "1"
fi
if [[ -e "${vm}swap_ratio" ]]; then
write "${vm}swap_ratio" "100"
fi
if [[ -e "${vm}oom_dump_tasks" ]]; then
    write "${vm}oom_dump_tasks" "0"
fi

if [[ -e "${lmk}parameters/minfree" ]]; then
    write "${lmk}parameters/minfree" "$fr,$bg,$et,$mr,$cd,$ab"
fi

if [[ -e "${lmk}parameters/oom_reaper" ]]; then
    write "${lmk}parameters/oom_reaper" "1"
fi
	
if [[ -e "${lmk}parameters/lmk_fast_run" ]]; then
    write "${lmk}parameters/lmk_fast_run" "1"
fi

if [[ -e "${lmk}parameters/enable_adaptive_lmk" ]]; then
    write "${lmk}parameters/enable_adaptive_lmk" "0"
fi

if [[ -e "${vm}min_free_kbytes" ]]; then
    write "${vm}min_free_kbytes" "$mfr"
fi

if [[ -e "${vm}extra_free_kbytes" ]]; then
    write "${vm}extra_free_kbytes" "$efr"
fi

if [[ -e "${lmk}parameters/cost" ]]; then
    lock_value "${lmk}parameters/cost" "4096"
fi

kmsg "Tweaked various VM and LMK parameters for a improved user-experience"
kmsg3 ""
}

vm_lmk_battery(){
fr=$(((total_ram * 3 / 2 / 100) * 1024 / 4))
bg=$(((total_ram * 4 / 100) * 1024 / 4))
et=$(((total_ram * 5 / 100) * 1024 / 4))
mr=$(((total_ram * 6 / 100) * 1024 / 4))
cd=$(((total_ram * 8 / 100) * 1024 / 4))
ab=$(((total_ram * 10 / 100) * 1024 / 4))

mfr=$((total_ram * 6 / 5))

efr=$((mfr * 16 / 5))

if [[ "${efr}" -le "18432" ]]; then
    efr=18432
fi

if [[ "${mfr}" -le "3072" ]]; then
    mfr=3072
fi

sync

write "${vm}drop_caches" "1"
write "${vm}dirty_background_ratio" "5"
write "${vm}dirty_ratio" "20"
write "${vm}dirty_expire_centisecs" "6000"
write "${vm}dirty_writeback_centisecs" "6000"
write "${vm}page-cluster" "0"
write "${vm}stat_interval" "60"
write "${vm}extfrag_threshold" "750"
if [[ "${samsung}" == "true" ]] && [[ "${total_ram}" -lt "4096" ]]; then
    lock_value "${vm}swappiness" "150"
else
    lock_value "${vm}swappiness" "100"
fi
write "${vm}laptop_mode" "1"
write "${vm}vfs_cache_pressure" "60"
lock_value "${vm}watermark_scale_factor" "30"
if [[ -e "/sys/module/process_reclaim/parameters/enable_process_reclaim" ]]; then
    write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
fi
if [[ -e "${vm}reap_mem_on_sigkill" ]]; then
    write "${vm}reap_mem_on_sigkill" "1"
fi
if [[ -e "${vm}swap_ratio" ]]; then
    write "${vm}swap_ratio" "100"
fi
if [[ -e "${vm}oom_dump_tasks" ]]; then
    write "${vm}oom_dump_tasks" "0"
fi

if [[ -e "${lmk}parameters/minfree" ]]; then
    write "${lmk}parameters/minfree" "$fr,$bg,$et,$mr,$cd,$ab"
fi

if [[ -e "${lmk}parameters/oom_reaper" ]]; then
    write "${lmk}parameters/oom_reaper" "1"
fi

if [[ -e "${lmk}parameters/lmk_fast_run" ]]; then
    write "${lmk}parameters/lmk_fast_run" "1"
fi

if [[ -e "${lmk}parameters/enable_adaptive_lmk" ]]; then
    write "${lmk}parameters/enable_adaptive_lmk" "0"
fi

if [[ -e "${vm}min_free_kbytes" ]]; then
    write "${vm}min_free_kbytes" "$mfr"
fi

if [[ -e "${vm}extra_free_kbytes" ]]; then
    write "${vm}extra_free_kbytes" "$efr"
fi

if [[ -e "${lmk}parameters/cost" ]]; then
    lock_value "${lmk}parameters/cost" "4096"
fi

kmsg "Tweaked various VM and LMK parameters for a improved user-experience"
kmsg3 ""
}

vm_lmk_gaming(){
fr=$(((total_ram * 3 / 100) * 1024 / 4))
bg=$(((total_ram * 5 / 100) * 1024 / 4))
et=$(((total_ram * 7 / 100) * 1024 / 4))
mr=$(((total_ram * 8 / 100) * 1024 / 4))
cd=$(((total_ram * 9 / 100) * 1024 / 4))
ab=$(((total_ram * 11 / 100) * 1024 / 4))

mfr=$((total_ram * 9 / 5))

efr=$((mfr * 16 / 5))

if [[ "${efr}" -le "18432" ]]; then
    efr=18432
fi

if [[ "${mfr}" -le "3072" ]]; then
    mfr=3072
fi

sync

write "${vm}drop_caches" "3"
write "${vm}dirty_background_ratio" "15"
write "${vm}dirty_ratio" "30"
write "${vm}dirty_expire_centisecs" "5000"
write "${vm}dirty_writeback_centisecs" "6000"
write "${vm}page-cluster" "0"
write "${vm}stat_interval" "60"
write "${vm}extfrag_threshold" "750"
if [[ "${samsung}" == "true" ]] && [[ "${total_ram}" -lt "4096" ]]; then
    lock_value "${vm}swappiness" "150"
else
    lock_value "${vm}swappiness" "100"
fi
write "${vm}laptop_mode" "0"
write "${vm}vfs_cache_pressure" "500"
lock_value "${vm}watermark_scale_factor" "30"
if [[ -e "/sys/module/process_reclaim/parameters/enable_process_reclaim" ]]; then
    write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
fi
if [[ -e "${vm}reap_mem_on_sigkill" ]]; then
    write "${vm}reap_mem_on_sigkill" "1"
fi
if [[ -e "${vm}swap_ratio" ]]; then
    write "${vm}swap_ratio" "100"
fi
if [[ -e "${vm}oom_dump_tasks" ]]; then
    write "${vm}oom_dump_tasks" "0"
fi

if [[ -e "${lmk}parameters/minfree" ]]; then
    write "${lmk}parameters/minfree" "$fr,$bg,$et,$mr,$cd,$ab"
fi

if [[ -e "${lmk}parameters/oom_reaper" ]]; then
    write "${lmk}parameters/oom_reaper" "1"
fi

if [[ -e "${lmk}parameters/lmk_fast_run" ]]; then
    write "${lmk}parameters/lmk_fast_run" "1"
fi

if [[ -e "${lmk}parameters/enable_adaptive_lmk" ]]; then
    write "${lmk}parameters/enable_adaptive_lmk" "1"
fi

if [[ -e "${vm}min_free_kbytes" ]]; then
    write "${vm}min_free_kbytes" "$mfr"
fi
  
if [[ -e "${vm}extra_free_kbytes" ]]; then
    write "${vm}extra_free_kbytes" "$efr"
fi

if [[ -e "${lmk}parameters/cost" ]]; then
    lock_value "${lmk}parameters/cost" "4096"
fi

kmsg "Tweaked various VM and LMK parameters for a improved user-experience"
kmsg3 ""
}

disable_msm_thermal(){
if [[ -d "/sys/module/msm_thermal/" ]]; then
    lock_value "/sys/module/msm_thermal/vdd_restriction/enabled" "0"
    lock_value "/sys/module/msm_thermal/core_control/enabled" "0"
    lock_value "/sys/module/msm_thermal/parameters/enabled" "N"
    kmsg "Disabled msm_thermal"
    kmsg3 ""
fi
}

enable_pewq(){
if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]; then 
    lock_value "/sys/module/workqueue/parameters/power_efficient" "Y"
    kmsg "Enabled power efficient workqueue"
    kmsg3 ""
fi
}

disable_pewq(){
if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]; then 
    lock_value "/sys/module/workqueue/parameters/power_efficient" "N"
    kmsg "Disabled power efficient workqueue"
    kmsg3 ""
fi
}

enable_mcps(){
if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]; then
    write "/sys/devices/system/cpu/sched_mc_power_savings" "2"
    kmsg "Enabled scheduler multi-core power-saving"
    kmsg3 ""
fi
}

disable_mcps(){
if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]; then
    write "/sys/devices/system/cpu/sched_mc_power_savings" "0"
    kmsg "Disabled scheduler multi-core power-saving"
    kmsg3 ""
fi
}

fix_dt2w(){
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

enable_tb(){
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

disable_tb(){
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

config_tcp(){
# Fetch the available TCP congestion control 
avail_con="$(cat "${tcp}tcp_available_congestion_control")"
	
    # Attempt to set the TCP congestion control in this order
    for tcpcc in bbr2 bbr westwood cubic bic
	do
	    # Once a matching TCP congestion control is found, set it and break
		if [[ "${avail_con}" == *"${tcpcc}"* ]]; then
			write "${tcp}"tcp_congestion_control "${tcpcc}"
		  break
		fi
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

enable_kern_batt_saver(){
if [[ -d "/sys/module/battery_saver/" ]]; then
    write "/sys/module/battery_saver/parameters/enabled" "Y"
    kmsg "Enabled kernel battery saver"
    kmsg3 ""
fi
}

disable_kern_batt_saver(){
if [[ -d "/sys/module/battery_saver/" ]]; then
    write "/sys/module/battery_saver/parameters/enabled" "N"
    kmsg "Disabled kernel battery saver"
    kmsg3 ""
fi
}

enable_hp_snd(){
for hpm in /sys/module/snd_soc_wcd*/
do
  if [[ -d "$hpm" ]]; then
      write "${hpm}parameters/high_perf_mode" "1"
      kmsg "Enabled high performance audio"
      kmsg3 ""
      break
   fi
done
}

disable_hp_snd(){
for hpm in /sys/module/snd_soc_wcd*/
do
  if [[ -d "${hpm}" ]]; then
      write "${hpm}parameters/high_perf_mode" "0"
      kmsg "Disabled high performance audio"
      kmsg3 ""
      break
   fi
done
}

enable_lpm(){
for lpm in /sys/module/lpm_levels/system/*/*/*/
do
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

disable_lpm(){
for lpm in /sys/module/lpm_levels/system/*/*/*/
do
  if [[ -d "/sys/module/lpm_levels/" ]]; then
      lock_value "/sys/module/lpm_levels/parameters/lpm_prediction" "N"
      lock_value "/sys/module/lpm_levels/parameters/lpm_ipi_prediction" "N"
      lock_value "/sys/module/lpm_levels/parameters/sleep_disabled" "Y"
      lock_value "${lpm}idle_enabled" "N"
      lock_value "${lpm}suspend_enabled" "N"
  fi
done

kmsg "Disabled LPM"
kmsg3 ""
}

enable_pm2_idle_mode(){
if [[ -e "/sys/module/pm2/parameters/idle_sleep_mode" ]]; then
    write "/sys/module/pm2/parameters/idle_sleep_mode" "Y"
    kmsg "Enabled pm2 idle sleep mode"
    kmsg3 ""
fi
}

disable_pm2_idle_mode(){
if [[ -e "/sys/module/pm2/parameters/idle_sleep_mode" ]]; then
    write "/sys/module/pm2/parameters/idle_sleep_mode" "Y"
    kmsg "Disabled pm2 idle sleep mode"
    kmsg3 ""
fi
}

enable_lcd_prdc(){
if [[ -e "/sys/class/lcd/panel/power_reduce" ]]; then
    write "/sys/class/lcd/panel/power_reduce" "1"
    kmsg "Enabled LCD power reduce"
    kmsg3 ""
fi
}

disable_lcd_prdc(){
if [[ -e "/sys/class/lcd/panel/power_reduce" ]]; then
    write "/sys/class/lcd/panel/power_reduce" "0"
    kmsg "Disabled LCD power reduce"
    kmsg3 ""
fi
}

enable_usb_fast_chrg(){
if [[ -e "/sys/kernel/fast_charge/force_fast_charge" ]]; then
    write "/sys/kernel/fast_charge/force_fast_charge" "1"
    kmsg "Enabled USB 3.0 fast charging"
    kmsg3 ""
fi
}

enable_sam_fast_chrg(){
if [[ -e "/sys/class/sec/switch/afc_disable" ]]; then
    write "/sys/class/sec/switch/afc_disable" "0"
    kmsg "Enabled fast charging on Samsung devices"
    kmsg3 ""
fi
}

emmc_clk_sclg_balanced(){
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

emmc_clk_sclg_pwr_saving(){
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

disable_emmc_clk_sclg(){
if [[ -d "/sys/class/mmc_host/mmc0/" ]] && [[ -d "/sys/class/mmc_host/mmc1/" ]]; then
    write "/sys/class/mmc_host/mmc0/clk_scaling/enable" "0"
    write "/sys/class/mmc_host/mmc1/clk_scaling/enable" "0"

elif [[ -d "/sys/class/mmc_host/mmc0/" ]]; then
      write "/sys/class/mmc_host/mmc0/clk_scaling/enable" "0"
fi
}

disable_debug(){
# Disable debugging / logging
for i in edac_mc_log* enable_event_log log_level* *log_ue* *log_ce* log_ecn_error snapshot_crashdumper seclog*; do
  for o in $(find /sys/ -type f -name "${i}"); do
      write "${o}" "0"
   done
done

kmsg "Disabled misc debugging"
kmsg3 ""
}

perfmgr_default(){ 
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

perfmgr_pwr_saving(){
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
write_panel(){
    echo "$1" >> "${bbn_log}"
}

save_panel(){
    write_panel "[*] Bourbon - the essential process optimizer"
    write_panel ""
    write_panel "Version: 1.2-r1"
    write_panel ""
    write_panel "Last performed: $(date '+%Y-%m-%d %H:%M:%S')"
    write_panel ""
    write_panel "FSCACHE status: $(fscc_status)"
    write_panel ""
    write_panel "Adjshield status: $(adjshield_status)"
    write_panel ""
    write_panel "Adjshield config file: $adj_cfg"
}

# $1:str
adjshield_write_cfg(){
    echo "$1" >> "${adj_cfg}"
}

adjshield_create_default_cfg(){
    adjshield_write_cfg "# AdjShield Config File"
    adjshield_write_cfg "# Prevent given processes from being killed by Android LMK by protecting oom_score_adj"
    adjshield_write_cfg "# List all the package names of your Apps which you want to keep alive."
    adjshield_write_cfg "com.riotgames.league.wildrift"
    adjshield_write_cfg "com.activision.callofduty.shooter"
    adjshield_write_cfg "com.mobile.legends"
    adjshield_write_cfg "com.tencent.ig"
}

adjshield_start(){
    # clear logs
    true > "${adj_log}"
    true > "${bbn_log}"
    # check interval: 120 seconds - Deprecated, use event driven instead
    ${MODPATH}system/bin/adjshield -o "${adj_log}" -c "${adj_cfg}" &
}

adjshield_stop(){
    killall "${adj_nm}" 2>/dev/null
}

# return:status
adjshield_status(){
    if [[ "$(ps -A | grep "${adj_nm}")" != "" ]]; then
        echo "Adjshield running. see $adj_log for details."
    else
        # "Error: Log file not found"
        err="$(cat "${adj_log}" | grep Error | head -n 1 | cut -d: -f2)"
        if [[ "${err}" != "" ]]; then
            echo "Not running. ${err}."
        else
            echo "Not running. Unknown reason."
        fi
    fi
}

# $1:task_name $2:cgroup_name $3:"cpuset"/"stune"
change_task_cgroup(){
    for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
        for temp_tid in $(ls "/proc/${temp_pid}/task/"); do
            comm="$(cat /proc/${temp_pid}/task/${temp_tid}/comm)"
            echo "${temp_tid}" > "/dev/$3/$2/tasks"
        done
    done
}

# $1:process_name $2:cgroup_name $3:"cpuset"/"stune"
change_proc_cgroup(){
    for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
        comm="$(cat /proc/${temp_pid}/comm)"
        echo "${temp_pid}" > "/dev/$3/$2/cgroup.procs"
    done
}

# $1:task_name $2:thread_name $3:cgroup_name $4:"cpuset"/"stune"
change_thread_cgroup(){
    for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
        for temp_tid in $(ls "/proc/$temp_pid/task/"); do
            comm="$(cat /proc/${temp_pid}/task/${temp_tid}/comm)"
            if [[ "$(echo ${comm} | grep -i -E "$2")" != "" ]]; then
                echo "${temp_tid}" > "/dev/$4/$3/tasks"
            fi
        done
    done
}

# $1:task_name $2:cgroup_name $3:"cpuset"/"stune"
change_main_thread_cgroup(){
    for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
        comm="$(cat /proc/${temp_pid}/comm)"
        echo "${temp_pid}" > "/dev/$3/$2/tasks"
    done
}

# $1:task_name $2:hex_mask(0x00000003 is CPU0 and CPU1)
change_task_affinity(){
    for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
        for temp_tid in $(ls "/proc/${temp_pid}/task/"); do
            comm="$(cat /proc/${temp_pid}/task/${temp_tid}/comm)"
            taskset -p "$2" "${temp_tid}" >> "${bbn_log}"
        done
    done
}

# $1:task_name $2:thread_name $3:hex_mask(0x00000003 is CPU0 and CPU1)
change_thread_affinity(){
    for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
        for temp_tid in $(ls "/proc/${temp_pid}/task/"); do
            comm="$(cat /proc/${temp_pid}/task/${temp_tid}/comm)"
            if [[ "$(echo ${comm} | grep -i -E "$2")" != "" ]]; then
                taskset -p "$3" "${temp_tid}" >> "${bbn_log}"
            fi
        done
    done
}

# $1:task_name $2:nice(relative to 120)
change_task_nice(){
    for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
        for temp_tid in $(ls "/proc/${temp_pid}/task/"); do
            renice -n +40 -p "${temp_tid}"
            renice -n -19 -p "${temp_tid}"
            renice -n "$2" -p "${temp_tid}"
        done
    done
}

# $1:task_name $2:thread_name $3:nice(relative to 120)
change_thread_nice(){
    for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
        for temp_tid in $(ls "/proc/${temp_pid}/task/"); do
            comm="$(cat /proc/${temp_pid}/task/${temp_tid}/comm)"
            if [[ "$(echo ${comm} | grep -i -E "$2")" != "" ]]; then
                renice -n +40 -p "${temp_tid}"
                renice -n -19 -p "${temp_tid}"
                renice -n "$3" -p "${temp_tid}"
            fi
        done
    done
}

# $1:task_name $2:priority(99-x, 1<=x<=99)
change_task_rt(){
    for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
        for temp_tid in $(ls "/proc/${temp_pid}/task/"); do
            comm="$(cat /proc/${temp_pid}/task/${temp_tid}/comm)"
            chrt -f -p "$2" "${temp_tid}" >> "${bbn_log}"
        done
    done
}

# $1:task_name $2:thread_name $3:priority(99-x, 1<=x<=99)
change_thread_rt(){
    for temp_pid in $(echo "${ps_ret}" | grep -i -E "$1" | awk '{print $1}'); do
        for temp_tid in $(ls "/proc/${temp_pid}/task/"); do
            comm="$(cat /proc/${temp_pid}/task/${temp_tid}/comm)"
            if [[ "$(echo ${comm} | grep -i -E "$2")" != "" ]]; then
                chrt -f -p "$3" "${temp_tid}" >> "${bbn_log}"
            fi
        done
    done
}

# $1:task_name
change_task_high_prio(){
    # audio thread nice <= -16
    change_task_nice "$1" "-19"
}

# $1:task_name $2:thread_name
change_thread_high_prio(){
    # audio thread nice <= -16
    change_thread_nice "$1" "$2" "-19"
}

# $1:task_name $2:thread_name
unpin_thread(){
    change_thread_cgroup "$1" "$2" "" "cpuset"
}

# $1:task_name $2:thread_name
pin_thread_on_pwr(){
    change_thread_cgroup "$1" "$2" "background" "cpuset"
}

# $1:task_name $2:thread_name
pin_thread_on_mid(){
    change_thread_cgroup "$1" "$2" "foreground" "cpuset"
    change_thread_affinity "$1" "$2" "7f"
}

# $1:task_name $2:thread_name
pin_thread_on_perf(){
    unpin_thread "$1" "$2"
    change_thread_affinity "$1" "$2" "f0"
}

# $1:task_name
unpin_proc(){
    change_task_cgroup "$1" "" "cpuset"
}

# $1:task_name
pin_proc_on_pwr(){
    change_task_cgroup "$1" "background" "cpuset"
}

# $1:task_name
pin_proc_on_mid(){
    unpin_proc "$1"
    change_task_affinity "$1" "7f"
}

# $1:task_name
pin_proc_on_perf(){
    unpin_proc "$1"
    change_task_affinity "$1" "f0"
}

rebuild_process_scan_cache(){
    # avoid matching grep itself
    # ps -Ao pid,args | grep kswapd
    # 150 [kswapd0]
    # 16490 grep kswapd
    ps_ret="$(ps -Ao pid,args)"
}

# $1:apk_path $return:oat_path
fscc_path_apk_to_oat(){
    # OPSystemUI/OPSystemUI.apk -> OPSystemUI/oat
    echo "${1%/*}/oat"
}

# $1:file/dir
fscc_list_append(){
    fscc_file_list="$fscc_file_list $1"
}

# $1:file/dir
fscc_add_obj(){
    # whether file or dir exists
    if [[ -e "$1" ]]; then
        fscc_list_append "$1"
    fi
}

# $1:package_name
fscc_add_apk(){
    if [[ "$1" != "" ]]; then
        # pm path -> "package:/system/product/priv-app/OPSystemUI/OPSystemUI.apk"
        fscc_add_obj "$(pm path "$1" | head -n 1 | cut -d: -f2)"
    fi
}

# $1:package_name
fscc_add_dex(){
    if [[ "$1" != "" ]]; then
        # pm path -> "package:/system/product/priv-app/OPSystemUI/OPSystemUI.apk"
        package_apk_path="$(pm path "$1" | head -n 1 | cut -d: -f2)"
        # user app: OPSystemUI/OPSystemUI.apk -> OPSystemUI/oat
        fscc_add_obj "${package_apk_path%/*}/oat"

        # remove apk name suffix
        apk_nm="${package_apk_path%/*}"
        # remove path prefix
        apk_nm="${apk_nm##*/}"
        # system app: get dex & vdex
        # /data/dalvik-cache/arm64/system@product@priv-app@OPSystemUI@OPSystemUI.apk@classes.dex
        for dex in $(find "${dvk}" | grep "@$apk_name@"); do
            fscc_add_obj "${dex}"
        done
   fi
}

fscc_add_app_home(){
    # well, not working on Android 7.1
    intent_act="android.intent.action.MAIN"
    intent_cat="android.intent.category.HOME"
    # "  packageName=com.microsoft.launcher"
    pkg_nm="$(pm resolve-activity -a "${intent_act}" -c "${intent_cat}" | grep packageName | head -n 1 | cut -d= -f2)"
    # /data/dalvik-cache/arm64/system@priv-app@OPLauncher2@OPLauncher2.apk@classes.dex 16M/31M  53.2%
    # /data/dalvik-cache/arm64/system@priv-app@OPLauncher2@OPLauncher2.apk@classes.vdex 120K/120K  100%
    # /system/priv-app/OPLauncher2/OPLauncher2.apk 14M/30M  46.1%
    fscc_add_apk "${pkg_nm}"
    fscc_add_dex "${pkg_nm}"
}

fscc_add_app_ime(){
    # "      packageName=com.baidu.input_yijia"
    pkg_nm="$(ime list | grep packageName | head -n 1 | cut -d= -f2)"
    # /data/dalvik-cache/arm/system@app@baidushurufa@baidushurufa.apk@classes.dex 5M/17M  33.1%
    # /data/dalvik-cache/arm/system@app@baidushurufa@baidushurufa.apk@classes.vdex 2M/7M  28.1%
    # /system/app/baidushurufa/baidushurufa.apk 1M/28M  5.71%
    # pin apk file in memory is not valuable
    fscc_add_dex "${pkg_nm}"
}

# $1:package_name
fscc_add_apex_lib(){
    fscc_add_obj "$(find /apex -name "$1" | head -n 1)"
}

# after appending fscc_file_list
fscc_start(){
    # multiple parameters, cannot be warped by ""
    ${MODPATH}system/bin/${fscc_nm} -fdlb0 $fscc_file_list
}

fscc_stop(){
    killall -9 "${fscc_nm}" 2>/dev/null
}

# return:status
fscc_status(){
    # get the correct value after waiting for fscc loading files
    sleep 2
    if [[ "$(ps -A | grep "${fscc_nm}")" != "" ]]; then
        echo "Running $(cat /proc/meminfo | grep Mlocked | cut -d: -f2 | tr -d ' ') in cache."
    else
        echo "Not running."
    fi
}

cgroup_bbn_opt(){
    # Reduce perf cluster wakeup
    # Daemons
    pin_proc_on_pwr "crtc_commit|crtc_event|pp_event|msm_irqbalance|netd|mdnsd|analytics"
    pin_proc_on_pwr "imsdaemon|cnss-daemon|qadaemon|qseecomd|time_daemon|ATFWD-daemon|ims_rtp_daemon|qcrilNrd"
    # ueventd related to hotplug of camera, wifi, usb... 
    # pin_proc_on_pwr "ueventd"
    # hardware services, eg. android.hardware.sensors@1.0-service
    pin_proc_on_pwr "android.hardware.bluetooth"
    pin_proc_on_pwr "android.hardware.gnss"
    pin_proc_on_pwr "android.hardware.health"
    pin_proc_on_pwr "android.hardware.thermal"
    pin_proc_on_pwr "android.hardware.wifi"
    pin_proc_on_pwr "android.hardware.keymaster"
    pin_proc_on_pwr "vendor.qti.hardware.qseecom"
    pin_proc_on_pwr "hardware.sensors"
    pin_proc_on_pwr "sensorservice"
    # com.android.providers.media.module controlled by uperf
    pin_proc_on_pwr "android.process.media"
    # com.miui.securitycenter & com.miui.securityadd
    pin_proc_on_pwr "miui\.security"

    # system_server blacklist
    # system_server controlled by uperf
    change_proc_cgroup "system_server" "" "cpuset"
    # input dispatcher
    change_thread_high_prio "system_server" "input"
    # related to camera startup
    # change_thread_affinity "system_server" "ProcessManager" "ff"
    # not important
    pin_thread_on_pwr "system_server" "Miui|Connect|Network|Wifi|backup|Sync|Observer|Power|Sensor|batterystats"
    pin_thread_on_pwr "system_server" "Thread-|pool-|Jit|CachedAppOpt|Greezer|TaskSnapshot|Oom"
    change_thread_nice "system_server" "Greezer|TaskSnapshot|Oom" "4"
    # pin_thread_on_pwr "system_server" "Async" # it blocks camera
    # pin_thread_on_pwr "system_server" "\.bg" # it blocks binders
    # do not let GC thread block system_server
    # pin_thread_on_mid "system_server" "HeapTaskDaemon"
    # pin_thread_on_mid "system_server" "FinalizerDaemon"

    # Render Pipeline
    # surfaceflinger controlled by uperf
    # android.phone controlled by uperf
    # speed up searching service binder
    change_task_cgroup "servicemanag" "top-app" "cpuset"
    # prevent display service from being preempted by normal tasks
    # vendor.qti.hardware.display.allocator-service cannot be set to RT policy, will be reset to 120
    unpin_proc "\.hardware\.display"
    change_task_affinity "\.hardware\.display" "7f"
    change_task_rt "\.hardware\.display" "2"
    # let UX related Binders run with top-app
    change_thread_cgroup "\.hardware\.display" "^Binder" "top-app" "cpuset"
    change_thread_cgroup "\.hardware\.display" "^HwBinder" "top-app" "cpuset"
    change_thread_cgroup "\.composer" "^Binder" "top-app" "cpuset"

    # Heavy Scene Boost
    # boost app boot process, zygote--com.xxxx.xxx
    # boost android process pool, usap--com.xxxx.xxx
    unpin_proc "zygote64|zygote|usap32|usap64"
    
    # busybox fork from magiskd
    pin_proc_on_mid "magiskd"
    change_task_nice "magiskd" "19"
}

clear_logs(){
# Remove debug log if size is >= 1 MB
kdbg_max_size=1000000

# Do the same to sqlite opt log
sqlite_opt_max_size=1000000

if [[ "$(stat -t "${KDBG}" 2>/dev/null | awk '{print $2}')" -ge "${kdbg_max_size}" ]]; then
    rm -rf "${KDBG}"

elif [[ "$(stat -t /data/media/0/KTSR/sqlite_opt.log 2>/dev/null | awk '{print $2}')" -ge "${sqlite_opt_max_size}" ]]; then
      rm -rf "/data/media/0/KTSR/sqlite_opt.log"
fi
}

get_all(){
get_gpu_dir

if [[ "${qcom}" != "true" ]]; then
    is_mtk
fi

if [[ "${mtk}" != "true" ]] && [[ "${qcom}" != "true" ]]; then
    is_exynos
fi

check_qcom

if [[ "${qcom}" != "true" ]] && [[ "${exynos}" != "true" ]]; then
    check_ppm_support
fi

if [[ "${qcom}" == "true" ]]; then
    define_gpu_pl
fi

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

if [[ "${qcom}" == "true" ]]; then
    setup_adreno_gpu_thrtl
fi

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

apply_all(){
print_info

stop_services

if [[ "${ktsr_prof_en}" == "balanced" ]] || [[ "${ktsr_prof_en}" == "battery" ]] || [[ "${ktsr_prof_en}" == "latency" ]]; then
    thermal_default
elif [[ "${ktsr_prof_en}" == "extreme" ]] || [[ "${ktsr_prof_en}" == "gaming" ]]; then
      thermal_dynamic
fi

if [[ "${ktsr_prof_en}" == "balanced" ]] || [[ "${ktsr_prof_en}" == "battery" ]]; then
    enable_core_ctl
else
    disable_core_ctl
fi

config_cpuset

if [[ "${ktsr_prof_en}" == "extreme" ]] || [[ "${ktsr_prof_en}" == "gaming" ]]; then
    enable_devfreq_boost
else
    disable_devfreq_boost
fi

boost_${ktsr_prof_en}

io_${ktsr_prof_en}

cpu_${ktsr_prof_en}

if [[ "${ktsr_prof_en}" == "extreme" ]] || [[ "${ktsr_prof_en}" == "gaming" ]]; then
    enable_kvb
else
    disable_kvb
fi

bring_all_cores

if [[ "${ktsr_prof_en}" == "latency" ]] || [[ "${ktsr_prof_en}" == "balanced" ]]; then
    misc_cpu_default
elif [[ "${ktsr_prof_en}" == "battery" ]]; then
      misc_cpu_pwr_saving
else
    misc_cpu_max_pwr
fi

disable_ppm

if [[ "${ktsr_prof_en}" != "extreme" ]] && [[ "${ktsr_prof_en}" != "gaming" ]]; then
    cpu_clk_default
else
    cpu_clk_max
fi

hmp_${ktsr_prof_en}

gpu_${ktsr_prof_en}

schedtune_${ktsr_prof_en}

sched_ft_${ktsr_prof_en}

disable_crc

sched_${ktsr_prof_en}

enable_fp_boost

uclamp_${ktsr_prof_en}

config_blkio

config_fs

config_dyn_fsync

if [[ "${ktsr_prof_en}" != "battery" ]]; then
    ufs_default
else
    ufs_pwr_saving
fi

vm_lmk_${ktsr_prof_en}

disable_msm_thermal

if [[ "${ktsr_prof_en}" == "balanced" ]] || [[ "${ktsr_prof_en}" == "battery" ]]; then
    enable_pewq
else
    disable_pewq
fi

if [[ "${ktsr_prof_en}" == "battery" ]]; then
    enable_mcps
else
    disable_mcps
fi

fix_dt2w

if [[ "${ktsr_prof_en}" == "extreme" ]] || [[ "${ktsr_prof_en}" == "gaming" ]]; then
    enable_tb
else
    disable_tb
fi

config_tcp

if [[ "${ktsr_prof_en}" == "battery" ]]; then
    enable_kern_batt_saver
else
    disable_kern_batt_saver
fi

#if [[ "${ktsr_prof_en}" != "battery" ]]; then
#    enable_hp_snd
#else
#    disable_hp_snd
#fi

if [[ "${ktsr_prof_en}" == "battery" ]] || [[ "${ktsr_prof_en}" == "balanced" ]] || [[ "${ktsr_prof_en}" == "latency" ]]; then
    enable_lpm
else
    disable_lpm
fi

if [[ "${ktsr_prof_en}" != "extreme" ]] && [[ "${ktsr_prof_en}" != "gaming" ]]; then
    enable_pm2_idle_mode
else
    disable_pm2_idle_mode
fi

if [[ "${ktsr_prof_en}" == "battery" ]]; then
    enable_lcd_prdc
else
    disable_lcd_prdc
fi

enable_usb_fast_chrg

enable_sam_fast_chrg

disable_spd_freqs

config_pwr_spd

if [[ "${ktsr_prof_en}" == "balanced" ]]; then
    emmc_clk_sclg_balanced
elif [[ "${ktsr_prof_en}" == "battery" ]]; then
      emmc_clk_sclg_pwr_saving
elif [[ "${ktsr_prof_en}" == "extreme" ]] || [[ "${ktsr_prof_en}" == "gaming" ]]; then
      disable_emmc_clk_sclg
fi

disable_debug

if [[ "${ktsr_prof_en}" != "battery" ]]; then
    perfmgr_default
else
    perfmgr_pwr_saving
fi
}

apply_all_auto(){
print_info

stop_services

if [[ "$(getprop kingauto.prof)" == "balanced" ]] || [[ "$(getprop kingauto.prof)" == "latency" ]] || [[ "$(getprop kingauto.prof)" == "battery" ]]; then
    thermal_default

elif [[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]]; then
      thermal_dynamic
fi

if [[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]]; then
    enable_devfreq_boost
else
    disable_devfreq_boost
fi

if [[ "$(getprop kingauto.prof)" == "balanced" ]] || [[ "$(getprop kingauto.prof)" == "battery" ]]; then
    enable_core_ctl
else
    disable_core_ctl
fi

config_cpuset

boost_$(getprop kingauto.prof)

io_$(getprop kingauto.prof)

boost_$(getprop kingauto.prof)

io_$(getprop kingauto.prof)

cpu_$(getprop kingauto.prof)

if [[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]]; then
    enable_kvb
else
    disable_kvb
fi

bring_all_cores

if [[ "$(getprop kingauto.prof)" == "latency" ]] || [[ "$(getprop kingauto.prof)" == "balanced" ]]; then
    misc_cpu_default

elif [[ "$(getprop kingauto.prof)" == "battery" ]]; then
      misc_cpu_pwr_saving
else
    misc_cpu_max_pwr
fi

disable_ppm

if [[ "$(getprop kingauto.prof)" != "extreme" ]] && [[ "$(getprop kingauto.prof)" != "latency" ]] && [[ "$(getprop kingauto.prof)" != "gaming" ]]; then
    cpu_clk_default
else
    cpu_clk_max
fi

hmp_$(getprop kingauto.prof)

gpu_$(getprop kingauto.prof)

schedtune_$(getprop kingauto.prof)

sched_ft_$(getprop kingauto.prof)

disable_crc

sched_$(getprop kingauto.prof)

enable_fp_boost

uclamp_$(getprop kingauto.prof)

config_blkio

config_fs

config_dyn_fsync

if [[ "$(getprop kingauto.prof)" != "battery" ]]; then
    ufs_default
else
    ufs_pwr_saving
fi

vm_lmk_$(getprop kingauto.prof)

disable_msm_thermal

if [[ "$(getprop kingauto.prof)" == "balanced" ]] || [[ "$(getprop kingauto.prof)" == "battery" ]]; then
    enable_pewq
else
    disable_pewq
fi

if [[ "$(getprop kingauto.prof)" == "battery" ]]; then
    enable_mcps
else
    disable_mcps
fi

fix_dt2w

if [[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]]; then
    enable_tb
else
    disable_tb
fi

config_tcp

if [[ "$(getprop kingauto.prof)" == "battery" ]]; then
    enable_kern_batt_saver
else
    disable_kern_batt_saver
fi

#if [[ "$(getprop kingauto.prof)" != "battery" ]]; then
#    enable_hp_snd
#else
#    disable_hp_snd
#fi

if [[ "$(getprop kingauto.prof)" == "battery" ]] || [[ "$(getprop kingauto.prof)" == "balanced" ]] || [[ "$(getprop kingauto.prof)" == "latency" ]]; then
    enable_lpm
else
    disable_lpm
fi

if [[ "$(getprop kingauto.prof)" != "extreme" ]] && [[ "$(getprop kingauto.prof)" != "gaming" ]]; then
    enable_pm2_idle_mode
else
    disable_pm2_idle_mode
fi

if [[ "$(getprop kingauto.prof)" == "battery" ]]; then
    enable_lcd_prdc
else
    disable_lcd_prdc
fi

enable_usb_fast_chrg

enable_sam_fast_chrg

disable_spd_freqs

config_pwr_spd

if [[ "$(getprop kingauto.prof)" == "balanced" ]]; then
    emmc_clk_sclg_balanced
elif [[ "$(getprop kingauto.prof)" == "battery" ]]; then
      emmc_clk_sclg_pwr_saving
elif [[ "$(getprop kingauto.prof)" == "extreme" ]] || [[ "$(getprop kingauto.prof)" == "gaming" ]]; then
      disable_emmc_clk_sclg
fi

disable_debug

if [[ "$(getprop kingauto.prof)" != "battery" ]]; then
    perfmgr_default
else
    perfmgr_pwr_saving
fi
}

###############################
# Abbreviations
###############################

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
perfmgr="/proc/perfmgr/"
fscc_file_list=""

latency(){
init=$(date +%s)

get_all

apply_all

kmsg "Latency profile applied. Enjoy!"
kmsg3 ""

kmsg "End of execution: $(date)"
kmsg3 ""
exit=$(date +%s)

exec_time=$((exit - init))
kmsg "Spent time: $exec_time seconds."
}
automatic(){     	
kmsg "Applying automatic profile"
kmsg3 ""

sync
kingauto &
	
kmsg "Applied automatic profile"
}
balanced(){
init=$(date +%s)

get_all

apply_all

kmsg "Balanced profile applied. Enjoy!"
kmsg3 ""

kmsg "End of execution: $(date)"
kmsg3 ""
exit=$(date +%s)

exec_time=$((exit - init))
kmsg "Spent time: $exec_time seconds."
}
extreme(){
init=$(date +%s)

get_all

apply_all

kmsg "Extreme profile applied. Enjoy!"
kmsg3 ""

kmsg "End of execution: $(date)"
kmsg3 ""
exit=$(date +%s)

exec_time=$((exit - init))
kmsg "Spent time: $exec_time seconds."
}
battery(){
init=$(date +%s)
   
get_all

apply_all

kmsg "Battery profile applied. Enjoy!"
kmsg3 ""

kmsg "End of execution: $(date)"
kmsg3 ""
exit=$(date +%s)

exec_time=$((exit - init))
kmsg "Spent time: $exec_time seconds."
}
gaming(){
init=$(date +%s)
     	
get_all

apply_all

kmsg "Gaming profile applied. Enjoy!"
kmsg3 ""

kmsg "End of execution: $(date)"
kmsg3 ""
exit=$(date +%s)

exec_time=$((exit - init))
kmsg "Spent time: $exec_time seconds."
}