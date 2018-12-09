
; ZX Spectrum emulator 

; Opcode tables
; (c) Freeman, August 2000, Prague

; -----------------------------------------------------------------------------

		ALIGN

OpTable:	DW		nop_		; 00 opcodes
		DW		ld_bc_nn
		DW		ld_ibc_a
		DW		inc_bc
		DW		inc_b
		DW		dec_b
		DW		ld_b_n
		DW		rlca
		DW		ex_af_af
		DW		add_hl_bc
		DW		ld_a_ibc
		DW		dec_bc
		DW		inc_c
		DW		dec_c
		DW		ld_c_n
		DW		rrca

		DW		djnz_e		; 10 opcodes
		DW		ld_de_nn
		DW		ld_ide_a
		DW		inc_de
		DW		inc_d
		DW		dec_d
		DW		ld_d_n
		DW		rla
		DW		jr_e
		DW		add_hl_de
		DW		ld_a_ide
		DW		dec_de
		DW		inc_e
		DW		dec_e
		DW		ld_e_n
		DW		rra

		DW		jr_nz_e		; 20 opcodes
		DW		ld_hl_nn
		DW		ld_inn_hl
		DW		inc_hl
		DW		inc_h
		DW		dec_h
		DW		ld_h_n
		DW		daa_
		DW		jr_z_e
		DW		add_hl_hl
		DW		ld_hl_inn
		DW		dec_hl
		DW		inc_l
		DW		dec_l
		DW		ld_l_n
		DW		cpl

		DW		jr_nc_e		; 30 opcodes  
		DW		ld_sp_nn
		DW		ld_inn_a
		DW		inc_sp
		DW		inc_ihl
		DW 		dec_ihl
		DW 		ld_ihl_n
		DW 		scf
		DW 		jr_c_e
		DW		add_hl_sp
		DW 		ld_a_inn
		DW 		dec_sp
		DW		inc_a
		DW 		dec_a
		DW 		ld_a_n
		DW 		ccf

		DW 		nop_		; 40 opcodes
		DW 		ld_b_c
		DW 		ld_b_d
		DW		ld_b_e
		DW 		ld_b_h
		DW 		ld_b_l
		DW 		ld_b_ihl
		DW 		ld_b_a
		DW 		ld_c_b
		DW 		nop_
		DW 		ld_c_d
		DW 		ld_c_e
		DW 		ld_c_h
		DW 		ld_c_l
		DW 		ld_c_ihl
		DW 		ld_c_a

		DW 		ld_d_b		; 50 opcodes
		DW 		ld_d_c
		DW 		nop_
		DW 		ld_d_e
		DW 		ld_d_h
		DW 		ld_d_l
		DW 		ld_d_ihl
		DW 		ld_d_a
		DW 		ld_e_b
		DW 		ld_e_c
		DW 		ld_e_d
		DW 		nop_
		DW 		ld_e_h
		DW 		ld_e_l
		DW 		ld_e_ihl
		DW 		ld_e_a

		DW 		ld_h_b		; 60 opcodes
		DW 		ld_h_c
		DW 		ld_h_d
		DW 		ld_h_e
		DW 		nop_
		DW 		ld_h_l
		DW 		ld_h_ihl
		DW 		ld_h_a
		DW 		ld_l_b
		DW 		ld_l_c
		DW 		ld_l_d
		DW 		ld_l_e
		DW 		ld_l_h
		DW 		nop_
		DW 		ld_l_ihl
		DW 		ld_l_a

		DW 		ld_ihl_b	; 70 opcodes
		DW 		ld_ihl_c
		DW 		ld_ihl_d
		DW 		ld_ihl_e
		DW 		ld_ihl_h
		DW 		ld_ihl_l
		DW 		halt
		DW 		ld_ihl_a
		DW 		ld_a_b
		DW 		ld_a_c
		DW 		ld_a_d
		DW 		ld_a_e
		DW 		ld_a_h
		DW 		ld_a_l
		DW 		ld_a_ihl
		DW 		nop_
	
		DW 		add_a_b		; 80 opcodes
		DW 		add_a_c
		DW 		add_a_d
		DW 		add_a_e
		DW 		add_a_h
		DW 		add_a_l
		DW 		add_a_ihl
		DW 		add_a_a
		DW 		adc_a_b
		DW 		adc_a_c
		DW 		adc_a_d
		DW 		adc_a_e
		DW 		adc_a_h
		DW 		adc_a_l
		DW 		adc_a_ihl
		DW 		adc_a_a

		DW 		sub_b		; 90 opcodes
		DW 		sub_c
		DW 		sub_d
		DW 		sub_e
		DW 		sub_h
		DW 		sub_l
		DW 		sub_ihl
		DW 		sub_a
		DW 		sbc_a_b
		DW 		sbc_a_c
		DW 		sbc_a_d
		DW 		sbc_a_e
		DW 		sbc_a_h
		DW 		sbc_a_l
		DW 		sbc_a_ihl
		DW 		sbc_a_a

		DW 		and_b		; A0 opcodes
		DW 		and_c
		DW 		and_d
		DW 		and_e
		DW 		and_h
		DW 		and_l
		DW 		and_ihl
		DW 		and_a
		DW 		xor_b
		DW 		xor_c
		DW 		xor_d
		DW 		xor_e
		DW 		xor_h
		DW 		xor_l
		DW 		xor_ihl
		DW 		xor_a

		DW 		or_b		; B0 opcodes
		DW 		or_c
		DW 		or_d
		DW 		or_e
		DW 		or_h
		DW 		or_l
		DW 		or_ihl
		DW 		or_a
		DW 		cp_b
		DW 		cp_c
		DW 		cp_d
		DW 		cp_e
		DW 		cp_h
		DW 		cp_l
		DW 		cp_ihl
		DW 		cp_a

		DW 		ret_nz		; C0 opcodes
		DW 		pop_bc
		DW 		jp_nz_nn
		DW 		jp_nn
		DW 		call_nz_nn
		DW 		push_bc
		DW 		add_a_n
		DW 		rst_00
		DW 		ret_z
		DW 		ret_
		DW 		jp_z_nn
		DW 		prefix_cb
		DW 		call_z_nn
		DW 		call_nn
		DW 		adc_a_n
		DW 		rst_08
		
		DW 		ret_nc		; D0 opcodes
		DW 		pop_de
		DW 		jp_nc_nn
		DW 		out_in_a
		DW 		call_nc_nn
		DW 		push_de
		DW 		sub_n
		DW 		rst_10
		DW 		ret_c
		DW 		exx
		DW 		jp_c_nn
		DW 		in_a_in
		DW 		call_c_nn
		DW 		prefix_dd
		DW 		sbc_a_n
		DW 		rst_18
	
		DW 		ret_po		; E0 opcodes
		DW 		pop_hl
		DW 		jp_po_nn
		DW 		ex_isp_hl
		DW 		call_po_nn
		DW 		push_hl
		DW 		and_n
		DW 		rst_20
		DW 		ret_pe
		DW 		jp_hl
		DW 		jp_pe_nn
		DW 		ex_de_hl
		DW 		call_pe_nn
		DW 		prefix_ed
		DW 		xor_n
		DW 		rst_28
		
		DW 		ret_p		; F0 opcodes
		DW 		pop_af
		DW 		jp_p_nn
		DW 		di_
		DW 		call_p_nn
		DW 		push_af
		DW 		or_n
		DW 		rst_30
		DW 		ret_m
		DW 		ld_sp_hl
		DW 		jp_m_nn
		DW 		ei_
		DW 		call_m_nn
		DW 		prefix_fd
		DW 		cp_n
		DW 		rst_38


; -----------------------------------------------------------------------------

		ALIGN

CbTable:	DW 		rlc_b		; 00 opcodes
		DW 		rlc_c
		DW 		rlc_d
		DW 		rlc_e
		DW 		rlc_h
		DW 		rlc_l
		DW 		rlc_ihl
		DW 		rlc_a
		DW 		rrc_b
		DW 		rrc_c
		DW 		rrc_d
		DW 		rrc_e
		DW 		rrc_h
		DW 		rrc_l
		DW 		rrc_ihl
		DW 		rrc_a

		DW 		rl_b		; 10 opcodes
		DW 		rl_c
		DW 		rl_d
		DW 		rl_e
		DW 		rl_h
		DW 		rl_l
		DW 		rl_ihl
		DW 		rl_a
		DW 		rr_b
		DW 		rr_c
		DW 		rr_d
		DW 		rr_e
		DW 		rr_h
		DW 		rr_l
		DW 		rr_ihl
		DW 		rr_a
	
		DW 		sla_b		; 20 opcodes
		DW 		sla_c
		DW 		sla_d
		DW 		sla_e
		DW 		sla_h
		DW 		sla_l
		DW 		sla_ihl
		DW 		sla_a
		DW 		sra_b
		DW 		sra_c
		DW 		sra_d
		DW 		sra_e
		DW 		sra_h
		DW 		sra_l
		DW 		sra_ihl
		DW 		sra_a

		DW 		sll_b		; 30 opcodes
		DW 		sll_c
		DW 		sll_d
		DW 		sll_e
		DW 		sll_h
		DW 		sll_l
		DW 		sll_ihl
		DW 		sll_a
		DW 		srl_b
		DW 		srl_c
		DW 		srl_d
		DW 		srl_e
		DW 		srl_h
		DW 		srl_l
		DW 		srl_ihl
		DW 		srl_a
		
		DW 		bit_0_b		; 40 opcodes
		DW 		bit_0_c
		DW 		bit_0_d
		DW 		bit_0_e
		DW 		bit_0_h
		DW 		bit_0_l
		DW 		bit_0_ihl
		DW 		bit_0_a
		DW 		bit_1_b
		DW 		bit_1_c
		DW 		bit_1_d
		DW 		bit_1_e
		DW 		bit_1_h
		DW 		bit_1_l
		DW 		bit_1_ihl
		DW 		bit_1_a

		DW 		bit_2_b		; 50 opcodes
		DW 		bit_2_c
		DW 		bit_2_d
		DW 		bit_2_e
		DW 		bit_2_h
		DW 		bit_2_l
		DW 		bit_2_ihl
		DW 		bit_2_a
		DW 		bit_3_b
		DW 		bit_3_c
		DW 		bit_3_d
		DW 		bit_3_e
		DW 		bit_3_h
		DW 		bit_3_l
		DW 		bit_3_ihl
		DW 		bit_3_a

		DW 		bit_4_b		; 60 opcodes
		DW 		bit_4_c
		DW 		bit_4_d
		DW 		bit_4_e
		DW 		bit_4_h
		DW 		bit_4_l
		DW 		bit_4_ihl
		DW 		bit_4_a
		DW 		bit_5_b
		DW 		bit_5_c
		DW 		bit_5_d
		DW 		bit_5_e
		DW 		bit_5_h
		DW 		bit_5_l
		DW 		bit_5_ihl
		DW 		bit_5_a

		DW 		bit_6_b		; 70 opcodes
		DW 		bit_6_c
		DW 		bit_6_d
		DW 		bit_6_e
		DW 		bit_6_h
		DW 		bit_6_l
		DW 		bit_6_ihl
		DW 		bit_6_a
		DW 		bit_7_b
		DW 		bit_7_c
		DW 		bit_7_d
		DW 		bit_7_e
		DW 		bit_7_h
		DW 		bit_7_l
		DW 		bit_7_ihl
		DW 		bit_7_a

		DW 		res_0_b		; 80 opcodes
		DW 		res_0_c
		DW 		res_0_d
		DW 		res_0_e
		DW 		res_0_h
		DW 		res_0_l
		DW 		res_0_ihl
		DW 		res_0_a
		DW 		res_1_b
		DW 		res_1_c
		DW 		res_1_d
		DW 		res_1_e
		DW 		res_1_h
		DW 		res_1_l
		DW 		res_1_ihl
		DW 		res_1_a
	
		DW 		res_2_b		; 90 opcodes
		DW 		res_2_c
		DW 		res_2_d
		DW 		res_2_e
		DW 		res_2_h
		DW 		res_2_l
		DW 		res_2_ihl
		DW 		res_2_a
		DW 		res_3_b
		DW 		res_3_c
		DW 		res_3_d
		DW 		res_3_e
		DW 		res_3_h
		DW 		res_3_l
		DW 		res_3_ihl
		DW 		res_3_a

		DW 		res_4_b		; A0 opcodes
		DW 		res_4_c
		DW 		res_4_d
		DW 		res_4_e
		DW 		res_4_h
		DW 		res_4_l
		DW 		res_4_ihl
		DW 		res_4_a
		DW 		res_5_b
		DW 		res_5_c
		DW 		res_5_d
		DW 		res_5_e
		DW 		res_5_h
		DW 		res_5_l
		DW 		res_5_ihl
		DW 		res_5_a
	
		DW 		res_6_b		; B0 opcodes
		DW 		res_6_c
		DW 		res_6_d
		DW 		res_6_e
		DW 		res_6_h
		DW 		res_6_l
		DW 		res_6_ihl
		DW 		res_6_a
		DW 		res_7_b
		DW 		res_7_c
		DW 		res_7_d
		DW 		res_7_e
		DW 		res_7_h
		DW 		res_7_l
		DW 		res_7_ihl
		DW 		res_7_a
	
		DW 		set_0_b		; C0 opcodes
		DW 		set_0_c
		DW 		set_0_d
		DW 		set_0_e
		DW 		set_0_h
		DW 		set_0_l
		DW 		set_0_ihl
		DW 		set_0_a
		DW 		set_1_b
		DW 		set_1_c
		DW 		set_1_d
		DW 		set_1_e
		DW 		set_1_h
		DW 		set_1_l
		DW 		set_1_ihl
		DW 		set_1_a
	
		DW 		set_2_b		; D0 opcodes
		DW 		set_2_c
		DW 		set_2_d
		DW 		set_2_e
		DW 		set_2_h
		DW 		set_2_l
		DW 		set_2_ihl
		DW 		set_2_a
		DW 		set_3_b
		DW 		set_3_c
		DW 		set_3_d
		DW 		set_3_e
		DW 		set_3_h
		DW 		set_3_l
		DW 		set_3_ihl
		DW 		set_3_a
		
		DW 		set_4_b		; E0 opcodes
		DW 		set_4_c
		DW 		set_4_d
		DW 		set_4_e
		DW 		set_4_h
		DW 		set_4_l
		DW 		set_4_ihl
		DW 		set_4_a
		DW 		set_5_b
		DW 		set_5_c
		DW 		set_5_d
		DW 		set_5_e
		DW 		set_5_h
		DW 		set_5_l
		DW 		set_5_ihl
		DW 		set_5_a

		DW 		set_6_b		; F0 opcodes
		DW 		set_6_c
		DW 		set_6_d
		DW 		set_6_e
		DW 		set_6_h
		DW 		set_6_l
		DW 		set_6_ihl
		DW 		set_6_a
		DW 		set_7_b
		DW 		set_7_c
		DW 		set_7_d
		DW 		set_7_e
		DW 		set_7_h
		DW 		set_7_l
		DW 		set_7_ihl
		DW 		set_7_a
	

