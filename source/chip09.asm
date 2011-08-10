				INCLUDE		"./includes/macro-definitions.asm"

				;**** Start execution here
				
				ORG	$E00		; Safe starting ram
				
				LBSR	SetVideoMode
				
				LBSR	ClearVideo
				
				LBSR	SetIntHandler	; Set up Interrupts
				
				
				;**** Main Loop
				
				INCLUDE		"./includes/main-loop.asm"
				
				;**** End Main loop
				
				;**** Load required subroutines into memory
			
				INCLUDE		"./includes/interrupt-handler.asm"

				INCLUDE		"./includes/graphics-routines.asm"
				
				;**** Storage area for data, variables, etc
				ORG	$1200
								
GraphicsPage			RMB	1024				; Coco video RAM - $1200
				
Chip8_RAM			ZMB	$100				; CHIP-8 RAM - $1600
Video_RAM			INCLUDEBIN	"./data/chip09.dat"	; CHIP-8 Video RAM - $1700 - 256 bytes
Chip8_Program			INCLUDEBIN	"./roms/chip8test.rom"	; CHIP-8 Program to run
Chip8_RestOfRAM			ZMB	Chip8_RAM+4096-*		; Empty RAM
Chip8_EndOfRAM			ZMB	1				; Placeholder/extra byte to get a convenient label
				
Chip8_Vars				
Chip8_V0			ZMB	1
Chip8_V1			ZMB	1
Chip8_V2			ZMB	1
Chip8_V3			ZMB	1
Chip8_V4			ZMB	1
Chip8_V5			ZMB	1
Chip8_V6			ZMB	1
Chip8_V7			ZMB	1
Chip8_V8			ZMB	1
Chip8_V9			ZMB	1
Chip8_VA			ZMB	1
Chip8_VB			ZMB	1
Chip8_VC			ZMB	1
Chip8_VD			ZMB	1
Chip8_VE			ZMB	1
Chip8_VF			ZMB	1
Chip8_I				ZMB	2
Chip8_Instruction		ZMB	4
Chip8_PC			ZMB	2
Chip8_StackPointer		ZMB	2
Chip8_Stack			ZMB	63
Chip8_StackEnd			ZMB	1
				
				
				;* Bit Transformation Table - CHIP-8 Video to Coco G1R Video
				INCLUDE		"./includes/bit-transformation-table.asm"

				END	$E00
				
				
