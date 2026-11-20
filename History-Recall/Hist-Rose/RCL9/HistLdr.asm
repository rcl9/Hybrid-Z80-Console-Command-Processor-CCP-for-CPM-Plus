;	HISTLDR.ASM	History RSX loader
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
;	This is the history loader, based upon the history loader
;	by Jim Lopushinsky. Basic difference is that this code is
;	written in 8080 assembler, rather than Z80 assembler.
;
;	This loader can be used with either HIST+ (history RSX
;	by Jim Lopushinsky) or HISTORY (history RSX/deamon by
;	Stuart Rose)
;
;	This loader will load the RSX, then issue the BDOS RSX
;	function call (BDOS#60) with a RSX-function to initialize
;	the history RSX (RSXFUN#55). If no history RSXes were
;	active prior to the load, then the BDOS call insures that
;	the RSX is properly initialized and buffers cleared. If
;	there was already an active history RSX, then both RSXes
;	are removed (ie: removes the active history RSX).
;
;	NOTE: this is the loader for CP/M+ only. For CP/M V2.2,
;	the loader is included in the HISTORY.ASM file.
;
;	To assemble, link and gencom:
;
;		mac histldr $pzsz
;		mload histldr.com=histldr.hex
;		rmac history $pzsz
;		link history [op]
;		ren history.rsx=history.rsx
;		gencom histldr history
;		ren history.com=histldr.com
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
;  Start the loader							      ;
;=============================================================================;

	org	TPA
	jmp	start			; load the RSX

;=============================================================================;
;  Define some values							      ;
;=============================================================================;

INIRSX:	db	55		; initialize history RSX RSX-function
NORSX:	db	'history: no RSX attached to loader','$'

;=============================================================================;
;  The actual loader							      ;
;=============================================================================;

start:	lxi	H,0			; get a local stack
	dad	SP			;
	shld	stack			;
	lxi	SP,stack		;

	lxi	D,INIRSX		; initialize the history RSX
	mvi	C,BDOSRSX		;
	call	BDOS			;
	ora	A			; everything okee-dokee?
	jz	return			; yep
	lxi	D,NORSX			; nope, can't find the RSX
	mvi	C,PUTS			; put the error string
	call	BDOS			;

return:	lhld	stack			; restore the stack
	sphl				;
	ret				; and return to CP/M+

	ds	40			; room for stack
stack:	ds	2			; old stack pointer goes here

	end
