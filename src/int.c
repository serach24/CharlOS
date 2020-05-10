//init relation 

#include "bootpack.h"

void init_pic(void)
// PIC init 
{
	io_out8(PIC0_IMR,  0xff  ); // forbid all interrupt 
	io_out8(PIC1_IMR,  0xff  ); // forbid all interrupt 

	io_out8(PIC0_ICW1, 0x11  ); // edge-triggering mode（edge trigger mode） 
	io_out8(PIC0_ICW2, 0x20  ); // IRQ0-7 is received by INT20-27 
	io_out8(PIC0_ICW3, 1 << 2); // PIC1 is connected by IRQ2 
	io_out8(PIC0_ICW4, 0x01  ); // no buffer-zone mode 

	io_out8(PIC1_ICW1, 0x11  ); // edge-triggering mode（edge trigger mode） 
	io_out8(PIC1_ICW2, 0x28  ); // IRQ8-15 is  received by INT28-2f 
	io_out8(PIC1_ICW3, 2     ); // PIC1 is connected by IRQ2 
	io_out8(PIC1_ICW4, 0x01  ); // no buffer-zone mode 

	io_out8(PIC0_IMR,  0xfb  ); // 11111011 forbid all except PIC1 
	io_out8(PIC1_IMR,  0xff  ); // 11111111 forbid all interrupt 

	return;
}

#define PORT_KEYDAT		0x0060

struct FIFO8 keyfifo;

void inthandler21(int *esp)
// interrupt come from PS/2 keyboard 
{
	struct BOOTINFO *binfo = (struct BOOTINFO *) ADR_BOOTINFO;
	unsigned char data, s[4];
	io_out8(PIC0_OCW2, 0x61);	// Notify PIC IRQ-01 has been done 
	data = io_in8(PORT_KEYDAT);
	fifo8_put(&keyfifo, data);
	return;
}

struct FIFO8 mousefifo;

void inthandler2c(int *esp)
// interrupt come from PS/2 mouse 
{
	unsigned char data;
	io_out8(PIC1_OCW2, 0x64);	// Notify PIC IRQ-12 has been done 
	io_out8(PIC0_OCW2, 0x62);	// Notify PIC IRQ-02 has been done 
	data = io_in8(PORT_KEYDAT);
	fifo8_put(&mousefifo, data);
	return;
}

void inthandler27(int *esp)
/* incomplete policy of PIC0 interrupt 
	 this interrupt executed once due to convenience of chipset on Athlon64X2 
	 this interrupt will not be handled since it may caused by noise */
{
	io_out8(PIC0_OCW2, 0x67); // Notify PIC IRQ-07 
	return;
}
