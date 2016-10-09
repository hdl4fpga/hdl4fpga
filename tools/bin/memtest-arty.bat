@ECHO OFF
DEL PP PP1
SCOPE 262144 64 > PP
SET I=1
:NEXT
  	SCOPE 262144 64  > PP1
 	CMP pp pp1 > log
	IF %ERRORLEVEL% EQU 0 (
		ECHO READ NUMBER %I%
		SET /A I=%I%+1
		GOTO NEXT
	)
	for /f "delims=" %%i in ('awk "{print $7}" log') do set a=%%i
echo line %a%
tail -n +%a% pp 2>nul|head
echo '-----'
tail -n +%a% pp1 2>nul|head
