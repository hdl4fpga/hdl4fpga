@echo off
for %%F in (%0) do set dirname=%%~dpF
%dirname%..\..\tools\bin\scope -p 262144 -d 128|%dirname%..\..\tools\bin\check -v -d 128 2>&1
