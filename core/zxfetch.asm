
; ZX Spectrum emulator 

; Instructions fetching
; (c) Freeman, September 2000, Prague

; -----------------------------------------------------------------------------

TableXlat	MACRO		TABLE

		lods		MemIPC
		xor		ah, ah
		add		ax, ax
		xchg		ax, di
		jmp		word ptr [di+TABLE]

		ENDM

; -----------------------------------------------------------------------------

GetAllRegs	MACRO

		mov		RegAF, Registers.rAF
		mov		RegBC, Registers.rBC
		mov		RegHL, Registers.rHL
		mov		RegSP, Registers.rSP
		mov		RegPC, Registers.rPC

		ENDM

; -----------------------------------------------------------------------------

SetAllRegs	MACRO

		mov		Registers.rPC, RegPC
		mov		Registers.rSP, RegSP
		mov		Registers.rHL, RegHL
		mov		Registers.rBC, RegBC
		mov		Registers.rAF, RegAF

		ENDM

; -----------------------------------------------------------------------------

GetSysRegs	MACRO

		mov		RegSP, Registers.rSP
		mov		RegPC, Registers.rPC

		ENDM

; -----------------------------------------------------------------------------

SetSysRegs	MACRO

		mov		Registers.rPC, RegPC
		mov		Registers.rSP, RegSP
		
		ENDM

; -----------------------------------------------------------------------------

FetchHere	MACRO
		LOCAL		@Stop

		dec		di
		jz		@Stop
		TableXlat	OpTable
@Stop:		jmp		Stop	

		ENDM

; -----------------------------------------------------------------------------

FetchSwapHere	MACRO
		LOCAL		@Stop

		mov		di, ax
		dec		di
		jz		@Stop
		TableXlat	OpTable
@Stop:		jmp		Stop

		ENDM

; -----------------------------------------------------------------------------

prefix_cb:	inc		RegR
		mov		di, ax
		TableXlat	CbTable
		
; -----------------------------------------------------------------------------

prefix_dd:	inc		RegR
		mov		di, ax
		TableXlat	DdTable
		
; -----------------------------------------------------------------------------

prefix_ed:	inc		RegR
		mov		di, ax
		TableXlat	EdTable
		
; -----------------------------------------------------------------------------

prefix_fd:	inc		RegR
		mov		di, ax
		TableXlat	FdTable

; -----------------------------------------------------------------------------

prefix_dd_cb:	inc		RegR
		mov		di, ax
		lods		MemIPC
		cbw	
		push		RegHL
		mov		RegHL, RegIX
		add		RegHL, ax
		TableXlat	XxCbTable

; -----------------------------------------------------------------------------

prefix_fd_cb:	inc		RegR
		mov		di, ax
		lods		MemIPC
		cbw
		push		RegHL
		mov		RegHL, RegIY
		add		RegHL, ax
		TableXlat	XxCbTable

; -----------------------------------------------------------------------------

bad_ed:		jmp		FetchSwap

; -----------------------------------------------------------------------------

bad_xxcb:	pop		RegHL
		jmp		FetchSwap

; -----------------------------------------------------------------------------

