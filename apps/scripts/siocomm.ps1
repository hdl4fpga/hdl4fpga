param (
	[string]$file,
	[string]$hostname,
	[string]$usbdev,
	[string]$tty = 'COM3',
	[int]$speed = 3000000
)

if ($hostname -ne '' )    {
	$process = Start-Process -FilePath .\bin\siosend.exe -RedirectStandardInput ${file} -RedirectStandardOutput ${tty} -NoNewWindow -Wait -ArgumentList "-p -h ${hostname}"
} elseif ($usbdev -ne '') {                                                                                                           
	$process = Start-Process -FilePath .\bin\siosend.exe -RedirectStandardInput ${file} -RedirectStandardOutput NUL    -NoNewWindow -Wait -ArgumentList "-p -u ${usbdev}"  
} else {                                                                                                                              
	.\scripts\setuart.ps1 -tty "${tty}" -speed ${speed}                                                                                  
	$process = Start-Process `
		-FilePath .\bin\siosend.exe `
		-ArgumentList "-p" `
		-RedirectStandardInput ${file} `
		-RedirectStandardOutput ${tty} `
		-NoNewWindow -Wait
}