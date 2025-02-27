@REM Copyright (c) <2015> <Miguel Angel Sagreras>                                   
@REM                                                                                
@REM Permission is hereby granted, free of charge, to any person obtaining a copy of
@REM this software and associated documentation files (the "Software"), to deal in  
@REM the Software without restriction, including without limitation the rights to   
@REM use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies  
@REM of the Software, and to permit persons to whom the Software is furnished to do 
@REM so, subject to the following conditions:                                       
@REM                                                                                
@REM The above copyright notice and this permission notice shall be included in all 
@REM copies or substantial portions of the Software.                                
@REM                                                                                
@REM THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i   
@REM IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       
@REM FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    
@REM AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         
@REM LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  
@REM OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  
@REM SOFTWARE.                                                                      
@REM                                                                                

@echo off
if defined host (
	.\bin\siosend.exe -p -h %host% 2>NUL
) else if defined usbdev (
	.\bin\siosend.exe -p -u %usbdev 2>NUL
) else if defined tty (
	if not defined speed (
		set speed=3000000
	)
)

if defined tty (
	if defined speed (
		mode %tty% %speed%,n,8,1 < nul 2> nul
		.\bin\siosend.exe -p 1>nul
	)
