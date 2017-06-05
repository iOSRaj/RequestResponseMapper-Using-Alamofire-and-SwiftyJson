#!/bin/sh
#
# build script executed by Build Server

echo 'Let the Action Begins'
# echo all commands
#set -x
#
#PS4='Line ${LINENO}: '
########################################################################
readPomFile() {
POM_FILE="./.pom"
source "${POM_FILE}"
}
########################################################################

installCocoapods(){
ls -lastrh
if [ -e "Podfile" ]
then
#pod repo update
rm -rf Podfile.lock
pod install
WORKSPACE="`ls -d *.xcworkspace`"
COCOAPODS_BUILD_ARGUMENT="-workspace \"$WORKSPACE\""
fi
PROJECT_FOLDER_NAME="`ls -a | grep xcworkspace -m 1 | cut -d'.' -f 1`"
}

########################################################################

getNumberOfSwiftFiles() {
NUMBER_OF_SWIFT_FILES="`find ${PROJECT_FOLDER_NAME} * "(" -name "*.swift" ")" -type f | wc -l`"
echo "Number of swift files: ${NUMBER_OF_SWIFT_FILES}"
}

getLinesOfCode() {
LINES_OF_CODE="`find ${PROJECT_FOLDER_NAME} * "(" -name "*.m" -or -name "*.mm" -or -name "*.cpp" -or -name "*.swift" ")" -print0 | xargs -0 wc -l | grep total | sed -e 's/^[ \t]*//' | cut -d' ' -f 1`"
echo "Lines of code: ${LINES_OF_CODE}"
}

postLinesOfCode() {
echo "Project: ${PROJECT_FOLDER_NAME}"
getLinesOfCode
getNumberOfSwiftFiles
}


########################################
### Sets build number in given plist ###
########################################
setBuildNumber() {
if [[ -z "$1" || -z "$2" ]]; then
fail "setBuildNumber requires plist & buildnumber arguments."
else
echo "Setting build number in ${1%.*} to $2"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $2" "$1" || exit 1
fi
}

