			
			;WaitForNextInterrupt			; Make the display prettier
			
			LDX	#Chip8_RAM+$200			; Set location of first instruction
			STX	Chip8_PC			; U = Chip8 Program Counter
			
			;**** Main fetch/decode/execute loop
			
MainLoop		LDD	,X++				; Get instruction into A/B
			STX	Chip8_PC			; This probably isn't needed
			STD	Chip8_Instruction		; Keep it.. we need this again
			LDY	#OpTable
			
			ANDA	#$F0				; Mask off MMM, leaving just the opcode
			LSRA
			LSRA
			LSRA
			BNE	@SkipZeroCase
			JSR	[0,Y]
			JMP	MainLoop			
@SkipZeroCase		JSR	[A,Y]			
ReturnFromExecute	JMP	MainLoop

			;**** 

			
			;CWAI	#$EF
			
Loop			JMP	Loop

OpTable			
			FDB	Loop				
			FDB	Op1NNN_Jump
			FDB	Op2NNN_Subroutine
			FDB	Op3XNN_SkipNextIfEqual
			FDB	Op4XNN_SkipNextIfNotEqual
			FDB	Op5XY0_SkipNextIfVarsEqual
			FDB	Op6XNN_SetVar
			FDB	Op7XNN_AddToVar
			FDB	Op8XYN_VariableManipulation
			
OpTableFor8XYN
			FDB	Op8XY0_CopyYToX
			FDB	Op8XY1_XOrYIntoX
			;FDB	Op8XY2_XAndYIntoX
			

*************************************************
* 
*************************************************
Op1NNN_Jump			JMP	Loop
				RTS		
*************************************************

*************************************************
* 
*************************************************
Op2NNN_Subroutine		JMP	Loop
				RTS		
*************************************************

*************************************************
* 
*************************************************
Op3XNN_SkipNextIfEqual		JMP	Loop
				RTS		
*************************************************

*************************************************
* 
*************************************************
Op4XNN_SkipNextIfNotEqual	JMP	Loop
				RTS		
*************************************************

*************************************************
* 
*************************************************
Op5XY0_SkipNextIfVarsEqual	JMP	Loop
				RTS		
*************************************************

*************************************************
* 
*************************************************
Op6XNN_SetVar			GetOtherHalfOfOpIntoA
				LDY	#Chip8_Vars
				STB	A,Y
				RTS		
*************************************************

*************************************************
* 
*************************************************
Op7XNN_AddToVar			GetOtherHalfOfOpIntoA
				LDY	#Chip8_Vars
				LEAY	A,Y
				ADDB	,Y
				STB	,Y
				RTS		
*************************************************

*************************************************
* 
*************************************************
Op8XYN_VariableManipulation	LDY	#OpTableFor8XYN
				GetPostByteIntoB
				BNE	@SkipZeroCase
				JSR	[0,Y]
				RTS
@SkipZeroCase			LSLB			; Since table is a set of double-bytes, offset must be doubled
				JSR	[B,Y]
				RTS
				
				
;***
Op8XY0_CopyYToX			LDY	#Chip8_Vars
				GetPreByteIntoB
				LDB	B,Y
				GetOtherHalfOfOpIntoA
				STB	A,Y
				RTS
;***				
Op8XY1_XOrYIntoX		LDY	#Chip8_Vars-1
				GetPreByteIntoB
				INCB		; Avoid zero-case
				GetOtherHalfOfOpIntoA
				INCA		; Avoid zero-case
				PSHS	A
				LDA	A,Y
				ORA	B,Y
				PULS	B
				STA	B,Y
				RTS
				
				
				
				
				
				
*************************************************





