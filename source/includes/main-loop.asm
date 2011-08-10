MainLoop			
				;* Temporary time-waster
				
				DisableInterrupts
				
				LDX	#Video_RAM
				LDY	#128
!				LDD	,X
				COMA
				COMB
				STD	,X++
				LEAY	-1,Y
				BNE	<
				
				WaitForNextInterrupt
				
				;* End Temporary time-waster
							
				
				
Loop				JMP	MainLoop