##########################################
### Update plists with new buildNumber ###
##########################################
updateBuildNumber() {
# Loop through Info Plist's
for (( i = 0 ; i < ${#INFO_PLISTS_ARR[@]} ; i++ )); do
INFO_PLIST=${INFO_PLISTS_ARR[$i]}
setBuildNumber "$INFO_PLIST" "`date +"%Y%m%d%H%M%S"`"
done
}


########################################################################
#XCODESCHEME="xcodebuild -project \"${PROJECT_FOLDER_NAME}.xcodeproj\" -list"
#echo ">>>SCHEME ${XCODESCHEME}"
#eval $XCODESCHEME
#
#eval ${XCODESCHEME} | \
#awk 'p && NF {print;} /Schemes:/ {p=1}' | \
#grep -v "Schemes:" > scheme.txt
#
#
#readSchemes() {
#schemeArray=() # Create array
#while IFS= read -r line # Read a line
#do
#array+=("$line") # Append line to the array
#done < "$1"
#}
#
#readSchemes "scheme.txt"
#
#for e in "${schemeArray[@]}"
#do
#echo "Schemes: --- > $e"
#done
########################################################################

xcodebuild -list
xcodebuild clean

#XCODEBUILD_COMMAND="xcodebuild -workspace \"${WORKSPACE}\" -scheme \"RequestResponseMapper\" -arch arm64"
#echo ">>> ${XCODEBUILD_COMMAND}"
#eval $XCODEBUILD_COMMAND



########################################################################
function _postToHipchat {
SLACK_COMMAND="curl -X POST --data-urlencode 'payload={\"channel\": \"#general\", \"username\": \"webhookbot\", \"text\": \" Message from bamboo : ${APP_SCHEME} ${VERSION_NUMBER} ${DEPLOYMENT_TYPE}\", \"icon_emoji\": \":ghost:\"}' \"https://hooks.slack.com/services/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\""
echo ">>> ${SLACK_COMMAND}"
eval $SLACK_COMMAND
}




########################################################################
# Ready Set Go
########################################################################
PROJECT_DIR=`pwd`
echo ">>> PROJECT_DIR: ${PROJECT_DIR}"
GIT_BRANCH_TO_MERGE_FROM="`git rev-parse --abbrev-ref HEAD`" # is the current branch
LOCALRUN=false
DEPLOY="YES"
COCOAPODS_BUILD_ARGUMENT=""
WORKSPACE=""
SERVER_IP_ADDRESS=`ifconfig en0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`

echo ">>> SERVER_IP_ADDRESS: ${SERVER_IP_ADDRESS}"
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo ">>> SCRIPTDIR: ${SCRIPTDIR}"

readPomFile
installCocoapods
postLinesOfCode

echo ">>> COCOAPODS_BUILD_ARGUMENT: ${COCOAPODS_BUILD_ARGUMENT}"

echo ">>> WORKSPACE: ${WORKSPACE}"


########################################################################

if [ "${bamboo_3_BUILD_TYPE}" = "SNAPSHOT" ] && [ "${bamboo_planRepository_1_branch}" != "release" ] ; then

figlet -w 400 -f big ">>> Starting snapshot build"

WEBDAV_SERVER="https://DOMAIN_URL/content/repositories/snapshots"
DEPLOYMENT_TYPE="SNAPSHOT"

# SNAPSHOT arrays
APP_SCHEMES_ARR=(${APP_SCHEMES[@]})
INFO_PLISTS_ARR=(${INFO_PLISTS[@]})

#set -x #echo on
updateBuildNumber
_build "-dry-run"
_build "archive"
#set +x #echo off

fi

echo "Build script completed."

exit 0







########################
### Create OTA files ###
########################
_createOTA() {
if [[ -z "$1" || -z "$2"  || -z "$3" ]]; then
fail "Expected three arguments"
else

echo ">>> ARG1 (URL +BASEPATH) ='${1}'"
echo ">>> ARG2 (     PATH    ) ='${2}'"
echo ">>> ARG3 (FILE_LOCATION) ='${3}'"

# Create OTA plist in targetDir (not indented because that generates troubles...)
cat << EOF > "${3}.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>items</key>
<array>
<dict>
<key>assets</key>
<array>
<dict>
<key>kind</key>
<string>software-package</string>
<key>url</key>
<string>${1}${2}</string>
</dict>
<dict>
<key>kind</key>
<string>display-image</string>
<key>needs-shine</key>
<false/>
<key>url</key>
<string>${1}${2}.png</string>
</dict>
</array>
<key>metadata</key>
<dict>
<key>bundle-identifier</key>
<string>${BUNDLE_ID}</string>
<key>bundle-version</key>
<string>${VERSION_NUMBER}</string>
<key>kind</key>
<string>software</string>
<key>subtitle</key>
<string>${APP_SCHEME}</string>
<key>title</key>
<string>${2}</string>
</dict>
</dict>
</array>
</dict>
</plist>
EOF

# Create install.html in targetDir (not indented because that generates troubles...)
cat << EOF > "${3}-install.html"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
<TITLE>${IPA_ARTIFACT}</TITLE>
<meta name="viewport" content="initial-scale=1.0">
</HEAD>
<BODY>
<CENTER>
<A href="itms-services://?action=download-manifest&url=${WEBDAV_URL}${IPA_ARTIFACT}.plist"><IMG src="${WEBDAV_URL}${IPA_ARTIFACT}.png">
<P style="font-family: museo-sans-1, museo-sans-2, sans-serif;font-size:18px;">
Install ${IPA_ARTIFACT}
</P>
</A>
</CENTER>
</BODY>
</HTML>
EOF

fi
}

##########################
### creates QR barcode ###
##########################
qrurl() {
if [[ -z "$1" || -z "$2" ]]; then
fail "Usage: qrurl http://www.google.com googleQRUrl.png"
else
echo "Creating QR png for $1"
curl "http://chart.apis.google.com/chart?chs=300x300&cht=qr&chld=H%7C0&chl=$1" -o "$2";
fi
}





##########################################
### Sets version number in given plist ###
##########################################
setVersionNumber() {
if [[ -z "$1" || -z "$2" ]]; then
fail "setVersionNumber requires plist & versionnumber arguments."
else
echo "Setting version number in ${1%.*} to $2"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $2" "$1" || exit 1
fi
}



#############################################
### Update plists with new versionNumbers ###
#############################################
updatePlists() {
if [ "${bamboo_2_NEXT_RELEASE_VERSION_STRING}" != "" ]; then
# switch to development branch and update info.plist
git checkout development || exit 1
# Link branch to origin
git branch --set-upstream-to=origin/development development
# update local branch with latest from origin
git pull origin development

# Loop through Info Plist's
for (( i = 0 ; i < ${#INFO_PLISTS_ARR[@]} ; i++ )); do
INFO_PLIST=${INFO_PLISTS_ARR[$i]}
setVersionNumber "$INFO_PLIST" "${bamboo_2_NEXT_RELEASE_VERSION_STRING}"
setBuildNumber "$INFO_PLIST" "`date +"%Y%m%d%H%M%S"`"
git add "$INFO_PLIST"
done

# Commit with msg
git commit -m "Setting next version in branch" || fail "Failed to commit"

# push plist
git push origin || fail "git push origin"
fi
}


#######################################
### Check if tag already exists.... ###
#######################################
checkIfTagExists() {
if GIT_DIR="$PROJECT_DIR/.git" git rev-parse "$1^{tag}" >/dev/null 2>&1
then
fail "Git tag already exists... Exiting before building..."
fi
}

#######################################
### Performs the actual tag command ###
#######################################
performTagCommand() {
# Tag the release / master branch build with the given version
git tag  -a "$APP_NAME-${bamboo_1_THIS_RELEASE_VERSION_STRING}" -m "Release $APP_NAME-${bamboo_1_THIS_RELEASE_VERSION_STRING}" || fail "Failed to tag $APP_NAME-${bamboo_1_THIS_RELEASE_VERSION_STRING}"
}


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
