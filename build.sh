#!/bin/bash

prntdash() { 
echo "-----------------------------------------------------------"
}

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

prntdash
echo "Build Number: $OCTO_BUILD"

# Create/Clean up folder
rm -rf tmp_build

# Make new dir for Add On
mkdir -p tmp_build/octpopus_deploy_addon

# Copy folders and Assets
cp -r src/bin tmp_build/octpopus_deploy_addon
cp -r src/default tmp_build/octpopus_deploy_addon
cp -r src/static tmp_build/octpopus_deploy_addon

# Remove any Python Cache
find tmp_build/octpopus_deploy_addon -name "*.pyc" -delete

# Increment Build Number
echo "Using version $APP_VERSION"
prntdash
bumpversion \
    --current-version 0.0.0 \
    --new-version $APP_VERSION \
    tmp_build/octpopus_deploy_addon/default/app.conf \
    --allow-dirty

# Package the app
cd tmp_build
tar -czvf octopusdeploy-addon.tgz octpopus_deploy_addon

# Run Splunk AppInspect
splunk-appinspect inspect octopusdeploy-addon.tgz

# Back to the root.
cd ..