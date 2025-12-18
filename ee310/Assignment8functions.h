/*-----------------------------
 Title: Assignment8functions
-----------------------------
 Purpose: This file holds the functions for assignment 8.
 Dependencies: Assignment8
 Compiler: MPLAB X IDE v6.20
 Author: Marcus Serrano
-----------------------------
 */

#ifndef ASSIGNMENT8FUNCTIONS_H
#define	ASSIGNMENT8FUNCTIONS_H

#ifdef	__cplusplus
extern "C" {
#endif




#ifdef	__cplusplus
}
#endif

#endif	/* ASSIGNMENT8FUNCTIONS_H */

void savenotification() {
    // Save notification
    PORTDbits.RD4 = 1;
    PORTDbits.RD5 = 1;
    __delay_ms(250);
    PORTDbits.RD4 = 0;
    PORTDbits.RD5 = 0;
    __delay_ms(250);
    PORTDbits.RD4 = 1;
    PORTDbits.RD5 = 1;
    __delay_ms(250);
    PORTDbits.RD4 = 0;
    PORTDbits.RD5 = 0;
    __delay_ms(250);
    PORTDbits.RD4 = 1;
    PORTDbits.RD5 = 1;
    __delay_ms(250);
    PORTDbits.RD4 = 0;
    PORTDbits.RD5 = 0;
    __delay_ms(250);
    PORTDbits.RD4 = 1;
    PORTDbits.RD5 = 1;
    __delay_ms(250);
    PORTDbits.RD4 = 0;
    PORTDbits.RD5 = 0;
    __delay_ms(250);
    PORTDbits.RD4 = 1;
    PORTDbits.RD5 = 1;
    __delay_ms(250);
    PORTDbits.RD4 = 0;
    PORTDbits.RD5 = 0;
    __delay_ms(250);
    PORTDbits.RD4 = 1;
    PORTDbits.RD5 = 1;
    __delay_ms(250);
    PORTDbits.RD4 = 0;
    PORTDbits.RD5 = 0;
    __delay_ms(250);
}

void getinputs() 
{
    int i = 0;
    int timer = 0;
    PORTA = 0;

    //Wait for user's first input
    while (RD0 == 0) {
        // Let use know input 1 is being polled.
        PORTDbits.RD4 = 1;
    }

    //Poll Photo resistor 0, with an exit time of 5 seconds.
    while (timer < 2000) {

        // Start timer
        __delay_ms(1);
        timer++;
        // Max value of i is 3.
        if (i > 3) {
            i = 1;
        }
        // Poll RD0
        if (RD0 == 1) {
            i++;

            // reset exit timer
            timer = 0;
            // Indicator led on and debounce photoresistor input
            while (RD0 == 1) {
                PORTDbits.RD4 = 1;
            }

            PORTDbits.RD4 = 0;
        }
        // OUTPUT to 7seg.
        PORTA = SegDisp[i];
        // Save input to UserInput
        UserInput[1] = i;

    }

    // Save notification
    savenotification();

    // reset timer, loops, and 7seg
    timer = 0;
    i = 0;
    PORTA = 0;

    //Wait for user's second input
    while (RD1 == 0) {
        // Let use know input 2 is being polled.
        PORTDbits.RD5 = 1;
    }

    //Poll Photo resistor 1, with an exit time of 5 seconds.
    while (timer < 2000) {

        // Start timer
        __delay_ms(1);
        timer++;
        // Max value of i is 3.
        if (i > 3) {
            i = 1;
        }
        // Poll Photoresistor 1
        if (RD1 == 1) {
            i++;

            // reset exit timer
            timer = 0;
            // Indicator led on and debounce photoresistor input
            while (RD1 == 1) {
                PORTDbits.RD5 = 1;
            }

            PORTDbits.RD5 = 0;
        }
        // OUTPUT to 7seg.
        PORTA = SegDisp[i];
        // Save input to UserInput
        UserInput[0] = i;

    }

    // Save notification
    savenotification();


    // now that both inputs have been recorded, check against secret code. SecretCode[] = {2,3}
    if (UserInput[0] == SecretCode[0] && UserInput[1] == SecretCode[1]) {
        motor = 1; //enable motor
        __delay_ms(2000);
    }
    motor = 0;
    if (UserInput[0] != SecretCode [0] || UserInput[1] != SecretCode[1]) {
        buzzer = 1;
        __delay_ms(2000); //enable buzzer
    }
    buzzer = 0;
}

// Defining Interrupt ISR

void __interrupt(irq(IRQ_INT0), base(0x4008)) INT0_ISR(void) {
    int i = 0;

    if (PIR1bits.INT0IF == 1) // Check if interrupt flag for INT0 is set to 1 - (note INT0 is your input)
        // if so, do something
    {
        i = 0;
        while (i != 10) // Play melody on buzzer connected to RD2
        {
            PORTDbits.RD2 = 1;
            i++;
            __delay_ms(125);
            PORTDbits.RD2 = 0;
            __delay_ms(125);

        }
        PIR1bits.INT0IF = 0; // always clear the interrupt flag for INT0 when done
        RD0 = 0; // turn off the led on PORTDbits.RD0
    }
}

void INTERRUPT_Initialize(void) {
    INTCON0bits.IPEN = 1; // Enable interrupt priority bit in INTCON0 (check INTCON0 register and find the bit)
    INTCON0bits.GIEH = 1; // Enable high priority interrupts using bits in INTCON0
    INTCON0bits.GIEL = 1; // Enable low priority interrupts using bits in INTCON0
    INTCON0bits.INT0EDG = 0; // Interrupt on falling edge of INT0 pin using bits in INTCON0
    IPR1bits.INT0IP = 1; // Set the interrupt high priority (IP) for INT0 - INT0IP
    PIE1bits.INT0IE = 1; // Enable the interrupt (IE) for INT0

    PIR1bits.INT0IF = 0; //Clear interrupt flag for INT01

    // Change IVTBASE by doing the following
    IVTBASEU = 0x00; // Set IVTBASEU to 0x00
    IVTBASEH = 0x40; // Set IVTBASEH to  0x40;
    IVTBASEL = 0x08; // Set IVTBASEL to 0x08;
}
