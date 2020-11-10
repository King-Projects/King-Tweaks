sleep 1
ui_print ""
ui_print "-------------------------------------------------------------------------------------------------------------------------------------------------"
ui_print "                                          King Unlocker                                                                                           "
ui_print "-------------------------------------------------------------------------------------------------------------------------------------------------"
ui_print ""
ui_print " [!] Attention: This may cause problems with mi camera and other system apps "
ui_print " And also will not work if you're using magiskhideprops or other like module. "
sleep 1
ui_print ""
ui_print " Volume + = Switch number "
ui_print " Volume - = Select "
sleep 1
ui_print ""
ui_print " 1- Apply PUBGM 90 FPS Settings. "
ui_print ""
sleep 0.5
ui_print " 2- Apply CODM 120 FPS Settings. "
ui_print ""
sleep 0.5
ui_print " 3- Apply Black Desert Mobile Max Settings. "
ui_print ""
sleep 0.5
ui_print " 4- None. "
ui_print ""
sleep 0.5
ui_print "[*] Select which you wanna: "
ui_print ""
FU=1
while true; do
	ui_print "  $FU"
	if $VKSEL; then
		FU=$((FU + 1))
	else 
		break
	fi
	if [ $FU -gt 4 ]; then
		FU=1
	fi
done

case $FU in
1 ) FCTEXTAD1="PUBGM 90 FPS";;
2 ) FCTEXTAD1="CODM 120 FPS";;
3 ) FCTEXTAD1="Black Desert Mobile Max Settings";;
4 ) FCTEXTAD1="None";;
esac

ui_print ""
ui_print "[*] Selected: $FCTEXTAD1 "
ui_print ""

if [[ "$FCTEXTAD1" == "PUBGM 90 FPS" ]]
then
sed -i '/ro.product.model=/s/.*/ro.product.model=IN2025/' $MODPATH/system.prop

elif [[ "$FCTEXTAD1" == "CODM 120 FPS" ]]
then
sed -i '/ro.product.model=/s/.*/ro.product.model=SO-52A/' $MODPATH/system.prop

elif [[ "$FCTEXTAD1" == "Black Desert Mobile Max Settings" ]]
then
sed -i '/ro.product.model=/s/.*/ro.product.model=SM-G975U/' $MODPATH/system.prop
fi

ui_print "[*] Done!"

ui_print "-------------------------------------------------------------------------------------------------------------------------------------------------"
ui_print "                                        DRM L1 Widevine Patch                                                                                    "
ui_print "-------------------------------------------------------------------------------------------------------------------------------------------------"
ui_print ""
ui_print " [!] Attention: Don't apply if your rom already have DRM L1 Widevine. "
sleep 1
ui_print ""
ui_print " Volume + = Switch number "
ui_print " Volume - = Select "
sleep 1
ui_print ""
ui_print " 1- Apply DRM L1 Widevine Patch. "
ui_print ""
sleep 0.5
ui_print " 2- Don't apply DRM L1 Widevine Patch. "
ui_print ""
sleep 0.5
ui_print "[*] Select which you wanna: "
ui_print ""
DL=1
while true; do
	ui_print "  $DL"
	if $VKSEL; then
		DL=$((DL + 1))
	else 
		break
	fi
	if [ $DL -gt 2 ]; then
		DL=1
	fi
done

case $DL in
1 ) FCTEXTAD2="Apply";;
2 ) FCTEXTAD2="Don't apply";;
esac
 
ui_print ""
ui_print "[*] Selected: $FCTEXTAD2 "
ui_print ""

 if [[ "$FCTEXTAD2" == "Apply" ]]
 then
 mv $MODPATH/vendor $MODPATH/system
 
 elif [[ "$FCTEXTAD2" == "Don't apply" ]]
 then
 busybox rm -rf $MODPATH/vendor
 fi
 
 ui_print "[*] Done!"
 ui_print ""
