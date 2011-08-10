

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

		
			
				INCLUDE		"./includes/interrupt-handler.asm"

				INCLUDE		"./includes/graphics-routines.asm"
				
				ORG	$1200
				
GraphicsPage			RMB	1024				
Video_RAM			
				INCLUDEBIN	"./data/chip09.dat"		; 256 bytes
				INCLUDE		"./includes/bit-transformation-table.asm"

				END	$E00
				
				
