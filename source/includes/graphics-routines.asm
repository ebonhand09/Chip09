*************************************************
* SetVideoMode - Sets G1R, Graphics Page to $3000 - 11000 0 00000000
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
				; F4	$FFCF / $FFCE	- 1
				STA	$FFCF				
				; F3	$FFCD / $FFCC	- 1
				STA	$FFCD				
				; F2	$FFCB / $FFCA	- 0
				STA	$FFCA				
				; F1	$FFC9 / $FFC8	- 0
				STA	$FFC8				
				; F0	$FFC7 / $FFC6	- 0
				STA	$FFC6
				
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
