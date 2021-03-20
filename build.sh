#!/system/bin/sh
# By pedro (pedrozzz0 @ GitHub)
# Thanks to bdashore3 @ GitHub
# Thanks to Draco (tytydraco @ GitHub)

date=`date`
version=`cat module.prop | grep version= | sed "s/version=//"`

read -p 'Build type: ' build_type

read -p 'Codename: ' codename

echo "builddate=$date
buildtype=$build_type
codename=$codename" > $(pwd)/info.prop
 
echo "Zipping KTSR-$version-$build_type-$codename..."

zip -r "KTSR-$version-$build_type-$codename.zip" . -x *.git* -x *.zip -x C1.sh -x kingauto -x kingtweaks -x *.apk -x *.bak -x libktsr.sh -x kcal.sh -x build.sh

mv "KTSR-$version-$build_type-$codename.zip" ../out

rm $(pwd)/info.prop

echo "Done, check the folder to the finished build."