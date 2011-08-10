			
			;WaitForNextInterrupt			; Make the display prettier
			
			LDX	#Chip8_RAM+$200			; Set location of first instruction
			STX	Chip8_PC			; U = Chip8 Program Counter
			
			;**** Main fetch/decode/execute loop
			
MainLoop		LDD	,X++				; Get instruction into A/B
			STX	Chip8_PC			; This probably isn't needed
			STD	Chip8_Instruction		; Keep it.. we need this again
			LDY	#OpTable-1			; Avoid zero case
			
			ANDA	#$F0				; Mask off MMM, leaving just the opcode
			LSRA
			LSRA
			LSRA
			INCA		; Avoid zero case

			JSR	[A,Y]			
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
			FDB	Op8XY2_XAndYIntoX
			FDB	Op8XY3_XEorYIntoX
			FDB	Op8XY4_XPlusYIntoXCarry
			FDB	Op8XY5_XMinusYIntoXCarry
			

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
Op8XYN_VariableManipulation	LDY	#OpTableFor8XYN-1
				GetPostByteIntoB
				LSLB			; Since table is a set of double-bytes, offset must be doubled
				INCB
				JSR	[B,Y]
				RTS
				
				
;***
Op8XY0_CopyYToX			LDY	#Chip8_Vars-1
				GetPreByteIntoB
				INCB
				LDB	B,Y
				GetOtherHalfOfOpIntoA
				INCA
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
				
;***				
Op8XY2_XAndYIntoX		LDY	#Chip8_Vars-1
				GetPreByteIntoB
				INCB		; Avoid zero-case
				GetOtherHalfOfOpIntoA
				INCA		; Avoid zero-case
				PSHS	A
				LDA	A,Y
				ANDA	B,Y
				PULS	B
				STA	B,Y
				RTS
				
;***				
Op8XY3_XEorYIntoX		LDY	#Chip8_Vars-1
				GetPreByteIntoB
				INCB		; Avoid zero-case
				GetOtherHalfOfOpIntoA
				INCA		; Avoid zero-case
				PSHS	A
				LDA	A,Y
				EORA	B,Y
				PULS	B
				STA	B,Y
				RTS				
				
;***				
Op8XY4_XPlusYIntoXCarry		LDY	#Chip8_Vars-1
				GetOtherHalfOfOpIntoA
				INCA		; Avoid zero-case
				PSHS	A
				CLRB
				PSHS	B	; Used to clear B without affecting CC
				GetPreByteIntoB
				INCB		; Avoid zero-case
				LDA	A,Y
				ADDA	B,Y
				PULS	B	; Clear B
				ROLB		; Get the carry into B
				STB	Chip8_VF
				PULS	B
				STA	B,Y
				RTS
				
;***				
Op8XY5_XMinusYIntoXCarry	LDY	#Chip8_Vars-1
				GetOtherHalfOfOpIntoA
				INCA		; Avoid zero-case
				PSHS	A
				CLRB
				PSHS	B	; Used to clear B without affecting CC
				GetPreByteIntoB
				INCB		; Avoid zero-case
				LDA	A,Y
				SUBA	B,Y
				PULS	B	; Clear B
				ROLB		; Get the carry into B
				STB	Chip8_VF
				PULS	B
				STA	B,Y
				RTS			
				
				
*************************************************





