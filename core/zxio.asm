
; ZX Spectrum emulator 

; Input/output and hardware controlling instructions
; (c) Freeman, August 2000, Prague

; -----------------------------------------------------------------------------

SetIMode	MACRO		MODE

		mov		RegIMODE, MODE
		jmp		FetchSwap

		ENDM

; -----------------------------------------------------------------------------

InPort		MACRO		HIPORT, LOPORT, REG
		LOCAL		@FetchPort
		
		mov		al, LOPORT
		xor		ah, ah
		test		al, 01h
		mov		di, offset AllPorts
		jnz		@FetchPort
		mov		al, HIPORT
		mov		di, offset InPortFE
@FetchPort:	add		di, ax
		mov		REG, byte ptr [di]

		ENDM

; -----------------------------------------------------------------------------

InPortM		MACRO		HIPORT, LOPORT, REG
		LOCAL		@FetchPort
		
		mov		al, LOPORT
		xor		ah, ah
		test		al, 01h
		mov		di, offset AllPorts
		jnz		@FetchPort
		mov		al, HIPORT
		mov		di, offset InPortFE
@FetchPort:	add		di, ax
		mov		al, byte ptr [di]
		mov		REG, al

		ENDM

; -----------------------------------------------------------------------------

InPortA		MACRO

		push		ax
		lods		MemIPC
		InPort		RegA, al, RegA
		pop		di
		jmp		Fetch

		ENDM

; -----------------------------------------------------------------------------

InPortC		MACRO		REG

		push		ax
		InPort		RegB, RegC, REG
		pop		di
		test		REG, REG
		ClearFlags	flgHN, flgSZP

		ENDM

; -----------------------------------------------------------------------------

InPortCM	MACRO		REG

		push		ax
		InPortM		RegB, RegC, REG
		pop		di
		test		al, al
		ClearFlags	flgHN, flgSZP
		
		ENDM		

; -----------------------------------------------------------------------------

OutPort		MACRO		HIPORT, LOPORT, REG

		mov		al, LOPORT
		xor		ah, ah
		mov		di, offset AllPorts
		add		di, ax
		mov		byte ptr [di], REG

		ENDM

; -----------------------------------------------------------------------------

OutPortM	MACRO		HIPORT, LOPORT, REG

		mov		al, LOPORT
		xor		ah, ah
		mov		di, offset AllPorts
		add		di, ax
		mov		al, REG
		mov		byte ptr [di], al

		ENDM

; -----------------------------------------------------------------------------

OutPortA	MACRO

		push		ax
		lods		MemIPC
		OutPort		RegA, al, RegA
		pop		di
		jmp		Fetch
		
		ENDM

; -----------------------------------------------------------------------------

OutPortC	MACRO		REG

		push		ax
		OutPort		RegB, RegC, REG
		pop		di
		jmp		Fetch

		ENDM
		
; -----------------------------------------------------------------------------

OutPortCM	MACRO		REG

		push		ax
		OutPortM	RegB, RegC, REG
		pop		di
		jmp		Fetch

		ENDM

; -----------------------------------------------------------------------------

InBlockI	MACRO		

		push		ax
		dec		RegB
		lahf
		or		RegF, flgN
		or		ah, NOT flgSZH
		and		RegF, ah
		InPortM		RegB, RegC, MemIHL
		inc		RegHL
		pop		di

		ENDM

; -----------------------------------------------------------------------------

InBlockD	MACRO		

		push		ax
		dec		RegB
		lahf
		or		RegF, flgN
		or		ah, NOT flgSZH
		and		RegF, ah
		InPortM		RegB, RegC, MemIHL
		dec		RegHL
		pop		di

		ENDM

; -----------------------------------------------------------------------------

OutBlockI	MACRO		

		push		ax
		dec		RegB
		lahf
		or		RegF, flgN
		or		ah, NOT flgSZH
		and		RegF, ah
		OutPortM	RegB, RegC, MemIHL
		inc		RegHL
		pop		di

		ENDM

; -----------------------------------------------------------------------------

OutBlockD	MACRO		

		push		ax
		dec		RegB
		lahf
		or		RegF, flgN
		or		ah, NOT flgSZH
		and		RegF, ah
		OutPortM	RegB, RegC, MemIHL
		dec		RegHL
		pop		di

		ENDM

; -----------------------------------------------------------------------------

BlockCheck	MACRO		DEST

		test		RegB, RegB
		jz		DEST
		
		ENDM

; -----------------------------------------------------------------------------

nop_:		FetchSwapHere
		
; -----------------------------------------------------------------------------

di_:		mov		RegIFF, 0
		FetchSwapHere

; -----------------------------------------------------------------------------

ei_:		mov		RegIFF, mskIFF
		FetchSwapHere

; -----------------------------------------------------------------------------

halt:		mov		HaltFlag, mskHALT
		dec		RegPC
		FetchSwapHere

; -----------------------------------------------------------------------------

im_0:		SetIMode	0
im_1:		SetIMode	1
im_2:		SetIMode	2

; -----------------------------------------------------------------------------

in_a_in:	InPortA
in_a_ic:	InPortC		RegA
in_b_ic:	InPortC		RegB
in_c_ic:	InPortC		RegC
in_d_ic:	InPortCM	RegD
in_e_ic:	InPortCM	RegE
in_h_ic:	InPortC		RegH
in_l_ic:	InPortC		RegL

in_ic:		InPortC		al

; -----------------------------------------------------------------------------

out_in_a:	OutPortA
out_ic_a:	OutPortC	RegA
out_ic_b:	OutPortC	RegB
out_ic_c:	OutPortC	RegC
out_ic_d:	OutPortCM	RegD
out_ic_e:	OutPortCM	RegE
out_ic_h:	OutPortC	RegH
out_ic_l:	OutPortC	RegL

out_ic_0:	OutPortC	0

; -----------------------------------------------------------------------------

ind:		InBlockD
		jmp		Fetch

; -----------------------------------------------------------------------------

ini:		InBlockI
		jmp		Fetch

; -----------------------------------------------------------------------------

indr:		InBlockD
		BlockCheck	BlockFinish
		BlockRepeat
		jmp		Fetch

; -----------------------------------------------------------------------------

inir:		InBlockI
		BlockCheck	BlockFinish
		BlockRepeat
		jmp		Fetch

; -----------------------------------------------------------------------------

BlockFinish:	jmp		Fetch

; -----------------------------------------------------------------------------

otdr:		OutBlockD
		BlockCheck	BlockFinish
		BlockRepeat
		jmp		Fetch
		
; -----------------------------------------------------------------------------
		
otir:		OutBlockI
		BlockCheck	BlockFinish
		BlockRepeat
		jmp		Fetch

; -----------------------------------------------------------------------------

outd:		OutBlockD
		jmp		Fetch
		
; -----------------------------------------------------------------------------
		
outi:		OutBlockI
		jmp		Fetch
		
; -----------------------------------------------------------------------------
		
