param (
	[string]$file,
	[string]$hostname,
	[string]$usbdev,
	[string]$tty,
	[int]$speed
)

if ($hostname -ne "" ) {
	Start-Process -FilePath .\bin\siosend.exe -ArgumentList "-p -h $hostname" -RedirectStandardInput $file  -RedirectStandardOutput ${tty} -NoNewWindow -Wait
} elseif ($usbdev -ne "") {
	Start-Process -FilePath .\bin\siosend.exe -ArgumentList "-p -u $usbdev"   -RedirectStandardInput $file -RedirectStandardOutput NUL -NoNewWindow -Wait
} else {
	Start-Process -FilePath .\bin\siosend.exe -ArgumentList "-p"              -RedirectStandardInput $file  -RedirectStandardOutput $tty -NoNewWindow -Wait
}
