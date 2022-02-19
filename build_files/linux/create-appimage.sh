#!/bin/sh
rm -r Slideboom.AppDir

cp -r ../../build/linux/x64/release/bundle/ Slideboom.AppDir

cp slideboom.png Slideboom.AppDir

chmod +x AppRun
cp AppRun Slideboom.AppDir

cp slideboom.desktop Slideboom.AppDir

appimagetool Slideboom.AppDir

chmod +x Slideboom-x86_64.AppImage
mv Slideboom-x86_64.AppImage Slideboom.AppDir

