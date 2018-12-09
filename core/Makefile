TASM  = C:\DEVELOP\BC\TASMX
TLINK = C:\DEVELOP\BC\TLINK
EMAKE = C:\PSION\DEVELOP\SIBOSDK\SYS\EMAKE

all: ..\zxemul.ldd ..\zxdos.obj

clean: 
	del OBJ\*.* 	     
	del ..\zxemul.ldd    >NUL
	del ..\zxdos.obj     >NUL

..\zxemul.ldd: OBJ\zxemul.exe
	$(EMAKE) -s -t2 -o..\zxemul OBJ\zxemul 

OBJ\zxemul.exe: OBJ\zxemul.obj
	$(TLINK) /v /n OBJ\zxemul.obj,OBJ\zxemul.exe,OBJ\zxemul.map

OBJ\zxemul.obj: zxemul.asm
	$(TASM) /ml /l zxemul.asm,OBJ\zxemul.obj

..\zxdos.obj: zxdos.asm
	$(TASM) /ml /l zxdos.asm,..\zxdos.obj

