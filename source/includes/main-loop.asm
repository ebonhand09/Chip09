			
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
			FDB	Loop	; nop - 8
			FDB	Loop	; nop - 9
			FDB	Loop	; nop - A
			FDB	Loop	; nop - B
			FDB	Loop	; nop - C
			FDB	Loop	; nop - D
			FDB	Op8XxE_ShiftLeftXCarry
			

*************************************************
* 1 - Jumps to address NNN.
*************************************************
Op1NNN_Jump			JMP	Loop
				RTS		
*************************************************

*************************************************
* 2 - Calls subroutine at NNN.
*************************************************
Op2NNN_Subroutine		JMP	Loop
				RTS		
*************************************************

*************************************************
* 3 - Skips the next instruction if VX equals NN.
*************************************************
Op3XNN_SkipNextIfEqual		JMP	Loop
				RTS		
*************************************************

*************************************************
* 4 - Skips the next instruction if VX doesn't equal NN.
*************************************************
Op4XNN_SkipNextIfNotEqual	JMP	Loop
				RTS		
*************************************************

*************************************************
* 5 - Skips the next instruction if VX equals VY.
*************************************************
Op5XY0_SkipNextIfVarsEqual	JMP	Loop
				RTS		
*************************************************

*************************************************
* 6 - Sets VX to NN.
*************************************************
Op6XNN_SetVar			GetOtherHalfOfOpIntoA
				LDY	#Chip8_Vars
				STB	A,Y
				RTS		
*************************************************

*************************************************
* 7 - Adds NN to VX.
*************************************************
Op7XNN_AddToVar			GetOtherHalfOfOpIntoA
				LDY	#Chip8_Vars
				LEAY	A,Y
				ADDB	,Y
				STB	,Y
				RTS		
*************************************************

*************************************************
* 8 - Various Variable Manipulations - Subtable
*************************************************
Op8XYN_VariableManipulation	LDY	#OpTableFor8XYN
				GetPostByteIntoB
				LSLB			; Since table is a set of double-bytes, offset must be doubled				
				JSR	[B,Y]
				RTS				
				
*************************************************
* 8-0 - Sets VX to the value of VY.
*************************************************
Op8XY0_CopyYToX			LDY	#Chip8_Vars
				GetPreByteIntoB
				LDB	B,Y
				GetOtherHalfOfOpIntoA
				STB	A,Y
				RTS
				
*************************************************
* 8-1 - Sets VX to VX OR VY.
*************************************************				
Op8XY1_XOrYIntoX		LDY	#Chip8_Vars
				GetPreByteIntoB
				GetOtherHalfOfOpIntoA
				PSHS	A
				LDA	A,Y
				ORA	B,Y
				PULS	B
				STA	B,Y
				RTS
				
*************************************************
* 8-2 - Sets VX to VX AND VY.
*************************************************			
Op8XY2_XAndYIntoX		LDY	#Chip8_Vars
				GetPreByteIntoB
				GetOtherHalfOfOpIntoA
				PSHS	A
				LDA	A,Y
				ANDA	B,Y
				PULS	B
				STA	B,Y
				RTS
				
*************************************************
* 8-3 - Sets VX to VX XOR VY.
*************************************************				
Op8XY3_XEorYIntoX		LDY	#Chip8_Vars
				GetPreByteIntoB
				GetOtherHalfOfOpIntoA
				PSHS	A
				LDA	A,Y
				EORA	B,Y
				PULS	B
				STA	B,Y
				RTS				
				
*************************************************
* 8-4 - Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't.
*************************************************				
Op8XY4_XPlusYIntoXCarry		LDY	#Chip8_Vars
				GetOtherHalfOfOpIntoA
				PSHS	A
				CLRB
				PSHS	B	; Used to clear B without affecting CC
				GetPreByteIntoB
				LDA	A,Y
				ADDA	B,Y
				PULS	B	; Clear B
				ROLB		; Get the carry into B
				STB	Chip8_VF
				PULS	B
				STA	B,Y
				RTS
				
*************************************************
* 8-5 - VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
*************************************************			
Op8XY5_XMinusYIntoXCarry	LDY	#Chip8_Vars
				GetOtherHalfOfOpIntoA
				PSHS	A
				CLRB
				PSHS	B	; Used to clear B without affecting CC
				GetPreByteIntoB
				LDA	A,Y
				SUBA	B,Y
				PULS	B	; Clear B
				ROLB		; Get the carry into B
				STB	Chip8_VF
				PULS	B
				STA	B,Y
				RTS			
				
*************************************************
* 8-6 - Shifts VX right by one. VF is set to the value of the least significant bit of VX before the shift.
*************************************************
Op8Xx6_ShiftRightXCarry		LDY	#Chip8_Vars
				CLRB
				GetOtherHalfOfOpIntoA
				LSR	A,Y
				ROLB		; Get the carry into B
				STB	Chip8_VF
				RTS

*************************************************
* 8-7 - Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
*************************************************
Op8XY7_YMinusXIntoXCarry	LDY	#Chip8_Vars
				GetOtherHalfOfOpIntoA
				PSHS	A
				CLRB
				PSHS	B	; Used to clear B without affecting CC
				GetPreByteIntoB
				LDB	B,Y
				SUBB	A,Y
				PULS	A	; Clear A
				ROLA		; Get the carry into A
				STA	Chip8_VF
				PULS	A
				STB	A,Y
				RTS

*************************************************
* 8-E - Shifts VX left by one. VF is set to the value of the most significant bit of VX before the shift.
*************************************************
Op8XxE_ShiftLeftXCarry		LDY	#Chip8_Vars
				CLRB
				GetOtherHalfOfOpIntoA
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





