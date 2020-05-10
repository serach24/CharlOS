; haribote-ipl
; TAB=4

CYLS	EQU		10				; declare CYLS=10

		ORG		0x7c00			; program load address

; Stand FAT12 format floppy code

		JMP		entry
		DB		0x90
		DB		"HARIBOTE"		; start sector name(8bytes)
		DW		512				; size of each sector(must be 512bytes)
		DB		1				; size of cluster (must be 1 sector)
		DW		1				; FAT start location(usually the first one)
		DB		2				; num of FAT(must be 2)
		DW		224				; size of root dir(usually 224)
		DW		2880			; size of disk(must be 2880 sector 1440*1024/512)
		DB		0xf0			; disk type(must be 0xf0)
		DW		9				; length of FAT(must be 9 sector)
		DW		18				; sector per track(must be 18)
		DW		2				; (must be 2)
		DD		0				; must be 0
		DD		2880			; rewrite size of disk
		DB		0,0,0x29		; fixed, don't know what this is
		DD		0xffffffff		; don't know what this is
		DB		"HARIBOTEOS "	; disk name (must be 11 bytes)
		DB		"FAT12   "		; name of disk format (muse be 8 bytes)
		RESB	18				; empty 18 bytes

; main

entry:
		MOV		AX,0			; init register
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX

; read disk

		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; cylinder 0
		MOV		DH,0			; head 0
		MOV		CL,2			; sector 2

readloop:
		MOV		SI,0			; register to record fail times

retry:
		MOV		AH,0x02			; AH=0x02 : 
		MOV		AL,1			
		MOV		BX,0
		MOV		DL,0x00		
		INT		0x13			; call disk BIOS
		ADD		SI,1			
		CMP		SI,5		
		JAE		error		
		MOV		AH,0x00
		MOV		DL,0x00		
		INT		0x13			; reset driver
		JMP		retry
next:
		MOV		AX,ES			; move address backward 0x200（512/16 hex conversion）
		ADD		AX,0x0020
		MOV		ES,AX			; no ADD ES
		ADD		CL,1			
		CMP		CL,18	
		JBE		readloop		; CL <= 18 jump to readloop
		MOV		CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop		; DH < 2 jump to readloop
		MOV		DH,0
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop		; CH < CYLS jump to readloop

; jump to haribote.sys
		MOV		[0x0ff0],CH		; record how much IPL read
		JMP		0xc200

error:
		MOV		SI,msg

putloop:
		MOV		AL,[SI]
		ADD		SI,1			
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e		
		MOV		BX,15			; set character colour
		INT		0x10			; call graphics card BIOS
		JMP		putloop

fin:
		HLT						; stop CPU and wait for instructions
		JMP		fin				; infinite loop

msg:
		DB		0x0a, 0x0a		; change line twice
		DB		"load error"
		DB		0x0a			; change line
		DB		0

		RESB	0x7dfe-$		; fill 0x00 till 0x001fe

		DB		0x55, 0xaa