; -----------------------------------------------------------------------------

		ALIGN

EdTable:	DW 		bad_ed		; 00 opcodes
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
	
		DW 		bad_ed		; 10 opcodes
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed

		DW 		bad_ed		; 20 opcodes
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
	
		DW 		bad_ed		; 30 opcodes
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
	
		DW 		in_b_ic		; 40 opcodes
		DW 		out_ic_b
		DW 		sbc_hl_bc
		DW 		ld_inn_bc
		DW 		neg_
		DW 		retn_
		DW 		im_0
		DW 		ld_i_a
		DW 		in_c_ic
		DW 		out_ic_c
		DW 		adc_hl_bc
		DW 		ld_bc_inn
		DW 		neg_
		DW 		reti_
		DW 		im_0
		DW 		ld_r_a
		
		DW 		in_d_ic		; 50 opcodes
		DW 		out_ic_d
		DW 		sbc_hl_de
		DW 		ld_inn_de
		DW 		neg_
		DW 		retn_
		DW 		im_1
		DW 		ld_a_i
		DW 		in_e_ic
		DW 		out_ic_e
		DW 		adc_hl_de
		DW 		ld_de_inn
		DW 		neg_
		DW 		retn_
		DW 		im_2
		DW 		ld_a_r
		
		DW 		in_h_ic		; 60 opcodes
		DW 		out_ic_h
		DW 		sbc_hl_hl
		DW 		ld_inn_hl
		DW 		neg_
		DW 		retn_
		DW 		im_0
		DW 		rrd
		DW 		in_l_ic
		DW 		out_ic_l
		DW 		adc_hl_hl
		DW 		ld_hl_inn
		DW 		neg_
		DW 		retn_
		DW 		im_0
		DW 		rld
	
		DW 		in_ic		; 70 opcodes
		DW 		out_ic_0
		DW 		sbc_hl_sp
		DW 		ld_inn_sp
		DW 		neg_
		DW 		retn_
		DW 		im_1
		DW 		bad_ed
		DW 		in_a_ic
		DW 		out_ic_a
		DW 		adc_hl_sp
		DW 		ld_sp_inn
		DW 		neg_
		DW 		retn_
		DW 		im_2
		DW 		bad_ed
	
		DW 		bad_ed		; 80 opcodes
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
	
		DW 		bad_ed		; 90 opcodes
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
	
		DW 		ldi		; A0 opcodes
		DW 		cpi
		DW 		ini
		DW 		outi
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		ldd
		DW 		cpd
		DW 		ind
		DW 		outd
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
	
		DW 		ldir		; B0 opcodes
		DW 		cpir
		DW 		inir
		DW 		otir
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		lddr
		DW 		cpdr
		DW 		indr
		DW 		otdr
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed

		DW 		bad_ed		; C0 opcodes
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed

		DW 		bad_ed		; D0 opcodes
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed

		DW 		bad_ed		; E0 opcodes
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed

		DW 		bad_ed		; F0 opcodes
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed
		DW 		bad_ed

