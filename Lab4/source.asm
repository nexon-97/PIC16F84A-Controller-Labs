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

v_value equ 0x20
v_tmp equ 0x21

;====================================================================
; RESET and INTERRUPT VECTORS
;====================================================================

; Reset Vector
RST   code  0x0 
      GOTO  START
      
;====================================================================
; INTERRUPT HANDLER
;====================================================================

      org 0x4
      
      CLRF PORTB        ; Clear PORTB
      
      INCF v_value, 1   ; v_value++
      MOVF v_value, 0
      MOVWF v_tmp       ; v_tmp = v_value
      
      RLF v_tmp, 1      ; v_tmp << 1 (to position to correct output pins location)
      MOVF v_tmp, 0     ; W = v_tmp
      ANDLW 0x1E        ; W &= 0x1E (b'11110')
      
      BTFSC v_value, 0  ; Check LSB or v_value
      IORLW 0x20        ; If set, enable led pin (b'100000')
      
      MOVWF PORTB       ; PORTB = W
      
      BCF INTCON, INTF  ; Clear button interrupt flag
      RETFIE		; Allow all interrupts & return
      
;====================================================================
; CODE SEGMENT
;====================================================================

PGM   code

START
      CLRF PORTB      ; Clear PORTB
      BSF STATUS, RP0 ; Switch to bank1
      MOVLW 0x01      ; 
      MOVWF TRISB     ; Configure RB0 as input, and all others as outputs   
      BCF STATUS, RP0 ; Switch to bank0
      
      MOVLW 0
      MOVWF v_value   ; v_value = 0
      
      CLRF INTCON      ; Clear all interrupts
      BSF INTCON, INTE ; Allow interrupt on INTE
      BSF INTCON, GIE  ; Allow all interrupts globally
      
LOOP
      NOP
      GOTO LOOP

;====================================================================
      END
