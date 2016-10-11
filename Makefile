windows : tools\bin\scope.exe tools\bin\check.exe

tools\bin\scope.exe : tools\src\scope.c
	gcc -O2 -DWINDOWS tools\src\scope.c -o tools\bin\scope.exe -lwsock32

tools\bin\check.exe: tools\src\check.c
	gcc -O2 tools\src\check.c -o tools\bin\check.exe

linux : tools/bin/scope tools/bin/check

tools/bin/scope : tools/src/scope.c
	gcc -O2 tools/src/scope.c -o tools/bin/scope 

tools/bin/check: tools/src/check.c
	gcc -O2 tools/src/check.c -o tools/bin/check

clean :
	del tools\bin\check.exe tools\bin\scope.exe
	rm  tools/bin/check tools/bin/scope
