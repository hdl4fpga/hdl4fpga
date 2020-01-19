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

CALL NPM INSTALL NW --NWJS_BUILD_TYPE=SDK
CALL NPM -G INSTALL NW-GYP
CALL NPM INSTALL SERIALPORT
CALL NPM VIEW NW VERSION > NWJS.VER
SETLOCAL ENABLEDELAYEDEXPANSION
SET /P "_NWJSVER=" < NWJS.VER
PUSHD NODE_MODULES\@SERIALPORT\BINDINGS\
CALL NW-GYP REBUILD --TARGET=%_NWJSVER% --ARCH=X64
POPD
DEL NWJS.VER
MKLINK /D HTML  ..\HTML
MKLINK /D SRCJS ..\SRCJS
