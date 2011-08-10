				INCLUDE		"./includes/macro-definitions.asm"

				;**** Start execution here
				
				ORG	$E00		; Safe starting ram
				
				LBSR	SetVideoMode
				
				LBSR	ClearVideo
				
				LBSR	SetIntHandler	; Set up Interrupts
				
				
				;**** Main Loop
MainLoop			
				DisableInterrupts
				
				;* Temporary time-waster
				
				LDX	#Video_RAM
				LDY	#128
!				LDD	,X
				COMA
				COMB
				STD	,X++
				LEAY	-1,Y
				BNE	<
				
				;* End Temporary time-waster
							
				WaitForNextInterrupt
				
Loop				JMP	MainLoop
				;**** End Main loop
				
				;**** Load required subroutines into memory
			
				INCLUDE		"./includes/interrupt-handler.asm"

				INCLUDE		"./includes/graphics-routines.asm"
				
				;**** Storage area for data, variables, etc
				ORG	$1200

				;* Coco video RAM - $1200				
GraphicsPage			RMB	1024
				
				;* CHIP-8 RAM - $1600
Video_RAM			
				INCLUDEBIN	"./data/chip09.dat"		; 256 bytes
				
				;* Bit Transformation Table - CHIP-8 Video to Coco G1R Video
				INCLUDE		"./includes/bit-transformation-table.asm"

				END	$E00
				
				
