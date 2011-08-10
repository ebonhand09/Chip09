DisableInterrupts	MACRO
			ORCC	#$50			* Set I and F bits of CC
			ENDM

EnableInterrupts	MACRO
			ANDCC	#$EF			* Clear I bit (allow ints)
			ENDM
			
WaitForNextInterrupt	MACRO
			CWAI	#$EF
			ENDM
