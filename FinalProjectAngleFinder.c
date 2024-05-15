/*-----------------------------
 Title: Final Project Angle Finder
-----------------------------
 Purpose: This program reads a voltage on RA0, and ouputs the result to an LCD.
 Dependencies: FinalProjectAnglefinderconfigwords.h
 Compiler: MPLAB X IDE v6.20
 Author: Marcus Serrano
 OUTPUTS: LCD, Buzzer
 INPUTS: Accelerometer, Button
 Versions:
 V1.0: First written 5/8/2024
 V1.1: Finished Accelerometer implementation. 5/8/2024
 V1.2: LCD finished. 5/10/2024
 V1.3: Implemented averaging to measurements. Calibrated Accelerometer 5/11/2024
 V1.4: Implemented 3 Axis measurement. 5/12/2024
 V1.5: Changed LCD port to ports C & D to allow for interrupt on RB0 5/14/2024
-----------------------------
 */

#include <xc.h> // must have this
#include "FinalProjectAngleFinderconfigwords.h"
#include "FinalProjectAnglefinderfunctions.h"
#include "C:\Program Files\Microchip\xc8\v2.46\pic\include\proc\pic18f47k42.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define _XTAL_FREQ 4000000                 // Fosc  frequency for _delay()  library
#define FCY    _XTAL_FREQ/4
#define RS LATC2                   /* PORTD 0 pin is used for Register Select  changed from d0 to c2*/
#define EN LATC3                   /* PORTD 1 pin is used for Enable changed from d1 to c3*/
#define ldata LATD                 /* changed from LATB to LATD*/
#define LCD_Port TRISD             // changed from LATB to LATD
#define LCD_Control TRISC           //changed from D to C
#define Vref 5.0 // voltage reference

void LCD_Init();
void LCD_Command(char);
void LCD_Char(char x);
void LCD_String(const char *);
void LCD_String_xy(char, char, const char*);

void measurementavg(void);
void measurementget(void);
void ADC_Init(void);
void __interrupt(irq(IRQ_INT0), base(0x4008)) INT0_ISR(void);
void INTERRUPT_Initialize(void);

float Xresult; // holds the result
float Yresult; // holds the result
float Zresult; // holds the result
float voltage = Vref / 4096; // Quantify voltage constant.
float result;
float sum;
float digitalarray[50]; //Digital array
float digitalavg;
char data[10];
int i = 0;
int alarmstate = 0;

