
; ZX Spectrum emulator 

; Bit operations, shifts and rotations
; (c) Freeman, August 2000, Prague

; -----------------------------------------------------------------------------

BitFlags	MACRO		

		lahf
		and		ah, flgZ
		and		al, flgS
		and		RegF, NOT flgSZN
		or		RegF, ah
		or		RegF, al
		
		jmp		Fetch

		ENDM

; -----------------------------------------------------------------------------

RotFlags	MACRO		REG

		lahf
		and		ah, flgC
		mov		RegF, ah
		
		test		REG, REG
		lahf
		and		ah, flgSZP
		or		RegF, ah
		
		FetchHere
		
		ENDM

; -----------------------------------------------------------------------------

BitReg		MACRO		BIT, REG
	
		mov		di, ax
		mov		al, REG
		and		al, 1 SHL BIT
		BitFlags
		
		ENDM

; -----------------------------------------------------------------------------

BitRegXY	MACRO		BIT

		mov		di, ax
		mov		al, MemIHL
		and		al, 1 SHL BIT
		pop		RegHL
		BitFlags
		
		ENDM

; -----------------------------------------------------------------------------

SetReg		MACRO		BIT, REG
	
		or		REG, 1 SHL BIT
		jmp		FetchSwap

		ENDM

; -----------------------------------------------------------------------------

SetRegXY	MACRO		BIT

		or		MemIHL, 1 SHL BIT
		pop		RegHL
		jmp		FetchSwap

		ENDM

; -----------------------------------------------------------------------------

ResReg		MACRO		BIT, REG

		and		REG, NOT (1 SHL BIT)
		jmp		FetchSwap
		
		ENDM		

; -----------------------------------------------------------------------------

ResRegXY	MACRO		BIT

		and		MemIHL, NOT (1 SHL BIT)
		pop		RegHL
		jmp		FetchSwap
		
		ENDM		

; -----------------------------------------------------------------------------

RlReg		MACRO		REG

		mov		di, ax
		LoadFlags
		rcl		REG, 1
		RotFlags	REG
		
		ENDM

; -----------------------------------------------------------------------------

RlRegM		MACRO		REG

		mov		di, ax
		LoadFlags
		rcl		REG, 1
		mov		al, REG
		RotFlags	al
		
		ENDM

; -----------------------------------------------------------------------------

RlRegXY		MACRO	

		mov		di, ax
		LoadFlags
		rcl		MemIHL, 1
		mov		al, MemIHL
		pop		RegHL
		RotFlags	al
		
		ENDM

; -----------------------------------------------------------------------------

RrReg		MACRO		REG

		mov		di, ax
		LoadFlags
		rcr		REG, 1
		RotFlags	REG
		
		ENDM		

; -----------------------------------------------------------------------------

RrRegM		MACRO		REG

		mov		di, ax
		LoadFlags
		rcr		REG, 1
		mov		al, REG
		RotFlags	al
		
		ENDM		

; -----------------------------------------------------------------------------

RrRegXY		MACRO		

		mov		di, ax
		LoadFlags
		rcr		MemIHL, 1
		mov		al, MemIHL
		pop		RegHL
		RotFlags	al
		
		ENDM		

; -----------------------------------------------------------------------------

RlcReg		MACRO		REG

		mov		di, ax
		rol		REG, 1
		RotFlags	REG

		ENDM

; -----------------------------------------------------------------------------

RlcRegM		MACRO		REG

		mov		di, ax
		rol		REG, 1
		mov		al, REG
		RotFlags	al

		ENDM

; -----------------------------------------------------------------------------

RlcRegXY	MACRO	

		mov		di, ax
		rol		MemIHL, 1
		mov		al, MemIHL
		pop		RegHL
		RotFlags	al

		ENDM

; -----------------------------------------------------------------------------

RrcReg		MACRO		REG

		mov		di, ax
		ror		REG, 1
		RotFlags	REG

		ENDM

; -----------------------------------------------------------------------------

RrcRegM		MACRO		REG

		mov		di, ax
		ror		REG, 1
		mov		al, REG
		RotFlags	al

		ENDM

; -----------------------------------------------------------------------------

RrcRegXY	MACRO	

		mov		di, ax
		ror		MemIHL, 1
		mov		al, MemIHL
		pop		RegHL
		RotFlags	al

		ENDM

; -----------------------------------------------------------------------------

SlaReg		MACRO		REG

		mov		di, ax
		sal		REG, 1
		RotFlags	REG

		ENDM

; -----------------------------------------------------------------------------

