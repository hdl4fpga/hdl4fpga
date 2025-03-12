@REM Author(s):                                                                
@REM   Miguel Angel Sagreras                                                   
@REM                                                                           
@REM Copyright (C) 2015                                                        
@REM    Miguel Angel Sagreras                                                  
@REM                                                                           
@REM This source file may be used and distributed without restriction provided 
@REM that this copyright statement is not removed from the file and that any   
@REM derivative work contains  the original copyright notice and the associated
@REM disclaimer.                                                               
@REM                                                                           
@REM This source file is free software; you can redistribute it and/or modify  
@REM it under the terms of the GNU General Public License as published by the  
@REM Free Software Foundation, either version 3 of the License, or (at your    
@REM option) any later version.                                                
@REM                                                                           
@REM This source is distributed in the hope that it will be useful, but WITHOUT
@REM ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or     
@REM FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for  
@REM more details at http://www.gnu.org/licenses/.                             
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