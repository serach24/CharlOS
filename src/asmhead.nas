; haribote-os boot asm
; TAB=4

BOTPAK	EQU		0x00280000		; load bootpack
DSKCAC	EQU		0x00100000		; disk cache location
DSKCAC0	EQU		0x00008000		; disk cache location(real mode)

; BOOT_INFO related
CYLS	EQU		0x0ff0			; boot sector setting
LEDS	EQU		0x0ff1
VMODE	EQU		0x0ff2			; info on colours
SCRNX	EQU		0x0ff4			; resolution X
SCRNY	EQU		0x0ff6			; resolution Y
VRAM	EQU		0x0ff8			; start address of image cache sector

		ORG		0xc200			;  address of this program to be load

;	graphics setting

		MOV		AL,0x13			; VGA graphics card，320x200x8bit
		MOV		AH,0x00
		INT		0x10
		MOV		BYTE [VMODE],8	; mode of the screen
		MOV		WORD [SCRNX],320
		MOV		WORD [SCRNY],200
		MOV		DWORD [VRAM],0x000a0000

;	get the state of indicator with BIOS

		MOV		AH,0x02
		INT		0x16 			; keyboard BIOS
		MOV		[LEDS],AL

;	everything stops when PIC is off
;	must initialize PIC before CLI
;	initialization of PIC

		MOV		AL,0xff
		OUT		0x21,AL
		NOP						; may not run well with continuous OUT command
		OUT		0xa1,AL

		CLI						; forbid interrupt on CPU level

;	set A20GATE for CPU to visit more than 1MB Memory space

		CALL	waitkbdout
		MOV		AL,0xd1
		OUT		0x64,AL
		CALL	waitkbdout
		MOV		AL,0xdf			; enable A20
		OUT		0x60,AL
		CALL	waitkbdout

;	switch to protection mode

[INSTRSET "i486p"]				; use 486 instructions

		LGDT	[GDTR0]			; set temporary GDT
		MOV		EAX,CR0
		AND		EAX,0x7fffffff	; set bit31 0（ban pagination）
		OR		EAX,0x00000001	; bit0to1 switch（switch protection mode）
		MOV		CR0,EAX
		JMP		pipelineflush
pipelineflush:
		MOV		AX,1*8			;  readable and writable segment 32bit
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX

; bootpack transmit

		MOV		ESI,bootpack	; source
		MOV		EDI,BOTPAK		; target
		MOV		ECX,512*1024/4
		CALL	memcpy

; disk data will be transfered to original location
; start from boot sector

		MOV		ESI,0x7c00		; source
		MOV		EDI,DSKCAC		; target
		MOV		ECX,512/4
		CALL	memcpy

; all left

		MOV		ESI,DSKCAC0+512	; source
		MOV		EDI,DSKCAC+512	; target
		MOV		ECX,0
		MOV		CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4	; cylinder num to byte num/4
		SUB		ECX,512/4		; subtract IPL offset
		CALL	memcpy

; all work of asmhead has finished
; left for bootpack

; bootpack launch

		MOV		EBX,BOTPAK
		MOV		ECX,[EBX+16]
		ADD		ECX,3			; ECX += 3;
		SHR		ECX,2			; ECX /= 4;
		JZ		skip			; nothing to transmit
		MOV		ESI,[EBX+20]	; source
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	; transmit
		CALL	memcpy
skip:
		MOV		ESP,[EBX+12]	; stack init
		JMP		DWORD 2*8:0x0000001b

waitkbdout:
		IN		AL,0x64
		AND		AL,0x02
		IN		AL,0x60			; read empty (to clean the garbage data in data-receiving cache)
		JNZ		waitkbdout	; jump to waitkbdout if result of AND is not zero
		RET

memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy			; jump to memcpy if result of subtraction is not zero
		RET
; size of memcpy address prefix

		ALIGNB	16
GDT0:
		RESB	8				; default value
		DW		0xffff,0x0000,0x9200,0x00cf	; readable and writable segment 32bit
		DW		0xffff,0x0000,0x9a28,0x0047	; 32 bit register of the executable (for bootpack)

		DW		0
GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16
bootpack:
