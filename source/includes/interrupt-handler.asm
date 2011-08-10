; X - Pointer to lookup table - to allow ABX
; Y - Pointer to Coco video byte
; U - Pointer Chip8 video byte
; A/B/D - Transformations/Offsets
; Use CMPX / BNE for loop for now until I unroll

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

