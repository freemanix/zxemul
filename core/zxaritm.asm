
; ZX Spectrum emulator 

; Arithmetic instructions
; (c) Freeman, August 2000, Prague

; -----------------------------------------------------------------------------

AddFlags	MACRO

		FastClearVFlags	flgN, flgSZHC
		
		ENDM
		
; -----------------------------------------------------------------------------
		
AddWFlags	MACRO
		
		FastClearVFlags	flgN, flgHC
		
		ENDM

; -----------------------------------------------------------------------------

SubFlags	MACRO

		FastSetVFlags	flgN, flgSZHC
		
		ENDM

; -----------------------------------------------------------------------------

OrFlags		MACRO

		FastClearFlags	flgHNC, flgSZP
		
		ENDM

; -----------------------------------------------------------------------------

AndFlags	MACRO

		FastCSFlags	flgNC, flgH, flgSZP
		
		ENDM

; -----------------------------------------------------------------------------

IncFlags	MACRO
		
		FastClearVFlags	flgN, flgSZH
		
		ENDM

; -----------------------------------------------------------------------------

DecFlags	MACRO

		FastSetVFlags	flgN, flgSZH
		
		ENDM

; -----------------------------------------------------------------------------

DaaFlags	MACRO

		FastClearFlags	flg0, flgSZHPC
		
		ENDM

; -----------------------------------------------------------------------------

AddReg		MACRO		SRC

		mov		di, ax
		add		RegA, SRC
		AddFlags
		
		ENDM

; -----------------------------------------------------------------------------

AddRegXY	MACRO		SRC

		push		ax
		FetchXY		SRC
		add		RegA, MemTMP
		pop		di
		AddFlags

		ENDM

; -----------------------------------------------------------------------------

AddRegImm	MACRO		

		mov		di, ax
		lods		MemIPC
		add		RegA, al
		AddFlags

		ENDM
		
; -----------------------------------------------------------------------------

AddRegW		MACRO		DST, SRC

		mov		di, ax
		add		DST, SRC
		AddWFlags

		ENDM

; -----------------------------------------------------------------------------

AddRegWM	MACRO		DST, SRC

		mov		di, ax
		mov		ax, SRC
		add		DST, ax
		AddWFlags

		ENDM
		
; -----------------------------------------------------------------------------

AdcReg		MACRO		SRC

		mov		di, ax
		LoadFlags
		adc		RegA, SRC
		AddFlags

		ENDM

; -----------------------------------------------------------------------------

AdcRegXY	MACRO		SRC

		push		ax
		FetchXY		SRC
		LoadFlags
		adc		RegA, MemTMP
		pop		di
		AddFlags

		ENDM
		
; -----------------------------------------------------------------------------

AdcRegImm	MACRO

		mov		di, ax
		LoadFlags	
		lods		MemIPC
		adc		RegA, al
		AddFlags
		
		ENDM
		
; -----------------------------------------------------------------------------

AdcRegW		MACRO		DST, SRC

		mov		di, ax
		LoadFlags
		adc		DST, SRC
		AddFlags

		ENDM

; -----------------------------------------------------------------------------

AdcRegWM	MACRO		DST, SRC

		mov		di, ax
		mov		ax, SRC
		LoadFlags
		adc		DST, ax
		AddFlags
		
		ENDM

; -----------------------------------------------------------------------------

SubReg		MACRO		SRC

		mov		di, ax	
		sub		RegA, SRC
		SubFlags

		ENDM

; -----------------------------------------------------------------------------

SubRegXY	MACRO		SRC

		push		ax
		FetchXY		SRC
		sub		RegA, MemTMP
		pop		di
		SubFlags

		ENDM
		
; -----------------------------------------------------------------------------

SubRegImm	MACRO

		mov		di, ax
		lods		MemIPC
		sub		RegA, al
		SubFlags

		ENDM
		
; -----------------------------------------------------------------------------

SbcReg		MACRO		SRC

		mov		di, ax
		LoadFlags
		sbb		RegA, SRC
		SubFlags

		ENDM
		
; -----------------------------------------------------------------------------

SbcRegXY	MACRO		SRC

		push		ax
		FetchXY		SRC
		LoadFlags
		sbb		RegA, MemTMP
		pop		di
		SubFlags
		
		ENDM

; -----------------------------------------------------------------------------

SbcRegImm	MACRO

		mov		di, ax
		LoadFlags
		lods		MemIPC
		sbb		RegA, al
		SubFlags
		
		ENDM

