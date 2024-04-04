//-----------------------------
// Title: Counter
//-----------------------------
// Purpose: This program counts up and down depending on switch inputs,
//	    and diplays current count on 7 segment display.
// Dependencies: AssemblyConfig.inc
// Compiler: MPLAB X IDE v6.20
// Author: Marcus Serrano 
// OUTPUTS: PORT D 0 thru 7 ; connected to 7 segment 
// INPUTS: switches A and B wired to RC2 and RC3
// Versions:
//  	V1.0: 3/25/2024 - First version 
//  	V1.1: 3/26/2024 - Fixed count up and count down loops, implemented switch logic.
//      V1.2: 4/1/2024 - Updated switch and counting logic. Waiting on parts for final test.
//	V1.3: 4/3/2024 - Completed project, final cleanup of file.
//-----------------------------
  
//----------------
// Program Initialization via file inclusion and memory initialization.
//----------------
#include "C:\Users\Marcus Serrano\MPLABXProjects\Assembly compiler.X\AssemblyConfig.inc"
#include <xc.inc>

// Program initialization
    org 0x0
    PSECT absdata,abs,ovrld	    ; Do not change  
      
    //Create port A as input
    banksel PORTA
    clrf PORTA
    banksel LATA
    setf LATA
    banksel ANSELA
    CLRF ANSELA
    banksel TRISA
    setf TRISA
    banksel WPUA
    bsf WPUA,0
    bsf WPUA,1
   
   //Create port D as output
    banksel PORTD
    clrf PORTD
    banksel LATD
    clrf LATD
    banksel ANSELD
    CLRF ANSELD
    banksel TRISD
    clrf TRISD

    //Set constants
    Inner_loop equ 0xff		    ;0xff
    Outer_loop equ 0xff		    ;0xff
    Outer_looptwo equ 0x2	    ;0x3
    count equ 0x05		    ;location for storing the counter.
    clrf 0x04			    ;Just a Zero reference number for the loops later on.
    movlw 2
    movwf 0x06			    ;2 reference number for logic.
    LFSR 0,0x10
    
 // Codes for display:
    // 6=A
    // 5=B
    // 4=C
    // 3=D
    // 2=E
    // 1=F
    // 0=G
    // 1111110 0 7e
    // 0110000 1 30
    // 1101101 2 6d
    // 1111001 3 79
    // 0110011 4 33
    // 1011011 5 5b
    // 1011111 6 
    // 1110000 7 70
    // 1111111 8 7f
    // 1111011 9 
    // 1110111 A 77
    // 0011111 B 
    // 1001110 C 4e
    // 0111101 D 
    // 1001111 E 4f
    // 1000111 F 47
    movlw 0b1111110 ;0
    movwf 0x10
    movlw 0b0110000 ;1
    movwf 0x11
    movlw 0b1101101 ;2
    movwf 0x12
    movlw 0b1111001 ;3
    movwf 0x13
    movlw 0b0110011 ;4
    movwf 0x14
    movlw 0b1011011 ;5
    movwf 0x15
    movlw 0b1011111 ;6
    movwf 0x16
    movlw 0b1110000 ;7
    movwf 0x17
    movlw 0b1111111 ;8
    movwf 0x18
    movlw 0b1111011 ;9
    movwf 0x19
    movlw 0b1110111 ;A
    movwf 0x1A
    movlw 0b0011111 ;B
    movwf 0x1B
    movlw 0b1001110 ;C
    movwf 0x1C
    movlw 0b0111101 ;D
    movwf 0x1D
    movlw 0b1001111 ;E
    movwf 0x1E
    movlw 0b1000111 ;F
    movwf 0x1F
   
// START PROGRAM
    movff 0x10,PORTD
    nop
    nop
    goto logic
     
// SWITCH LOGIC
//  RA0 is switch A and will count up
//  RA1 is switch B and will count down
//  Weak pullup resistors are enabled, so by default the pins read 1.
//  Upon button press, the pins should read 0, as I short the button to ground.
logic:
    call delay
    btfsc   PORTA, 0    ; Test if PORTA0 is clear
    goto    portA1_set  ; If PORTA0 is set, check PORTA1
    btfss   PORTA, 1    ; Test if PORTA1 is clear
    goto    rst         ; If both PORTA0 and PORTA1 are clear, jump to RST
    goto    end_check   ; If either PORTA0 or PORTA1 is set, skip the next instruction

portA1_set:
    btfsc   PORTA, 1    ; Test if PORTA1 is set
    goto    end_check   ; If PORTA1 is set, skip the next instruction
    
end_check:
    btfss PORTA ,0
    call countup
    
    btfss PORTA ,1
    call countdown
    
    goto logic
        
// COUNT UP    
countup: 
    incf FSR0L,f	;increment fsr
    //IF FSR0L > 0x20 THEN FSR0L = 0x10 ELSE SKIP
    movlw   0x20        ; Load value 0x20 into WREG
    subwf   FSR0L, W    ; Subtract FSR0L from WREG and store result in WREG
    btfss   STATUS, 2   ; Skip next instruction if result is zero (FSR0L is not greater than 0x20)
    goto    not_greater ; If FSR0L is not greater than 0x20, skip the next instruction
    movlw   0x10        ; Load value 0x10 into WREG
    movwf   FSR0L       ; Store WREG into FSR0L (FSR0L = 0x10)
not_greater:
    movff INDF0,PORTD		    ;output contents to portD
    return
       
// COUNT DOWN
countdown:
    decf FSR0L,1	;decrement FSR
    //IF FSR0L < 0x10 THEN FSR0L = 0x1F ELSE SKIP
    movlw   0x10        ; Load value 0x10 into WREG
    subwf   FSR0L, W    ; Subtract FSR0L from WREG and store result in WREG
    btfsc   STATUS, 0   ; Skip next instruction if carry flag is set (FSR0L is less than 0x10)
    goto    not_less    ; If FSR0L is not less than 0x10, skip the next instruction
    movlw   0x1F        ; Load value 0x1F into WREG
    movwf   FSR0L       ; Store WREG into FSR0L (FSR0L = 0x1F)
not_less:
    movff INDF0,PORTD		    ;output contents to portD
    return

// RESET (RST) FUNCTION
rst: 
    LFSR 0,0x10
    movff INDF0,PORTD
    goto logic
       
// DELAY FUNCTION
delay: 
    MOVLW       Inner_loop
    MOVWF       0x0
    MOVLW       Outer_loop
    MOVWF       0x1
    movlw	Outer_looptwo
    movwf	0x2
_loop1:
    DECF        0x0,1 // Inner loop
    BNZ         _loop1
    DECF        0x1,1 // Outer loop
    BNZ         _loop1
    decf	0x2,1 // Tertiary loop
    bnz		_loop1
    RETURN
   
end
