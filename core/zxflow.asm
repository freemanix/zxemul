
; ZX Spectrum emulator 

; Program flow change instructions, push/pop instructions
; (c) Freeman, August 2000, Prague

; -----------------------------------------------------------------------------

PushLoc		MACRO		REG

		dec		RegSP
		dec		RegSP
		mov		MemISPW, REG

		ENDM

; -----------------------------------------------------------------------------

PushReg		MACRO		REG

		PushLoc		REG
		FetchSwapHere
		
		ENDM

; -----------------------------------------------------------------------------

PushRegM	MACRO		REG

		mov		di, ax
		dec		RegSP
		dec		RegSP
		mov		ax, REG
		mov		MemISPW, ax
		FetchHere

		ENDM

; -----------------------------------------------------------------------------

PopLoc		MACRO		REG

		mov		REG, MemISPW
		inc		RegSP
		inc		RegSP

		ENDM

; -----------------------------------------------------------------------------

PopReg		MACRO		REG
	
		PopLoc		REG
		FetchSwapHere
		
		ENDM		

; -----------------------------------------------------------------------------

PopRegM		MACRO		REG

		mov		di, ax
		mov		ax, MemISPW
		mov		REG, ax
		inc		RegSP
		inc		RegSP
		FetchHere

		ENDM

; -----------------------------------------------------------------------------

JumpNn		MACRO	

		mov		RegPC, MemIPCW
		FetchSwapHere
	
		ENDM

; -----------------------------------------------------------------------------

JumpReg		MACRO		REG

		mov		RegPC, REG
		FetchSwapHere

		ENDM

; -----------------------------------------------------------------------------

JumpCondNn	MACRO		FLAG

		test		RegF, FLAG
		jnz		jp_nn
		inc		RegPC
		inc		RegPC
		FetchSwapHere
		
		ENDM

; -----------------------------------------------------------------------------

JumpNCondNn	MACRO		FLAG

		test		RegF, FLAG
		jz		jp_nn
		inc		RegPC
		inc		RegPC
		FetchSwapHere

		ENDM

; -----------------------------------------------------------------------------

JumpE		MACRO
		
		mov		di, ax
		lods		MemIPC
		cbw	
		add		RegPC, ax
		FetchHere

		ENDM

; -----------------------------------------------------------------------------

JumpCondE	MACRO		FLAG
	
		test		RegF, FLAG
		jnz		jr_e
		inc		RegPC
		FetchSwapHere
		
		ENDM		

; -----------------------------------------------------------------------------

JumpNCondE	MACRO		FLAG

		test		RegF, FLAG
		jz		jr_e
		inc		RegPC
		FetchSwapHere
		
		ENDM		

; -----------------------------------------------------------------------------

CallNn		MACRO

		mov		di, ax
		lods		MemIPCW
		PushLoc		RegPC
		mov		RegPC, ax
		FetchHere

		ENDM		

; -----------------------------------------------------------------------------

CallCondNn	MACRO		FLAG

		test		RegF, FLAG
		jnz		call_nn
		inc		RegPC
		inc		RegPC
		FetchSwapHere

		ENDM

; -----------------------------------------------------------------------------

CallNCondNn	MACRO		FLAG

		test		RegF, FLAG
		jz		call_nn
		inc		RegPC
		inc		RegPC
		FetchSwapHere
	
	 	ENDM

; -----------------------------------------------------------------------------

RstN		MACRO		ADDR

		PushLoc		RegPC
		mov		RegPC, ADDR
		FetchSwapHere

		ENDM

; -----------------------------------------------------------------------------

RetX		MACRO	

		PopLoc		RegPC
		FetchSwapHere
		
		ENDM

; -----------------------------------------------------------------------------

RetI		MACRO

		mov		di, ax
		mov		al, RegIFF
		shr		al, 1
		and		al, mskIFF1
		or		RegIFF, al
		PopLoc		RegPC
		FetchHere

		ENDM

; -----------------------------------------------------------------------------

RetCond		MACRO		FLAG

		test		RegF, FLAG
		jnz		ret_
		FetchSwapHere
	
		ENDM

; -----------------------------------------------------------------------------

RetNCond	MACRO		FLAG

		test		RegF, FLAG
		jz		ret_
		FetchSwapHere
			
		ENDM		

