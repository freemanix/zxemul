
; ZX Spectrum emulator 

; MS-DOS emulation entry points
; (c) Freeman, August 2000, Prague

; -----------------------------------------------------------------------------

		.MODEL		small
		.CODE
		
		ASSUME		DS:_TEXT

; -----------------------------------------------------------------------------

ZXMemory	DW		?		

; -----------------------------------------------------------------------------

		INCLUDE		zxregs.asm
		INCLUDE		zxfetch.asm
		INCLUDE		zxload.asm
		INCLUDE		zxflow.asm
		INCLUDE		zxaritm.asm
		INCLUDE		zxbits.asm
		INCLUDE		zxblock.asm
		INCLUDE		zxio.asm
		INCLUDE		zxtable.asm

; -----------------------------------------------------------------------------

PUBLIC		C		ZXGInit
PUBLIC		C		ZXGClose
PUBLIC		C		ZXGSetPal
PUBLIC		C		ZXGGetKey
PUBLIC		C		ZXGGetShift

PUBLIC		C		ZXGetRegs
PUBLIC		C		ZXSetRegs
PUBLIC		C		ZXGetPort
PUBLIC		C		ZXSetPort
PUBLIC		C		ZXSetKeys
PUBLIC		C		ZXReset
PUBLIC		C		ZXGenINT
PUBLIC		C		ZXGenNMI
PUBLIC		C		ZXEmulate

; -----------------------------------------------------------------------------
		
ZXGInit		PROC	C

		mov 		ax,0013h	
		int 		10h
		ret

ZXGInit		ENDP

; -----------------------------------------------------------------------------

ZXGClose	PROC	C

		mov    		ax,0003h
		int 		10h
                ret

ZXGClose	ENDP

; -----------------------------------------------------------------------------

ZXGSetPal	PROC	C	TBL:PTR, NUM:WORD

		push		es
		
		mov		ax, ds
		mov		es, ax

		mov		ax, 1012h
		mov		bx, 0
		mov		cx, NUM
		mov		dx, TBL
		int		10h
	
		pop		es
		ret
		
ZXGSetPal	ENDP

; -----------------------------------------------------------------------------

ZXGGetKey	PROC	C

		mov		ah, 01h
		int		16h
		jnz		ZXEnd
		xor		ax, ax
ZXEnd:		ret
		
ZXGGetKey	ENDP

; -----------------------------------------------------------------------------

ZXGGetShift	PROC	C

		mov		ah, 02h
		int		16h
		xor		ah, ah
		
		ret

ZXGGetShift	ENDP

; -----------------------------------------------------------------------------

PortKey		PROC		

		lodsb
		mov		bx, offset InPortFE
		mov		cx, 256
PortLoop:	test		ah, dl
		jnz		PortNext
		and		cs:[bx], al
PortNext:	inc		ah
		inc		bx
		loop		PortLoop
		ret
		
PortKey		ENDP

; -----------------------------------------------------------------------------

ZXGetRegs	PROC	C	REGS:PTR Z80Regs

		push		si
		push		di
		push		ds
		push		es
		
		mov		ax, ds
		mov		es, ax
		mov		ax, cs
		mov		ds, ax

		cld
		mov		cx, (SIZE Z80Regs)/2
		mov		si, offset Registers
		mov		di, REGS
		rep		movsw
		
		pop		es
		pop		ds
		pop		di
		pop		si
		
		ret
		
ZXGetRegs	ENDP

; -----------------------------------------------------------------------------

ZXSetRegs	PROC	C	REGS:PTR Z80Regs

		push		si
		push		di
		push		es
	
		mov		ax, cs
		mov		es, ax

		cld
		mov		cx, (SIZE Z80Regs)/2
		mov		si, REGS
		mov		di, offset Registers
		rep		movsw
	
		pop		es
		pop		di
		pop		si
		
		ret

ZXSetRegs	ENDP

; -----------------------------------------------------------------------------