/*****************************Main Program*******************************/
void main(void) {
    //initialize PORTD
    TRISD = 0;
    ANSELD = 0;
    PORTD = 0;

    //Initialize PORTB
    ANSELB = 0;
    TRISB = 0b00000001;
    PORTB = 0;

    LCD_Init(); //Initialize 16x2 LCD
    LCD_String_xy(1, 0, "0 & 90 ALERT:OFF   "); /* Display string at location(row,location). */
    ADC_Init(); //ADC Initialization
    INTERRUPT_Initialize(); // initialize the interrupt_initialization by calling the proper function

    while (1) {
        PORTBbits.RB3 = 0; //reset buzzer
        measurementget();
        // Accelerometer Calibrated by EYEBALLIN'
        /*
         * (2 - (measurement)) this is from the voltage measurement. 2.5v = 0deg 2.0v = 90deg
         * *20 this is a constant multiplication factor from 2.25 * X = 45deg; x = 20
         * +10 constant offset to prevent negative angles
         * *9 constant multiple to fix measurement of 10deg at 90deg.
         */
        // Display voltage of pin, used for calibration.
        //result = digitalavg*voltage;
        //result = (((2 - (digitalavg * voltage))*20) + 10)*9; // Quantify ADC result.

        /*This is used to convert integer value to ASCII string*/
        sprintf(data, "X:%.0f Y:%.0f Z:%.0f  ", Xresult, Yresult, Zresult);
        LCD_String_xy(2, 0, data); /*Display string at location(row,location). */

        //Alarm Logic
        if (alarmstate == 1 && ((Xresult >= -1 && Xresult <= 1) || (Xresult >= 89 && Xresult <= 91) || (Xresult <= -89 && Xresult >= -91))) {
            PORTBbits.RB3 = 1;
        }
        if (alarmstate == 1 && ((Yresult >= -1 && Yresult <= 1) || (Yresult >= 89 && Yresult <= 91) || (Yresult <= -89 && Yresult >= -91))) {
            PORTBbits.RB3 = 1;
        }
        if (alarmstate == 3 && ((Zresult >= -1 && Zresult <= 1) || (Zresult >= 89 && Zresult <= 91) || (Zresult <= -89 && Zresult >= -91))) {
            PORTBbits.RB3 = 1;
        }
        if (alarmstate == 4 && ((Xresult >= -1 && Xresult <= 1) || (Xresult >= 89 && Xresult <= 91) || (Xresult >= -91 && Xresult <= -89) || (Yresult >= -1 && Yresult <= 1) || (Yresult >= 89 && Yresult <= 91) || (Yresult >= -91 && Yresult <= -89) || (Zresult >= -1 && Zresult <= 1) || (Zresult >= 89 && Zresult <= 91) || (Zresult >= -91 && Zresult <= -89))) {
            PORTBbits.RB3 = 1;
        }

        __delay_ms(500); //Delay to combat sensitivity
    }
}
///****************************Functions********************************/
//// Defining Interrupt ISR
//
//void __interrupt(irq(IRQ_INT0), base(0x4008)) INT0_ISR(void) {
//    // Check if interrupt flag for INT0 is set to 1 - (note INT0 is your input) if so, do something
//    // cycle through alarm states
//    if (PIR1bits.INT0IF == 1) {
//        __delay_ms(100);//debounce delay
//        alarmstate++;
//        if (alarmstate > 4) {
//            alarmstate = 0;
//        }
//        switch (alarmstate) { //Update LCD
//            case 0:
//                LCD_String_xy(1, 0, "0 & 90 ALERT:OFF   "); /* Display string at location(row,location). */
//                break;
//            case 1:
//                LCD_String_xy(1, 0, "0 & 90 ALERT:X   "); /* Display string at location(row,location). */
//                break;
//            case 2:
//                LCD_String_xy(1, 0, "0 & 90 ALERT:Y   "); /* Display string at location(row,location). */
//                break;
//            case 3:
//                LCD_String_xy(1, 0, "0 & 90 ALERT:Z   "); /* Display string at location(row,location). */
//                break;
//            case 4:
//                LCD_String_xy(1, 0, "0 & 90 ALERT:ALL   "); /* Display string at location(row,location). */
//                break;
//        }
//    }
//    PIR1bits.INT0IF = 0; // always clear the interrupt flag for INT0 when done
//}
//
//void INTERRUPT_Initialize(void) {
//    INTCON0bits.IPEN = 1; // Enable interrupt priority bit in INTCON0 (check INTCON0 register and find the bit)
//    INTCON0bits.GIEH = 1; // Enable high priority interrupts using bits in INTCON0
//    INTCON0bits.GIEL = 1; // Enable low priority interrupts using bits in INTCON0
//    INTCON0bits.INT0EDG = 1; // Interrupt on rising edge of INT0 pin using bits in INTCON0
//    IPR1bits.INT0IP = 1; // Set the interrupt high priority (IP) for INT0 - INT0IP
//    PIE1bits.INT0IE = 1; // Enable the interrupt (IE) for INT0
//    PIR1bits.INT0IF = 0; //Clear interrupt flag for INT01
//
//    // Change IVTBASE by doing the following
//    IVTBASEU = 0x00; // Set IVTBASEU to 0x00
//    IVTBASEH = 0x40; // Set IVTBASEH to  0x40;
//    IVTBASEL = 0x08; // Set IVTBASEL to 0x08;
//}
//
//void measurementavg(void) {
//    i = 0; // reset average counter
//    while (i < 50) // store 50 measurements.
//    {
//        i++;
//        ADCON0bits.GO = 1; //DO: Set ADCON0 Go to start conversion
//        while (ADCON0bits.GO); //Wait for conversion done
//
//        digitalarray[i] = (ADRESH * 256) | (ADRESL); /*Combine 8-bit LSB and 2-bit MSB*/
//    }
//    // Calculate average of array
//    i = 0;
//    sum = 0;
//    while (i < 50) {
//        i++;
//        sum = sum + digitalarray[i];
//    }
//    digitalavg = sum / 50;
//}
//
//void measurementget(void) {
//    //*************GET X MEASUREMENT*************************************
//    ADPCH = 0x0; //DO: Using ADPCH register set RA0 as Analog channel
//    measurementavg();
//    Xresult = (((2 - (digitalavg * voltage))*20) + 10)*9; // Quantify ADC result.
//
//    //*************GET Y MEASUREMENT*************************************
//    ADPCH = 0x1; //DO: Using ADPCH register set RA1 as Analog channel
//    measurementavg();
//    Yresult = (((2 - (digitalavg * voltage))*20) + 10)*9; // Quantify ADC result.
//
//    //*************GET Z MEASUREMENT*************************************
//    ADPCH = 0x2; //DO: Using ADPCH register set RA2 as Analog channel
//    measurementavg();
//    Zresult = (((2 - (digitalavg * voltage))*20) + 10)*9; // Quantify ADC result.
//}
//
//void ADC_Init(void) {
//    //Setup ADC
//    ADCON0bits.FM = 1; //DO: using ADCON0 set right justify
//    ADCON0bits.CS = 1; //DO: Using ADCON0 set ADCRC Clock
//    TRISA = 0b00000111; //DO: Set RA0-2 to input
//    ANSELA = 0b00000111; //DO: Set RA0-2 to analog
//    ADCON0bits.ON = 1; //DO: Turn ADC On on register ADCON0
//    //ADPCH = 0x0; //DO: Set RA0 as Analog channel in ADC ADPCH
//    ADCLK = 0x0; //DO: set ADC CLOCK Selection register to zero
//
//    ADRESL = 0x0;
//    ADRESH = 0x0; //DO: Clear ADC Result registers
//
//    ADPREL = 0x0;
//    ADPREH = 0x0; //DO: set precharge select to 0 in register ADPERL & ADPERH
//
//    ADACQL = 0x0;
//    ADACQH = 0x0; //DO: set acquisition low and high byte to zero
//
//}
//void LCD_Init() {
//    __delay_ms(15); /* 15ms,16x2 LCD Power on delay */
//    LCD_Port = 0x00; /* Set PORTB as output PORT for LCD data(D0-D7) pins */
//    LCD_Control = 0x00; /* Set PORTD as output PORT LCD Control(RS,EN) Pins */
//    LCD_Command(0x01); /* clear display screen */
//    LCD_Command(0x38); /* uses 2 line and initialize 5*7 matrix of LCD */
//    LCD_Command(0x0c); /* display on cursor off */
//    LCD_Command(0x06); /* increment cursor (shift cursor to right) */
//}
//
//void LCD_Clear() {
//    LCD_Command(0x01); /* clear display screen */
//}
//
//void LCD_Command(char cmd) {
//    ldata = cmd; /* Send data to PORT as a command for LCD */
//    RS = 0; /* Command Register is selected */
//    EN = 1; /* High-to-Low pulse on Enable pin to latch data */
//    NOP();
//    EN = 0;
//    __delay_ms(3);
//}
//
//void LCD_Char(char dat) {
//    ldata = dat; /* Send data to LCD */
//    RS = 1; /* Data Register is selected */
//    EN = 1; /* High-to-Low pulse on Enable pin to latch data */
//    NOP();
//    EN = 0;
//    __delay_ms(1);
//}
//
//void LCD_String(const char *msg) {
//    while ((*msg) != 0) {
//        LCD_Char(*msg);
//        msg++;
//    }
//}
//
//void LCD_String_xy(char row, char pos, const char *msg) {
//    char location = 0;
//    if (row <= 1) {
//        location = (0x80) | ((pos) & 0x0f); /*Print message on 1st row and desired location*/
//        LCD_Command(location);
//    } else {
//        location = (0xC0) | ((pos) & 0x0f); /*Print message on 2nd row and desired location*/
//        LCD_Command(location);
//    }
//    LCD_String(msg);
//}
