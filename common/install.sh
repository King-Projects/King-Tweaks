ui_print ""
ui_print "[*] Do you want to enable King Xvision KCAL Preset?"
ui_print ""
ui_print "[*] King Xvision brings you more vivid and beautiful colors, and also better balance between them."
ui_print ""
sleep 3
ui_print "[!] Warning: If you have problems with this preset, just reinstall the module and choose to do not apply this preset."
ui_print ""
sleep 2
ui_print " Vol + = Switch option "
ui_print ""
sleep 0.2
ui_print " Vol - = Select option "
sleep 1
ui_print ""
ui_print " 1- Yes "
ui_print ""
sleep 0.5
ui_print " 2- No "
ui_print ""
sleep 0.5
ui_print "[*] Select which you wanna: "
ui_print ""
KL=1
while true
do
ui_print "  $KL"
if $VKSEL 
then
KL=$((KL + 1))
else 
break
fi
if [ $KL -gt 2 ]
then
KL=1
fi
done

case $KL in
1 ) FCTEXTAD1="Enable King Xvision KCAL preset";;
2 ) FCTEXTAD1="Don't enable King Xvision KCAL preset";;
esac

ui_print ""
ui_print "[*] Selected: $FCTEXTAD1 "

if [[ "$FCTEXTAD1" == "Don't enable King Xvision KCAL preset" ]]
then
rm $MODPATH/post-fs-data.sh
fi

ui_print ""
ui_print "[*] Do you want to optimize apps package?"
sleep 2
ui_print ""
ui_print "[!] Warning: This process can last 5-10 minutes or longer"
ui_print "just wait and it will be done."
sleep 5
ui_print ""
ui_print " Vol + = Switch option "
ui_print ""
sleep 0.2
ui_print " Vol - = Select option "
sleep 1
ui_print ""
ui_print " 1- Yes "
ui_print ""
sleep 0.5
ui_print " 2- No "
ui_print ""
sleep 0.5
ui_print "[*] Select which you wanna: "
ui_print ""
AO=1
while true
do
ui_print "  $AO"
if $VKSEL 
then
AO=$((AO + 1))
else 
break
fi
if [ $AO -gt 2 ]
then
AO=1
fi
done

case $AO in
1 ) FCTEXTAD2="Yes";;
2 ) FCTEXTAD2="No";;
esac

ui_print ""
ui_print "[*] Selected: $FCTEXTAD2 "
ui_print ""

if [[ $FCTEXTAD2 == "Yes" ]]
then
ui_print "[*] Optimizing apps package..."
cmd package bg-dexopt-job
ui_print ""
fi

ui_print "[*] Done!"
ui_print ""