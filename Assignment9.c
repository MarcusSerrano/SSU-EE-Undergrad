/*
 * The purpose of this program is to demonstrate how a 20x2 LCD can be interfaced with a PIC processor.
 * Refer to the lecture slides for more details on the physical connections.
 * You may want to consider changing this code, as needed, depending on your hardware.
 * Author: Farid Farahmand
 */


// PIC18F46K42 Configuration Bit Settings

// 'C' source line config statements


#include <xc.h> // must have this
#include "Assignment9configwords.h"
#include "C:\Program Files\Microchip\xc8\v2.46\pic\include\proc\pic18f47k42.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define _XTAL_FREQ 4000000                 // Fosc  frequency for _delay()  library
#define FCY    _XTAL_FREQ/4

#define RS LATD0                   /* PORTD 0 pin is used for Register Select */
#define EN LATD1                   /* PORTD 1 pin is used for Enable */
#define ldata LATB                 /* PORTB is used for transmitting data to LCD */

#define LCD_Port TRISB
#define LCD_Control TRISD

void LCD_Init();
void LCD_Command(char);
void LCD_Char(char x);
void LCD_String(const char *);
void LCD_String_xy(char, char, const char*);

#define Vref 5.0 // voltage reference
int digital; // holds the digital value
float voltage; // hold the analog value (volt))
char data[10];
void ADC_Init(void); // DO: Declare void ADC_Init
float result;

/*This code block configures the ADC
for polling, VDD and VSS references, ADCRC
oscillator and AN0 input.
Conversion start & polling for completion
are included.
 */

/*****************************Main Program*******************************/
void main(void) {    
    //initialize PORTB
    TRISB = 0;
    ANSELB = 0;
    PORTB = 0;

    LCD_Init(); /* Initialize 16x2 LCD */  
    /* This function passes string to display */
    LCD_String_xy(1, 0, "Input LUX:"); /* Display string at location(row,location). */

    //ADC Initialization
    ADC_Init(); //DO: CALL ADC_Init function defined below;    
    while (1) {
        ADCON0bits.GO = 1; //DO: Set ADCON0 Go to start conversion
        while (ADCON0bits.GO); //Wait for conversion done
        digital = (ADRESH * 256) | (ADRESL); /*Combine 8-bit LSB and 2-bit MSB*/
        voltage = Vref / 4096;// DO: define voltage = Vref/4096 (note that voltage is float type

                // DO: Write a code to translate the values from ADRESH:ADRESL register
                //     pair to IO Port. In this case we can connect ADRESL to Port D
                result = digital * voltage * 50 - 150;
                
                
                //adjustment of LUX results, photoresistors arent linear, so manual adjustment is neccessary.
                if (result < 0){result = 0;}
                if (result > 60){result = result * 1.25;}
                if (result > 100){result = result * 1.5;}
                if (result > 160){result = result * 2;}

                
               /*This is used to convert integer value to ASCII string*/
                sprintf(data, "%.0f", result);
        strcat(data, " LUX             "); /*Concatenate result and unit to print*/
        
        
        LCD_String_xy(2, 0, data); /*Display string at location(row,location). */
        __delay_ms(500);
    }    
}

/****************************Functions********************************/
void ADC_Init(void) {
    //Setup ADC
    ADCON0bits.FM = 1; //DO: using ADCON0 set right justify
    ADCON0bits.CS = 1; //DO: Using ADCON0 set ADCRC Clock
    ADPCH = 0x0; //DO: Using ADPCH register set RA0 as Analog channel
    TRISA = 0b00000001; //DO: Set RA0 to input
    ANSELA = 0b00000001; //DO: Set RA0 to analog
    ADCON0bits.ON = 1; //DO: Turn ADC On on register ADCON0
    //ADPCH = 0x0; //DO: Set RA0 as Analog channel in ADC ADPCH
    ADCLK = 0x0; //DO: set ADC CLOCK Selection register to zero

    ADRESL = 0x0;
    ADRESH = 0x0; //DO: Clear ADC Result registers

    ADPREL = 0x0;
    ADPREH = 0x0; //DO: set precharge select to 0 in register ADPERL & ADPERH

    ADACQL = 0x0;
    ADACQH = 0x0; //DO: set acquisition low and high byte to zero

}

void LCD_Init() {
    __delay_ms(15); /* 15ms,16x2 LCD Power on delay */
    LCD_Port = 0x00; /* Set PORTB as output PORT for LCD data(D0-D7) pins */
    LCD_Control = 0x00; /* Set PORTD as output PORT LCD Control(RS,EN) Pins */
    LCD_Command(0x01); /* clear display screen */
    LCD_Command(0x38); /* uses 2 line and initialize 5*7 matrix of LCD */
    LCD_Command(0x0c); /* display on cursor off */
    LCD_Command(0x06); /* increment cursor (shift cursor to right) */
}

void LCD_Clear() {
    LCD_Command(0x01); /* clear display screen */
}

void LCD_Command(char cmd) {
    ldata = cmd; /* Send data to PORT as a command for LCD */
    RS = 0; /* Command Register is selected */
    EN = 1; /* High-to-Low pulse on Enable pin to latch data */
    NOP();
    EN = 0;
    __delay_ms(3);
}

void LCD_Char(char dat) {
    ldata = dat; /* Send data to LCD */
    RS = 1; /* Data Register is selected */
    EN = 1; /* High-to-Low pulse on Enable pin to latch data */
    NOP();
    EN = 0;
    __delay_ms(1);
}

void LCD_String(const char *msg) {
    while ((*msg) != 0) {
        LCD_Char(*msg);
        msg++;
    }
}

void LCD_String_xy(char row, char pos, const char *msg) {
    char location = 0;
    if (row <= 1) {
        location = (0x80) | ((pos) & 0x0f); /*Print message on 1st row and desired location*/
        LCD_Command(location);
    } else {
        location = (0xC0) | ((pos) & 0x0f); /*Print message on 2nd row and desired location*/
        LCD_Command(location);
    }
    LCD_String(msg);

}