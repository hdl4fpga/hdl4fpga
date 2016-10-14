@echo off
for %%F in (%0) do set dirname=%%~dpF
%dirname%..\..\tools\bin\memtest 65536 128 %1
