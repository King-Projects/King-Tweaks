#!/system/bin/sh
# Thanks to bdashore3 @ GitHub
# Thanks to Draco (tytydraco @ GitHub)

date=`date`
type=beta
hash=`git rev-parse --short HEAD`
version=`cat module.prop | grep version= | sed "s/version=//"`

echo "builddate=$date
buildtype=$type" > $(pwd)/info.prop
 
echo "Zipping KTSR-$version-$hash..."

zip -r "KTSR-$version-$hash.zip" . -x *.git* -x "*.zip" -x build.sh

mv "KTSR-$version-$hash.zip" ../out

echo "Done, check the folder to the finished build."