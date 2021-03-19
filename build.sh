#!/system/bin/sh
# By pedro (pedrozzz0 @ GitHub)
# Thanks to bdashore3 @ GitHub
# Thanks to Draco (tytydraco @ GitHub)

date=`date`
version=`cat module.prop | grep version= | sed "s/version=//"`

read -p 'Build type: ' build_type

echo "builddate=$date
buildtype=$build_type" > $(pwd)/info.prop
 
echo "Zipping KTSR-$version-$build_type..."

zip -r "KTSR-$version-$build_type.zip" . -x *.git* -x *.zip -x C1.sh -x kingauto -x kingtweaks -x *.apk -x *.bak -x libktsr.sh -x kcal.sh -x build.sh

mv "KTSR-$version-$build_type.zip" ../out

rm $(pwd)/info.prop

echo "Done, check the folder to the finished build."