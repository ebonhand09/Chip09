			
			;WaitForNextInterrupt			; Make the display prettier
			
			LDX	#Chip8_RAM+$200			; Set location of first instruction
			STX	Chip8_PC			; U = Chip8 Program Counter
			
			;**** Main fetch/decode/execute loop
			
MainLoop		LDD	,X++				; Get instruction into A/B
			STX	Chip8_PC			; This probably isn't needed
			STD	Chip8_Instruction		; Keep it.. we need this again
			LDY	#OpTable			; Avoid zero case
			
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
			FDB	Op8Xx6_ShiftRightXCarry
			FDB	Op8XY7_YMinusXIntoXCarry
			

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
* Sets VX to NN.
*************************************************
Op6XNN_SetVar			GetOtherHalfOfOpIntoA
				LDY	#Chip8_Vars-1
				INCA
				STB	A,Y
				RTS		
*************************************************

*************************************************
* Adds NN to VX.
*************************************************
Op7XNN_AddToVar			GetOtherHalfOfOpIntoA
				LDY	#Chip8_Vars-1
				INCA
				LEAY	A,Y
				ADDB	,Y
				STB	,Y
				RTS		
*************************************************

*************************************************
* Various Variable Manipulations - Subtable
*************************************************
Op8XYN_VariableManipulation	LDY	#OpTableFor8XYN-1
				GetPostByteIntoB
				LSLB			; Since table is a set of double-bytes, offset must be doubled
				INCB
				JSR	[B,Y]
				RTS				
				
*************************************************
* 0 - Sets VX to the value of VY.
*************************************************
Op8XY0_CopyYToX			LDY	#Chip8_Vars-1
				GetPreByteIntoB
				INCB
				LDB	B,Y
				GetOtherHalfOfOpIntoA
				INCA
				STB	A,Y
				RTS
				
*************************************************
* 1 - Sets VX to VX OR VY.
*************************************************				
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
* 2 - Sets VX to VX AND VY.
*************************************************			
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
				
*************************************************
* 3 - Sets VX to VX XOR VY.
*************************************************				
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
				
*************************************************
* 4 - Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't.
*************************************************				
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
				
*************************************************
* 5 - VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
*************************************************			
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
* 6 - Shifts VX right by one. VF is set to the value of the least significant bit of VX before the shift.
*************************************************
Op8Xx6_ShiftRightXCarry		LDY	#Chip8_Vars-1
				CLRB
				GetOtherHalfOfOpIntoA
				INCA		; Avoid zero-case
				LSR	A,Y
				ROLB		; Get the carry into B
				STB	Chip8_VF
				RTS

*************************************************
* 7 - Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
*************************************************
Op8XY7_YMinusXIntoXCarry	LDY	#Chip8_Vars-1
				GetOtherHalfOfOpIntoA
				INCA		; Avoid zero-case
				PSHS	A
				CLRB
				PSHS	B	; Used to clear B without affecting CC
				GetPreByteIntoB
				INCB		; Avoid zero-case
				LDB	B,Y
				SUBB	A,Y
				PULS	A	; Clear A
				ROLA		; Get the carry into A
				STA	Chip8_VF
				PULS	A
				STB	A,Y
				RTS

*************************************************
* E - Shifts VX left by one. VF is set to the value of the most significant bit of VX before the shift.
*************************************************
Op8XxE_ShiftLeftXCarry		LDY	#Chip8_Vars-1
				CLRB
				GetOtherHalfOfOpIntoA
				INCA		; Avoid zero-case
				LSL	A,Y
				ROLB		; Get the carry into B
				STB	Chip8_VF
				RTS

*************************************************
* 
*************************************************



*************************************************
* 
*************************************************





