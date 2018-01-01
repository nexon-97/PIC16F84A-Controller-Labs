#include p16f84a.inc                
;====================================================================
; VARIABLES
;====================================================================
#DEFINE BANK0 BCF STATUS, RP0
#DEFINE BANK1 BSF STATUS, RP0

RS equ 0x01
RW equ 0x02
EN equ 0x03
v_pause equ 0x10
v_lcd_buf equ 0x11
v_lcd_tmp equ 0x12
v_count equ 0x13
v_count_spaces equ 0x14
v_pause_2 equ 0x15
v_control_flags equ 0x16
v_t equ 0x17

; LCD instructions
constant LCD_CD=0x01 ; Clear Display :2ms
constant LCD_CH=0x02 ; Cursor Home :2ms
constant LCD_ON=0x0C ; Display On :40us
constant LCD_OF=0x08 ; Display Off :40us
constant LCD_CN=0x0E ; Cursor On :40us
constant LCD_CB=0x09 ; Cursor Blink :40us
constant LCD_2L=0x28 ; LCD has 2 lines,
constant LCD_4B=0x20 ; 4-bitinterface :40us
constant LCD_L1=0x80 ; select 1 line :40us
constant LCD_L2=0xC0 ; select 2 line :40us

constant letter_A = 0x41
constant letter_B = 0x42
constant letter_C = 0x43
constant letter_D = 0x44
constant letter_E = 0x45
constant letter_G = 0x47
constant letter_H = 0x48
constant letter_I = 0x49
constant letter_K = 0x4B
constant letter_L = 0x4C
constant letter_M = 0x4D
constant letter_N = 0x4E
constant letter_O = 0x4F
constant letter_P = 0x50
constant letter_R = 0x52
constant letter_S = 0x53
constant letter_U = 0x55
constant letter_V = 0x56
constant letter_X = 0x58
constant letter_Y = 0x59

constant empty = 0xA0

;====================================================================
; RESET and INTERRUPT VECTORS
;====================================================================

      ; Reset Vector
RST   code  0x0 
      GOTO  MAIN

;====================================================================
; CODE SEGMENT
;====================================================================

PGM   code

;--------------------------------------------
; ~1ms delay for 4MHz
; One instruction in 1us
; Delay=2+1+1+249*4+3+2=1005
; Real delay for 1,005 ms.

DELAY_1MS
      MOVLW 0xFA ; 1us, W=250
      MOVWF v_pause ; 1us
DELAY_LOOP:
      NOP ; 1us
      DECFSZ v_pause,1 ; 1us
      GOTO DELAY_LOOP ; 2us
      RETURN
      
Delay_2ms macro
      CALL DELAY_1MS
      CALL DELAY_1MS
      endm


Delay_250ms macro 
      MOVLW 0x8F ; 1us
      MOVWF v_pause_2 ; 1us
DELAY_500LOOP      
      NOP ; 1us
      Delay_2ms
      DECFSZ v_pause_2,1 ; 1us
      GOTO DELAY_500LOOP ; 2us
      endm
      
      ;~40us delay for 4MHz
Delay_40us
      MOVLW 0x08
      MOVWF v_pause
D1:
      NOP
      DECFSZ v_pause,1
      GOTO D1
      RETURN
      
PAUSE
      Delay_250ms
      RETURN
      
START_1L 
      MOVLW LCD_L1
      CALL LCD_CMD
      CALL Delay_40us 
      RETURN
   
START_2L 
      MOVLW LCD_L2
      CALL LCD_CMD
      CALL Delay_40us 
      RETURN
      
WRITE_SYMBOL macro symbol
      MOVLW symbol
      CALL LCD_DAT

      endm
    
; ========================================  
; Writes W spaces
WRITE_SPACES:
      MOVWF v_count
      
SPACES_LOOP:
      WRITE_SYMBOL empty
      DECFSZ v_count
      GOTO SPACES_LOOP

      RETURN
      
; ========================================

BSUIR:
      BTFSC v_control_flags, 0
      GOTO SPACES_BSUIR

LETTERS_BSUIR:
      WRITE_SYMBOL letter_B
      WRITE_SYMBOL letter_S
      WRITE_SYMBOL letter_U
      WRITE_SYMBOL letter_I
      WRITE_SYMBOL letter_R
      
      BTFSC v_control_flags, 0
      GOTO END_BSUIR
      
SPACES_BSUIR:
      MOVLW 0x0B
      CALL WRITE_SPACES
      
      BTFSC v_control_flags, 0
      GOTO LETTERS_BSUIR
      
END_BSUIR:    
      RETURN
 
