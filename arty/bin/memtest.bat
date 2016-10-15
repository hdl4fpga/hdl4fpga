for %%F in (%0) do set dirname=%%~dpF
"%dirname%..\..\tools\bin\memtest.bat" 262144 64 %1
