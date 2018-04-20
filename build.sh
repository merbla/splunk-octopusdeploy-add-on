#!/bin/bash
set -e

# Get a build number from TravisCI
if [ "$TRAVIS_BUILD_NUMBER" = "" ]
then
    # Used for local builds
   export OCTO_BUILD=999
else
   export OCTO_BUILD=$TRAVIS_BUILD_NUMBER
fi

# Control the Major/Minor here
export MAJOR=0 
export MINOR=1
export APP_VERSION=$MAJOR.$MINOR.$OCTO_BUILD

echo "-----------------------------------------------------------"
echo "Major: $MAJOR"
echo "Minor: $MINOR"
echo "Build Number: $OCTO_BUILD"

# Create/Clean up folder
rm -rf tmp_build
rm -rf package

# Make new dir for Add On
mkdir -p tmp_build/octopus_deploy_addon

# Copy folders and Assets
cp -r src/octopus_deploy_addon tmp_build/ 
cp README.md tmp_build/octopus_deploy_addon/README.md # README from repo 

# Increment Build Number
echo "Using version $APP_VERSION"
echo "-----------------------------------------------------------"
bumpversion --current-version 0.0.1 --new-version $APP_VERSION tmp_build --allow-dirty

# Copy Pip dependencies
pip download -r src/octopus_deploy_addon/requirements.txt -d tmp_build/octopus_deploy_addon/bin

# Package the app
slim package tmp_build/octopus_deploy_addon -o package

echo
echo "-----------------------------------------------------------"
echo "Running PyTest"
echo "-----------------------------------------------------------"
pytest test/

echo
echo "-----------------------------------------------------------"
echo "Running Splunk AppInspect"
echo "-----------------------------------------------------------"
for file in package/*.tar.gz; 
do
  	splunk-appinspect inspect $file
done