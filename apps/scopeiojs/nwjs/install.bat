@REM Copyright (c) 2015 Miguel Angel Sagreras                                       
@REM                                                                                
@REM Permission is hereby granted, free of charge, to any person obtaining a copy   
@REM of this software and associated documentation files (the "Software"), to deal  
@REM in the Software without restriction, including without limitation the rights   
@REM to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      
@REM copies of the Software, and to permit persons to whom the Software is          
@REM furnished to do so, subject to the following conditions:                       
@REM                                                                                
@REM The above copyright notice and this permission notice shall be included in all 
@REM copies or substantial portions of the Software.                                
@REM                                                                                
@REM THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     
@REM IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       
@REM FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    
@REM AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         
@REM LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  
@REM OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  
@REM SOFTWARE.                                                                      
@REM                                                                                

@SET PYTHON=C:\Python27\python.exe
@SET PATH=C:\Python27;%PATH%
DEL package-lock.json
CALL npm install nw-gyp
CALL npm install --save-dev "nw@sdk"
CALL npm view nw version > nwjs.ver
CALL npm install ----msvs_version=2019
CALL npm install serialport
CALL npm install usb
SET /P "_NWJSVER=" < NWJS.VER
SET "file_path=./node_modules/nw-gyp/lib/configure.js"
REM See https://github.com/nwjs/nw-gyp/issues/155
POWERSHELL -Command "(Get-Content -Path '%file_path%') | ForEach-Object { $_ -replace 'var config = process.config', 'var config = JSON.parse(JSON.stringify(process.config))' } | Set-Content -Path '%file_path%'"
PUSHD node_modules\@serialport\bindings-cpp\
@REM ECHO %_NWJSVER%
CALL npx nw-gyp rebuild --target=%_NWJSVER% --arch=x64
POPD
PUSHD node_modules\usb
CALL npx nw-gyp rebuild --target=%_NWJSVER% --arch=x64
POPD
DEL nwjs.ver
MKLINK /D html  ..\html 
MKLINK /D srcjs ..\srcjs