; -----------------------------------------------------------------------------

		ALIGN

DdTable:	DW 		nop_		; 00 opcodes
		DW 		ld_bc_nn
		DW 		ld_ibc_a
		DW 		inc_bc
		DW 		inc_b
		DW 		dec_b
		DW 		ld_b_n
		DW 		rlca
		DW 		ex_af_af
		DW 		add_ix_bc
		DW 		ld_a_ibc
		DW 		dec_bc
		DW 		inc_c
		DW 		dec_c
		DW 		ld_c_n
		DW 		rrca
		
		DW 		djnz_e		; 10 opcodes
		DW 		ld_de_nn
		DW 		ld_ide_a
		DW 		inc_de
		DW 		inc_d
		DW 		dec_d
		DW 		ld_d_n
		DW 		rla
		DW 		jr_e
		DW 		add_ix_de
		DW 		ld_a_ide
		DW 		dec_de
		DW 		inc_e
		DW 		dec_e
		DW 		ld_e_n
		DW 		rra
		
		DW 		jr_nz_e		; 20 opcodes
		DW 		ld_ix_nn
		DW 		ld_inn_ix
		DW 		inc_ix
		DW 		inc_ixh
		DW 		dec_ixh
		DW 		ld_ixh_n
		DW 		daa_
		DW 		jr_z_e
		DW 		add_ix_ix
		DW 		ld_ix_inn
		DW 		dec_ix
		DW 		inc_ixl
		DW 		dec_ixl
		DW 		ld_ixl_n
		DW 		cpl
		
		DW 		jr_nc_e		; 30 opcodes
		DW 		ld_sp_nn
		DW 		ld_inn_a
		DW 		inc_sp
		DW 		inc_iix
		DW 		dec_iix
		DW 		ld_iix_n
		DW 		scf
		DW 		jr_c_e
		DW 		add_ix_sp
		DW 		ld_a_inn
		DW 		dec_sp
		DW 		inc_a
		DW 		dec_a
		DW 		ld_a_n
		DW 		ccf
	
		DW 		nop_		; 40 opcodes
		DW 		ld_b_c
		DW 		ld_b_d
		DW 		ld_b_e
		DW 		ld_b_ixh
		DW 		ld_b_ixl
		DW 		ld_b_iix
		DW 		ld_b_a
		DW 		ld_c_b
		DW 		nop_
		DW 		ld_c_d
		DW 		ld_c_e
		DW 		ld_c_ixh
		DW 		ld_c_ixl
		DW 		ld_c_iix
		DW 		ld_c_a
	
		DW 		ld_d_b		; 50 opcodes
		DW 		ld_d_c
		DW 		nop_
		DW 		ld_d_e
		DW 		ld_d_ixh
		DW 		ld_d_ixl
		DW 		ld_d_iix
		DW 		ld_d_a
		DW 		ld_e_b
		DW 		ld_e_c
		DW 		ld_e_d
		DW 		nop_
		DW 		ld_e_ixh
		DW 		ld_e_ixl
		DW 		ld_e_iix
		DW 		ld_e_a
	
		DW 		ld_ixh_b	; 60 opcodes
		DW 		ld_ixh_c
		DW 		ld_ixh_d
		DW 		ld_ixh_e
		DW 		nop_
		DW 		ld_ixh_ixl
		DW 		ld_h_iix
		DW 		ld_ixh_a
		DW 		ld_ixl_b
		DW 		ld_ixl_c
		DW 		ld_ixl_d
		DW 		ld_ixl_e
		DW 		ld_ixl_ixh
		DW 		nop_
		DW 		ld_l_iix
		DW 		ld_ixl_a
	
		DW 		ld_iix_b	; 70 opcodes
		DW 		ld_iix_c
		DW 		ld_iix_d
		DW 		ld_iix_e
		DW 		ld_iix_h
		DW 		ld_iix_l
		DW 		halt   
		DW 		ld_iix_a
		DW 		ld_a_b
		DW 		ld_a_c
		DW 		ld_a_d
		DW 		ld_a_e
		DW 		ld_a_ixh
		DW 		ld_a_ixl
		DW 		ld_a_iix
		DW 		nop_

		DW 		add_a_b		; 80 opcodes
		DW 		add_a_c
		DW 		add_a_d
		DW 		add_a_e
		DW 		add_a_ixh
		DW 		add_a_ixl
		DW 		add_a_iix
		DW 		add_a_a
		DW 		adc_a_b
		DW 		adc_a_c
		DW 		adc_a_d
		DW 		adc_a_e
		DW 		adc_a_ixh
		DW 		adc_a_ixl
		DW 		adc_a_iix
		DW 		adc_a_a
		
		DW 		sub_b		; 90 opcodes
		DW 		sub_c
		DW 		sub_d
		DW 		sub_e
		DW 		sub_ixh
		DW 		sub_ixl
		DW 		sub_iix
		DW 		sub_a
		DW 		sbc_a_b
		DW 		sbc_a_c
		DW 		sbc_a_d
		DW 		sbc_a_e
		DW 		sbc_a_ixh
		DW 		sbc_a_ixl
		DW 		sbc_a_iix
		DW 		sbc_a_a

		DW 		and_b		; A0 opcodes
		DW 		and_c
		DW 		and_d
		DW 		and_e
		DW 		and_ixh
		DW 		and_ixl
		DW 		and_iix
		DW 		and_a
		DW 		xor_b
		DW 		xor_c
		DW 		xor_d
		DW 		xor_e
		DW 		xor_ixh
		DW 		xor_ixl
		DW 		xor_iix
		DW 		xor_a
	
		DW 		or_b		; B0 opcodes
		DW 		or_c
		DW 		or_d
		DW 		or_e
		DW 		or_ixh
		DW 		or_ixl
		DW 		or_iix
		DW 		or_a
		DW 		cp_b
		DW 		cp_c
		DW 		cp_d
		DW 		cp_e
		DW 		cp_ixh
		DW 		cp_ixl
		DW 		cp_iix
		DW 		cp_a

		DW 		ret_nz		; C0 opcodes
		DW 		pop_bc
		DW 		jp_nz_nn
		DW 		jp_nn
		DW 		call_nz_nn
		DW 		push_bc
		DW 		add_a_n
		DW 		rst_00
		DW 		ret_z
		DW 		ret_
		DW 		jp_z_nn
		DW 		prefix_dd_cb
		DW 		call_z_nn
		DW 		call_nn
		DW 		adc_a_n
		DW 		rst_08

		DW 		ret_nc		; D0 opcodes
		DW 		pop_de
		DW 		jp_nc_nn
		DW 		out_in_a
		DW 		call_nc_nn
		DW 		push_de
		DW 		sub_n
		DW 		rst_10
		DW 		ret_c
		DW 		exx
		DW 		jp_c_nn
		DW 		in_a_in
		DW 		call_c_nn
		DW 		prefix_dd
		DW 		sbc_a_n
		DW 		rst_18
	
		DW 		ret_po		; E0 opcodes
		DW 		pop_ix
		DW 		jp_po_nn
		DW 		ex_isp_ix
		DW 		call_po_nn
		DW 		push_ix
		DW 		and_n
		DW 		rst_20
		DW 		ret_pe
		DW 		jp_ix
		DW 		jp_pe_nn
		DW 		ex_de_hl
		DW 		call_pe_nn
		DW 		prefix_ed
		DW 		xor_n
		DW 		rst_28

		DW 		ret_p		; F0 opcodes
		DW 		pop_af
		DW 		jp_p_nn
		DW 		di_
		DW 		call_p_nn
		DW 		push_af
		DW 		or_n
		DW 		rst_30
		DW 		ret_m
		DW 		ld_sp_ix
		DW 		jp_m_nn
		DW 		ei_
		DW 		call_m_nn
		DW 		prefix_fd
		DW 		cp_n
		DW 		rst_38
		
