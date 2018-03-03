" Vim syntax file
" Language:	MD/RTL
" Maintainer:	cole945@gmail.com
" Last Change:	2012 Jan 6

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn keyword mdRtlExpr		UnKnown value debug_expr expr_list insn_list sequence address debug_insn insn jump_insn
syn keyword mdRtlExpr		call_insn barrier code_label note cond_exec parallel asm_input asm_operands unspec
syn keyword mdRtlExpr		unspec_volatile addr_vec addr_diff_vec prefetch set use clobber call return eh_return
syn keyword mdRtlExpr		trap_if const_int const_fixed const_double const_vector const_string const pc reg scratch
syn keyword mdRtlExpr		subreg strict_low_part concat concatn mem label_ref symbol_ref cc0 if_then_else compare
syn keyword mdRtlExpr		plus minus neg mult ss_mult us_mult div ss_div us_div mod udiv umod and ior xor not ashift
syn keyword mdRtlExpr		rotate ashiftrt lshiftrt rotatert smin smax umin umax pre_dec pre_inc post_dec post_inc
syn keyword mdRtlExpr		pre_modify post_modify ne eq ge gt le lt geu gtu leu ltu unordered ordered uneq unge ungt
syn keyword mdRtlExpr		unle unlt ltgt sign_extend zero_extend truncate float_extend float_truncate float fix
syn keyword mdRtlExpr		unsigned_float unsigned_fix fract_convert unsigned_fract_convert sat_fract unsigned_sat_fract
syn keyword mdRtlExpr		abs sqrt bswap ffs clz ctz popcount parity sign_extract zero_extract high lo_sum vec_merge
syn keyword mdRtlExpr		vec_select vec_concat vec_duplicate ss_plus us_plus ss_minus ss_neg us_neg ss_abs ss_ashift
syn keyword mdRtlExpr		us_ashift us_minus ss_truncate us_truncate fma var_location debug_implicit_ptr match_operand
syn keyword mdRtlExpr		match_scratch match_operator match_parallel match_dup match_op_dup match_par_dup match_code
syn keyword mdRtlExpr		match_test define_insn define_peephole define_split define_insn_and_split define_peephole2
syn keyword mdRtlExpr		define_expand define_delay define_asm_attributes define_cond_exec define_predicate
syn keyword mdRtlExpr		define_special_predicate define_register_constraint define_constraint define_memory_constraint
syn keyword mdRtlExpr		define_address_constraint define_cpu_unit define_query_cpu_unit exclusion_set presence_set
syn keyword mdRtlExpr		final_presence_set absence_set final_absence_set define_bypass define_automaton automata_option
syn keyword mdRtlExpr		define_reservation define_insn_reservation define_attr define_enum_attr attr set_attr
syn keyword mdRtlExpr		set_attr_alternative eq_attr eq_attr_alt attr_flag cond contained

syn keyword mdOthExpr		define_constants define_enum define_c_enum include contained

syn keyword mdCBuiltin		gen_rtx_ABS gen_rtx_ABSENCE gen_rtx_ADDR gen_rtx_ADDRESS gen_rtx_AND gen_rtx_ASHIFT gen_rtx_ASHIFTRT gen_rtx_ASM
syn keyword mdCBuiltin		gen_rtx_ATTR gen_rtx_AUTOMATA gen_rtx_BARRIER gen_rtx_BSWAP gen_rtx_CALL gen_rtx_CC0 gen_rtx_CLOBBER gen_rtx_CLZ
syn keyword mdCBuiltin		gen_rtx_CODE gen_rtx_COMPARE gen_rtx_CONCAT gen_rtx_CONCATN gen_rtx_COND gen_rtx_CONST gen_rtx_CTZ gen_rtx_DEBUG
syn keyword mdCBuiltin		gen_rtx_DEFINE gen_rtx_DIV gen_rtx_EH gen_rtx_EQ gen_rtx_EXCLUSION gen_rtx_EXPR gen_rtx_FFS gen_rtx_FINAL
syn keyword mdCBuiltin		gen_rtx_FIX gen_rtx_FLOAT gen_rtx_FMA gen_rtx_fmt gen_rtx_FRACT gen_rtx_GE gen_rtx_GEU gen_rtx_GT gen_rtx_GTU
syn keyword mdCBuiltin		gen_rtx_HIGH gen_rtx_IF gen_rtx_INSN gen_rtx_IOR gen_rtx_JUMP gen_rtx_LABEL gen_rtx_LE gen_rtx_LEU gen_rtx_LO
syn keyword mdCBuiltin		gen_rtx_LSHIFTRT gen_rtx_LT gen_rtx_LTGT gen_rtx_LTU gen_rtx_MATCH gen_rtx_MINUS gen_rtx_MOD gen_rtx_MULT
syn keyword mdCBuiltin		gen_rtx_NE gen_rtx_NEG gen_rtx_NOT gen_rtx_ORDERED gen_rtx_PARALLEL gen_rtx_PARITY gen_rtx_PC gen_rtx_PLUS
syn keyword mdCBuiltin		gen_rtx_POPCOUNT gen_rtx_POST gen_rtx_PRE gen_rtx_PREFETCH gen_rtx_PRESENCE gen_rtx_raw gen_rtx_RETURN gen_rtx_ROTATE
syn keyword mdCBuiltin		gen_rtx_ROTATERT gen_rtx_SAT gen_rtx_SCRATCH gen_rtx_SEQUENCE gen_rtx_SET gen_rtx_SIGN gen_rtx_SMAX gen_rtx_SMIN
syn keyword mdCBuiltin		gen_rtx_SQRT gen_rtx_SS gen_rtx_STRICT gen_rtx_SYMBOL gen_rtx_TRAP gen_rtx_TRUNCATE gen_rtx_UDIV gen_rtx_UMAX
syn keyword mdCBuiltin		gen_rtx_UMIN gen_rtx_UMOD gen_rtx_UNEQ gen_rtx_UNGE gen_rtx_UNGT gen_rtx_UNLE gen_rtx_UNLT gen_rtx_UNORDERED
syn keyword mdCBuiltin		gen_rtx_UNSIGNED gen_rtx_UNSPEC gen_rtx_US gen_rtx_USE gen_rtx_VALUE gen_rtx_VAR gen_rtx_VEC gen_rtx_XOR gen_rtx_ZERO

