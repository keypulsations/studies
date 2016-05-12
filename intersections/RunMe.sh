#!/bin/bash

root=$(pwd)
file=$1
cp -rf ${root}/SCMIR/SCMIRExtensions ~/Library/Application\ Support/SuperCollider/Extensions
cp -rf ${root}/SCMIR/SCMIRUgens ~/Library/Application\ Support/SuperCollider/Extensions
cp -rf ${root}/SCMIR/SCMIRUgens ~/Library/Application\ Support/SuperCollider/Extensions
cp -rf ${root}/bbcut2/bbcut2\ classes ~/Library/Application\ Support/SuperCollider/Extensions/
mkdir -p ~/Library/Application\ Support/SuperCollider/Extensions/sc3-plugins
cp -rf ${root}/PitchDetection ~/Library/Application\ Support/SuperCollider/Extensions/sc3-plugins
cp -rf ${root}/bbcut2/bbcut2\ ugens ~/Library/Application\ Support/SuperCollider/Extensions/sc3-plugins
cd /Applications/SuperCollider/SuperCollider.app/Contents/MacOS
if [ $# -eq 0 ]
  then
    exec ./sclang ${root}/intersections.scd ${root} ${root}/hooks.wav
  else
    exec ./sclang ${root}/intersections.scd ${root} ${file}
fi