SlaRegM		MACRO		REG

		mov		di, ax
		sal		REG, 1
		mov		al, REG
		RotFlags	al

		ENDM

; -----------------------------------------------------------------------------

SlaRegXY	MACRO	

		mov		di, ax
		sal		MemIHL, 1
		mov		al, MemIHL
		pop		RegHL
		RotFlags	al

		ENDM

; -----------------------------------------------------------------------------

SraReg		MACRO		REG

		mov		di, ax
		sar		REG, 1
		RotFlags	REG

		ENDM

; -----------------------------------------------------------------------------

SraRegM		MACRO		REG

		mov		di, ax
		sar		REG, 1
		mov		al, REG
		RotFlags	al

		ENDM

; -----------------------------------------------------------------------------

SraRegXY	MACRO	

		mov		di, ax
		sar		MemIHL, 1
		mov		al, MemIHL
		pop		RegHL
		RotFlags	al

		ENDM

; -----------------------------------------------------------------------------

SllReg		MACRO		REG

		mov		di, ax
		shl		REG, 1
		
		lahf
		and		ah, flgC
		mov		RegF, ah
		
		or		REG, 1
		lahf
		and		ah, flgSZP
		or		RegF, ah

		FetchHere

		ENDM

; -----------------------------------------------------------------------------

SllRegXY	MACRO	

		mov		di, ax
		shl		MemIHL, 1
		
		lahf
		and		ah, flgC
		mov		RegF, ah
		
		or		MemIHL, 1
		lahf
		and		ah, flgSZP
		or		RegF, ah

		pop		RegHL
		FetchHere

		ENDM

; -----------------------------------------------------------------------------

SrlReg		MACRO		REG

		mov		di, ax
		shr		REG, 1
		RotFlags	REG

		ENDM

; -----------------------------------------------------------------------------

SrlRegM		MACRO		REG

		mov		di, ax
		shr		REG, 1
		mov		al, REG
		RotFlags	al

		ENDM

; -----------------------------------------------------------------------------

SrlRegXY	MACRO	

		mov		di, ax
		shr		MemIHL, 1
		mov		al, MemIHL
		pop		RegHL
		RotFlags	al

		ENDM

; -----------------------------------------------------------------------------

bit_0_a:	BitReg		0, RegA
bit_0_b:	BitReg		0, RegB
bit_0_c:	BitReg		0, RegC
bit_0_d:	BitReg		0, RegD
bit_0_e:	BitReg		0, RegE
bit_0_h:	BitReg		0, RegH
bit_0_l:	BitReg		0, RegL
bit_0_ihl:	BitReg		0, MemIHL
bit_0_ixy:	BitRegXY	0

; -----------------------------------------------------------------------------

bit_1_a:	BitReg		1, RegA
bit_1_b:	BitReg		1, RegB
bit_1_c:	BitReg		1, RegC
bit_1_d:	BitReg		1, RegD
bit_1_e:	BitReg		1, RegE
bit_1_h:	BitReg		1, RegH
bit_1_l:	BitReg		1, RegL
bit_1_ihl:	BitReg		1, MemIHL
bit_1_ixy:	BitRegXY	1

; -----------------------------------------------------------------------------

bit_2_a:	BitReg		2, RegA
bit_2_b:	BitReg		2, RegB
bit_2_c:	BitReg		2, RegC
bit_2_d:	BitReg		2, RegD
bit_2_e:	BitReg		2, RegE
bit_2_h:	BitReg		2, RegH
bit_2_l:	BitReg		2, RegL
bit_2_ihl:	BitReg		2, MemIHL
bit_2_ixy:	BitRegXY	2

; -----------------------------------------------------------------------------

bit_3_a:	BitReg		3, RegA
bit_3_b:	BitReg		3, RegB
bit_3_c:	BitReg		3, RegC
bit_3_d:	BitReg		3, RegD
bit_3_e:	BitReg		3, RegE
bit_3_h:	BitReg		3, RegH
bit_3_l:	BitReg		3, RegL
bit_3_ihl:	BitReg		3, MemIHL
bit_3_ixy:	BitRegXY	3

; -----------------------------------------------------------------------------

bit_4_a:	BitReg		4, RegA
bit_4_b:	BitReg		4, RegB
bit_4_c:	BitReg		4, RegC
bit_4_d:	BitReg		4, RegD
bit_4_e:	BitReg		4, RegE
bit_4_h:	BitReg		4, RegH
bit_4_l:	BitReg		4, RegL
bit_4_ihl:	BitReg		4, MemIHL
bit_4_ixy:	BitRegXY	4

; -----------------------------------------------------------------------------