; -----------------------------------------------------------------------------

TerminateHALT	MACRO

		mov		HaltFlag, 0
		inc		RegPC

		ENDM

; -----------------------------------------------------------------------------

GenerateINT	MACRO
		LOCAL		@CheckMode, @IssueInt, @Disabled

		test		RegIFF, mskIFF1
		jz		@Disabled
		test		HaltFlag, mskHALT
		jz		@CheckMode
		TerminateHALT
@CheckMode:	mov		RegIFF, 0
		push		ax
		cmp		RegIMODE, 2
		mov		ax, 0038h
		jnz		@IssueInt
		mov		al, 0FFh
		mov		ah, RegI
		mov		di, ax
		mov		ax, MemTMPW
@IssueInt:	PushLoc		RegPC
		mov		RegPC, ax
		pop		ax
@Disabled:	

		ENDM

; -----------------------------------------------------------------------------

GenerateNMI	MACRO
		LOCAL		@IssueNMI

		test		HaltFlag, mskHALT
		jnz		@IssueNMI
		TerminateHALT
@IssueNMI:	and		RegIFF, mskIFF1
		PushLoc		RegPC
		mov		RegPC, 0066h
		
		ENDM

; -----------------------------------------------------------------------------

push_af:	PushReg		RegAF
push_bc:	PushReg		RegBC
push_de:	PushRegM	RegDE
push_hl:	PushReg		RegHL
push_ix:	PushRegM	RegIX
push_iy:	PushRegM	RegIY

; -----------------------------------------------------------------------------

pop_af:		PopReg		RegAF
pop_bc:		PopReg		RegBC
pop_de:		PopRegM		RegDE
pop_hl:		PopReg		RegHL
pop_ix:		PopRegM		RegIX
pop_iy:		PopRegM		RegIY

; -----------------------------------------------------------------------------

jp_z_nn:	JumpCondNn	flgZ
jp_nz_nn:	JumpNCondNn	flgZ
jp_c_nn:	JumpCondNn	flgC
jp_nc_nn:	JumpNCondNn	flgC

jp_nn:		JumpNn

jp_pe_nn:	JumpCondNn	flgP
jp_po_nn:	JumpNCondNn	flgP
jp_m_nn:	JumpCondNn	flgS
jp_p_nn:	JumpNCondNn	flgS

; -----------------------------------------------------------------------------

jp_hl:		JumpReg		RegHL
jp_ix:		JumpReg		RegIX
jp_iy:		JumpReg		RegIY

; -----------------------------------------------------------------------------

jr_e:		JumpE
jr_z_e:		JumpCondE	flgZ
jr_nz_e:	JumpNCondE	flgZ
jr_c_e:		JumpCondE	flgC
jr_nc_e:	JumpNCondE	flgC

; -----------------------------------------------------------------------------

djnz_e:		dec		RegB
		jnz		jr_e
		inc		RegPC
		jmp		FetchSwap

; -----------------------------------------------------------------------------

call_z_nn:	CallCondNn	flgZ
call_nz_nn:	CallNCondNn	flgZ
call_c_nn:	CallCondNn	flgC
call_nc_nn:	CallNCondNn	flgC

call_nn:	CallNn

call_pe_nn:	CallCondNn	flgP
call_po_nn:	CallNCondNn	flgP
call_m_nn:	CallCondNn	flgS
call_p_nn:	CallNCondNn	flgS

; -----------------------------------------------------------------------------

ret_z:		RetCond		flgZ
ret_nz:		RetNCond	flgZ
ret_c:		RetCond		flgC
ret_nc:		RetNCond	flgC

ret_:		RetX

ret_pe:		RetCond		flgP
ret_po:		RetNCond	flgP
ret_m:		RetCond		flgS
ret_p:		RetNCond	flgS

; -----------------------------------------------------------------------------

rst_00:		RstN		00h
rst_08:		RstN		08h
rst_10:		RstN		10h
rst_18:		RstN		18h
rst_20:		RstN		20h
rst_28:		RstN		28h
rst_30:		RstN		30h
rst_38:		RstN		38h

; -----------------------------------------------------------------------------

retn_:		RetI
reti_:		RetI

; -----------------------------------------------------------------------------
