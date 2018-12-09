
; ZX Spectrum emulator 

; Instructions fetching
; (c) Freeman, August 2000, Prague

; -----------------------------------------------------------------------------

AirFlags	MACRO

		test		RegA, RegA
		ClearFlags	flgHPN, flgSZ
		mov		al, RegIFF
		and		al, mskIFF2
		or		RegF, al

		ENDM

; -----------------------------------------------------------------------------

LoadReg		MACRO		DST, SRC

		mov		DST, SRC
		FetchSwapHere

		ENDM

; -----------------------------------------------------------------------------

LoadRegM	MACRO		DST, SRC

		mov		di, ax
		mov		al, SRC
		mov		DST, al
		FetchHere

		ENDM

; -----------------------------------------------------------------------------

LoadRegXY	MACRO		DST, SRC

		push		ax
		FetchXY		SRC	
		mov		DST, MemTMP
		pop		di
		FetchHere

		ENDM

; -----------------------------------------------------------------------------

LoadRegXYM	MACRO		DST, SRC

		push		ax
		FetchXY		SRC
		mov		al, MemTMP
		mov		DST, al
		pop		di
		FetchHere

		ENDM

; -----------------------------------------------------------------------------

LoadXYReg	MACRO		DST, SRC

		push		ax
		FetchXY		DST
		mov		MemTMP, SRC
		pop		di
		FetchHere
		
		ENDM

; -----------------------------------------------------------------------------

LoadXYRegM	MACRO		DST, SRC

		push		ax
		FetchXY		DST
		mov		al, SRC
		mov		MemTMP, al
		pop		di
		FetchHere

		ENDM

; -----------------------------------------------------------------------------

LoadAIReg	MACRO		SRC
		
		mov		di, SRC
		mov		RegA, MemTMP
		FetchSwapHere
		
		ENDM

; -----------------------------------------------------------------------------

LoadIRegA	MACRO		DST

		mov		di, DST
		mov		MemTMP, RegA
		FetchSwapHere
		
		ENDM

; -----------------------------------------------------------------------------

LoadImm		MACRO		DST

		mov		DST, MemIPC
		inc		RegPC
		FetchSwapHere

		ENDM

; -----------------------------------------------------------------------------

LoadImmM	MACRO		DST

		mov		di, ax
		lods		MemIPC
		mov		DST, al
		FetchHere
		
		ENDM

; -----------------------------------------------------------------------------

LoadImmW	MACRO		DST

		mov		DST, MemIPCW
		inc		RegPC
		inc		RegPC
		FetchSwapHere

		ENDM

; -----------------------------------------------------------------------------

LoadImmWM	MACRO		DST
	
		mov		di, ax
		lods		MemIPCW
		mov		DST, ax
		FetchHere

		ENDM

; -----------------------------------------------------------------------------

LoadImmXY	MACRO		DST

		push		ax
		FetchXY		DST
		lods		MemIPC
		mov		MemTMP, al
		pop		di
		FetchHere

		ENDM

; -----------------------------------------------------------------------------

LoadRegAddr	MACRO		DST

		mov		di, MemIPCW
		inc		RegPC
		inc		RegPC
		mov		DST, es:[di]
		FetchSwapHere

		ENDM

; -----------------------------------------------------------------------------

LoadRegAddrM	MACRO		DST

		push		ax
		mov		di, MemIPCW
		inc		RegPC
		inc		RegPC
		mov		ax, MemTMPW
		mov		DST, ax
		pop		di
		FetchHere

		ENDM

; -----------------------------------------------------------------------------

LoadAddrReg	MACRO		SRC

		mov		di, MemIPCW
		inc		RegPC
		inc		RegPC
		mov		es:[di], SRC
		FetchSwapHere

		ENDM

; -----------------------------------------------------------------------------

LoadAddrRegM	MACRO		SRC

		push		ax
		mov		di, MemIPCW
		inc		RegPC
		inc		RegPC
		mov		ax, SRC
		mov		MemTMPW, ax
		pop		di
		FetchHere

		ENDM

; -----------------------------------------------------------------------------

SwapReg		MACRO		SRC, DST

		xchg		SRC, DST
		FetchSwapHere

		ENDM

; -----------------------------------------------------------------------------

