@echo off
for %%F in (%0) do set dirname=%%~dpF
%dirname%..\..\tools\bin\memtest 262144 128 %1
