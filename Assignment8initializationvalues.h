/*-----------------------------
 Title: assignment8initializationvalues
-----------------------------
 Purpose: This file defines macros for assignment8
 Dependencies: Assignment 8
 Compiler: MPLAB X IDE v6.20
 Author: Marcus Serrano
 
-----------------------------
 */

#ifndef ASSIGNMENT8INITIALIZATIONVALUES_H
#define	ASSIGNMENT8INITIALIZATIONVALUES_H

#ifdef	__cplusplus
extern "C" {
#endif




#ifdef	__cplusplus
}
#endif

#endif	/* ASSIGNMENT8INITIALIZATIONVALUES_H */

#define RD0 PORTDbits.RD0
#define RD1 PORTDbits.RD1

#define buzzer PORTDbits.RD2
#define motor PORTDbits.RD6


#define seg0 0b01111110
#define seg1 0b00110000
#define seg2 0b01101101
#define seg3 0b01111001
#define seg4 0b00110011
#define seg5 0b01011011
#define seg6 0b01011111
#define seg7 0b01110000
#define seg8 0b01111111
#define seg9 0b01111011
#define segA 0b01110111
#define segB 0b00011111
#define segC 0b01001110
#define segD 0b00111101
#define segE 0b01001111
#define segF 0b01000111

// Define array SegDisp
int SegDisp[9] = {seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8, seg9, segA, segB, segC, segD, segE, segF};
int UserInput[2] = {0,0};
int SecretCode[2] = {1,1}; //MAX INPUT IS 3

