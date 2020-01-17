			.text			// executable code follows
			.global _start
_start:
			MOV		R6, #0			//Number to display				
			LDR		R10, =0xFF200050

PRELOOP:	LDRB	R3, [R10, #12]
			MOV		R3, #15
			STR		R3, [R10, #12]
MAINLOOP:	LDRB	R2, [R10]
			LDRB	R3, [R10, #12]
			
			CMP		R3, #0
			BNE		PAUSE
			
			ADD		R6, #1
			CMP		R6, #100
			BEQ		SETZERO
						
			B		DO_DELAY
			
WAIT:		LDRB	R2, [R10]
			CMP		R2, #0
			BEQ		PRELOOP
			B		WAIT
			
SETZERO:	MOV		R6, #0
			B		DISPLAY
			
PAUSE:		LDRB	R2, [R10]
			LDRB	R3, [R10, #12]
			MOV		R12, #0
			MOV		R3, #15
			
			STR		R3, [R10, #12]
			CMP		R2, #0
			BEQ		PAUSE
			B		WAIT
			
DO_DELAY: 	LDR	 	R7, =0xFFFEC600  	// delay counter 
			LDR		R0, =50000000
			STR		R0, [R7]
			MOV		R0, #0b00000101
			STR		R0, [R7, #8]
			MOV		R0, #0b00000001
			STR		R0, [R7, #12]
SUB_LOOP: 	LDR		R0, [R7, #12]
			CMP		R0, #0b00000001
			BNE SUB_LOOP
			B DISPLAY


/* Display R5 on HEX1-0*/
DISPLAY:    LDR     R3, =0xFF200020 // base address of HEX3-HEX0
            MOV     R0, R6          // display R5 on HEX1-0
            BL      DIVIDE          // ones digit will be in R0; tens
                                    // digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE       
            MOV     R4, R0          // save bit code
            MOV     R0, R9          // retrieve the tens digit, get bit
                                    // code
            BL      SEG7_CODE       
            LSL     R0, #8
            ORR     R4, R0     
			
			STR     R4, [R3]        // display the number from R7
			B		MAINLOOP

			
SEG7_CODE:  MOV     R11, #BIT_CODES  
            ADD     R11, R0         // index into the BIT_CODES "array"
			LDRB    R0, [R11]       // load the bit pattern (to be returned)
            MOV     PC, LR              

DIVIDE:   	MOV    	R2, #0			// Setting the quotients to zero
DTEN:       CMP    	R0, #10			// Checking if the value is greater than the Divisor to the Second power
            BLT    	DIV_END			// Moving to the next function if Divisor is greater than the remaining value
            SUB    	R0, #10			// Subtracting the divisor from the remaining value
            ADD    	R2, #1			// incrementing Tens value for each time through the full function
            B      	DTEN			// going back to beginning of function
DIV_END:    MOV    	R1, R2       	// quotient in R1 (remainder in R0)
            MOV    	PC, LR
			
   

		  
BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
			.byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
			.byte	0b00000000
			.skip   2      // pad with 2 bytes to maintain word alignment

			
.end