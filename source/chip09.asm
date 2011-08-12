				INCLUDE		"./includes/macro-definitions.asm"
				INCLUDE		"./includes/keyboard-definitions.asm"

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
				ORG	$3000
								
GraphicsPage			RMB	1024				; Coco video RAM - $3000
				
Chip8_RAM			INCLUDE		"./includes/font-table.asm"	; CHIP-8 RAM
				ZMB	Chip8_RAM+$100-*
;Video_RAM			INCLUDEBIN	"./data/chip09.dat"	; CHIP-8 Video RAM 256 bytes
Video_RAM			ZMB	256
Chip8_Program			INCLUDEBIN	"./roms/breakout.rom"	; CHIP-8 Program to run
Chip8_RestOfRAM			ZMB	Chip8_RAM+4096-*		; Empty RAM
Chip8_EndOfRAM				
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
Chip8_VX			ZMB	1
Chip8_VY			ZMB	1
Chip8_I				ZMB	2
Chip8_N				ZMB	1
Chip8_Instruction		ZMB	4
Chip8_PC			ZMB	2
Chip8_StackPointer		ZMB	2
Chip8_StackStart		ZMB	63
Chip8_Stack			ZMB	1
Chip8_Seed			ZMB	1
Chip8_Random			ZMB	2
Chip8_PatternHigh		ZMB	1
Chip8_PatternLow		ZMB	1
Chip8_PatternCount		ZMB	1
Chip8_DelayTimer		FCB	0
Chip8_SoundTimer		FCB	0

KeymapTable
Keymap_0_Row			FCB	KB_Row_X
Keymap_0_Bit			FCB	KB_Bit_X
Keymap_1_Row			FCB	KB_Row_1
Keymap_1_Bit			FCB	KB_Bit_1
Keymap_2_Row			FCB	KB_Row_2
Keymap_2_Bit			FCB	KB_Bit_2
Keymap_3_Row			FCB	KB_Row_3
Keymap_3_Bit			FCB	KB_Bit_3
Keymap_4_Row			FCB	KB_Row_Q
Keymap_4_Bit			FCB	KB_Bit_Q
Keymap_5_Row			FCB	KB_Row_W
Keymap_5_Bit			FCB	KB_Bit_W
Keymap_6_Row			FCB	KB_Row_E
Keymap_6_Bit			FCB	KB_Bit_E
Keymap_7_Row			FCB	KB_Row_A
Keymap_7_Bit			FCB	KB_Bit_A
Keymap_8_Row			FCB	KB_Row_S
Keymap_8_Bit			FCB	KB_Bit_S
Keymap_9_Row			FCB	KB_Row_D
Keymap_9_Bit			FCB	KB_Bit_D
Keymap_A_Row			FCB	KB_Row_Z
Keymap_A_Bit			FCB	KB_Bit_Z
Keymap_B_Row			FCB	KB_Row_C
Keymap_B_Bit			FCB	KB_Bit_C
Keymap_C_Row			FCB	KB_Row_4
Keymap_C_Bit			FCB	KB_Bit_4
Keymap_D_Row			FCB	KB_Row_R
Keymap_D_Bit			FCB	KB_Bit_R
Keymap_E_Row			FCB	KB_Row_F
Keymap_E_Bit			FCB	KB_Bit_F
Keymap_F_Row			FCB	KB_Row_V
Keymap_F_Bit			FCB	KB_Bit_V
				
				;* Bit Transformation Table - CHIP-8 Video to Coco G1R Video
				INCLUDE		"./includes/bit-transformation-table.asm"

				END	$E00
				
				
