#!/system/bin/sh
# By pedro (pedrozzz0 @ GitHub)
# Thanks to bdashore3 @ GitHub
# Thanks to Draco (tytydraco @ GitHub)
yellow=$(tput setaf 3)
green=$(tput setaf 2)
boldgreen=${bold}$green
boldred=${bold}$red
red=$(tput setaf 1)
blue=$(tput setaf 4)
bold=$(tput bold)
blink=$(tput blink)
default=$(tput sgr0)
date=$(date)
v=$(grep version= module.prop | sed "s/version=//")
vcd=$(grep versionCode= module.prop | sed "s/versionCode=//")

read -r -p 'Build release: ' br

read -r -p 'Codename: ' cdn

init=$(date +%s)

if [[ "$(grep codename $(pwd)/module.prop)" ]]; then
    sed -i -e "/build_date=/s/=.*/=$date/" $(pwd)/module.prop
    sed -i -e "/build_rel=/s/=.*/=$br/" $(pwd)/module.prop
    sed -i -e "/codename=/s/=.*/=$cdn/" $(pwd)/module.prop
else
    echo "build_date=$date
build_rel=$br
codename=$cdn" >> $(pwd)/module.prop
fi

if [[ "$br" != b* ]]; then
    vcd=$(printf "%.3d" "$((${vcd} + 1))")
    sed -i -e "/versionCode=/s/=.*/=$vcd/" $(pwd)/module.prop
fi

echo ""
echo "Build starting at $(date)"
echo ""

echo "Zipping ${blink}KTSR-$v-$br-$cdn${default}..."

zip -r9T "KTSR-$v-$br-$cdn.zip" . -x *.git* -x cleantrash -x *.zip -x adjshield -x fscache-ctrl -x *.yml -x C1.sh -x kingauto -x ktsrmenu -x update.json -x kingtweaks -x *.apk -x *.bak -x libktsr.sh -x kcal.sh -x build.sh

mv -f "KTSR-$v-$br-$cdn.zip" ../out

exit=$(date +%s)

exectime=$((exit - init))

if [[ $? -ne 1 ]]; then
    echo "${boldgreen}Build done in $((exectime / 60)) minutes and $exectime seconds!${blue} Check the folder to the finished build."
else
    echo "${boldred}Build failed in $((exectime / 60)) minutes and $exectime seconds!${yellow} Please fix the error(s) and try again."
fi