; -----------------------------------------------------------------------------

SbcRegW		MACRO		DST, SRC

		mov		di, ax
		LoadFlags
		sbb		DST, SRC
		SubFlags

		ENDM
		
; -----------------------------------------------------------------------------

SbcRegWM	MACRO		DST, SRC

		mov		di, ax
		mov		ax, SRC
		LoadFlags
		sbb		DST, ax
		SubFlags

		ENDM
		
; -----------------------------------------------------------------------------

CpReg		MACRO		SRC

		mov		di, ax
		cmp		RegA, SRC
		SubFlags
		
		ENDM		

; -----------------------------------------------------------------------------

CpRegXY		MACRO		SRC

		push		ax
		FetchXY		SRC
		cmp		RegA, MemTMP
		pop		di
		SubFlags
		
		ENDM		

; -----------------------------------------------------------------------------

CpRegImm	MACRO

		mov		di, ax
		lods		MemIPC
		cmp		RegA, al
		SubFlags
		
		ENDM
		
; -----------------------------------------------------------------------------

OrReg		MACRO		SRC

		mov		di, ax
		or		RegA, SRC
		OrFlags

		ENDM

; -----------------------------------------------------------------------------

OrRegXY		MACRO		SRC

		push		ax
		FetchXY		SRC
		or		RegA, MemTMP
		pop		di
		OrFlags

		ENDM

; -----------------------------------------------------------------------------

OrRegImm	MACRO

		mov		di, ax
		lods		MemIPC
		or		RegA, al
		OrFlags
		
		ENDM
		
; -----------------------------------------------------------------------------

XorReg		MACRO		SRC

		mov		di, ax
		xor		RegA, SRC
		OrFlags
		
		ENDM

; -----------------------------------------------------------------------------

XorRegXY	MACRO		SRC

		push		ax
		FetchXY		SRC
		xor		RegA, MemTMP
		pop		di
		OrFlags
		
		ENDM

; -----------------------------------------------------------------------------

XorRegImm	MACRO		

		mov		di, ax
		lods		MemIPC
		xor		RegA, al
		OrFlags
		
		ENDM

; -----------------------------------------------------------------------------

AndReg		MACRO		SRC

		mov		di, ax
		and		RegA, SRC
		AndFlags
		
		ENDM

; -----------------------------------------------------------------------------

AndRegXY	MACRO		SRC

		push		ax
		FetchXY		SRC
		and		RegA, MemTMP
		pop		di
		AndFlags
		
		ENDM

; -----------------------------------------------------------------------------

AndRegImm	MACRO

		mov		di, ax
		lods		MemIPC
		and		RegA, al
		AndFlags
		
		ENDM

; -----------------------------------------------------------------------------

IncReg		MACRO		REG

		mov		di, ax
		inc		REG
		IncFlags

		ENDM

; -----------------------------------------------------------------------------

IncRegXY	MACRO		REG

		push		ax
		FetchXY		REG
		inc		MemTMP
		pop		di
		IncFlags

		ENDM

; -----------------------------------------------------------------------------

IncRegW		MACRO	REG

		inc		REG
		FetchSwapHere	
		
		ENDM		

; -----------------------------------------------------------------------------

DecReg		MACRO	REG

		mov		di, ax
		dec		REG
		DecFlags
		
		ENDM		

; -----------------------------------------------------------------------------

DecRegXY	MACRO	REG

		push		ax
		FetchXY		REG
		dec		MemTMP
		pop		di
		DecFlags
		
		ENDM		

; -----------------------------------------------------------------------------

DecRegW		MACRO	REG

		dec		REG
		FetchSwapHere

		ENDM

; -----------------------------------------------------------------------------

NegOp		MACRO

		mov		di, ax
		neg		RegA
		SubFlags

		ENDM
		
; -----------------------------------------------------------------------------

DaaOp		MACRO
		LOCAL		@DaaSub
		
		mov		di,ax
		mov		al, RegA
		test		RegF, flgN
		jnz		@DaaSub
		LoadFlags	
		daa
		mov		RegA, al
		DaaFlags
@DaaSub:	LoadFlags
		das
		mov		RegA, al
		DaaFlags

		ENDM

; -----------------------------------------------------------------------------
		
