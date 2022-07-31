#!/system/bin/sh
# KTSR™ by Pedro (pedrozzz0 @ GitHub)
# Credits: Ktweak, by Draco (tytydraco @ GitHub), LSpeed, Dan (Paget69 @ XDA), mogoroku @ GitHub, vtools, by helloklf @ GitHub, Cuprum-Turbo-Adjustment, by chenzyadb @ CoolApk, qti-mem-opt & Uperf, by Matt Yang (yc9559 @ CoolApk) and Pandora's Box, by Eight (dlwlrma123 @ GitHub)
# If you wanna use the code as part of your project, please maintain the credits to it's respectives authors

#####################
# Variables
#####################
bbn_log="/data/media/0/ktsr/bourbon.log"
bbn_info="/data/media/0/ktsr/bourbon.info"
adj_cfg="/data/media/0/ktsr/adjshield.conf"
adj_log="/data/media/0/ktsr/adjshield.log"
sys_frm="/system/framework"
sys_lib="/system/lib64"
vdr_lib="/vendor/lib64"
dvk="/data/dalvik-cache"
apx1="/apex/com.android.art/javalib"
apx2="/apex/com.android.runtime/javalib"
fscc_file_list=""

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

notif_custom() { su -lp 2000 -c "cmd notification post -S bigtext -t '$1' tag '$2'" >/dev/null 2>&1; }

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

write_lock() {
	[[ ! -f "$1" ]] && return 1

	chmod +w "$1" 2>/dev/null

	! echo "$2" >"$1" 2>/dev/null && {
		log_e "Failed: $1 → $2"
		return 1
	}
	log_d "$1 → $2"
	chmod 0444 "$1"
}

kill_svc() {
	stop "$1" 2>/dev/null
	killall -9 "$1" 2>/dev/null
	killall -9 $(find /system/bin -type f -name "$1") 2>/dev/null
	killall -9 $(find /vendor/bin -type f -name "$1") 2>/dev/null
}

write_info() { echo "$1" >>"$bbn_info"; }

save_info() {
	write_info "[*] Bourbon - the essential AIO optimizer 
Version: 1.4.2-r7-master
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
com.garena.game.kgid
com.epicgames.fortnite
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
com.garena.game.codm
com.pixelfederation.ts2
com.gameloft.android.GloftNOMP
"
}

adjshield_start() {
	rm -rf "$adj_log"
	rm -rf "$bbn_log"
	rm -rf "$bbn_info"
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

pin_thread_on_all() {
	unpin_proc "$1"
	change_task_affinity "$1" "ff"
}

pin_thread_on_custom() {
	unpin_thread "$1" "$2"
	change_thread_affinity "$1" "$2" "$3"
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

pin_proc_on_custom() {
	unpin_proc "$1"
	change_task_affinity "$1" "$2"
}

# avoid matching grep itself
# ps -Ao pid,args | grep kswapd
# 150 [kswapd0]
# 16490 grep kswapd
rebuild_ps_cache() { ps_ret="$(ps -Ao pid,args)"; }

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