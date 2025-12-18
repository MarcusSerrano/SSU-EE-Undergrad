/*-----------------------------
 Title: Assignment 8
-----------------------------
 Purpose: This program takes two inputs and performs different functions depending if the inputs match SecretCode[]
 Dependencies: Assignment8initializationvalues.h Assignment8configwords.h Assignment8functions.h
 Compiler: MPLAB X IDE v6.20
 Author: Marcus Serrano
 OUTPUTS: 7 segment display, relay, status LEDs, buzzer
 INPUTS: Photoresistors, emergency button
 Versions:
    V1.0: First written 4/16/2024
 * V1.1: Finished photoresistor implementation. 4/19/2024
 * V1.2: 7 segment and logic. 4/20/2024
 * V2.0: Completed buzzer and relay. 4/21/2024
-----------------------------
 */

#include <xc.h> // must have this
#include "C:\Program Files\Microchip\xc8\v2.46\pic\include\proc\pic18f47k42.h"
#include <stdlib.h>

#include "Assignment8configwords.h"
#include "Assignment8initializationvalues.h"
#include "Assignment8functions.h"

void main(void) {

    //Initialize ports
    ANSELB = 0x0;
    ANSELD = 0x0;
    ANSELA = 0;
    TRISA = 0;
    TRISB = 0b00000001; //set port B as input
    TRISD = 0b00000011; // set port D as mixed in/out
    WPUB = 0b00000001; // A weak pull-up is ENABLED for port B0

    PORTB = 0;
    PORTD = 0b00001000; //enable power LED
    PORTA = 0;

    INTERRUPT_Initialize(); // initialize the interrupt_initialization by calling the proper function
    asm("NOP");

    int timer = 0;


    while (1) {// main code here
        getinputs();
    }
}