add_a_a:	AddReg		RegA
add_a_b:	AddReg		RegB
add_a_c:	AddReg		RegC
add_a_d:	AddReg		RegD
add_a_e:	AddReg		RegE
add_a_h:	AddReg		RegH
add_a_l:	AddReg		RegL
add_a_ihl:	AddReg		MemIHL
add_a_iix:	AddRegXY	RegIX
add_a_iiy:	AddRegXY	RegIY
add_a_n:	AddRegImm

add_a_ixh:	AddReg		RegIXH
add_a_ixl:	AddReg		RegIXL
add_a_iyh:	AddReg		RegIYH
add_a_iyl:	AddReg		RegIYL

; -----------------------------------------------------------------------------

adc_a_a:	AdcReg		RegA
adc_a_b:	AdcReg		RegB
adc_a_c:	AdcReg		RegC
adc_a_d:	AdcReg		RegD
adc_a_e:	AdcReg		RegE
adc_a_h:	AdcReg		RegH
adc_a_l:	AdcReg		RegL
adc_a_ihl:	AdcReg		MemIHL
adc_a_iix:	AdcRegXY	RegIX
adc_a_iiy:	AdcRegXY	RegIY
adc_a_n:	AdcRegImm

adc_a_ixh:	AdcReg		RegIXH
adc_a_ixl:	AdcReg		RegIXL
adc_a_iyh:	AdcReg		RegIYH
adc_a_iyl:	AdcReg		RegIYL
	
; -----------------------------------------------------------------------------

sub_a:		SubReg		RegA
sub_b:		SubReg		RegB
sub_c:		SubReg		RegC
sub_d:		SubReg		RegD
sub_e:		SubReg		RegE
sub_h:		SubReg		RegH
sub_l:		SubReg		RegL
sub_ihl:	SubReg		MemIHL
sub_iix:	SubRegXY	RegIX
sub_iiy:	SubRegXY	RegIY
sub_n:		SubRegImm

sub_ixh:	SubReg		RegIXH
sub_ixl:	SubReg		RegIXL
sub_iyh:	SubReg		RegIYH
sub_iyl:	SubReg		RegIYL

; -----------------------------------------------------------------------------

sbc_a_a:	SbcReg		RegA
sbc_a_b:	SbcReg		RegB
sbc_a_c:	SbcReg		RegC
sbc_a_d:	SbcReg		RegD
sbc_a_e:	SbcReg		RegE
sbc_a_h:	SbcReg		RegH
sbc_a_l:	SbcReg		RegL
sbc_a_ihl:	SbcReg		MemIHL
sbc_a_iix:	SbcRegXY	RegIX
sbc_a_iiy:	SbcRegXY	RegIY
sbc_a_n:	SbcRegImm

sbc_a_ixh:	SbcReg		RegIXH
sbc_a_ixl:	SbcReg		RegIXL
sbc_a_iyh:	SbcReg		RegIYH
sbc_a_iyl:	SbcReg		RegIYL

; -----------------------------------------------------------------------------

cp_a:		CpReg		RegA
cp_b:		CpReg		RegB
cp_c:		CpReg		RegC
cp_d:		CpReg		RegD
cp_e:		CpReg		RegE
cp_h:		CpReg		RegH
cp_l:		CpReg		RegL
cp_ihl:		CpReg		MemIHL
cp_iix:		CpRegXY		RegIX
cp_iiy:		CpRegXY		RegIY
cp_n:		CpRegImm

cp_ixh:		CpReg		RegIXH
cp_ixl:		CpReg		RegIXL
cp_iyh:		CpReg		RegIYH
cp_iyl:		CpReg		RegIYL

; -----------------------------------------------------------------------------

and_a:		AndReg		RegA
and_b:		AndReg		RegB
and_c:		AndReg		RegC
and_d:		AndReg		RegD
and_e:		AndReg		RegE
and_h:		AndReg		RegH
and_l:		AndReg		RegL
and_ihl:	AndReg		MemIHL
and_iix:	AndRegXY	RegIX
and_iiy:	AndRegXY	RegIY
and_n:		AndRegImm

and_ixh:	AndReg		RegIXH 
and_ixl:	AndReg		RegIXL
and_iyh:	AndReg		RegIYH
and_iyl:	AndReg		RegIYL

; -----------------------------------------------------------------------------

or_a:		OrReg		RegA
or_b:		OrReg		RegB
or_c:		OrReg		RegC
or_d:		OrReg		RegD
or_e:		OrReg		RegE
or_h:		OrReg		RegH
or_l:		OrReg		RegL
or_ihl:		OrReg		MemIHL
or_iix:		OrRegXY		RegIX
or_iiy:		OrRegXY		RegIY
or_n:		OrRegImm

