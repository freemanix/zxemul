
; ZX Spectrum emulator 

; Logical device driver interface
; (c) Freeman, August 2000, Prague

; -----------------------------------------------------------------------------

		INCLUDE		epocdef.inc
	        INCLUDE 	epocmac.inc

; -----------------------------------------------------------------------------

_TEXT		SEGMENT WORD PUBLIC 'CODE'
		ASSUME	CS:_TEXT, DS:_TEXT

; -----------------------------------------------------------------------------
	
DriverStart:   	DW      	LDDSignature
        	DB      	'ZXS',0,0,0,0,0
        	DW      	(VectorEnd-VectorStart)/2
VectorStart:   	DW      	ZXS_Install
        	DW      	ZXS_Remove
        	DW      	ZXS_Hold
        	DW      	ZXS_Resume
        	DW      	ZXS_Reset
        	DW      	ZXS_Units
        	DW      	ZXS_Open
        	DW      	ZXS_Strategy
VectorEnd:
	
; -----------------------------------------------------------------------------

StrategyFunc:	DW		ZX_Reset
		DW		ZX_SetRegs
		DW		ZX_GetRegs
		DW		ZX_GenINT
		DW		ZX_GenNMI
		DW		ZX_Emulate
		DW		ZX_SetPort
		DW		ZX_GetPort
		DW		ZX_SetKeys
		DW		ZX_DrawScreen
		DW		ZX_DrawBorder
		DW		ZX_EraseGray
		DW		ZX_ForceRedraw
StrategyEnd:

FuncNum		EQU		(StrategyEnd-StrategyFunc)/2

; -----------------------------------------------------------------------------

ZXMemorySeg	DW		?

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

ZXS_Install	PROC		FAR

		; check for presence of the Freeman logo (black & grey planes)
		
		mov		ax, 040h
		mov		es, ax
		
		; keep tested data in bx, control data in cx
		
		mov		bx, es:[88*60+32]
		mov		cx, 1001101010011110b
		add		bx, es:[79*60+31+9600]
		add		cx, 0110000010000100b
		add		bx, es:[63*60+27]
		add		cx, 0011111110001111b
		
		; report NotSupportedErr if test fails
		
		mov		al, NotSupportedErr
		
		; set carry if the numbers are not equal
		
		dec		bx
		sub		bx, cx
		cmp		bx, 0FFFFh
		
		ret

ZXS_Install	ENDP
		
; -----------------------------------------------------------------------------

ZXS_Remove	PROC		FAR

		clc		
		ret

ZXS_Remove	ENDP

; -----------------------------------------------------------------------------

ZXS_Hold	PROC		FAR

		ret

ZXS_Hold	ENDP

; -----------------------------------------------------------------------------

ZXS_Resume	PROC		FAR

		ret

ZXS_Resume	ENDP

; -----------------------------------------------------------------------------

ZXS_Reset	PROC		FAR

		ret

ZXS_Reset	ENDP

; -----------------------------------------------------------------------------

ZXS_Units	PROC		FAR

		; we can be opened only once

		mov		ax, 1
		ret

ZXS_Units	ENDP

; -----------------------------------------------------------------------------

ZXS_Open	PROC		FAR

		; allocate channel data block
		
		mov		cx, size ChanEnt
		HeapAllocateCell
		jc		NoMem
		mov		bx, ax
		
		; fill up channel data 
		
		mov		[bx].ChanNext, bx
		mov		[bx].ChanSignature, IoChanSignature
		mov		[bx].ChanLibHandle, dx
		
		; finish succesfully

		clc
NoMem:		ret

ZXS_Open	ENDP
		
; -----------------------------------------------------------------------------

ZXS_Strategy	PROC		FAR

		; check if called with valid function number

		mov		ax, [si].RqFunction
		cmp		ax, FuncNum
		jge		UnknownFunc
		
		; compute strategy function procedure address
		
		add		ax, ax
		mov		di, offset StrategyFunc
		add		di, ax
		
		; call handler for given function number
		
		call		word ptr cs:[di] 
		
		; always synchronous call - mark as finished
		
		mov		di, [si].RqStatusPtr
		stosw
		
		; signal finish
		
		IoSignal
		
		; finished
		
		xor		ax, ax
		ret

		; pass it to root (will fail there)
		
UnknownFunc:	IoRoot		
		ret

ZXS_Strategy	ENDP
		
; -----------------------------------------------------------------------------

ZX_Reset	PROC	

		mov		ax, cs
		mov		es, ax
		
		mov		ax, [si].RqA1Ptr
		mov		cs:ZXMemorySeg, ax

		cld
		xor		ax, ax
		mov		cx, (SIZE Z80Regs)/2
		mov		di, offset Registers
		rep		stosw
		
		mov		cs:HaltFlag, al
		
		mov		es, [bp].IntES

		ret

