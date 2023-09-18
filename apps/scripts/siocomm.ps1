param (
	[string]$file,
	[string]$hostname,
	[string]$usbdev,
	[string]$tty = 'COM3',
	[int]$speed = 3000000
)

if ($hostname -ne '' )    {
	Start-Process `
		-FilePath .\bin\siosend.exe `
		-ArgumentList "-p -h ${hostname}" `
		-RedirectStandardInput ${file} `
		-RedirectStandardOutput NUL `
		-NoNewWindow -Wait
} elseif ($usbdev -ne '') {                                                                                                           
	Start-Process `
		-FilePath .\bin\siosend.exe `
		-ArgumentList "-p -u ${usbdev}" `
		-RedirectStandardInput ${file} `
		-RedirectStandardOutput NUL `
		-NoNewWindow -Wait 
} else {                                                                                                                              
	.\scripts\setuart.ps1 -tty "${tty}" -speed ${speed}                                                                                  
	Start-Process `
		-FilePath .\bin\siosend.exe `
		-ArgumentList "-p" `
		-RedirectStandardInput ${file} `
		-RedirectStandardOutput NUL `
		-NoNewWindow -Wait
}