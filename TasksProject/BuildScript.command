#!/bin/sh

#  BuildScript.command
#  TasksProject
#
#  Created by Super User on 03.08.13.
#  Copyright (c) 2013 Ray Wenderlich. All rights reserved.

echo "*********************************"
echo "Build Started"
echo "*********************************"

echo "*********************************"
echo "Beginning Build Process"
echo "*********************************"
xcodebuild -project "${1}" -target "${2}" -sdk iphoneos -verbose

echo "*********************************"
echo "Creating IPA"
echo "*********************************"
/usr/bin/xcrun -verbose -sdk iphoneos PackageApplication -v "${3}/${4}.app" -o "${5}/app.ipa"
