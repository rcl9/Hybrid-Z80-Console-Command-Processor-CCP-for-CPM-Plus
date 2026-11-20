;	HISTCLR.ASM	History RSX clearer (re-initializer)
;
;	Version 1.1	January 04 1987
;
; Version 1.1	Fixes bug in stack. Old stack pointer used to be
; (Jan 01 1987)	stored at the top of the stack (ie: on top of
;		the last program instruction) instead of the
;		bottom of the stack). Stack size increase just
;		for the fun of it all (from 20 to 40).
;					- Stuart Rose
;
;	This is the history re-initializer, based upon the history
;	re-initializer by Jim Lopushinsky. Basic difference is that
;	this code is written in 8080 assembler, rather than Z80
;	assembler.
;
;	This program can be used with either HIST+ (history RSX
;	by Jim Lopushinsky) or HISTORY (history RSX/deamon by
;	Stuart Rose)
;
;	This program will re-initialize (clear) the loaded history
;	RSX. This is done by clearing all history buffers, setting
;	the number of active history buffers to zero, and re-setting
;	the insert/overstrike mode toggle back to the default. A
;	message is displayed if the history RSX has been successfully
;	re-initialized (cleared). If no history RSXes were loaded,
;	then an appropriate error message is displayed.
;
;	NOTE: this is the re-initializer for CP/M+ only. For CP/M V2.2,
;	the equivalent program is included in the HISTORY.ASM file.
;
;	To assemble and link:
;
;		mac histclr $pzsz
;		mload histclr.com=histclr.hex
;
;	Stuart Rose,
;	Co-Sysop, Starling CP/M+ RCPM
;	Mississauga, Ontario, CANADA
;	(416) 624-4935   300/1200/2400 bps
;
;=============================================================================;
; Define some equates							      ;
;=============================================================================;

TPA	equ	0100H		; TPA starts here
BDOS	equ	0005H		; BDOS vector lives here
PUTS	equ	9		; BDOS put string function call
BDOSRSX	equ	60		; BDOS RSX function call

;=============================================================================;
;  Start the program							      ;
;=============================================================================;

	org	TPA
	jmp	start			; clear the RSX

;=============================================================================;
;  Define some values							      ;
;=============================================================================;

CLRRSX:	db	56		; re-initialize history RSX RSX-function
NORSX:	db	'history: can''t find a loaded history RSX','$'

;=============================================================================;
;  The actual loader							      ;
;=============================================================================;

start:	lxi	H,0			; get a local stack
	dad	SP			;
	shld	stack			;
	lxi	SP,stack		;

	lxi	D,CLRRSX		; clear (re-intialize) the history RSX
	mvi	C,BDOSRSX		;
	call	BDOS			;
	ora	A			; everything okee-dokee?
	jz	return			; yep
	lxi	D,NORSX			; nope, can't find the RSX
	mvi	C,PUTS			; put the error string

return:	lhld	stack			; restore the stack
	sphl				;
	ret				; and return to CP/M+

	ds	20			; room for stack
stack:	ds	2			; old stack pointer goes here

	end
