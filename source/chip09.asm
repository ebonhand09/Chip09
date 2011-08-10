

				ORG	$E00		; Safe starting ram
				
				LBSR	SetVideoMode
				
				LBSR	ClearVideo
				
				LBSR	SetIntHandler	; Set up Interrupts
				
				
				
MainLoop			
				ORCC	#$50		; Turn off ints
				LDX	#Video_RAM
				LDY	#128
!				LDD	,X
				COMA
				COMB
				STD	,X++
				LEAY	-1,Y
				BNE	<
							
				CWAI	#$EF
				
Loop				JMP	MainLoop

*************************************************
* IntHandler - Interrupt Handler
*************************************************		
IntHandler		
			
				INCLUDE	"./includes/interrupt-handler.asm"

		
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

*************************************************
* SetVideoMode - Sets G1R, Graphics Page to $1200
*************************************************

SetVideoMode			LDA	$FF23		; Get CRB
				ANDA	#$FB		; Clear bit 2
				STA	$FF23		; Put it back
				LDA	#$F8		; DDRB Config
				STA	$FF22		; Put in DDRB
				LDA	$FF23		; CRB Again
				ORA	#$04		; Set bit 2
				STA	$FF23		; Put it back again
				LDA	#$98		; VDG=G1R, C=1
				STA	$FF22		; Write it
				
				; Set video display starting address
				; Name	Set	Clear
				
				; F6	$FFD3 / $FFD2	- 0
				STA	$FFD2				
				; F5	$FFD1 / $FFD0	- 0
				STA	$FFD0				
				; F4	$FFCF / $FFCE	- 0
				STA	$FFCE				
				; F3	$FFCD / $FFCC	- 1
				STA	$FFCD				
				; F2	$FFCB / $FFCA	- 0
				STA	$FFCA				
				; F1	$FFC9 / $FFC8	- 0
				STA	$FFC8				
				; F0	$FFC7 / $FFC6	- 1
				STA	$FFC7
				
				STA	$FFC1	; Ciaran fix?
				
				RTS
				
*************************************************
* ClearVideo - Clears the graphics page at GraphicsPage
*************************************************
ClearVideo			LDX	#GraphicsPage
				LDY	#1024
				LDA	#%00000000
!				STA	,X+
				LEAY	-1,Y
				BNE	<
				RTS
				
				ORG	$1200
GraphicsPage			RMB	1024				
Video_RAM			
				INCLUDEBIN	"./data/chip09.dat"		; 256 bytes
				INCLUDE		"./includes/bit-transformation-table.asm"

				END	$E00
				
				
