windows : tools\bin\scope.exe tools\bin\check.exe

tools\bin\scope.exe : tools\src\scope.c
	gcc -O2 -DWINDOWS tools\src\scope.c -o tools\bin\scope -static -lwsock32

tools\bin\check.exe: tools\src\check.c
	gcc -O2 tools\src\check.c -o tools\bin\check -static 