SwapRegM	MACRO		SRC, DST

		mov		di, ax
		mov		ax, SRC
		xchg		ax, DST
		mov		SRC, ax
		FetchHere

		ENDM

; -----------------------------------------------------------------------------

ld_a_b:		LoadReg		RegA, RegB
ld_a_c:		LoadReg		RegA, RegC
ld_a_d:		LoadReg		RegA, RegD
ld_a_e:		LoadReg		RegA, RegE
ld_a_h:		LoadReg		RegA, RegH
ld_a_l:		LoadReg		RegA, RegL
ld_a_ihl:	LoadReg		RegA, MemIHL
ld_a_iix:	LoadRegXY	RegA, RegIX
ld_a_iiy:	LoadRegXY	RegA, RegIY

ld_a_ixh:	LoadReg		RegA, RegIXH
ld_a_ixl:	LoadReg		RegA, RegIXL
ld_a_iyh:	LoadReg		RegA, RegIYH
ld_a_iyl:	LoadReg		RegA, RegIYL
	
; -----------------------------------------------------------------------------

ld_b_a:		LoadReg		RegB, RegA
ld_b_c:		LoadReg		RegB, RegC
ld_b_d:		LoadReg		RegB, RegD
ld_b_e:		LoadReg		RegB, RegE
ld_b_h:		LoadReg		RegB, RegH
ld_b_l:		LoadReg		RegB, RegL
ld_b_ihl:	LoadReg		RegB, MemIHL
ld_b_iix:	LoadRegXY	RegB, RegIX
ld_b_iiy:	LoadRegXY	RegB, RegIY

ld_b_ixh:	LoadReg		RegB, RegIXH
ld_b_ixl:	LoadReg		RegB, RegIXL
ld_b_iyh:	LoadReg		RegB, RegIYH
ld_b_iyl:	LoadReg		RegB, RegIYL
		
; -----------------------------------------------------------------------------

ld_c_a:		LoadReg		RegC, RegA
ld_c_b:		LoadReg		RegC, RegB
ld_c_d:		LoadReg		RegC, RegD
ld_c_e:		LoadReg		RegC, RegE
ld_c_h:		LoadReg		RegC, RegH
ld_c_l:		LoadReg		RegC, RegL
ld_c_ihl:	LoadReg		RegC, MemIHL
ld_c_iix:	LoadRegXY	RegC, RegIX
ld_c_iiy:	LoadRegXY	RegC, RegIY

ld_c_ixh:	LoadReg		RegC, RegIXH
ld_c_ixl:	LoadReg		RegC, RegIXL
ld_c_iyh:	LoadReg		RegC, RegIYH
ld_c_iyl:	LoadReg		RegC, RegIYL
		
; -----------------------------------------------------------------------------

ld_d_a:		LoadReg		RegD, RegA
ld_d_b:		LoadReg		RegD, RegB
ld_d_c:		LoadReg		RegD, RegC
ld_d_e:		LoadRegM	RegD, RegE
ld_d_h:		LoadReg		RegD, RegH
ld_d_l:		LoadReg		RegD, RegL
ld_d_ihl:	LoadRegM	RegD, MemIHL
ld_d_iix:	LoadRegXYM	RegD, RegIX
ld_d_iiy:	LoadRegXYM	RegD, RegIY

ld_d_ixh:	LoadRegM	RegD, RegIXH
ld_d_ixl:	LoadRegM	RegD, RegIXL
ld_d_iyh:	LoadRegM	RegD, RegIYH
ld_d_iyl:	LoadRegM	RegD, RegIYL
		
; -----------------------------------------------------------------------------

ld_e_a:		LoadReg		RegE, RegA
ld_e_b:		LoadReg		RegE, RegB
ld_e_c:		LoadReg		RegE, RegC
ld_e_d:		LoadRegM	RegE, RegD
ld_e_h:		LoadReg		RegE, RegH
ld_e_l:		LoadReg		RegE, RegL
ld_e_ihl:	LoadRegM	RegE, MemIHL
ld_e_iix:	LoadRegXYM	RegE, RegIX
ld_e_iiy:	LoadRegXYM	RegE, RegIY

ld_e_ixh:	LoadRegM	RegE, RegIXH
ld_e_ixl:	LoadRegM	RegE, RegIXL
ld_e_iyh:	LoadRegM	RegE, RegIYH
ld_e_iyl:	LoadRegM	RegE, RegIYL
		