bit_5_a:	BitReg		5, RegA
bit_5_b:	BitReg		5, RegB
bit_5_c:	BitReg		5, RegC
bit_5_d:	BitReg		5, RegD
bit_5_e:	BitReg		5, RegE
bit_5_h:	BitReg		5, RegH
bit_5_l:	BitReg		5, RegL
bit_5_ihl:	BitReg		5, MemIHL
bit_5_ixy:	BitRegXY	5

; -----------------------------------------------------------------------------

bit_6_a:	BitReg		6, RegA
bit_6_b:	BitReg		6, RegB
bit_6_c:	BitReg		6, RegC
bit_6_d:	BitReg		6, RegD
bit_6_e:	BitReg		6, RegE
bit_6_h:	BitReg		6, RegH
bit_6_l:	BitReg		6, RegL
bit_6_ihl:	BitReg		6, MemIHL
bit_6_ixy:	BitRegXY	6

; -----------------------------------------------------------------------------

bit_7_a:	BitReg		7, RegA
bit_7_b:	BitReg		7, RegB
bit_7_c:	BitReg		7, RegC
bit_7_d:	BitReg		7, RegD
bit_7_e:	BitReg		7, RegE
bit_7_h:	BitReg		7, RegH
bit_7_l:	BitReg		7, RegL
bit_7_ihl:	BitReg		7, MemIHL
bit_7_ixy:	BitRegXY	7

; -----------------------------------------------------------------------------

set_0_a:	SetReg		0, RegA
set_0_b:	SetReg		0, RegB
set_0_c:	SetReg		0, RegC
set_0_d:	SetReg		0, RegD
set_0_e:	SetReg		0, RegE
set_0_h:	SetReg		0, RegH
set_0_l:	SetReg		0, RegL
set_0_ihl:	SetReg		0, MemIHL
set_0_ixy:	SetRegXY	0

; -----------------------------------------------------------------------------

set_1_a:	SetReg		1, RegA
set_1_b:	SetReg		1, RegB
set_1_c:	SetReg		1, RegC
set_1_d:	SetReg		1, RegD
set_1_e:	SetReg		1, RegE
set_1_h:	SetReg		1, RegH
set_1_l:	SetReg		1, RegL
set_1_ihl:	SetReg		1, MemIHL
set_1_ixy:	SetRegXY	1

; -----------------------------------------------------------------------------

set_2_a:	SetReg		2, RegA
set_2_b:	SetReg		2, RegB
set_2_c:	SetReg		2, RegC
set_2_d:	SetReg		2, RegD
set_2_e:	SetReg		2, RegE
set_2_h:	SetReg		2, RegH
set_2_l:	SetReg		2, RegL
set_2_ihl:	SetReg		2, MemIHL
set_2_ixy:	SetRegXY	2

; -----------------------------------------------------------------------------

set_3_a:	SetReg		3, RegA
set_3_b:	SetReg		3, RegB
set_3_c:	SetReg		3, RegC
set_3_d:	SetReg		3, RegD
set_3_e:	SetReg		3, RegE
set_3_h:	SetReg		3, RegH
set_3_l:	SetReg		3, RegL
set_3_ihl:	SetReg		3, MemIHL
set_3_ixy:	SetRegXY	3

; -----------------------------------------------------------------------------

set_4_a:	SetReg		4, RegA
set_4_b:	SetReg		4, RegB
set_4_c:	SetReg		4, RegC
set_4_d:	SetReg		4, RegD
set_4_e:	SetReg		4, RegE
set_4_h:	SetReg		4, RegH
set_4_l:	SetReg		4, RegL
set_4_ihl:	SetReg		4, MemIHL
set_4_ixy:	SetRegXY	4

; -----------------------------------------------------------------------------

set_5_a:	SetReg		5, RegA
set_5_b:	SetReg		5, RegB
set_5_c:	SetReg		5, RegC
set_5_d:	SetReg		5, RegD
set_5_e:	SetReg		5, RegE
set_5_h:	SetReg		5, RegH
set_5_l:	SetReg		5, RegL
set_5_ihl:	SetReg		5, MemIHL
set_5_ixy:	SetRegXY	5

; -----------------------------------------------------------------------------

set_6_a:	SetReg		6, RegA
set_6_b:	SetReg		6, RegB
set_6_c:	SetReg		6, RegC
set_6_d:	SetReg		6, RegD
set_6_e:	SetReg		6, RegE
set_6_h:	SetReg		6, RegH
set_6_l:	SetReg		6, RegL
set_6_ihl:	SetReg		6, MemIHL
set_6_ixy:	SetRegXY	6

