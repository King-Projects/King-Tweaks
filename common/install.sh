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
KU=1
while true
do
ui_print "  $KU"
if $VKSEL 
then
KU=$((KU + 1))
else 
break
fi
if [ $KU -gt 4 ]; then
KU=1
fi
done

case $KU in
1 ) FCTEXTAD1="PUBGM 90 FPS";;
2 ) FCTEXTAD1="CODM 120 FPS";;
3 ) FCTEXTAD1="BDM Max Settings";;
4 ) FCTEXTAD1="None";;
esac

ui_print ""
ui_print "[*] Selected: $FCTEXTAD1 "
ui_print ""

if [[ "$FCTEXTAD1" == "PUBGM 90 FPS" ]]
then
sed -i '/ro.product.model/s/.*/ro.product.model=IN2025/' $MODPATH/system.prop

elif [[ "$FCTEXTAD1" == "CODM 120 FPS" ]]
then
sed -i '/ro.product.model/s/.*/ro.product.model=SO-52A/' $MODPATH/system.prop

elif [[ "$FCTEXTAD1" == "BDM Max Settings" ]]
then
sed -i '/ro.product.model/s/.*/ro.product.model=SM-G975U/' $MODPATH/system.prop
fi

ui_print "[*] Done!"

ui_print ""
ui_print "-------------------------------------------------------------------------------------------------------------------------------------------------"
ui_print "                                          Enable MIUI 12 gesture bar (ginkgo)                                                                    "
ui_print "-------------------------------------------------------------------------------------------------------------------------------------------------"
ui_print ""
ui_print " [!] Attention: This will enable MIUI 12 gesture bar by changing ro.product.model to one that's not blacklisted on framework.jar."
ui_print ""
sleep 1
ui_print " Volume + = Switch number "
ui_print " Volume - = Select "
sleep 1
ui_print ""
ui_print " 1- Enable gesture bar. "
ui_print ""
sleep 1
ui_print " 2- Don't enable gesture bar. "
ui_print ""
ui_print " [*] Select which you wanna: "
ui_print ""
GB=1
while true
do
ui_print "  $GB"
if $VKSEL
then
GB=$((GB + 1))
else 
break
fi
if [ $GB -gt 2 ]
then
GB=1
fi
done

case $GB in 
1 ) FCTEXTAD2="Enable gesture bar";;
2 ) FCTEXTAD2="Don't enable gesture bar";;
esac

ui_print ""
ui_print " [*] Selected: $FCTEXTAD2 "
ui_print ""

if [[ "$FCTEXTAD2" == "Enable gesture bar" ]]
then
sed -i '/ro.product.device/s/.*/ro.product.device=laurus/' $MODPATH/system.prop
fi

if [[ "$FCTEXTAD2" == "Don't enable gesture bar" && "$FCTEXTAD1" == "None" ]]
then
rm $MODPATH/system.prop
fi