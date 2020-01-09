#!/bin/sh
npm install nw --nwjs_build_type=sdk
npm install serialport
cd node_modules/\@serialport/bindings/
nw-gyp rebuild --target=$(npm view nw version) --arch=x64
