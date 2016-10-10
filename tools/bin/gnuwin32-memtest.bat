@ECHO OFF
DEL DUMP0 DUMP
SCOPE %1 %2 > DUMP0
IF %ERRORLEVEL% NEQ 0 EXIT
SET I=1
:NEXT
  	SCOPE %1 %2 > DUMP
	IF %ERRORLEVEL% NEQ 0 EXIT
 	CMP DUMP0 DUMP > LOG
	IF %ERRORLEVEL% EQU 0 (
		ECHO READ NUMBER %I%
		SET /A I=%I%+1
		GOTO NEXT
	)
	for /f "delims=" %%I in ('awk "{print $7}" LOG') do set a=%%I
echo line %a%
tail -n +%a% DUMP0 2>nul|head
echo '-----'
tail -n +%a% DUMP1 2>nul|head