; -----------------------------------------------------------------------------

		ALIGN

FdTable:	DW 		nop_		; 00 opcodes
		DW 		ld_bc_nn
		DW 		ld_ibc_a
		DW 		inc_bc
		DW 		inc_b
		DW 		dec_b
		DW 		ld_b_n
		DW 		rlca
		DW 		ex_af_af
		DW 		add_iy_bc
		DW 		ld_a_ibc
		DW 		dec_bc
		DW 		inc_c
		DW 		dec_c
		DW 		ld_c_n
		DW 		rrca
		
		DW 		djnz_e		; 10 opcodes
		DW 		ld_de_nn
		DW 		ld_ide_a
		DW 		inc_de
		DW 		inc_d
		DW 		dec_d
		DW 		ld_d_n
		DW 		rla
		DW 		jr_e
		DW 		add_iy_de
		DW 		ld_a_ide
		DW 		dec_de
		DW 		inc_e
		DW 		dec_e
		DW 		ld_e_n
		DW 		rra
		
		DW 		jr_nz_e		; 20 opcodes
		DW 		ld_iy_nn
		DW 		ld_inn_iy
		DW 		inc_iy
		DW 		inc_iyh
		DW 		dec_iyh
		DW 		ld_iyh_n
		DW 		daa_
		DW 		jr_z_e
		DW 		add_iy_iy
		DW 		ld_iy_inn
		DW 		dec_iy
		DW 		inc_iyl
		DW 		dec_iyl
		DW 		ld_iyl_n
		DW 		cpl
		
		DW 		jr_nc_e		; 30 opcodes
		DW 		ld_sp_nn
		DW 		ld_inn_a
		DW 		inc_sp
		DW 		inc_iiy
		DW 		dec_iiy
		DW 		ld_iiy_n
		DW 		scf
		DW 		jr_c_e
		DW 		add_iy_sp
		DW 		ld_a_inn
		DW 		dec_sp
		DW 		inc_a
		DW 		dec_a
		DW 		ld_a_n
		DW 		ccf
		
		DW 		nop_		; 40 opcodes
		DW 		ld_b_c
		DW 		ld_b_d
		DW 		ld_b_e
		DW 		ld_b_iyh
		DW 		ld_b_iyl
		DW 		ld_b_iiy
		DW 		ld_b_a
		DW 		ld_c_b
		DW 		nop_
		DW 		ld_c_d
		DW 		ld_c_e
		DW 		ld_c_iyh
		DW 		ld_c_iyl
		DW 		ld_c_iiy
		DW 		ld_c_a
	
		DW 		ld_d_b		; 50 opcodes
		DW 		ld_d_c
		DW 		nop_
		DW 		ld_d_e
		DW 		ld_d_iyh
		DW 		ld_d_iyl
		DW 		ld_d_iiy
		DW 		ld_d_a
		DW 		ld_e_b
		DW 		ld_e_c
		DW 		ld_e_d
		DW 		nop_
		DW 		ld_e_iyh
		DW 		ld_e_iyl
		DW 		ld_e_iiy
		DW 		ld_e_a
	
		DW 		ld_iyh_b	; 60 opcodes
		DW 		ld_iyh_c
		DW 		ld_iyh_d
		DW 		ld_iyh_e
		DW 		nop_
		DW 		ld_iyh_iyl
		DW 		ld_h_iiy
		DW 		ld_iyh_a
		DW 		ld_iyl_b
		DW 		ld_iyl_c
		DW 		ld_iyl_d
		DW 		ld_iyl_e
		DW 		ld_iyl_iyh
		DW 		nop_
		DW 		ld_l_iiy
		DW 		ld_iyl_a
	
		DW 		ld_iiy_b	; 70 opcodes
		DW 		ld_iiy_c
		DW 		ld_iiy_d
		DW 		ld_iiy_e
		DW 		ld_iiy_h
		DW 		ld_iiy_l
		DW 		halt
		DW 		ld_iiy_a
		DW 		ld_a_b
		DW 		ld_a_c
		DW 		ld_a_d
		DW 		ld_a_e
		DW 		ld_a_iyh
		DW 		ld_a_iyl
		DW 		ld_a_iiy
		DW 		nop_

		DW 		add_a_b		; 80 opcodes
		DW 		add_a_c
		DW 		add_a_d
		DW 		add_a_e
		DW 		add_a_iyh
		DW 		add_a_iyl
		DW 		add_a_iiy
		DW 		add_a_a
		DW 		adc_a_b
		DW 		adc_a_c
		DW 		adc_a_d
		DW 		adc_a_e
		DW 		adc_a_iyh
		DW 		adc_a_iyl
		DW 		adc_a_iiy
		DW 		adc_a_a
		
		DW 		sub_b		; 90 opcodes
		DW 		sub_c
		DW 		sub_d
		DW 		sub_e
		DW 		sub_iyh
		DW 		sub_iyl
		DW 		sub_iiy
		DW 		sub_a
		DW 		sbc_a_b
		DW 		sbc_a_c
		DW 		sbc_a_d
		DW 		sbc_a_e
		DW 		sbc_a_iyh
		DW 		sbc_a_iyl
		DW 		sbc_a_iiy
		DW 		sbc_a_a

		DW 		and_b		; A0 opcodes
		DW 		and_c
		DW 		and_d
		DW 		and_e
		DW 		and_iyh
		DW 		and_iyl
		DW 		and_iiy
		DW 		and_a
		DW 		xor_b
		DW 		xor_c
		DW 		xor_d
		DW 		xor_e
		DW 		xor_iyh
		DW 		xor_iyl
		DW 		xor_iiy
		DW 		xor_a
	
		DW 		or_b		; B0 opcodes
		DW 		or_c
		DW 		or_d
		DW 		or_e
		DW 		or_iyh
		DW 		or_iyl
		DW 		or_iiy
		DW 		or_a
		DW 		cp_b
		DW 		cp_c
		DW 		cp_d
		DW 		cp_e
		DW 		cp_iyh
		DW 		cp_iyl
		DW 		cp_iiy
		DW 		cp_a
		
		DW 		ret_nz		; C0 opcodes
		DW 		pop_bc
		DW 		jp_nz_nn
		DW 		jp_nn
		DW 		call_nz_nn
		DW 		push_bc
		DW 		add_a_n
		DW 		rst_00
		DW 		ret_z
		DW 		ret_
		DW 		jp_z_nn
		DW 		prefix_fd_cb
		DW 		call_z_nn
		DW 		call_nn
		DW 		adc_a_n
		DW 		rst_08
	
		DW 		ret_nc		; D0 opcodes
		DW 		pop_de
		DW 		jp_nc_nn
		DW 		out_in_a
		DW 		call_nc_nn
		DW 		push_de
		DW 		sub_n
		DW 		rst_10
		DW 		ret_c
		DW 		exx
		DW 		jp_c_nn
		DW 		in_a_in
		DW 		call_c_nn
		DW 		prefix_dd
		DW 		sbc_a_n
		DW 		rst_18
	
		DW 		ret_po		; E0 opcodes
		DW 		pop_iy
		DW 		jp_po_nn
		DW 		ex_isp_iy
		DW 		call_po_nn
		DW 		push_iy
		DW 		and_n
		DW 		rst_20
		DW 		ret_pe
		DW 		jp_iy
		DW 		jp_pe_nn
		DW 		ex_de_hl
		DW 		call_pe_nn
		DW 		prefix_ed
		DW 		xor_n
		DW 		rst_28
	
		DW 		ret_p		; F0 opcodes
		DW 		pop_af
		DW 		jp_p_nn
		DW 		di_
		DW 		call_p_nn
		DW 		push_af
		DW 		or_n
		DW 		rst_30
		DW 		ret_m
		DW 		ld_sp_iy
		DW 		jp_m_nn
		DW 		ei_
		DW 		call_m_nn
		DW 		prefix_fd
		DW 		cp_n
		DW 		rst_38
		
	
