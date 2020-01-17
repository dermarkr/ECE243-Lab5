			.text			// executable code follows
			.global _start
_start:
			MOV		R0, #0			//Number to display				
			MOV		R3, #1			//Display On
			MOV 	R5, #KEYMASKS
			LDR		R10, =0xFF200050
			
			
MAINLOOP:	MOV		R4, PC
			ADD		R4, #4
			B       DISPLAY

			LDRB	R2, [R10]
			
			LDRB	R6, [R5]
			AND		R6, R2
			MOV		R4, PC
			ADD		R4, #8
			CMP		R6, #0b00000001
			MOVEQ	PC, #SETZERO
			
			LDRB	R6, [R5, #1]
			AND		R6, R2
			MOV		R4, PC
			ADD		R4, #8
			CMP		R6, #0b00000010
			MOVEQ	PC, #ADDONE
			
			LDRB	R6, [R5, #2]
			AND		R6, R2
			MOV		R4, PC
			ADD		R4, #8
			CMP		R6, #0b00000100
			MOVEQ	PC, #CHECKZERO
			
			LDRB	R6, [R5, #3]
			AND		R6, R2
			MOV		R4, PC
			ADD		R4, #8
			CMP		R6, #0b00001000
			MOVEQ	PC, #BLANK
			
			B		MAINLOOP
			
WAIT:		LDRB	R2, [R10]
			CMP		R2, #0
			MOVEQ	PC, R4
			B		WAIT
			
SETZERO:	MOV		R0, #0
			MOV		R3, #1
			B 		WAIT
			
ADDONE:		CMP		R3, #0
			BEQ		SETZERO
			ADD		R0, #1
			MOV		R3, #1
			B		WAIT
			
CHECKZERO:	CMP		R3, #0
			BEQ		SETZERO
			CMP		R0, #0
			BEQ		WAIT
			B		SUBONE
			
SUBONE:		SUB		R0, #1
			MOV		R3, #1
			B		WAIT
			
BLANK:		MOV 	R3, #0
			B		WAIT
			
SHOW:		MOV 	R3, #1
			B		WAIT
			

KEYMASKS:	.byte	0b00000001, 0b00000010, 0b00000100, 0b00001000			



			
/* Display R5 on HEX1-0*/
DISPLAY:    LDR     R8, =0xFF200020 // base address of HEX3-HEX0
            MOV     R7, R0          // display R5 on HEX1-0
			CMP		R3, #0
			MOVEQ	R7, #11
            BL      SEG7_CODE       
			
			STR     R7, [R8]        // display the number from R7
			MOV		PC, R4

			
SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R7         // index into the BIT_CODES "array"
			LDRB    R7, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR              


			
   

		  
BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
			.byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
			.byte	0b00000000
			.skip   2      // pad with 2 bytes to maintain word alignment

			
		  .end