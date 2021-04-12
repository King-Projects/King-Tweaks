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
version=$(cat module.prop | grep version= | sed "s/version=//")

read -p 'Build type: ' build_type

read -p 'Codename: ' codename

init=$(date +%s)

echo "builddate=$date
buildtype=$build_type
codename=$codename" > $(pwd)/ktsr.prop

echo ""
echo "Build starting at $(date)"
echo ""

echo "Zipping ${blink}KTSR-v$version-$build_type-$codename${default}..."

zip -r "KTSR-v$version-$build_type-$codename.zip" . -x *.git* -x *.zip -x *.yml -x C1.sh -x kingauto -x ktsrmenu -x update.json -x kingtweaks -x *.apk -x *.bak -x libktsr.sh -x kcal.sh -x build.sh

mv "KTSR-v$version-$build_type-$codename.zip" ../out

rm $(pwd)/ktsr.prop

exit=$(date +%s)

exectime=$((exit - init))

if [ $? -ne 1 ]; then
echo "${boldgreen}Build done in $((exectime / 60)) minutes and $exectime seconds!${blue} Check the folder to the finished build."

else
echo "${boldred}Build failed in $((exectime / 60)) minutes and $exectime seconds!${yellow} Please fix the error(s) and try again."
fi