or_ixh:		OrReg		RegIXH
or_ixl:		OrReg		RegIXL
or_iyh:		OrReg		RegIYH
or_iyl:		OrReg		RegIYL

; -----------------------------------------------------------------------------

xor_a:		XorReg		RegA
xor_b:		XorReg		RegB
xor_c:		XorReg		RegC
xor_d:		XorReg		RegD
xor_e:		XorReg		RegE
xor_h:		XorReg		RegH
xor_l:		XorReg		RegL
xor_ihl:	XorReg		MemIHL
xor_iix:	XorRegXY	RegIX
xor_iiy:	XorRegXY	RegIY
xor_n:		XorRegImm

xor_ixh:	XorReg		RegIXH
xor_ixl:	XorReg		RegIXL
xor_iyh:	XorReg		RegIYH
xor_iyl:	XorReg		RegIYL

; -----------------------------------------------------------------------------

inc_a:		IncReg		RegA
inc_b:		IncReg		RegB
inc_c:		IncReg		RegC
inc_d:		IncReg		RegD
inc_e:		IncReg		RegE
inc_h:		IncReg		RegH
inc_l:		IncReg		RegL
inc_ihl:	IncReg		MemIHL
inc_iix:	IncRegXY	RegIX
inc_iiy:	IncRegXY	RegIY

inc_ixh:	IncReg		RegIXH
inc_ixl:	IncReg		RegIXL
inc_iyh:	IncReg		RegIYH
inc_iyl:	IncReg		RegIYL

; -----------------------------------------------------------------------------
	
dec_a:		DecReg		RegA
dec_b:		DecReg		RegB
dec_c:		DecReg		RegC
dec_d:		DecReg		RegD
dec_e:		DecReg		RegE
dec_h:		DecReg		RegH
dec_l:		DecReg		RegL
dec_ihl:	DecReg		MemIHL
dec_iix:	DecRegXY	RegIX
dec_iiy:	DecRegXY	RegIY

dec_ixh:	DecReg		RegIXH
dec_ixl:	DecReg		RegIXL
dec_iyh:	DecReg		RegIYH
dec_iyl:	DecReg		RegIYL

; -----------------------------------------------------------------------------

add_hl_bc:	AddRegW		RegHL, RegBC
add_hl_de:	AddRegW		RegHL, RegDE
add_hl_hl:	AddRegW		RegHL, RegHL
add_hl_sp:	AddRegW		RegHL, RegSP
add_ix_bc:	AddRegW		RegIX, RegBC
add_ix_de:	AddRegWM	RegIX, RegDE
add_ix_ix:	AddRegWM	RegIX, RegIX
add_ix_sp:	AddRegW		RegIX, RegSP
add_iy_bc:	AddRegW		RegIY, RegBC
add_iy_de:	AddRegWM	RegIY, RegDE
add_iy_iy:	AddRegWM	RegIY, RegIY
add_iy_sp:	AddRegW		RegIY, RegSP

; -----------------------------------------------------------------------------

adc_hl_bc:	AdcRegW		RegHL, RegBC
adc_hl_de:	AdcRegW		RegHL, RegDE
adc_hl_hl:	AdcRegW		RegHL, RegHL
adc_hl_sp:	AdcRegW		RegHL, RegSP

; -----------------------------------------------------------------------------

sbc_hl_bc:	SbcRegW		RegHL, RegBC
sbc_hl_de:	SbcRegW		RegHL, RegDE
sbc_hl_hl:	SbcRegW		RegHL, RegHL
sbc_hl_sp:	SbcRegW		RegHL, RegSP

; -----------------------------------------------------------------------------

inc_bc:		IncRegW		RegBC
inc_de:		IncRegW		RegDE
inc_hl:		IncRegW		RegHL
inc_ix:		IncRegW		RegIX
inc_iy:		IncRegW		RegIY
inc_sp:		IncRegW		RegSP

; -----------------------------------------------------------------------------

dec_bc:		DecRegW		RegBC
dec_de:		DecRegW		RegDE
dec_hl:		DecRegW		RegHL
dec_ix:		DecRegW		RegIX
dec_iy:		DecRegW		RegIY
dec_sp:		DecRegW		RegSP

; -----------------------------------------------------------------------------

neg_:		NegOp

; -----------------------------------------------------------------------------

daa_:		DaaOp

; -----------------------------------------------------------------------------

