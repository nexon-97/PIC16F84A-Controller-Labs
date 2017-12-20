;====================================================================
; Processor: PIC16F84A
; Compiler:  MPASM (Proteus)
;====================================================================

;====================================================================
; DEFINITIONS
;====================================================================

#include p16f84a.inc ; Include register definition file            

;====================================================================
; VARIABLES

v_pause equ 0x20
v_serial_value equ 0x21
v_counter equ 0x22

;====================================================================
; RESET and INTERRUPT VECTORS
;====================================================================

; Reset Vector
RST   code  0x0 
      GOTO  START

;====================================================================
; CODE SEGMENT
;====================================================================

PGM   code

PAUSE
      MOVLW 0xFF
      MOVWF v_pause
L0:
      NOP
      DECFSZ v_pause
      GOTO L0
      RETURN

START:
      BSF STATUS, RP0 ; Switch to bank1
      MOVLW 0x04      ; Set port RA2 as input, others as outputs
      MOVWF TRISA     ;
      CLRF TRISB      ; Set all PORTB as output
      BCF STATUS, RP0 ; Switch to bank0
      
      GOTO MAIN_LOOP
            
WRITE_REGISTER_OUTPUT:
      RLF v_serial_value, 1     ; Shift v_serial_value
      BTFSC PORTA, 2		; Write RA2 input v_serial_value LSB
      BSF v_serial_value, 0     ;
      
      RETURN
      
MAIN_LOOP:
      CLRF v_serial_value ; v_serial_value = 0
      MOVLW 3
      MOVWF PORTA  
      CLRF PORTB

      BCF PORTA, 0
      BSF PORTA, 0    ; Pulse shift register load command input, 
		      ; then register MSB is written to RA2 input
      BCF STATUS, C 

      MOVLW 8
      MOVWF v_counter ; v_counter = 7
		      
LOAD_LOOP:	
      CALL WRITE_REGISTER_OUTPUT
      
      BCF PORTA, 1    ; Shift register, get next bit in RA2
      BSF PORTA, 1
      
      DECFSZ v_counter, 1
      GOTO LOAD_LOOP
      
      BTFSS v_serial_value, 7
      GOTO SET_FIRST_LED
      
SET_SECOND_LED:
      BCF PORTA, 3
      BSF PORTB, 7
      GOTO END_SET_LED
      
SET_FIRST_LED:
      BSF PORTA, 3
      BCF PORTB, 7
  
END_SET_LED:  
      MOVF v_serial_value, W
      XORLW 0x7F
      MOVWF PORTB
      
      CALL PAUSE
      
      GOTO MAIN_LOOP
  
      END
