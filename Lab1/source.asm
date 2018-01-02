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

v_ptr equ 0x2F  ; the pointer to the current element in array, a variable
v_min equ 0x2D  ; the maximal number in array, a variable
v_swap1 equ 0x2C
v_swap2 equ 0x2B
v_addsum equ 0x20
v_subsum equ 0x21

c_adr set 0x30  ; the starting address of the array, a constant
c_num set 0x14   ; the number of elements in array, a constant 

;====================================================================
; RESET and INTERRUPT VECTORS
;====================================================================

; Reset Vector
RST      code 0x0 
	GOTO MAIN
      
;====================================================================
; Default interrupt handler
;====================================================================      
org 0x04
	RETFIE      
      
;====================================================================

MAIN:
	BCF STATUS, RP0 ; Switch to bank 0
	CLRF v_ptr   
	CLRF v_min 
	GOTO OUTLOOP2

; Exercise 1
MININIT:
	MOVF v_ptr, 0 
	ADDLW c_adr
	MOVWF FSR
	MOVF INDF, 0
	MOVWF v_min

LOOP1:
	MOVF v_min, 0 
	SUBWF INDF, 0
	BTFSC STATUS, 0
	GOTO SKIP1
		
	MOVF INDF, 0
	MOVWF v_min 
	
SKIP1:
	INCF FSR, 1
	MOVLW c_num
	ADDLW c_adr
	SUBWF FSR,0
	BTFSS STATUS,0
	GOTO LOOP1
	GOTO CLEAR

; Exercise 2
OUTLOOP2: 
	MOVLW c_adr
	MOVWF FSR
	INCF FSR, 1

INLOOP2: 
	MOVF INDF,0
	MOVWF v_swap1 
	DECF FSR, 1
	MOVF INDF, 0
	INCF FSR, 1
	SUBWF v_swap1, 0 
	BTFSC STATUS,0 
	GOTO SKIP2

	DECF FSR, 1
	MOVF INDF,0
	MOVWF v_swap2
	MOVF v_swap1, 0
	MOVWF INDF
	INCF FSR, 1
	MOVF v_swap2, 0
	MOVWF INDF

SKIP2:
	INCF FSR, 1
	MOVF v_ptr, 0
	SUBLW c_num
	ADDLW c_adr
	SUBWF FSR, 0
	BTFSS STATUS, 0
	GOTO INLOOP2
	
	;Outloop2 continue
	INCF v_ptr, 1	
	MOVLW c_num
	SUBWF v_ptr, 0
	BTFSS STATUS, 0 
	GOTO OUTLOOP2
	GOTO CLEAR

; Exercise 3
OUTLOOP3: 
	MOVLW c_adr
	MOVWF FSR
	INCF FSR, 1

INLOOP3: 
	MOVF INDF, 0
	MOVWF v_swap1 
	DECF FSR, 1
	MOVF v_swap1, 0
	SUBWF INDF, 0
	INCF FSR, 1
	BTFSC STATUS,0
	GOTO SKIP3

	DECF FSR, 1
	MOVF INDF,0
	MOVWF v_swap2
	MOVF v_swap1, 0
	MOVWF INDF
	INCF FSR, 1
	MOVF v_swap2, 0
	MOVWF INDF

SKIP3:
	INCF FSR, 1
	MOVF v_ptr, 0
	SUBLW c_num
	ADDLW c_adr
	SUBWF FSR, 0
	BTFSS STATUS, 0
	GOTO INLOOP3

	INCF v_ptr, 1	
	MOVLW c_num
	SUBWF v_ptr, 0
	BTFSS STATUS, 0
	GOTO OUTLOOP3
	GOTO CLEAR

; Additional task
ADDINIT:
	CLRF v_subsum
	CLRF v_addsum
	MOVF v_ptr, 0 
	ADDLW c_adr
	MOVWF FSR

LOOPA:
	MOVLW 0x7F  
	SUBWF INDF, 0
	BTFSC STATUS, 0
	GOTO SUB 
	
ADD:
	MOVF INDF, 0
	ADDWF v_addsum, 1
	GOTO NEXT
SUB:
	MOVF INDF, 0
	ADDWF v_subsum, 1

NEXT:
	INCF FSR, 1
	MOVLW c_num
	ADDLW c_adr
	SUBWF FSR, 0
	BTFSS STATUS,0
	GOTO LOOPA

CLEAR:
	CLRF v_ptr
	CLRF v_min
 
END
