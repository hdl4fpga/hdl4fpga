param (
	[string]$tty,
	[string]$speed
)

Start-Process -FilePath "mode.com" -ArgumentList "${tty}:${speed},n,8,1" -NoNewWindow -Wait