syn keyword mdCBuiltin		BImode BLKmode CCAmode CCANmode CCAPmode CCCmode CCFPEmode CCFPmode CCFPUmode CCGCmode CCGOCmode
syn keyword mdCBuiltin		CCImode CCLmode CCmode CCNOmode CCOmode CCRCmode CCSmode CCUmode CCZmode CDImode CHImode Cmode
syn keyword mdCBuiltin		COImode CQImode CSImode CTImode CZmode DCmode DDmode DFmode DImode EAmode Fmode GPRmode HAmode
syn keyword mdCBuiltin		HCmode HFmode HImode HQmode Imode INTRmode LTOmode NCVmode Nmode NOOVmode NOTBmode NZmode OFmode
syn keyword mdCBuiltin		OImode PDImode PHImode Pmode PQImode PSImode QCmode QFmode QImode QQmode RFmode Rmode SCmode SDmode
syn keyword mdCBuiltin		SFmode SImode TCmode TDmode TFmode TImode TLSmode TQFmode UDWmode UHAmode UHQmode UQQmode UTAmode
syn keyword mdCBuiltin		UWmode VOIDmode XCmode XFmode XImode Zmode ZSmode ZSOmode

syn keyword mdCBuiltin		EQ NE LE LT GE GT LEU LTU GEU GTU

syn keyword mdCBuiltin		DONE FAIL GET_CODE PUT_MODE XEXP
syn keyword mdCBuiltin		gen_reg_rtx emit_insn emit_move_insn gen_rtx_fmt_ee which_alternative force_reg GEN_INT PUT_CODE GET_CODE contained


syn match mdComment		";.*"

syn keyword mdCKeywords		auto break case continue default do else extern for goto if return sizeof switch while contained
syn keyword mdCTypes		char const double enum float int long register short static struct signed typedef union unsigned void volatile contained
syn region mdCComment		start="/\*" end="\*/" contained
syn match mdCConst		"\<[0-9]\>" contained
syn region mdCBlock		start="{" end="}" transparent fold contains=mdCBlock,mdCKeywords,mdString,mdCTypes,mdCComment,mdCConst,mdPatternCode,mdCBuiltin

syn match mdPatternCode		"{\*\?[a-zA-Z0-9_]*}" contained
" syn match mdBrackets		"\[\|\]" contained
syn region mdString		start=+"+ skip=+\\\\\|\\"+ end=+"+
syn region mdBlock		start="(" end=")" contains=mdRtlExpr,mdString,mdOthExpr,mdPatternCode,mdBrackets,mdBlock,mdCBlock

hi mdWhite     ctermfg=White
hi mdRed       ctermfg=1
hi mdGreen     ctermfg=2

hi def link mdCTypes		Type
hi def link mdCKeywords		Statement
hi def link mdCConst		Constant
hi def link mdCComment		Comment

hi def link mdPatternCode	Statement
hi def link mdCBuiltin		mdWhite
hi def link mdRtlExpr		mdGreen
hi def link mdOthExpr		Statement
hi def link mdComment		Comment
hi def link mdString		mdRed
hi def link mdBrackets		PreProc

let b:current_syntax = "md"
