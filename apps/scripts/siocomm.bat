@echo off
if defined host (
	.\bin\siosend.exe -p -h %host% 2>NUL
) else if defined usbdev (
	.\bin\siosend.exe -p -u %usbdev 2>NUL
) else if defined tty (
	if not defined speed (
		set speed=3000000
	)
	mode %tty% %speed%,n,8,1 < nul 2> nul
	.\bin\siosend.exe -p 1>nul
)