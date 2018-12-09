
; ZX Spectrum emulator 

; Z80 registers
; (c) Freeman, August 2000, Prague

; -----------------------------------------------------------------------------

Z80Regs		STRUC

rAF		LABEL		WORD
rF		DB		?
rA		DB		?

rBC		LABEL		WORD
rC		DB		?
rB		DB		?

rDE		LABEL		WORD
rE		DB		?
rD		DB		?

rHL		LABEL		WORD
rL		DB		?
rH		DB		?

rAF_		LABEL		WORD
rF_		DB		?
rA_		DB		?

rBC_		LABEL		WORD
rC_		DB		?
rB_		DB		?

rDE_		LABEL		WORD
rE_		DB		?
rD_		DB		?

rHL_		LABEL		WORD
rL_		DB		?
rH_		DB		?

rIX		LABEL 		WORD
rIXL		DB		?
rIXH		DB		?

rIY		LABEL		WORD
rIYL		DB		?
rIYH		DB		?

rSP		DW		?
rPC		DW		?

rR		DB		?
rI		DB		?

rIFF		DB		?
rIMODE		DB		?

Z80Regs		ENDS

; -----------------------------------------------------------------------------

		ALIGN
		
Registers	Z80Regs		<>

HaltFlag	DB		?
RegR7bit	DB		?	

; -----------------------------------------------------------------------------

		ALIGN

InPortFE	DB		256 DUP (0FFh)
AllPorts	DB		256 DUP (0FFh)

; -----------------------------------------------------------------------------

RegA		EQU		dh
RegF		EQU		dl
RegAF		EQU		dx
	
RegB		EQU		ch
RegC		EQU		cl
RegBC		EQU		cx

RegD		EQU		Registers.rD
RegE		EQU		Registers.rE
RegDE		EQU		Registers.rDE

RegH		EQU		bh
RegL		EQU		bl
RegHL		EQU		bx

RegAF_		EQU		Registers.rAF_
RegBC_		EQU		Registers.rBC_
RegDE_		EQU		Registers.rDE_
RegHL_		EQU		Registers.rHL_

RegIXH		EQU		Registers.rIXH
RegIXL		EQU		Registers.rIXL
RegIX		EQU		Registers.rIX

RegIYH		EQU		Registers.rIYH
RegIYL		EQU		Registers.rIYL
RegIY		EQU		Registers.rIY

RegSP		EQU		bp
RegPC		EQU		si

RegI		EQU		Registers.rI
RegR		EQU		Registers.rR
	
RegIFF		EQU		Registers.rIFF
RegIMODE	EQU		Registers.rIMODE
	
MemTMP		EQU		byte ptr es:[di]
MemTMPW		EQU		word ptr es:[di]
MemIHL		EQU		byte ptr es:[RegHL]
MemIHLW		EQU		word ptr es:[RegHL]
MemISPW		EQU		word ptr es:[RegSP]
MemIPC		EQU		byte ptr es:[RegPC]
MemIPCW		EQU		word ptr es:[RegPC]

; -----------------------------------------------------------------------------

flgS		EQU		80h
flgZ		EQU		40h
flgH		EQU		10h
flgP		EQU		04h
flgN		EQU		02h
flgC		EQU		01h

flg0		EQU		00h

flgSZHPC	EQU		flgS OR flgZ OR flgH OR flgP OR flgC
flgSZHC		EQU		flgS OR flgZ OR flgH OR flgC
flgSHC		EQU		flgS OR flgH OR flgC
flgSZH		EQU		flgS OR flgZ OR flgH
flgSZP		EQU		flgS OR flgZ OR flgP
flgSZN		EQU		flgS OR flgZ Or flgN
flgHNC		EQU		flgH OR flgN OR flgC
flgHPN		EQU		flgH OR flgP OR flgN
flgSZ		EQU		flgS OR flgZ
flgHC		EQU		flgH OR flgC	
flgHN		EQU		flgH OR flgN
flgNC		EQU		flgN OR flgC

; -----------------------------------------------------------------------------

mskIFF1		EQU		flgN
mskIFF2		EQU		flgP
mskIFF		EQU		mskIFF1 OR mskIFF2
mskHALT		EQU		01h
mskR7		EQU		80h

; -----------------------------------------------------------------------------

LoadFlags	MACRO

		mov		ah, RegF
		sahf

		ENDM

