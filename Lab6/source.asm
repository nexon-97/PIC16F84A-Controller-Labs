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
v_bit equ 0x21
v_counter equ 0x22
v_scancode equ 0x23
v_key equ 0x24

;====================================================================
; SCANCODES TABLE (DCBA0123)
SCANCODE_0 equ b'10000010'
SCANCODE_1 equ b'00010100'
SCANCODE_2 equ b'00010010'
SCANCODE_3 equ b'00010001'
SCANCODE_4 equ b'00100100'
SCANCODE_5 equ b'00100010'
SCANCODE_6 equ b'00100001'
SCANCODE_7 equ b'01000100'
SCANCODE_8 equ b'01000010'
SCANCODE_9 equ b'01000001'

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

;====================================================================
;== Pause routine

PAUSE:
      MOVLW 0xFF
      MOVWF v_pause
      
L0:
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      DECFSZ v_pause, 1
      GOTO L0
      RETURN
      
;====================================================================     
;== Tests scancode match (v_scancode vs W), result is stored in v_is_ok LSB 

SCANCODE_TEST MACRO key, scancode
      
      MOVLW key
      MOVWF v_key
      MOVLW scancode
      
      SUBWF v_scancode, 0
      SKPNZ
      GOTO SIGNAL_PROCESSED
      
      ENDM

;====================================================================            
      
READ_KEY:
      MOVLW 1
      MOVWF v_bit
      MOVLW 3
      MOVWF v_counter
      BCF STATUS, C ; Clear carry flag
      
COLUMN_LOOP:
      MOVF v_bit, 0
      MOVWF PORTB   ; pass v_bit to PORTB
      
      GOTO SIGNAL_TEST

SIGNAL_FOUND:
      MOVF PORTB, 0 
      MOVWF v_scancode ; v_scancode = PORTB
      
      SCANCODE_TEST 0, SCANCODE_0
      SCANCODE_TEST 1, SCANCODE_1
      SCANCODE_TEST 2, SCANCODE_2
      SCANCODE_TEST 3, SCANCODE_3
      SCANCODE_TEST 4, SCANCODE_4
      SCANCODE_TEST 5, SCANCODE_5
      SCANCODE_TEST 6, SCANCODE_6
      SCANCODE_TEST 7, SCANCODE_7
      SCANCODE_TEST 8, SCANCODE_8
      SCANCODE_TEST 9, SCANCODE_9
     
SIGNAL_TEST:      
      ; Test 4 MSB to check keyboard signal
      BTFSC PORTB, 4
      GOTO SIGNAL_FOUND
      BTFSC PORTB, 5
      GOTO SIGNAL_FOUND
      BTFSC PORTB, 6
      GOTO SIGNAL_FOUND
      BTFSC PORTB, 7
      GOTO SIGNAL_FOUND
      
      ; Make next one-hot sequence
      RLF v_bit, 1
      
      DECFSZ v_counter
      GOTO COLUMN_LOOP
      GOTO READ_KEY_EXIT
      
SIGNAL_PROCESSED:
      MOVF v_key, 0
      MOVWF PORTA
      
READ_KEY_EXIT:     
      RETURN
      
;====================================================================       
      
START:
      BSF STATUS, RP0   ; Switch to bank1
      CLRF TRISA        ; PORTA is output only
      MOVLW b'11110000' ; Set port RA2 as input, others as outputs
      MOVWF TRISB       ; RP4-RP7 are inputs, R0-R3 are outputs
      BCF STATUS, RP0   ; Switch to bank0
      
      CLRF PORTA        ; Clear ports
      CLRF PORTB        ;

MAIN:
      CALL READ_KEY
      CALL PAUSE
      
      GOTO MAIN

;====================================================================
      END
