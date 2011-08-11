			
			;WaitForNextInterrupt			; Make the display prettier
			
			LDX	#Chip8_RAM+$200			; Set location of first instruction
			STX	Chip8_PC			; X = Chip8 Program Counter
			LDU	#Chip8_Stack			; U = Chip8 Stack
			STU	Chip8_StackPointer
			
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

			
			INCLUDE		"./optable-main.asm"	; System opcode table
			
			INCLUDE		"./optable-0nnn.asm"	; System opcode table
			
			INCLUDE		"./optable-8xyn.asm"	; System opcode table		
			

			
*************************************************
* 0 - Call System
*************************************************
Op0NNN_System			LDY	#OpTableFor0NNN
				GetOtherHalfOfOpIntoA	; B is pre-set
				BEQ	@DoSystemLookup
				RTS			; Calling an undefined routine
@DoSystemLookup			LSLB			; Since table is a set of double-bytes, offset must be doubled
				ROLA					
				JSR	[D,Y]
				RTS
				
*************************************************
* 00-E0 - Clear Screen
*************************************************
Op00E0_ClearScreen		PSHS	X
				LDX	#Video_RAM
				LDD	#$00
				LDY	#120
!				STD	,X++
				LEAY	-1,Y
				BNE	<
				PULS	X
				RTS
				
*************************************************
* 00-EE - Return from Subroutine
*************************************************
Op00EE_ReturnFromSubroutine	PULU	X
				RTS
				
*************************************************
* 1 - Jumps to address NNN.
*************************************************
Op1NNN_Jump			GetOtherHalfOfOpIntoA	; B is pre-set
				LDX	#Chip8_RAM
				LEAX	D,X	
				RTS
						
*************************************************

*************************************************
* 2 - Calls subroutine at NNN.
*************************************************
Op2NNN_Subroutine		PSHU	X
				STU	Chip8_StackPointer
				GetOtherHalfOfOpIntoA	; B is pre-set
				LEAX	D,X
				RTS
					
*************************************************

*************************************************
* 3 - Skips the next instruction if VX equals NN.
*************************************************
Op3XNN_SkipNextIfEqual		LDY	#Chip8_Vars
				GetOtherHalfOfOpIntoA
				LDA	A,Y
				CMPA	Chip8_Instruction+1	; Value of B in 
				BNE	@Return
				LEAX	2,X		; Skip next instruction
@Return				RTS
						
*************************************************

*************************************************
* 4 - Skips the next instruction if VX doesn't equal NN.
*************************************************
Op4XNN_SkipNextIfNotEqual	LDY	#Chip8_Vars
				GetOtherHalfOfOpIntoA
				LDA	A,Y
				CMPA	Chip8_Instruction+1	; Value of B in 
				BEQ	@Return
				LEAX	2,X		; Skip next instruction
@Return				RTS

*************************************************

*************************************************
* 5 - Skips the next instruction if VX equals VY.
*************************************************
Op5XY0_SkipNextIfVarsEqual	LDY	#Chip8_Vars
				GetOtherHalfOfOpIntoA
				ANDB	#$F0
				LSRB
				LSRB
				LSRB
				LSRB
				LDA	A,Y
				CMPA	B,Y
				BNE	@Return
				LEAX	2,X		; Skip next instruction
@Return				RTS

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
* 9-0 - Skips the next instruction if VX doesn't equal VY.
*************************************************
Op9XY0_SkipNextIfVarsNotEqual	LDY	#Chip8_Vars
				GetOtherHalfOfOpIntoA
				ANDB	#$F0
				LSRB
				LSRB
				LSRB
				LSRB
				LDA	A,Y
				CMPA	B,Y
				BEQ	@Return
				LEAX	2,X		; Skip next instruction
@Return				RTS

*************************************************

*************************************************
* A - Sets I to the address NNN.
*************************************************
OpANNN_SetI			GetOtherHalfOfOpIntoA
				STD	Chip8_I
				RTS

*************************************************

*************************************************
* B - Jumps to the address NNN plus V0.
*************************************************
OpBNNN_JumpToAddressPlusV0	GetOtherHalfOfOpIntoA	; B is pre-set
				LDX	#Chip8_RAM
				LEAX	D,X
				LDY	#Chip8_Vars
				CLRA
				LDB	Chip8_V0
				LEAX	D,X
				RTS

*************************************************
* C - Sets VX to a random number and NN.
*************************************************
OpCXNN_RandomNumberAndNN	LDA	#$0E		; Program execution space
				STA	Chip8_Random
				INC	Chip8_Random+1
				LDY	Chip8_Random
				LDA	Chip8_Seed
				ADDA	,Y
				EORA	$FF,Y
				STA	Chip8_Seed
				ANDA	Chip8_Instruction+1
				TFR	A,B
				GetOtherHalfOfOpIntoA
				LDY	#Chip8_Vars
				STB	A,Y
				RTS
				
*************************************************
* D - Draw sprite at I to VX, VY with N lines
*************************************************
OpDXYN_DrawSprite		PSHS	X		; X = Source (Sprite)
				LDX	#Chip8_RAM
				CLR	Chip8_VF
				LDD	Chip8_I
				LEAX	D,X		; X now points at sprite
				
				LDY	#Chip8_Vars
				GetPreByteIntoB
				LDB	B,Y
				STB	Chip8_VY	; VY = vertical loc
				
				GetOtherHalfOfOpIntoA
				LDA	A,Y
				STA	Chip8_VX	; VX = horizontal loc
				
				GetPostByteIntoB
				BNE	@Not16Case
				LDB	#16
@Not16Case			STB	Chip8_PatternCount	; N = number of vertbytes

@GetByte			LDA	,X
				STA	Chip8_PatternHigh
				CLR	Chip8_PatternLow
				LDB	Chip8_VX
				ANDB	#7
@CheckPosition			BEQ	@CorrectPosition
				LSR	Chip8_PatternHigh
				ROR	Chip8_PatternLow
				DECB
				BNE	@CheckPosition				
@CorrectPosition		LDA	Chip8_VY
				ANDA	#$1F	; Mask to 5 bits for wrap
				ASLA
				ASLA
				ASLA	
				LDB	Chip8_VX
				ANDB	#$3F	; Mask to 6 bits
				LSRB
				LSRB
				LSRB
				PSHS	A
				ADDB	,S+
				PSHS	X
				LDX	#Video_RAM
				ABX
				TFR	X,Y
				PULS	X
				LDA	Chip8_PatternHigh
				LDB	Chip8_PatternHigh
				EORA	,Y
				ORB	,Y
				STA	,Y
				CMPB	,Y
				BEQ	@NoOverlapHigh
				LDA	$1
				STA	Chip8_VF
@NoOverlapHigh			LDA	Chip8_PatternLow
				LDB	Chip8_PatternLow
				EORA	1,Y
				ORB	1,Y
				STA	1,Y
				CMPB	1,Y
				BEQ	@NoOverlapLow
				LDA	$1
				STA	Chip8_VF
@NoOverlapLow			INC	Chip8_VY
				LEAX	1,X
				DEC	Chip8_PatternCount
				BNE	@GetByte
				
				PULS	X
				RTS
				
				
				
				
				
				






