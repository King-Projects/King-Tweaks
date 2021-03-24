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
date=`date`
version=`cat module.prop | grep version= | sed "s/version=//"`

read -p 'Build type: ' build_type

read -p 'Codename: ' codename

echo "builddate=$date
buildtype=$build_type
codename=$codename" > $(pwd)/info.prop
 
echo "Zipping ${blink}KTSR-$version-$build_type-$codename${default}..."

zip -r "KTSR-$version-$build_type-$codename.zip" . -x *.git* -x *.zip -x C1.sh -x kingauto -x kingtweaks -x *.apk -x *.bak -x libktsr.sh -x kcal.sh -x build.sh

mv "KTSR-$version-$build_type-$codename.zip" ../out

rm $(pwd)/info.prop

if [ $? -ne 1 ]; then
echo "${boldgreen}Build done${blue}, check the folder to the finished build."

else
echo "${boldred}Build failed!${yellow}, please fix the error(s) and try again."
fi