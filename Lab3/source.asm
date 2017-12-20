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

v_timer_delay equ 0x20
v_led_status equ 0x21

;====================================================================

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
      
      COMF v_led_status, 1 ; v_led_status = ~v_led_status
      MOVF v_led_status, 0 ; W = v_led_status
      MOVWF PORTB
      
      MOVF v_timer_delay, 0 ; W = v_timer_delay
      MOVWF TMR0 	    ; TMR0 = W
      
      BCF INTCON, T0IF ; Clear timer interrupt flag
      RETFIE		; BSF INTCON, GIE, RETURN

;====================================================================
; CODE SEGMENT
;====================================================================

PGM   code      
     
START:
      CLRF PORTB ; Clear PORTB & TMR0
      CLRF TMR0

      BSF STATUS, RP0 ; Switch to bank1
      MOVLW 0x0
      MOVWF TRISB     ; Configuring all ports B as outputs
      
      BCF OPTION_REG, 5 ; Use internal clock for TMR0
      BCF OPTION_REG, 3 ; Prescaler assigned to TMR0
      
      MOVLW 0xF8	  ; W = 0xF8 (Prescaler mask, masks out 3 LSB)
      ANDWF OPTION_REG, 1 ; OPTION_REG &= 0xF8
      MOVLW b'010'	  ; W = b'010' (1:8)
      IORWF OPTION_REG, 1 ; OPTION_REG |= W
      
      BCF STATUS, RP0
      CLRF INTCON ; Clear all interrupts
     
      MOVLW 0x0F
      MOVWF v_timer_delay ; v_timer_delay = 0x0F
      MOVWF TMR0 	  ; TMR0 = v_timer_delay
      
      MOVLW 0
      MOVWF v_led_status ; v_led_status = 0
      
      BSF INTCON, T0IE ; Allow interrupt on T0IE
      BSF INTCON, GIE  ; Allow all interrupts

LOOP:      
      NOP
      GOTO  LOOP

;====================================================================
      END
