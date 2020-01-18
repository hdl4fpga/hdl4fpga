#!/bin/sh
sudo npm -g install nw-gyp
npm install nw --nwjs_build_type=sdk
npm install serialport
npm_config_target=`npm view nw version`
npm_config_arch="x64"
npm_config_traget_arch="x64"
export npm_config_target npm_config_arch npm_config_traget_arch
npm_config_node_gyp=`which nw-gyp`
export npm_config_node_gyp

cd node_modules/\@serialport/bindings
nw-gyp rebuild --target=`npm view nw version` --arch=x64
