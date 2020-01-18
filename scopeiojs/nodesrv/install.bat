call npm install bufferutil
call npm install utf-8-validate
call npm install socket.io
call npm install serialport
del nodesrv.js
del comm.js
mklink /H nodesrv.js ..\srcjs\nodesrv.js 
mklink /H comm.js    ..\srcjs\comm.js 
