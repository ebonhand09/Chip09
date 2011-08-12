*************************************************
* IntHandler - Interrupt Handler
*************************************************		


; X - Pointer to lookup table - to allow ABX
; Y - Pointer to Coco video byte
; U - Pointer Chip8 video byte
; A/B/D - Transformations/Offsets
; Use CMPX / BNE for loop for now until I unroll

IntHandler
				TST	Chip8_DelayTimer
				BNE	@SkipDecDelay
				DEC	Chip8_DelayTimer
@SkipDecDelay			TST	Chip8_SoundTimer
				BNE	@SkipDecSound
				DEC	Chip8_SoundTimer
@SkipDecSound				
				LDY	#GraphicsPage+16	; offset so I can write behind
				PSHS	U
				LDU	#Video_RAM
				LDX	#TransformTable
DrawLine			
						
				CLRA				; Draw Byte/Word 1
				LDB	,U+
				LSLB
				ROLA
				LDD	D,X
				STD	-16,Y
				STD	,Y++
				
				CLRA				; Draw Byte/Word 2
				LDB	,U+
				LSLB
				ROLA
				LDD	D,X
				STD	-16,Y
				STD	,Y++
				
				CLRA				; Draw Byte/Word 3
				LDB	,U+
				LSLB
				ROLA
				LDD	D,X
				STD	-16,Y
				STD	,Y++
				
				CLRA				; Draw Byte/Word 4
				LDB	,U+
				LSLB
				ROLA
				LDD	D,X
				STD	-16,Y
				STD	,Y++
				
				CLRA				; Draw Byte/Word 5
				LDB	,U+
				LSLB
				ROLA
				LDD	D,X
				STD	-16,Y
				STD	,Y++
				
				CLRA				; Draw Byte/Word 6
				LDB	,U+
				LSLB
				ROLA
				LDD	D,X
				STD	-16,Y
				STD	,Y++
				
				CLRA				; Draw Byte/Word 7
				LDB	,U+
				LSLB
				ROLA
				LDD	D,X
				STD	-16,Y
				STD	,Y++
				
				CLRA				; Draw Byte/Word 8
				LDB	,U+
				LSLB
				ROLA
				LDD	D,X
				STD	-16,Y
				STD	,Y++
							
				LEAY	16,Y			; Skip line already drawn	
								
				CMPU	#Video_RAM+256
				LBNE	DrawLine	
				
				PULS	U
				
IntExit				LDA	$FF02
				RTI

*************************************************
* SetIntHandler - Sets up the Interrupt Handler
*************************************************
SetIntHandler
				ORCC	#$50		; Set I and F bits of CC
				LDA	#$7E		; JMP Opcode
				STA	$010C		; JMP Opcode in Vector Table
				LDX	#IntHandler
				STX	$010D
		
				LDA	$FF03		; Read CRB
				ORA	#$05		; Set bits 0 and 2
				ORA	#%00000010	; Set bit 1
				STA	$FF03		; Put in CRB
		
				LDA	$FF02		; Read DRB(Clear Flag)
				ANDCC	#$EF		; Clear I bit (allow ints)
				RTS

