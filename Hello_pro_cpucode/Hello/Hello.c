/******************************************************************************/
/* HELLO.C: Hello World Example                                               */
/******************************************************************************/
/* This file is part of the uVision/ARM development tools.                    */
/* Copyright (c) 2005-2006 Keil Software. All rights reserved.                */
/* This software may only be used under the terms of a valid, current,        */
/* end user licence from KEIL for a compatible version of KEIL software       */
/* development tools. Nothing else gives you the right to use this software.  */
/******************************************************************************/

#include <stdio.h>                /* prototype declarations for I/O functions */
//#include <LPC21xx.H>              /* LPC21xx definitions                      */

void busyLoop(int loop)
{
	volatile int iii;

	iii=loop;
	do{
	}while(iii--);
}
#define IOPIN          (*((volatile unsigned long *) 0xD0000000))
#define BUSY_LOOP_TIMES (10000000)/*10M about 4 sec*/

extern int  sendchar(int ch); 
int output_str(char *str)
{
	int i;
	
	for(i=0;str[i];i++){
		sendchar(str[i]);
	}
	return 0;
}

/****************/
/* main program */
/****************/
int main (void)  {                /* execution starts here                    */
  busyLoop(BUSY_LOOP_TIMES);
#if 0
  printf ("Hello World\n");       /* the 'printf' function call               */
#else
  output_str("Hello World\n");
#endif
  while (1) {                          /* An embedded program does not stop and       */
  	IOPIN=0x1;
  	busyLoop(BUSY_LOOP_TIMES);
	IOPIN=0x0;
  	busyLoop(BUSY_LOOP_TIMES);
      /* ... */                       /* never returns. We use an endless loop.      */
  }                                    /* Replace the dots (...) with your own code.  */

}
