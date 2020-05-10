# CharlOS

> A toy operating system in progress implemented with C and Assembly

To run, use `make run` to run in emulator, use `make install` to run in USB flash drive.   
(Note the QEMU attached may not work, if you want to use emulator to run this, please download the new version of QEMU.)

## Done:
- Boot sector
- Interrupt function
- Palette function and image display
- Added font (hankaku.txt) and character display
- GDT(Global segment descriptor table)
- IDT(interrupt descriptor table)
- PIC init function
- Keyboard interruption handling and FIFO BUF
- Mouse input support

## TODO：
- Keyboard input support
- Memory Management
- Timer
- High resolution
- Multitask support
- Command line
- Application
- Window operation  
 ......