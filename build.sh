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

# Make new dir for Add On
mkdir -p tmp_build/octpopus_deploy_addon

# Copy folders and Assets
cp -r src/bin tmp_build/octpopus_deploy_addon
cp -r src/default tmp_build/octpopus_deploy_addon
cp -r src/static tmp_build/octpopus_deploy_addon

cp README.md tmp_build/octpopus_deploy_addon/README.md # README from repo

# Set permissions on the app
chmod -R 777 tmp_build/octpopus_deploy_addon/bin/octopus_deploy_client.py

# Remove any Python Cache
find tmp_build/octpopus_deploy_addon -name "*.pyc" -delete

# Remove any hidden files 
find tmp_build/octpopus_deploy_addon -name '._*' -type f -delete
find tmp_build/octpopus_deploy_addon -name ".*" -exec rm -rf {} \;

# Increment Build Number
echo "Using version $APP_VERSION"
echo "-----------------------------------------------------------"
bumpversion \
    --current-version 0.0.1 \
    --new-version $APP_VERSION \
    tmp_build/octpopus_deploy_addon/default/app.conf \
    --allow-dirty

# Package the app
cd tmp_build
tar -czvf octopusdeploy-addon.tgz octpopus_deploy_addon
# Back to the root.
cd ..

echo
echo "-----------------------------------------------------------"
echo "Running PyTest"
echo "-----------------------------------------------------------"
py.test test/

echo
echo "-----------------------------------------------------------"
echo "Running Splunk AppInspect"
echo "-----------------------------------------------------------"
splunk-appinspect inspect tmp_build/octopusdeploy-addon.tgz

