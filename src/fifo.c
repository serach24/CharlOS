// FIFO 

#include "bootpack.h"

#define FLAGS_OVERRUN		0x0001

void fifo8_init(struct FIFO8 *fifo, int size, unsigned char *buf)
// init FIFO buffer 
{
	fifo->size = size;
	fifo->buf = buf;
	fifo->free = size; // size of buffer 
	fifo->flags = 0;
	fifo->p = 0; // next location of data write in  
	fifo->q = 0; // next location of data read out  
	return;
}

int fifo8_put(struct FIFO8 *fifo, unsigned char data)
// transmit data to fifo and save 
{
	if (fifo->free == 0) {
		// overflow 
		fifo->flags |= FLAGS_OVERRUN;
		return -1;
	}
	fifo->buf[fifo->p] = data;
	fifo->p++;
	if (fifo->p == fifo->size) {
		fifo->p = 0;
	}
	fifo->free--;
	return 0;
}

int fifo8_get(struct FIFO8 *fifo)
// get data from fifo 
{
	int data;
	if (fifo->free == fifo->size) {
		// if buffer is empty 
		return -1;
	}
	data = fifo->buf[fifo->q];
	fifo->q++;
	if (fifo->q == fifo->size) {
		fifo->q = 0;
	}
	fifo->free++;
	return data;
}

int fifo8_status(struct FIFO8 *fifo)
// report amount of data accumulated  
{
	return fifo->size - fifo->free;
}
