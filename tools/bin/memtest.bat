@ECHO OFF
for %%F in (%0) do set dirname=%%~dpF
WHERE /Q AWK
IF %ERRORLEVEL% NEQ 0 "%dirname%"DOS-MEMTEST %1 %2
WHERE /Q TAIL
IF %ERRORLEVEL% NEQ 0 "%dirname%"DOS-MEMTEST %1 %2
"%dirname%"GNUWIN32-MEMTEST %1 %2
