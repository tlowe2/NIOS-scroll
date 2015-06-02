.include "key_codes.s"			/* defines values for KEY1, KEY2, KEY3 */
/********************************************************************************
 * Teddy Lowe ECEN3350 Homework 5                                                                        
 * Initializes LEDs and interval timer, waits for interrupt
********************************************************************************/
	.text									/* executable code follows */
	.global _start
_start:
	/* set up the stack */
	movia 	sp, 0x007FFFFC			/* stack starts from largest memory address */

	movia		r16, 0x10002000		/* internal timer base address */
	/* set the interval timer period for scrolling the HEX displays */
	movia		r3, 0x017D7840			/* 50 MHz clock adjusted for 0.5s  */
	sthio		r3, 8(r16)				/* store the low half word of counter start value */ 
	srli		r8, r3, 16
	sthio		r8, 0xC(r16)			/* high half word of counter start value */ 

	/* start interval timer, enable its interrupts */
	movi		r15, 0b0111				/* START = 1, CONT = 1, ITO = 1 */
	sthio		r15, 4(r16)

	/* initialize leds */
	movia		r4, 0x10000010		/* led address*/
	movia		r5, LEDVAL
	ldw			r6, 0(r5)
	stwio		r6, 0(r4)
	
	/* write to the pushbutton port interrupt mask register */
	movia		r15, 0x10000050		/* pushbutton key base address */
	movi		r7, 0b0110				/* set 2 interrupt mask bits (bit 0 is Nios II Reset) */
	stwio		r7, 8(r15)				/* interrupt mask register is (base + 8) */

	add		r2, r0, r0
	
	/* enable Nios II processor interrupts */
	movi		r7, 0b011				/* set interrupt mask bits for levels 0 (interval */
	wrctl		ienable, r7				/* timer) and level 1 (pushbuttons) */
	movi		r7, 1
	wrctl		status, r7				/* turn on Nios II interrupt processing */
	

IDLE:
	br 		IDLE						/* main program simply idles */

	.data
/* The two global variables used by the interrupt service routines for the interval timer
 * and the pushbutton keys are declared below */
	.global	PATTERN
PATTERN:
	.word 0x00063000
	.word 0x00300600
	.word 0x06000030
	.word 0x30000006
	.word 0x303D3F06
	.word 0x00000000
	.word 0x303D3F06
	.word 0x00000000
	.word 0x0000007C
	.word 0x00007C1C
	.word 0x007C1C71
	.word 0x7C1C7171
	.word 0x1C71716D
	.word 0x71716D00
	.word 0x716D0000
	.word 0x6D000000
	.word 0x00000000
	.word 0x2908010D
	.word 0x30090906
	.word 0x1901080B
	.word 0x2908010D
	.word 0x30090906
	.word 0x1901080B
	.word 0x2908010D
	.word 0x30090906
	.word 0x1901080B
	.word 0x00000000
	
	.global	KEY_PRESSED
KEY_PRESSED:
	.word		KEY2						/* stores code representing pushbutton key pressed */
	
	.global LEDVAL
LEDVAL:
	.word 0x00000040

	.end