; -----------------------------------------------------------------------------

		ALIGN

XxCbTable:	DW 		bad_xxcb	; 00 opcodes
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		rlc_ixy
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		rrc_ixy
		DW 		bad_xxcb
	
		DW 		bad_xxcb	; 10 opcodes
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		rl_ixy
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		rr_ixy
		DW 		bad_xxcb
	
		DW 		bad_xxcb	; 20 opcodes
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		sla_ixy
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		sra_ixy
		DW 		bad_xxcb
	
		DW 		bad_xxcb	; 30 opcodes
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		sll_ixy
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		srl_ixy
		DW 		bad_xxcb

		DW 		bad_xxcb	; 40 opcodes
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bit_0_ixy
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bit_1_ixy
		DW 		bad_xxcb

		DW 		bad_xxcb	; 50 opcodes
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bit_2_ixy
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bit_3_ixy
		DW 		bad_xxcb

		DW 		bad_xxcb	; 60 opcodes
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bit_4_ixy
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bit_5_ixy
		DW 		bad_xxcb

		DW 		bad_xxcb	; 70 opcodes
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bit_6_ixy
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bit_7_ixy
		DW 		bad_xxcb

		DW 		bad_xxcb	; 80 opcodes
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		res_0_ixy
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		res_1_ixy
		DW 		bad_xxcb
	
		DW 		bad_xxcb	; 90 opcodes
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		res_2_ixy
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		res_3_ixy
		DW 		bad_xxcb
	
		DW 		bad_xxcb	; A0 opcodes
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		res_4_ixy
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		res_5_ixy
		DW 		bad_xxcb
		
		DW 		bad_xxcb	; B0 opcodes
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		res_6_ixy
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		res_7_ixy
		DW 		bad_xxcb
	
		DW 		bad_xxcb	; C0 opcodes
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		set_0_ixy
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		set_1_ixy
		DW 		bad_xxcb
		
		DW 		bad_xxcb	; D0 opcodes
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		set_2_ixy
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		set_3_ixy
		DW 		bad_xxcb
		
		DW 		bad_xxcb	; E0 opcodes
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		set_4_ixy
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		set_5_ixy
		DW 		bad_xxcb
	
		DW 		bad_xxcb	; F0 opcodes
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		set_6_ixy
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		bad_xxcb
		DW 		set_7_ixy
		DW 		bad_xxcb
		
; -----------------------------------------------------------------------------

