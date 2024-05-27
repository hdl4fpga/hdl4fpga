@echo off
if not defined width (
	set width=800
)

if not defined pixel (
	set pixel=rgb24
)

if not defined baddr (
	set baddr=0
)

if not defined bsize (
	set bsize=1280
)

if not defined pktmd (
	set pktmd=PKT
)

if "%pktmd%"=="PKT" (
	set popt=-p
)

magick - -resize %width% -size %width% rgb:- | .\bin\rgb8topixel -f %pixel%|.\bin\format -b %bsize%|.\bin\bundle -b %baddr% %popt% 