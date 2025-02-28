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

@echo off
if not defined width (
	set width=800
)

if not defined pixel (
	set pixel=rgb24
)

if not defined baddr (
	set baddr=0
)

if not defined bsize (
	set bsize=1280
)

if not defined pktmd (
	set pktmd=PKT
)

if "%pktmd%"=="PKT" (
	set popt=-p
)

magick - -resize %width% -size %width% rgb:- | .\bin\rgb8topixel -f %pixel%|.\bin\format -b %bsize%|.\bin\bundle -b %baddr% %popt% 