; -----------------------------------------------------------------------------

ld_h_a:		LoadReg		RegH, RegA
ld_h_b:		LoadReg		RegH, RegB
ld_h_c:		LoadReg		RegH, RegC
ld_h_d:		LoadReg		RegH, RegD
ld_h_e:		LoadReg		RegH, RegE
ld_h_l:		LoadReg		RegH, RegL
ld_h_ihl:	LoadReg		RegH, MemIHL
ld_h_iix:	LoadRegXY	RegH, RegIX
ld_h_iiy:	LoadRegXY	RegH, RegIY

; -----------------------------------------------------------------------------

ld_l_a:		LoadReg		RegL, RegA
ld_l_b:		LoadReg		RegL, RegB
ld_l_c:		LoadReg		RegL, RegC
ld_l_d:		LoadReg		RegL, RegD
ld_l_e:		LoadReg		RegL, RegE
ld_l_h:		LoadReg		RegL, RegH
ld_l_ihl:	LoadReg		RegL, MemIHL
ld_l_iix:	LoadRegXY	RegL, RegIX
ld_l_iiy:	LoadRegXY	RegL, RegIY

; -----------------------------------------------------------------------------

ld_ixh_a:	LoadReg		RegIXH, RegA
ld_ixh_b:	LoadReg		RegIXH, RegB
ld_ixh_c:	LoadReg		RegIXH, RegC
ld_ixh_d:	LoadRegM	RegIXH, RegD
ld_ixh_e:	LoadRegM	RegIXH, RegE
ld_ixh_ixl:	LoadRegM	RegIXH, RegIXL

; -----------------------------------------------------------------------------

ld_ixl_a:	LoadReg		RegIXL, RegA
ld_ixl_b:	LoadReg		RegIXL, RegB
ld_ixl_c:	LoadReg		RegIXL, RegC
ld_ixl_d:	LoadRegM	RegIXL, RegD
ld_ixl_e:	LoadRegM	RegIXL, RegE
ld_ixl_ixh:	LoadRegM	RegIXL, RegIXH

; -----------------------------------------------------------------------------

ld_iyh_a:	LoadReg		RegIYH, RegA
ld_iyh_b:	LoadReg		RegIYH, RegB
ld_iyh_c:	LoadReg		RegIYH, RegC
ld_iyh_d:	LoadRegM	RegIYH, RegD
ld_iyh_e:	LoadRegM	RegIYH, RegE
ld_iyh_iyl:	LoadRegM	RegIYH, RegIYL

; -----------------------------------------------------------------------------

ld_iyl_a:	LoadReg		RegIYL, RegA
ld_iyl_b:	LoadReg		RegIYL, RegB
ld_iyl_c:	LoadReg		RegIYL, RegC
ld_iyl_d:	LoadRegM	RegIYL, RegD
ld_iyl_e:	LoadRegM	RegIYL, RegE
ld_iyl_iyh:	LoadRegM	RegIYL, RegIYH

; -----------------------------------------------------------------------------

ld_ihl_a:	LoadReg		MemIHL, RegA
ld_ihl_b:	LoadReg		MemIHL, RegB
ld_ihl_c:	LoadReg		MemIHL, RegC
ld_ihl_d:	LoadRegM	MemIHL, RegD
ld_ihl_e:	LoadRegM	MemIHL, RegE
ld_ihl_h:	LoadReg		MemIHL, RegH
ld_ihl_l:	LoadReg		MemIHL, RegL

; -----------------------------------------------------------------------------

ld_iix_a:	LoadXYReg	RegIX, RegA
ld_iix_b:	LoadXYReg	RegIX, RegB
ld_iix_c:	LoadXYReg	RegIX, RegC
ld_iix_d:	LoadXYRegM	RegIX, RegD
ld_iix_e:	LoadXYRegM	RegIX, RegE
ld_iix_h:	LoadXYReg	RegIX, RegH
ld_iix_l:	LoadXYReg	RegIX, RegL

; -----------------------------------------------------------------------------

