#!/system/bin/sh
# By pedro (pedrozzz0 @ GitHub)
# Thanks to bdashore3 @ GitHub
# Thanks to Draco (tytydraco @ GitHub)
yellow=$(tput setaf 3)
green=$(tput setaf 2)
boldgreen=${bold}${green}
boldred=${bold}${red}
red=$(tput setaf 1)
blue=$(tput setaf 4)
bold=$(tput bold)
blink=$(tput blink)
default=$(tput sgr0)
date=$(date)
v="2.0.3"
vcd=$(grep versionCode= module.prop | sed "s/versionCode=//")

read -r -p 'Build release: ' br

read -r -p 'Codename: ' cdn

init=$(date +%s)

if [[ "$(grep build_date $(pwd)/module.prop)" ]]; then
	sed -i -e "/build_date=/s/=.*/=$date/" "$(pwd)/module.prop"
fi

if [[ ! "$(grep build_date $(pwd)/module.prop)" ]]; then
	echo "build_date=$date" >>"$(pwd)/module.prop"
fi

if [[ "$br" == b* ]]; then
	vcd=$(printf "%.3d" "$((${vcd} + 1))")
	sed -i -e "/versionCode=/s/=.*/=$vcd/" "$(pwd)/module.prop"
fi

sed -i -e "/version=/s/=.*/=$v-$br-$cdn/" "$(pwd)/module.prop"

echo ""
echo "Build starting at $(date)"
echo ""

echo "Zipping ${blink}KTSR-$v-$br-$cdn${default}..."

zip -r9 "KTSR-$v-$br-$cdn.zip" . -x *.git* -x cleantrash -x mod-util.sh -x *.zip -x adjshield -x fscache-ctrl -x *.yml -x C1.sh -x kingauto -x ktsrmenu -x update.json -x kingtweaks -x *.apk -x *.bak -x libktsr.sh -x kcal.sh -x build.sh

mv -f "KTSR-$v-$br-$cdn.zip" ../out

exit=$(date +%s)

exec_time=$((exit - init))

[[ $? -ne 1 ]] && {
	echo "${boldgreen}Build done in $((exec_time / 60)) minutes and $exec_time seconds!${blue} Check the folder to the finished build."
	exit 0
} || {
	echo "${boldred}Build failed in $((exec_time / 60)) minutes and $exec_time seconds!${yellow} Please fix the error(s) and try again."
	exit 1
}
