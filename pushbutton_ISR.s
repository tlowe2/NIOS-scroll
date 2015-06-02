.include "key_codes.s"				/* defines values for KEY1, KEY2, KEY3 */
.extern	KEY_PRESSED					/* externally defined variable */
.extern LEDVAL
/***************************************************************************************
 * Pushbutton - Interrupt Service Routine                                
 * Teddy Lowe ECEN3350 Homework 5                                                                        
 * Detects which key has been pressed, and updates speed and LED value as needed 
****************************************************************************************/
	.global	PUSHBUTTON_ISR
PUSHBUTTON_ISR:
	subi		sp, sp, 56					/* reserve space on the stack */
   stw		ra, 0(sp)
   stw		r4, 4(sp)
   stw		r5, 8(sp)
   stw		r6, 12(sp)
   stw		r7, 16(sp)
   stw		r8, 20(sp)
   stw		r9, 24(sp)
   stw		r10, 28(sp)
   stw		r11, 32(sp)
   stw		r12, 36(sp)
   stw		r13, 40(sp)
   stw		r14, 52(sp)
   stw		r15, 44(sp)
   stw		r16, 48(sp)

	movia		r10, 0x10000050			/* base address of pushbutton KEY parallel port */
	ldwio		r11, 0xC(r10)				/* read edge capture register */
	stwio		r0,  0xC(r10)				/* clear the interrupt */
	
	movia		r4, 0x00000200
	movia		r5, 0x00000008
	
	movia		r9, 0x10000010
	movia		r12, LEDVAL
	ldw			r6, 0(r12)
	
	addi		r7, r0, 1
	movia		r8, 0x006C4B40				/* add or subtract time seconds (used to be 0.1s, now adjusted*/

	movia		r10, KEY_PRESSED			/* global variable to return the result */
CHECK_KEY1:
	andi		r13, r11, 0b0010			/* check KEY1 */
	beq			r13, zero, CHECK_KEY2
	
	beq			r6, r5, END_PUSHBUTTON_ISR
	
	add			r3, r3, r8
	
	ror			r6, r6, r7
	
	br			TIME_CHANGE

CHECK_KEY2:
	andi		r13, r11, 0b0100			/* check KEY2 */
	beq			r13, zero, END_PUSHBUTTON_ISR 
	
	beq			r6, r4, END_PUSHBUTTON_ISR
	
	sub			r3, r3, r8
	
	rol			r6, r6, r7

TIME_CHANGE:
	movia		r16, 0x10002000		/* internal timer base address */
	
	movi		r15, 0b1000			/* stop timer */
	sthio		r15, 4(r16)
	
	/* set the interval timer period for scrolling the HEX displays */
	sthio		r3, 8(r16)				/* store the low half word of counter start value */ 
	srli		r14, r3, 16
	sthio		r14, 0xC(r16)			/* high half word of counter start value */ 

	/* start interval timer, enable its interrupts */
	movi		r15, 0b0111				/* START = 1, CONT = 1, ITO = 1 */
	sthio		r15, 4(r16)
	
END_PUSHBUTTON_ISR:
	
	/* LED change */
	stwio	r6, 0(r9)
	stw		r6, 0(r12)

   ldw		ra, 0(sp)					/* Restore all used register to previous */
   ldw		r4, 4(sp)
   ldw		r5, 8(sp)
   ldw		r6, 12(sp)
   ldw		r7, 16(sp)
   ldw		r8, 20(sp)
   ldw		r9, 24(sp)
   ldw		r10, 28(sp)
   ldw		r11, 32(sp)
   ldw		r12, 36(sp)
   ldw		r13, 40(sp)
   ldw		r14, 52(sp)
   ldw		r15, 44(sp)
   ldw		r16, 48(sp)
   addi		sp,  sp, 56

	ret
	.end
	