ld_iiy_a:	LoadXYReg	RegIY, RegA
ld_iiy_b:	LoadXYReg	RegIY, RegB
ld_iiy_c:	LoadXYReg	RegIY, RegC
ld_iiy_d:	LoadXYRegM	RegIY, RegD
ld_iiy_e:	LoadXYRegM	RegIY, RegE
ld_iiy_h:	LoadXYReg	RegIY, RegH
ld_iiy_l:	LoadXYReg	RegIY, RegL

; -----------------------------------------------------------------------------

ld_a_ibc:	LoadAIReg	RegBC
ld_a_ide:	LoadAIReg	RegDE
ld_ibc_a:	LoadIRegA	RegBC
ld_ide_a:	LoadIRegA	RegDE

; -----------------------------------------------------------------------------

ld_a_n:		LoadImm		RegA
ld_b_n:		LoadImm		RegB
ld_c_n:		LoadImm		RegC
ld_d_n:		LoadImmM	RegD
ld_e_n:		LoadImmM	RegE
ld_h_n:		LoadImm		RegH
ld_l_n:		LoadImm		RegL
ld_ihl_n:	LoadImmM	MemIHL
ld_iix_n:	LoadImmXY	RegIX
ld_iiy_n:	LoadImmXY	RegIY

ld_ixh_n:	LoadImmM	RegIXH
ld_ixl_n:	LoadImmM	RegIXL
ld_iyh_n:	LoadImmM	RegIYH
ld_iyl_n:	LoadImmM	RegIYL

; -----------------------------------------------------------------------------

ld_bc_nn:	LoadImmW	RegBC
ld_de_nn:	LoadImmWM	RegDE
ld_hl_nn:	LoadImmW	RegHL
ld_ix_nn:	LoadImmWM	RegIX
ld_iy_nn:	LoadImmWM	RegIY
ld_sp_nn:	LoadImmW	RegSP

; -----------------------------------------------------------------------------

ld_inn_a:	LoadAddrReg	RegA
ld_inn_bc:	LoadAddrReg	RegBC
ld_inn_de:	LoadAddrRegM	RegDE
ld_inn_hl:	LoadAddrReg	RegHL
ld_inn_ix:	LoadAddrRegM	RegIX
ld_inn_iy:	LoadAddrRegM	RegIY
ld_inn_sp:	LoadAddrReg	RegSP

; -----------------------------------------------------------------------------

ld_a_inn:	LoadRegAddr	RegA
ld_bc_inn:	LoadRegAddr	RegBC
ld_de_inn:	LoadRegAddrM	RegDE
ld_hl_inn:	LoadRegAddr	RegHL
ld_ix_inn:	LoadRegAddrM	RegIX
ld_iy_inn:	LoadRegAddrM	RegIY
ld_sp_inn:	LoadRegAddr	RegSP

; -----------------------------------------------------------------------------

ld_sp_hl:	LoadReg		RegSP, RegHL
ld_sp_ix:	LoadReg		RegSP, RegIX
ld_sp_iy:	LoadReg		RegSP, RegIY

; -----------------------------------------------------------------------------

ex_isp_hl:	SwapReg		RegHL, MemISPW
ex_isp_ix:	SwapRegM	RegIX, MemISPW
ex_isp_iy:	SwapRegM	RegIY, MemISPW

; -----------------------------------------------------------------------------

ex_af_af:	SwapReg		RegAF, RegAF_
ex_de_hl:	SwapReg		RegDE, RegHL

; -----------------------------------------------------------------------------

exx:		mov		di, ax
		xchg		RegBC, RegBC_
		mov		ax, RegDE
		xchg		ax, RegDE_
		mov		RegDE, ax
		xchg		RegHL, RegHL_
		FetchHere
		
; -----------------------------------------------------------------------------

ld_a_i:		mov		di, ax
		mov		RegA, RegI
		AirFlags		
		jmp		Fetch		

; -----------------------------------------------------------------------------

ld_i_a:		mov		RegI, RegA
		jmp		FetchSwap

; -----------------------------------------------------------------------------

ld_a_r:		mov		di, ax
		mov		ah, RegR
		sub		ah, al
		and		ah, NOT mskR7
		or		ah, RegR7bit
		mov		RegA, ah
		AirFlags
		FetchHere

; -----------------------------------------------------------------------------

ld_r_a:		add		al, RegA
		mov		RegR, al
		mov		al, RegA
		and		al, mskR7
		mov		RegR7bit, al
		FetchSwapHere

; -----------------------------------------------------------------------------