; -----------------------------------------------------------------------------

set_7_a:	SetReg		7, RegA
set_7_b:	SetReg		7, RegB
set_7_c:	SetReg		7, RegC
set_7_d:	SetReg		7, RegD
set_7_e:	SetReg		7, RegE
set_7_h:	SetReg		7, RegH
set_7_l:	SetReg		7, RegL
set_7_ihl:	SetReg		7, MemIHL
set_7_ixy:	SetRegXY	7

; -----------------------------------------------------------------------------

res_0_a:	ResReg		0, RegA
res_0_b:	ResReg		0, RegB
res_0_c:	ResReg		0, RegC
res_0_d:	ResReg		0, RegD
res_0_e:	ResReg		0, RegE
res_0_h:	ResReg		0, RegH
res_0_l:	ResReg		0, RegL
res_0_ihl:	ResReg		0, MemIHL
res_0_ixy:	ResRegXY	0

; -----------------------------------------------------------------------------

res_1_a:	ResReg		1, RegA
res_1_b:	ResReg		1, RegB
res_1_c:	ResReg		1, RegC
res_1_d:	ResReg		1, RegD
res_1_e:	ResReg		1, RegE
res_1_h:	ResReg		1, RegH
res_1_l:	ResReg		1, RegL
res_1_ihl:	ResReg		1, MemIHL
res_1_ixy:	ResRegXY	1

; -----------------------------------------------------------------------------

res_2_a:	ResReg		2, RegA
res_2_b:	ResReg		2, RegB
res_2_c:	ResReg		2, RegC
res_2_d:	ResReg		2, RegD
res_2_e:	ResReg		2, RegE
res_2_h:	ResReg		2, RegH
res_2_l:	ResReg		2, RegL
res_2_ihl:	ResReg		2, MemIHL
res_2_ixy:	ResRegXY	2

; -----------------------------------------------------------------------------

res_3_a:	ResReg		3, RegA
res_3_b:	ResReg		3, RegB
res_3_c:	ResReg		3, RegC
res_3_d:	ResReg		3, RegD
res_3_e:	ResReg		3, RegE
res_3_h:	ResReg		3, RegH
res_3_l:	ResReg		3, RegL
res_3_ihl:	ResReg		3, MemIHL
res_3_ixy:	ResRegXY	3

; -----------------------------------------------------------------------------

res_4_a:	ResReg		4, RegA
res_4_b:	ResReg		4, RegB
res_4_c:	ResReg		4, RegC
res_4_d:	ResReg		4, RegD
res_4_e:	ResReg		4, RegE
res_4_h:	ResReg		4, RegH
res_4_l:	ResReg		4, RegL
res_4_ihl:	ResReg		4, MemIHL
res_4_ixy:	ResRegXY	4

; -----------------------------------------------------------------------------

res_5_a:	ResReg		5, RegA
res_5_b:	ResReg		5, RegB
res_5_c:	ResReg		5, RegC
res_5_d:	ResReg		5, RegD
res_5_e:	ResReg		5, RegE
res_5_h:	ResReg		5, RegH
res_5_l:	ResReg		5, RegL
res_5_ihl:	ResReg		5, MemIHL
res_5_ixy:	ResRegXY	5

; -----------------------------------------------------------------------------

res_6_a:	ResReg		6, RegA
res_6_b:	ResReg		6, RegB
res_6_c:	ResReg		6, RegC
res_6_d:	ResReg		6, RegD
res_6_e:	ResReg		6, RegE
res_6_h:	ResReg		6, RegH
res_6_l:	ResReg		6, RegL
res_6_ihl:	ResReg		6, MemIHL
res_6_ixy:	ResRegXY	6

; -----------------------------------------------------------------------------

res_7_a:	ResReg		7, RegA
res_7_b:	ResReg		7, RegB
res_7_c:	ResReg		7, RegC
res_7_d:	ResReg		7, RegD
res_7_e:	ResReg		7, RegE
res_7_h:	ResReg		7, RegH
res_7_l:	ResReg		7, RegL
res_7_ihl:	ResReg		7, MemIHL
res_7_ixy:	ResRegXY	7

; -----------------------------------------------------------------------------

rl_a:		RlReg		RegA
rl_b:		RlReg		RegB
rl_c:		RlReg		RegC
rl_d:		RlRegM		RegD
rl_e:		RlRegM		RegE
rl_h:		RlReg		RegH
rl_l:		RlReg		RegL
rl_ihl:		RlRegM		MemIHL
rl_ixy:		RlRegXY	

; -----------------------------------------------------------------------------

