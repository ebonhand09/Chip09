DisableInterrupts		MACRO
				ORCC	#$50			* Set I and F bits of CC
				ENDM

EnableInterrupts		MACRO
				ANDCC	#$EF			* Clear I bit (allow ints)
				ENDM
			
WaitForNextInterrupt		MACRO
				CWAI	#$EF
				ENDM
			
GetOtherHalfOfOpIntoA		MACRO
				LDA	Chip8_Instruction
				ANDA	#$0F
				ENDM
				
				
GetPostByteIntoB		MACRO
				LDB	Chip8_Instruction+1
				ANDB	#$0F
				ENDM
				
GetPreByteIntoB			MACRO
				LDB	Chip8_Instruction+1
				ANDB	#$F0				; Mask off MMM, leaving just the opcode
				LSRB
				LSRB
				LSRB
				LSRB
				ENDM
