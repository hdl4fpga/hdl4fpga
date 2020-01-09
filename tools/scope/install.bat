rem npm install nw --nwjs_build_type=sdk
rem npm install serialport
cd node_modules\@serialport\bindings\
set PATH=%PATH%;f:\python27;
nw-gyp rebuild --target=0.43.3 --arch=x64
