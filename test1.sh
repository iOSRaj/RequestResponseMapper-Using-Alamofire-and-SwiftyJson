#!/bin/sh
#
# build script executed by Build Server

#pod repo update

rm -rf Podfile.lock
pod install

# if build is triggered by another project, only do a dryrun
if [[ $bamboo_dependency_parent_0 != "" ]]; then
	DRYRUN_COMMAND=" -dry-run"
else
	DRYRUN_COMMAND=" "
fi

xcodebuild -list
xcodebuild clean

#XCODEBUILD_COMMAND="xcodebuild -workspace \"RequestResponseMapper.xcworkspace\" -scheme \"RequestResponseMapper\" -arch arm64 $DRYRUN_COMMAND"
#echo ">>> ${XCODEBUILD_COMMAND}"
#eval $XCODEBUILD_COMMAND


#xcodebuild -project RequestResponseMapper.xcodeproj -list | \
#awk 'p && NF {print;} /Schemes:/ {p=1}' | \
#grep -v "Schemes:" | \
# while read -r -a myArray
#do
##echo "Building ${scheme}"
#echo "Schemes : ${myArray}"
#schemeArray=${myArray}
#done

XCODESCHEME="xcodebuild -project \"RequestResponseMapper.xcodeproj\" -list"
echo ">>>SCHEME ${XCODESCHEME}"
eval $XCODESCHEME


eval ${XCODESCHEME} | \
awk 'p && NF {print;} /Schemes:/ {p=1}' | \
grep -v "Schemes:" > scheme.txt


getArray() {
array=() # Create array
while IFS= read -r line # Read a line
do
array+=("$line") # Append line to the array
done < "$1"
}

getArray "scheme.txt"

for e in "${array[@]}"
do
echo "Value --- > $e"
done

#xcodebuild -project RequestResponseMapper.xcodeproj -list | \
#awk 'p && NF {print;} /Schemes:/ {p=1}' | \
#grep -v "Schemes:" | \
#while read scheme; do
#echo "Building ${scheme}"
#
#build_dir="$(pwd)/build"
#archivePath="${build_dir}/Archives/${scheme}.xcarchive"
#exportPath="${build_dir}/${scheme}.ipa"
#
#echo "$build_dir"
#echo "$archivePath"
#echo "$exportPath"
#
#done
