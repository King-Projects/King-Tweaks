#!/system/bin/sh
# Thanks to bdashore3 @ GitHub
# Thanks to Draco (tytydraco @ GitHub)

date=`date`
hash=`git rev-parse --short HEAD`
version=`cat module.prop | grep version= | sed "s/version=//"`

read -p 'Build type: ' build_type

echo "builddate=$date
buildtype=$build_type" > $(pwd)/info.prop
 
echo "Zipping KTSR-$version-$hash..."

zip -r "KTSR-$version-$hash.zip" . -x *.git* -x *.zip -x *.bak -x build.sh

mv "KTSR-$version-$hash.zip" ../out

rm $(pwd)/info.prop

echo "Done, check the folder to the finished build."