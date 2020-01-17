#!/bin/sh
npm install nw --nwjs_build_type=sdk
npm -g install nw-gyp
npm install serialport
cd node_modules/\@serialport/bindings/
npm nw-gyp rebuild --target=$(npm view nw version) --arch=x64