ZX_Reset	ENDP

; -----------------------------------------------------------------------------
		
ZX_SetRegs	PROC

		push		si
		mov		si, [si].RqA1Ptr
		mov		di, offset Registers

		mov		ax, cs
		mov		es, ax
		
		cld
		mov		cx, (SIZE Z80Regs)/2
		rep		movsw

		mov		es, [bp].IntES
		pop		si

		xor		ax, ax
		ret	

ZX_SetRegs	ENDP

; -----------------------------------------------------------------------------

ZX_GetRegs	PROC

		push		si
		mov		di, [si].RqA1Ptr
		mov		si, offset Registers

		mov		ax, cs
		mov		ds, ax
		
		cld
		mov		cx, (SIZE Z80Regs)/2
		rep		movsw

		mov		ds, [bp].IntDS
		pop		si

		xor		ax, ax
		ret

ZX_GetRegs	ENDP

; -----------------------------------------------------------------------------

ZX_GenINT	PROC

		push		si
		push		bp		
		
		mov		ax, cs
		mov		ds, ax

		GenDataSegment
		mov		di, ZXMemorySeg
		mov		es, es:[di]   
		
		GetSysRegs
		GenerateINT
		SetSysRegs
		
		pop		bp
		pop		si
		
		mov		ds, [bp].IntDS
		mov		es, [bp].IntES

		xor		ax, ax
		ret
		
ZX_GenINT	ENDP

; -----------------------------------------------------------------------------

ZX_GenNMI	PROC

		push		si
		push		bp		
		
		mov		ax, cs
		mov		ds, ax
		
		GenDataSegment
		mov		di, ZXMemorySeg
		mov		es, es:[di]   
		
		GetSysRegs
		GenerateNMI
		SetSysRegs
		
		pop		bp
		pop		si
		
		mov		ds, [bp].IntDS
		mov		es, [bp].IntES

		xor		ax, ax
		ret

ZX_GenNMI	ENDP

; -----------------------------------------------------------------------------

ZX_Emulate	PROC

		push		bx
		push		dx
		push		si
		push		bp		
		
		mov		di, [si].RqA1Ptr
		
		mov		ax, cs
		mov		ds, ax
		
		GenDataSegment
		mov		bx, ZXMemorySeg
		mov		es, es:[bx]   
		
		cld
		
		mov		al, RegR
		and		al, mskR7
		mov		RegR7bit, al
		
		mov		ax, di
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
		
		pop		bp
		pop		si
		pop		dx
		pop		bx
		
		mov		ds, [bp].IntDS
		mov		es, [bp].IntES

		xor		ax, ax
		ret

ZX_Emulate	ENDP

; -----------------------------------------------------------------------------

ZX_SetPort	PROC

		mov		di, [si].RqA1Ptr
		mov		ax, [si].RqA2Ptr
		mov		cs:[di+AllPorts], al

		xor		ax, ax		
		ret		

ZX_SetPort	ENDP

; -----------------------------------------------------------------------------

ZX_GetPort	PROC

		mov		di, [si].RqA1Ptr
		mov		al, cs:[di+AllPorts]
		xor		ah, ah
		
		ret

ZX_GetPort	ENDP

; -----------------------------------------------------------------------------

ZX_SetKeys	PROC

		push		si
		
		; get code segment into es
		
		mov		ax, cs
		mov		es, ax
		
		; cx = start of port table (07Fh, 0BFh, ..)
		
		mov		cx, [si].RqA1Ptr
		mov		di, offset InPortFE
		
		; start with zero

		xor		dl, dl
NextPort:	mov		dh, dl

		; al = constructed value, ah = counter

		mov		ax, 008FFh
		mov		si, cx
		
		; get highest bits
		
NextBit:	shl		dh, 1
		jc		BitSet
		and		al, [si]
BitSet:		inc		si
		
		dec		ah
		jnz		NextBit
		
		; store final masked bit
		
		stosb
		
		inc		dl
		test		dl, dl
		jnz		NextPort
		
		; restore segment register
		
		mov		es, [bp].IntES
		pop		si
		ret

ZX_SetKeys	ENDP

; -----------------------------------------------------------------------------

		INCLUDE		zxdraw.asm
		
; -----------------------------------------------------------------------------

_TEXT		ENDS

; -----------------------------------------------------------------------------

DUMMY		SEGMENT STACK PARA 'DATA'
DUMMY		ENDS

; -----------------------------------------------------------------------------

		END	DriverStart