rr_a:		RrReg		RegA
rr_b:		RrReg		RegB
rr_c:		RrReg		RegC
rr_d:		RrRegM		RegD
rr_e:		RrRegM		RegE
rr_h:		RrReg		RegH
rr_l:		RrReg		RegL
rr_ihl:		RrRegM		MemIHL
rr_ixy:		RrRegXY

; -----------------------------------------------------------------------------

rlc_a:		RlcReg		RegA
rlc_b:		RlcReg		RegB
rlc_c:		RlcReg		RegC
rlc_d:		RlcRegM		RegD
rlc_e:		RlcRegM		RegE
rlc_h:		RlcReg		RegH
rlc_l:		RlcReg		RegL
rlc_ihl:	RlcRegM		MemIHL
rlc_ixy:	RlcRegXY

; -----------------------------------------------------------------------------

rrc_a:		RrcReg		RegA
rrc_b:		RrcReg		RegB
rrc_c:		RrcReg		RegC
rrc_d:		RrcRegM		RegD
rrc_e:		RrcRegM		RegE
rrc_h:		RrcReg		RegH
rrc_l:		RrcReg		RegL
rrc_ihl:	RrcRegM		MemIHL
rrc_ixy:	RrcRegXY

; -----------------------------------------------------------------------------

sla_a:		SlaReg		RegA
sla_b:		SlaReg		RegB
sla_c:		SlaReg		RegC
sla_d:		SlaRegM		RegD
sla_e:		SlaRegM		RegE
sla_h:		SlaReg		RegH
sla_l:		SlaReg		RegL
sla_ihl:	SlaRegM		MemIHL
sla_ixy:	SlaRegXY

; -----------------------------------------------------------------------------

sra_a:		SraReg		RegA
sra_b:		SraReg		RegB
sra_c:		SraReg		RegC
sra_d:		SraRegM		RegD
sra_e:		SraRegM		RegE
sra_h:		SraReg		RegH
sra_l:		SraReg		RegL
sra_ihl:	SraRegM		MemIHL
sra_ixy:	SraRegXY

; -----------------------------------------------------------------------------

sll_a:		SllReg		RegA
sll_b:		SllReg		RegB
sll_c:		SllReg		RegC
sll_d:		SllReg		RegD
sll_e:		SllReg		RegE
sll_h:		SllReg		RegH
sll_l:		SllReg		RegL
sll_ihl:	SllReg		MemIHL
sll_ixy:	SllRegXY

; -----------------------------------------------------------------------------

srl_a:		SrlReg		RegA
srl_b:		SrlReg		RegB
srl_c:		SrlReg		RegC
srl_d:		SrlRegM		RegD
srl_e:		SrlRegM		RegE
srl_h:		SrlReg		RegH
srl_l:		SrlReg		RegL
srl_ihl:	SrlRegM		MemIHL
srl_ixy:	SrlRegXY

; -----------------------------------------------------------------------------

rla:		mov		di, ax
		LoadFlags
		rcl		RegA, 1
		FastClearFlags	flgHN, flgC
		
; -----------------------------------------------------------------------------

rra:		mov		di, ax
		LoadFlags	
		rcr		RegA, 1
		FastClearFlags	flgHN, flgC

; -----------------------------------------------------------------------------

rlca:		mov		di, ax
		rol		RegA, 1
		FastClearFlags	flgHN, flgC
		
; -----------------------------------------------------------------------------

rrca:		mov		di, ax
		ror		RegA, 1
		FastClearFlags	flgHN, flgC

; -----------------------------------------------------------------------------

rrd:		mov		di, ax
		mov		ah, RegA
		mov		al, MemIHL
		shl		ax, 4
		shr		al, 4
		and		RegA, 0F0h
		or		RegA, al
		mov		MemIHL, ah
		FastClearFlags	flgHN, flgSZP

; -----------------------------------------------------------------------------

rld:		mov		di, ax
		mov		ah, MemIHL
		mov		al, RegA
		shl		al, 4
		shr		ax, 4
		and		RegA, 0F0h
		or		RegA, ah
		mov		MemIHL, al
		FastClearFlags	flgHN, flgSZP

; -----------------------------------------------------------------------------

scf:		and		RegF, NOT flgHN
		or		RegF, flgC
		FetchSwapHere

; -----------------------------------------------------------------------------

ccf:		xor		RegF, flgC
		and		RegF, NOT flgN
		FetchSwapHere

; -----------------------------------------------------------------------------

cpl:		not		RegA
		or		RegF, flgHN
		FetchSwapHere

; -----------------------------------------------------------------------------