; ======================================== 
PONYAKOV:
      BTFSC v_control_flags, 0
      GOTO SPACES_PON

LETTERS_PON:
      WRITE_SYMBOL letter_P
      WRITE_SYMBOL letter_O
      WRITE_SYMBOL letter_N
      WRITE_SYMBOL letter_Y
      WRITE_SYMBOL letter_A
      WRITE_SYMBOL letter_K
      WRITE_SYMBOL letter_O
      WRITE_SYMBOL letter_V
      
      BTFSC v_control_flags, 0
      GOTO END_PONYAKOV
      
SPACES_PON:
      MOVLW 8
      CALL WRITE_SPACES
      
      BTFSC v_control_flags, 0
      GOTO LETTERS_PON
  
END_PONYAKOV:   
      RETURN
      
;============================================
; Write W to LCD
LCD_W_WR
      CLRF PORTB 
      MOVWF PORTB 
      CALL DELAY_1MS 
      BSF PORTB, EN ; E='1'
      BCF PORTB, EN ; E='0'; EN defined as equ 3 higher
      CALL DELAY_1MS ; Wait for 1ms
      CLRF PORTB ; Clear port
      RETURN
   
;============================================
;Write command or data to LCD
;Command or data is Wreg   
LCD_CMD
      CLRF v_lcd_buf ; clear buffer
      
      MOVWF v_lcd_tmp ; v_lcd_tmp := W
      ANDLW 0xF0 	; 
      IORWF v_lcd_buf, W ; v_lcd_buf = (W & 0xF0) | v_lcd_buf
      CALL LCD_W_WR 
      
      SWAPF v_lcd_tmp, W 
      ANDLW 0xF0 
      IORWF v_lcd_buf, W 
      CALL LCD_W_WR 
      
      RETURN
      
      
;============================================
; Write data to LCD
LCD_DAT
      CLRF v_lcd_buf
      BSF v_lcd_buf, RS
      MOVWF v_lcd_tmp
      ANDLW 0xF0
      IORWF v_lcd_buf, W
      CALL LCD_W_WR
      
      SWAPF v_lcd_tmp, W
      ANDLW 0xF0
      IORWF v_lcd_buf, W
      CALL LCD_W_WR
      
      CALL Delay_40us
      
      RETURN
      
;============================================
; LCD display initialization
LCD_INIT
      BANK1
      CLRF TRISB ; All outputs on PORTB
      MOVLW 0x03
      MOVWF TRISA ; All inputs on PORTA
      
      BANK0
      CLRF PORTA ; Clear PORTA
      CLRF PORTB ; Clear PORTB
      
      CALL DELAY_1MS ; Delay in 4ms after
      CALL DELAY_1MS ; power is on
      CALL DELAY_1MS
      CALL DELAY_1MS
      
      MOVLW LCD_4B ; 4-bit data interface
      CALL LCD_W_WR
      CALL Delay_40us
      
      MOVLW LCD_ON ; Turn on LCD
      CALL LCD_CMD
      CALL Delay_40us
      
      MOVLW LCD_2L ; 2 lines
      CALL LCD_CMD
      CALL Delay_40us
      
      MOVLW LCD_CD
      CALL LCD_CMD ; Clear LCD
      Delay_2ms
       
      MOVLW LCD_L1
      CALL LCD_CMD ;
      Delay_2ms
      
      RETURN
      
MAIN
      CALL LCD_INIT
   
LOOP:
      GOTO CHECK_BUTTONS
      
HANDLE_BTN_1:
      MOVF v_control_flags, 0
      XORLW 0x01
      MOVWF v_control_flags
 
      RETURN
      
HANDLE_BTN_2:
      MOVF v_control_flags, 0
      XORLW 0x02
      MOVWF v_control_flags
      
      RETURN
      
CHECK_BUTTONS:
      BTFSC PORTA, 0
      CALL HANDLE_BTN_1
      BTFSC PORTA, 1
      CALL HANDLE_BTN_2
      
      BCF PORTA, 2
      BCF PORTA, 3
      BTFSC v_control_flags, 0
      BSF PORTA, 2
      BTFSC v_control_flags, 1
      BSF PORTA, 3
      
      BTFSC v_control_flags, 1
      GOTO LINE_VAR_1
      GOTO LINE_VAR_2

LINE_VAR_1:
      CALL START_1L
      CALL BSUIR
      CALL START_2L
      CALL PONYAKOV
      
      GOTO END_WRITE
      
LINE_VAR_2:
      CALL START_1L
      CALL PONYAKOV
      CALL START_2L
      CALL BSUIR
      
END_WRITE:
      CALL PAUSE
      GOTO  LOOP

;====================================================================
      END