ZXGetPort	PROC	C	PORT:BYTE

		mov		bl, PORT
		xor		bh, bh
		mov		al, cs:[bx+AllPorts]
		xor		ah, ah
		
		ret		
		
ZXGetPort	ENDP

; -----------------------------------------------------------------------------

ZXSetPort	PROC	C	PORT:BYTE, VAL:BYTE

		mov		bl, PORT
		xor		bh, bh
		mov		al, VAL
		mov		cs:[bx+AllPorts], al
		
		ret		
		
ZXSetPort	ENDP

; -----------------------------------------------------------------------------

ZXSetKeys	PROC	C	KEYS:PTR

		push		si
		push		es
		
		mov		ax, cs
		mov		es, ax
		
		mov		cx, 128
		mov		di, offset InPortFE
		mov		ax, 0FFFFh
		rep		stosw
		
		mov		si, KEYS
		xor		ah, ah

		mov		dl, NOT 07Fh
		call		PortKey
		mov		dl, NOT 0BFh
		call		PortKey
		mov		dl, NOT 0DFh
		call		PortKey
		mov		dl, NOT 0EFh
		call		PortKey
		mov		dl, NOT 0F7h
		call		PortKey
		mov		dl, NOT 0FBh
		call		PortKey
		mov		dl, NOT 0FDh
		call		PortKey
		mov		dl, NOT 0FEh
		call		PortKey
		
		pop		es
		pop		si		
		
		ret

ZXSetKeys	ENDP

; -----------------------------------------------------------------------------

ZXReset		PROC	C	ZXSEG:WORD

		push		di
		push		es
		
		mov		ax, cs
		mov		es, ax
		
		cld
		mov		cx, (SIZE Z80Regs)/2
		xor		ax, ax
		mov		di, offset Registers
		rep		stosw
		
		mov		ax, ZXSEG
		mov		cs:ZXMemory, ax

		mov		cs:HaltFlag, 0
		
		pop		es
		pop		di
		
		ret

ZXReset		ENDP

; -----------------------------------------------------------------------------

ZXGenINT	PROC
		
		push		bp
		push		si
		push		di
		push		ds
		push		es
		
		mov		ax, cs
		mov		ds, ax
		mov		es, ZXMemory

		mov		RegSP, Registers.rSP
		mov		RegPC, Registers.rPC

		GenerateINT
		
		mov		Registers.rPC, RegPC
		mov		Registers.rSP, RegSP

		pop		es
		pop		ds
		pop		di
		pop		si
		pop		bp
		
		ret

ZXGenINT	ENDP

; -----------------------------------------------------------------------------

ZXGenNMI	PROC

		push		bp
		push		si
		push		di
		push		ds
		push		es

		mov		ax, cs
		mov		ds, ax
		mov		es, ZXMemory
		
		mov		RegSP, Registers.rSP
		mov		RegPC, Registers.rPC

		GenerateNMI

		mov		Registers.rPC, RegPC
		mov		Registers.rSP, RegSP
		
		pop		es
		pop		ds
		pop		di
		pop		si
		pop		bp
		
		ret

ZXGenNMI	ENDP

; -----------------------------------------------------------------------------

ZXEmulate	PROC	C	OPS:WORD

		push		si
		push		di
		push		ds
		push		es
	
		mov		ax, cs
		mov		ds, ax
		mov		es, ZXMemory
		
		cld
		
		mov		al, RegR
		and		al, mskR7
		mov		RegR7bit, al
		
		mov		ax, OPS
		add		RegR, al
		inc		ax
		
		GetAllRegs

FetchSwap:	mov		di, ax
Fetch:		dec		di
		jz		Stop
		TableXlat	OpTable	  	
		
Stop:		mov		al, RegR
		and		al, NOT mskR7
		or		al, RegR7bit
		mov		RegR, al

		SetAllRegs
		
		pop		es
		pop		ds
		pop		di
		pop		si
		
		ret

ZXEmulate	ENDP

; -----------------------------------------------------------------------------

		END