; -----------------------------------------------------------------------------

StoreFlags	MACRO

		lahf
		mov		RegF, ah
		
		ENDM

; -----------------------------------------------------------------------------

ClearFlags	MACRO		CLEAR, CHANGE

		lahf	
		and		RegF, NOT (CLEAR OR CHANGE)
		and		ah, CHANGE
		or		RegF, ah
		jmp		Fetch

		ENDM

; -----------------------------------------------------------------------------

FastClearFlags	MACRO		CLEAR, CHANGE

		lahf	
		and		RegF, NOT (CLEAR OR CHANGE)
		and		ah, CHANGE
		or		RegF, ah
		FetchHere

		ENDM

; -----------------------------------------------------------------------------

ClearVFlags	MACRO		CLEAR, CHANGE
		LOCAL		@OverFlow

		lahf
		jo		@OverFlow
		and		RegF, NOT (CLEAR OR CHANGE OR flgP)
		and		ah, CHANGE
		or		RegF, ah
		jmp		Fetch
@OverFlow:	and		RegF, NOT (CLEAR OR CHANGE)
		and		ah, CHANGE
		or		RegF, ah
		or		RegF, flgP
		jmp		Fetch

		ENDM

; -----------------------------------------------------------------------------

FastClearVFlags	MACRO		CLEAR, CHANGE
		LOCAL		@OverFlow

		lahf
		jo		@OverFlow
		and		RegF, NOT (CLEAR OR CHANGE OR flgP)
		and		ah, CHANGE
		or		RegF, ah
		FetchHere
@OverFlow:	and		RegF, NOT (CLEAR OR CHANGE)
		and		ah, CHANGE
		or		RegF, ah
		or		RegF, flgP
		FetchHere

		ENDM
		
; -----------------------------------------------------------------------------

SetFlags	MACRO		SET, CHANGE

		lahf
		or		RegF, SET OR CHANGE
		or		ah, NOT CHANGE
		and		RegF, ah
		jmp		Fetch

		ENDM
		
; -----------------------------------------------------------------------------

FastSetFlags	MACRO		SET, CHANGE

		lahf
		or		RegF, SET OR CHANGE
		or		ah, NOT CHANGE
		and		RegF, ah
		FetchHere

		ENDM
		
; -----------------------------------------------------------------------------

SetVFlags	MACRO		SET, CHANGE
		LOCAL		@OverFlow

		lahf
		jo		@OverFlow
		or		RegF, SET OR CHANGE OR flgP
		or		ah, NOT CHANGE
		and		RegF, ah
		and		RegF, NOT flgP
		jmp		Fetch
@OverFlow:	or		RegF, SET OR CHANGE OR flgP
		or		ah, NOT CHANGE
		and		RegF, ah
		jmp		Fetch

		ENDM

; -----------------------------------------------------------------------------

FastSetVFlags	MACRO		SET, CHANGE
		LOCAL		@OverFlow

		lahf
		jo		@OverFlow
		or		RegF, SET OR CHANGE OR flgP
		or		ah, NOT CHANGE
		and		RegF, ah
		and		RegF, NOT flgP
		FetchHere
@OverFlow:	or		RegF, SET OR CHANGE OR flgP
		or		ah, NOT CHANGE
		and		RegF, ah
		FetchHere

		ENDM

; -----------------------------------------------------------------------------

ClearSetFlags	MACRO		CLEAR, SET, CHANGE

		lahf
		and		RegF, NOT (CLEAR OR CHANGE)
		or		ah, SET
		and		ah, CHANGE
		or		RegF, ah
		jmp		Fetch
	
		ENDM

; -----------------------------------------------------------------------------

FastCSFlags	MACRO		CLEAR, SET, CHANGE

		lahf
		and		RegF, NOT (CLEAR OR CHANGE)
		or		ah, SET
		and		ah, CHANGE
		or		RegF, ah
		jmp		Fetch
	
		ENDM

; -----------------------------------------------------------------------------

FetchXY		MACRO		REG

		lods		MemIPC
		cbw
		mov		di, REG
		add		di, ax

		ENDM
		
; -----------------------------------------------------------------------------

BlockRepeat	MACRO

		dec		RegPC
		dec		RegPC
		
		ENDM
	
; -----------------------------------------------------------------------------

		