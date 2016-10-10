for %%F in (%0) do set dirname=%%~dpF
%dirname%..\..\tools\bin\memtest 131072 64
