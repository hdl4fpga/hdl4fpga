call npm install nw --nwjs_build_type=sdk
call npm -g install nw-gyp
call npm install serialport
call npm view nw version > nwjs.ver
setlocal enableDelayedExpansion
set /P "_nwjsver=" < nwjs.ver
pushd node_modules\@serialport\bindings\
call nw-gyp rebuild --target=%_nwjsver% --arch=x64
popd
del nwjs.ver
mklink /D html  ..\html
mklink /D srcjs ..\srcjs 
