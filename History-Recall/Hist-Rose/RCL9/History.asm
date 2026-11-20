;	HISTORY.ASM	Command line history RSX

; Nov 16 2026, tweaks by RCL9:
;	(Rob's Retro Computing Archive)
;	RetroComputingArchive@gmail.com
;	https://github.com/rcl9
;
;	Added key binding help info to start-up message.
;
;	Changed 'HISTSIZ' from 128 to 40 to save on TPA memory. 9 buffers remain as-is.
;
;	Version 1.9	November 05 1986
;
; Nov 05 1986	Corrected bug with UNIX-style logout character. Now will
;  (Ver 1.9)	only logout if the logout character is entered on an
;		empty line.
;
; Sep 18 1986	Ignore comment lines. Comment lines are returned as null
;  (Ver 1.8)	command lines, and not remembered in the history.
;
; Sep 12 1986	Reset the insert/overstrike flag upon buffer clear RSX
;  (Ver 1.7)	function for CP/M+ operation.
;
; Sep 06 1986	Fixed bug when a null command line is entered. Now correctly
;  (Ver 1.6)	returns the number of characters in the returned line (zero).
;
; Aug 13 1986	Added multiple commands per line capability. Also, now forgets
;  (Ver 1.5)	null command lines. Auto-load added for V2.2 (loader taken from
;		BYE5). Now compatible with Jim Lopushinsky's history RSX, and
;		thusly BYE5.
;
; Jul 31 1986	Added code to auto-find the BDOS jump vector in the BIOS (used
;  (Ver 1.4)	to refresh the system page after a warm boot).
;
; Jun 01 1986	Fixed bug in "ovrc" routine which displayed garbage when a
;  (Ver 1.3)	non-ctrl character overstruck a ctrl character at the EOL.
;		Also allowed the use of this RSX as a V2.2 daemon. Added
;		delete to beginning of word key.
;
; May 23 1986	Fixed bug in which interrupt character caused history buffer
;  (Ver 1.2)	pointer to rollover.
;
; Feb 27 1986	Fixed bug in "strcpy" routine which neglected to copy over the
;  (Ver 1.1)	end-of-string character to the history buffer. This gave the
;		effect of overwriting re-used history buffers, rather than
;		replacing them. Implemented a insert/overstrike toggle, and a
;		recall past histories function character.
;
; Feb 19 1986	First try at history RSX. You get CP/M+ line editing functions,
;  (Ver 1.0)	and then some. Move by character or word (left or right). Move
;		to beginning or end of line. Delete character (left or right),
;		delete to beginning of line, to end of line, or entire line.
;		Recall 9 history buffers (if WHEEL) or just 1 (if not WHEEL).
;
;	Stuart Rose,
;	Starling CP/M+ RCPM
;	Mississauga, Ontario, CANADA
;	(416) 624-4935
;
; Define universal Boolean constants
;
FALSE	equ	000H		; boolean false
TRUE	equ	0FFH		; boolean true
;
; Define some switch states
;
YES	equ	TRUE		; yep
NO	equ	FALSE		; nope
OFF	equ	FALSE		; something is turned off
ON	equ	TRUE		; something is turned on
INSERT	equ	000H		; insert mode
OVERS	equ	0FFH		; overstrike mode
;
; Define some ASCII character equates
;
CTRL$A	equ	'A' - '@'	; (^A)
CTRL$B	equ	'B' - '@'	; (^B)
CTRL$C	equ	'C' - '@'	; (^C)
CTRL$D	equ	'D' - '@'	; (^D)
CTRL$E	equ	'E' - '@'	; (^E)
CTRL$F	equ	'F' - '@'	; (^F)
CTRL$G	equ	'G' - '@'	; (^G)
CTRL$H	equ	'H' - '@'	; (^H)
CTRL$I	equ	'I' - '@'	; (^I)
CTRL$J	equ	'J' - '@'	; (^J)
CTRL$K	equ	'K' - '@'	; (^K)
CTRL$L	equ	'L' - '@'	; (^L)
CTRL$M	equ	'M' - '@'	; (^M)
CTRL$N	equ	'N' - '@'	; (^N)
CTRL$O	equ	'O' - '@'	; (^O)
CTRL$P	equ	'P' - '@'	; (^P)
CTRL$Q	equ	'Q' - '@'	; (^Q)
CTRL$R	equ	'R' - '@'	; (^R)
CTRL$S	equ	'S' - '@'	; (^S)
CTRL$T	equ	'T' - '@'	; (^T)
CTRL$U	equ	'U' - '@'	; (^U)
CTRL$V	equ	'V' - '@'	; (^V)
CTRL$W	equ	'W' - '@'	; (^W)
CTRL$X	equ	'X' - '@'	; (^X)
CTRL$Y	equ	'Y' - '@'	; (^Y)
CTRL$Z	equ	'Z' - '@'	; (^Z)
XON	equ	CTRL$Q		; XON character
XOFF	equ	CTRL$S		; XOFF character
BS	equ	CTRL$H		; backspace character
TAB	equ	CTRL$I		; tab character
CR	equ	CTRL$M		; carriage return character
LF	equ	CTRL$J		; line feed character
NULL	EQU	0		; null character
UNIXEOF	EQU	CTRL$D		; UNIX end-of-file character
DEL	equ	07FH		; delete character
EOS	equ	0		; end-of-string character
BELL	equ	CTRL$G		; bell character
;
;==============================================================================
;
; Define your line editing characters to suit
;
CL$CHAR	equ	CTRL$S		; character left
CR$CHAR	equ	CTRL$D		; character right
WL$CHAR	equ	CTRL$A		; word left
WR$CHAR	equ	CTRL$F		; word right
BL$CHAR	equ	CTRL$B		; move to beginning of line
EL$CHAR	equ	CTRL$T		; move to end of line
DC$CHAR	equ	CTRL$G		; delete next character
DL$CHAR	equ	CTRL$Y		; delete line
PC$CHAR	equ	CTRL$W		; previous command
NC$CHAR	equ	CTRL$Z		; next command
;
DELCC1	equ	BS		; delete last character #1
DELCC2	equ	DEL		; delete last character #2
;
DELCBL1	equ	CTRL$U		; delete to beginning of line #1
DELCBL2	equ	CTRL$X		; delete to beginning of line #2
;
DELCEL1	equ	CTRL$K		; delete to end of line #1
DELCEL2	equ	CTRL$N		; delete to end of line #2
;
DELCBW1	equ	CTRL$J		; delete to beginning of word
;
RECALL	equ	'!'		; recall all/one history buffer(s)
CMDSEP1	equ	'!'		; command separator #1
CMDSEP2	equ	';'		; command separator #2
COMCHR1	equ	';'		; comment character #1
COMCHR2	equ	'#'		; command character #2
TOGGLE	equ	CTRL$V		; insert/overstrike toggle
INTR	equ	CTRL$C		; interrupt character
;
CCPSIZ	equ	2048		; size of your CCP in bytes (for CP/M V2.2)
CPM3	equ	YES		; YES = running CP/M+
UNIX	equ	NO		; YES = use UNIX EOF character to logout
IODEF	equ	INSERT		; Insert (INSERT) or Overstrike (OVERS) default
;
;==============================================================================
;
; Define some BDOS function number equates
;
conin	equ	1		; BDOS console input
conout	equ	2		; BDOS console output
direct	equ	6		; BDOS direct console I/O
putline	equ	9		; BDOS put a line
getline	equ	10		; BDOS get a line
const	equ	11		; BDOS console status
clrsys	equ	13		; BDOS clear disk system
setSCB	equ	49		; BDOS set SCB database
getSCB	equ	49		; BDOS get SCB database
rsx	equ	60		; BDOS RSX function
;
inirsx	equ	55		; BDOS RSX initialize sub-function
clrbuf	equ	56		; BDOS RSX clear buffer sub-function
;
; Define some addresses
;
WBOOT	equ	0000H		; warm boot jump vector
BDOS	equ	0005H		; bdos vector
DMABUF	equ	0080H		; DMA buffer lives here
TPA	equ	0100H		; tpa starts here
;
; Miscellaneous equates
;
HISTSIZ	equ	40		; size of a history buffer
; HISTSIZ	equ	128	; size of a history buffer
;
;  Start of V2.2 loader
;
	if	(NOT CPM3)
	org	TPA

start:	lxi 	H,0		; save user stack pointer
	dad	SP 		;
	shld 	stack		;
	lxi 	SP,stack	;

	lda	DMABUF+1	; any arguments?
	ora	A		;
	jnz	unload		; yep, unload the daemon

	mvi	A,0		; clear reload flag
	sta	RLFLAG		;

	call	chkhist		; history already loaded?
	jnz	load		; nope
	lhld	BDOS+1		; yep, get true start of BDOS
	lxi	D,next-daemon-6+1; offset in daemon
	dad	D		; point to it
	mov	E,M		; get low byte of address
	inx	H		; bump up pointer
	mov	D,M		; get high byte of address
	xchg			; back in <HL> register pair
	mvi	A,1		; set reload flag
	sta	RLFLAG		;
	jmp	reload		; and re-load the daemon

load:	lhld	BDOS+1		; get start of BDOS
reload:	shld	next+1		; stuff in daemon

	push	H		; save it
	lxi	D,-6		; point to serial number
	dad	D		;
	lxi	D,daemon	; point to unloaded daemon
	mvi	B,6		; 6 bytes in serial number
mvsn:	mov	A,M		; move it
	stax	D		;
	inx	H		;
	inx	D		;
	dcr	B		;
	jnz	mvsn		;

	lhld	WBOOT + 1	; point to start of BIOS

find1:	lxi	D,next		; point to BDOS vector in daemon
	mvi	B,3		; match this many characters

fndbdos:ldax	D		; get character from daemon
	inx	H		; bump up BIOS pointer
	cmp	M		; compare
	jz	gotone		; gotta match
	mov	A,H		; done?
	ora	L		;
	jz	bioserr		; yep, error
	jmp	find1		; nope, try again
gotone:	inx	D		; bump up jmp bdos pointer
	dcr	B		; got a match bump down counter
	jnz	fndbdos		; merry-go-round time

	dcx	H		; point to it
	shld	BBIOS		; and save
	pop	H		; restore start of BDOS

	lxi	D,-(CCPSIZ+7)	; get CCP size + 7
	dad	D		; subtract (daemon ends lives here)
	lxi	D,ENDCOD-1	; get end of daemon
	lxi	B,ENDCOD-BEGCOD	; get number of bytes to move
mvcode:	mov	A,B		; done?
	ora	C		;
	jz	update		; yep, modify the code
	ldax	D		; nope, get a byte
	mov	M,A		; put a byte
	dcx	D		; bump down from pointer
	dcx	H		; bump down to pointer
	dcx	B		; bump down counter
	jmp	mvcode		; merry-go-round time

update:	xchg			; get the start of daemon
	call	NEGHL		; make it negative
	dad	D		; subtract from where daemon start lives
	shld	OFFSET+1	; this is the offset we add, so store
	xchg			; and save
	lxi	H,BEGDAT	; beginning of daemon data area (not modified)
	dad	D		; add offset
	shld	ENDRNG+1	; this is where we stop modifying live daemon
	lxi	H,BEGCOD	; point to start of daemon code
	dad	D		; add offset (point to start of live daemon)
	dcx	H		; bump down to begin modifying
modify:	inx	H		; bump up live daemon pointer
ENDRNG:	lxi	D,0		; point to end modify address
	mov	A,E		; and subtract
	sub	L		;
	mov	A,D		;
	sbb	H		;
	jc	BEGIN		; done modifying
	mvi	B,INST3E-INST3	; not done, test for a 3 byte instruction
	lxi	D,INST3		;
thrbyt:	ldax	D		; get a 3 byte instruction
	cmp	M		; a 3 byte instruction to modify?
	jz	change		; yep, do it
	inx	D		; nope, bump up 3 byte instruction pointer
	dcr	B		; bump down counter
	jnz	thrbyt		; merry-go-round 3 byte instructions
	mvi	B,INST2E-INST2	; test for a 2 byte instruction
	lxi	D,INST2		;
twobyt:	ldax	D		; get a 2 byte instruction
	cmp	M		; a 2 byte instruction to skip?
	jz	SKIP		; yep, skip it (no address here)
	inx	D		; nope, bump up 2 byte instruction pointer
	dcr	B		; bump down conter
	jnz	twobyt		; merry-go-round 2 byte instrunctions
	jmp	modify		; merry-go-round live daemon code
skip:	inx	H		; point to next daemon byte
	jmp	modify		; and try again

change:	lxi	D,ENDCOD	; point to end of daemon code
	lxi	B,BEGCOD	; point to beginning of daemon code
	inx	H		; point to live daemon address
	mov	A,E		; past last address to modify?
	sub	M		;
	inx	H		;
	mov	A,D		;
	sbb	M		;
	jc	modify		; yep, try next byte
	dcx	H		; nope, before first address to modfiy?
	mov	A,M		;
	sub	C		;
	inx	H		;
	mov	A,M		;
	sbb	B		;
	jc	modify		; yep, try next byte
	dcx	H		; nope, point to low byte of address
OFFSET:	lxi	D,0		; get offset
	mov	A,M		; modify by adding offset
	add	E		;
	mov	M,A		;
	inx	H		;
	mov	A,M		;
	adc	D		;
	mov	M,A		;
	jmp	modify		;
negHL:	mov	A,H		; 2's complement <HL> register
	cma			;
	mov	H,A		;
	mov	A,L		;
	cma			;
	mov	L,A		;
	inx	H		;
	ret			;

INST3:	db	001H,011H,021H,022H,02AH,031H,032H,03AH,0C2H
	db	0C3H,0C4H,0CAH,0CCH,0CDH,0D2H,0D4H,0DAH,0DCH
	db	0E2H,0E4H,0EAH,0ECH,0F2H,0F4H,0FAH,0FCH
INST3E	equ	$
INST2:	db	006H,00EH,016H,01EH,026H,02EH,036H,03EH,0C6H
	db	0CEH,0D3H,0D6H,0DBH,0DEH,0E6H,0EEH,0F6H,0FEH
INST2E	equ	$


begin:	lhld	BDOS+1		; point to BDOS jump vector address
	lxi	D,daemon+6	; get start of daemon
	lhld	OFFSET+1	; get offset
	dad	D		; add offset
	shld	BDOS+1		; this is new BDOS jump vector
	push	H		; save it
	lxi	D,BBIOS		; get the BIOS address of BDOS jump vector
	lhld	OFFSET+1	; get offset
	dad	D		; add offset
	mov	E,M		; get the low byte of address
	inx	H		; bump up pointer
	mov	D,M		; get the high byte of address
	xchg			; back in <HL>
	pop	D		; restore the start of daemon
	mov	M,E		; and stuff into the BIOS
	inx	H		;
	mov	M,D		;

	lxi	D,HIST1		; get address of first history buffer
	lhld	OFFSET+1	; get offset
	dad	D		; add offset
	push	H		; and save
	lxi	D,CHBUF		; get the pointer to current history buffer
	lhld	OFFSET+1	; get offset
	dad	D		; add offset
	pop	D		; restore live address of first history buffer
	mov	M,E		; and stuff into live daemon
	inx	H		;
	mov	M,D		;

	lda	RLFLAG		; reloading daemon?
	cpi	0		;
	jnz	again		; yep

	call	ilprt
	db	'History daemon loaded',0
	jmp	exit

again:	call	ilprt
	db	'Hstory daemon re-loaded',0
	jmp	exit

unload:	call	chkhist		; check to see if daemon loaded
	jz	unpatch		;
	call	ilprt
db	'History daemon not loaded',0
	jmp	exit

unpatch:lhld	BDOS+1		; get start of live history daemon
	push	H		; and save
	lxi	D,next-daemon-6+1; get offset to true BDOS start
	dad	D		; point to it
	mov	E,M		; get low byte of address
	inx	H		; bump up pointer
	mov	D,M		; get high byte of address
	xchg			;
	shld	BDOS+1		; put back into BDOS vector
	push	H		; move from <HL>
	pop	B		; to <BC>
	pop	H		; restore daemon start
	lxi	D,BBIOS-daemon-6; get offset to true BDOS start
	dad	D		; point to it
	mov	E,M		; get low byte of address
	inx	H		; bump up pointer
	mov	D,M		; get high byte of address
	xchg			; point to BIOS jump BDOS vector
	mov	M,C		; put low byte of address
	inx	H		; bump up pointer
	mov	M,B		; put high byte of address

	call	ilprt
	db	'History daemon unloaded',0
	jmp	exit

bioserr:call	ilprt
	db	'History: can''t locate BDOS jump vector in BIOS',0
	jmp	exit

ilprt:	xthl			; vanilla flavored in-line print

ilprt1:	mov	A,M		; get a character
	ora	A		; done?
	jz	ilprt2		; yep
	call	ctype		; nope, print it
	inx	H		; bump up pointer
	jmp	ilprt1		; merry-go-round time

ilprt2:	xthl			; reset return address
	ret			; done

chkhist:lhld	BDOS+1		; get the start of BDOS (or daemon)
	lxi	D,rsxnam-daemon-6; point to daemon name
	dad	D		;
	lxi	D,rsxnam	; point to history daemon name
	mvi	B,8		; name is this long
chkh$1:	ldax	D		; is history daemon loaded?
	cmp	M		;
	rnz			; nope
	inx	H		; bump up live daemon name pointer
	inx	D		; bump up history deamon name pointer
	dcr	B		; bump down counter
	jnz	chkh$1		; merry-go-round time
	ret			;

ctype:	push	H		; save the HL register pair
	push	D		; save the DE register pair
	push	B		; save the BC register pair
	mov	E,A		; character to output
	call	chkint		; check for interrupt
	jz	exit		; aborted
	mvi	C,direct	; bdos DIRECT CONSOLE OUTPUT function
	call	BDOS		; do it
	pop	B		; restore the BC register pair
	pop	D		; restore the DE register pair
	pop	H		; restore the HL register pair
	ret			;

cinput:	push	H		; save the HL register pair
	push	D		; save the DE register pair
	push	B		; save the BC register pair
	mvi	E,0FFH		; query for character
	mvi	C,direct	; bdos DIRECT CONSOLE OUTPUT function
	call	BDOS		; do it
	pop	B		; restore the BC register pair
	pop	D		; restore the DE register pair
	pop	H		; restore the HL register pair
	ana	A		; setup PSW
	ret			;

chkint	call	cinput		; get a character from keyboard
	cpi	XOFF		; XOFF (^S) character?
chki1:	cz	cinput		; yep, wait for another character
	jz	chki1		; merry-go-round tinme
	cpi	INTR		; an intr character?
	ret			;

exit:	lhld 	stack		; restore user stack pointer
	sphl			;
	ret			;

RLFLAG:	db	0		; reload flag
	endif			; (NOT CPM3)

BEGCOD:
daemon:	db	0,0,0,0,0,0	; room for serial number
	jmp	test		; start of program
next:	db	0C3H		; jump instruction
	dw	0		; address next module in line
prev:	dw	0		; address previous module
remove:	db	0		; remove flag (FF = remove on wboot)
nonbnk:	db	0		; nonbanked flag (FF = nonbanked only)
rsxnam:	db	'HISTORY '	; RSX name
loader:	db	0		; loader flag (FF = loader RSX)
	db	0,0		; reserved

test:
	if	CPM3
	mov	A,C		; get the BDOS function
	cpi	rsx		; BDOS RSX function?
	jz	rsxtest		; yep, check it out
	lda	VIRGIN		; are we initialized yet?
	ora	A		;
	jz	next		; nope, play dead
	endif			; CPM3

	mov	A,C		; get the BDOS function (again)
	cpi 	getline		; are we trying to get a line from the console?
	jnz 	next		; nope, let it be

	lxi 	H,0		; save user stack pointer
	dad	SP 		;
	shld 	stack		;
	lxi 	SP,stack	;

	call	history		; get a command line with history

nulhist:lhld 	stack 		; restore user stack pointer
	sphl			;
	ret			;

putc:	push	H		; save the HL register pair
	push	D		; save the DE register pair
	push	B		; save the BC register pair
	push	PSW		; save the output character
	mov	E,A		; this is character to output

	if	(NOT CPM3)
	call	chkex		; check for EX
	jz	pnoex		; EX active
	endif			; (NOT CPM3)

	mvi	C,direct	; bdos DIRECT CONSOLE OUTPUT function
	call	next		; do it (if EX is not alive)

pnoex:	pop	PSW		; restore the output character
	pop	B		; restore the BC register pair
	pop	D		; restore the DE register pair
	pop	H		; restore the HL register pair
	ret			;

putctrl:cpi	' '		; is it a control character?
	cnc	putc		; nope
	rnc			;
	push	PSW		; yep, save the character
	mvi	A,'^'		; output as ^<char+' '>
	call	putc		;
	pop	PSW		;
	adi	'@'		; no longer control
	call	putc		;
	ret			;

getc:	push	H		; save the HL register pair
	push	D		; save the DE register pair
	push	B		; save the BC register pair
	mvi	C,direct	; bdos DIRECT CONSOLE I/O function
	mvi	E,0FFH		;

	if	(NOT CPM3)
	call	chkex		; check for EX
	jnz	gnoex		; EX not active
	mvi	C,conin		; use BDOS CONSOLE INPUT for EX
	endif			; (NOT CPM3)

gnoex:	call	next		; do it
	pop	B		; restore the BC register pair
	pop	D		; restore the DE register pair
	pop	H		; restore the HL register pair
	ani	07FH		; strip off parity
	cpi	TAB		; is it a tab?
	jz	getc		; yep, ignore for now
	ana	A		; setup PSW
	ret			;

chkintr:call	getc		; get a character from keyboard
	cpi	XOFF		; XOFF (^S) character?
chk1:	cz	getc		; yep, wait for another character
	jz	chk1		; merry-go-round tinme
	cpi	INTR		; an intr character?
	ret			;
;
; check for EX (submit daemon). If EX is present, then it will intercept
; console I/O calls, and return a character from its own buffer, to replace
; a character from the console. This works fine if you are GETTING a
; character, not CHECKING for a character. Since BDOS#6, does a check
; before a get, this method of console redirection fails. To compensate,
; we check for EX, then use BDOS#1 to get a character instead of a BDOS#6.
; Likewise the put character is ignored (as BDOS#1 also echos) if EX is
; present.
;
	if	(NOT CPM3)
chkex:	lhld	BDOS + 1	; check to see if EX daemon loaded
	inx	H		;
	inx	H		;
	inx	H		;
	mov	A,M		;
	cpi	'E'		;
	rnz			;
	inx	H		;
	mov	A,M		;
	cpi	'X'		;
	rnz			;
	inx	H		;
	mov	A,M		;
	cpi	0FFH		;
	ret			;
	endif			; (NOT CPM3)

puts:	push	H		; save registers
	push	B		;
	push	PSW		;
	lda	MAXCHR		; get maximum number of character to put
	mov	B,A		;
puts$1:	call	chkintr		;
	jz	nocmd		;
	mov	A,M		; get a character
	cpi	EOS		; end of string?
	jz	puts$2		; yep, done
	call	putctrl		; nope, show it
	inx	H		; bump up pointer
	dcr	B		; bump down counter
	jnz	puts$1		; merry-go-round time
puts$2:	pop	PSW		; restore registers
	pop	B		;
	pop	H		;
	ret			;

gets:	lhld	BUFADR		; get the buffer address
	xra	A		;
	sta	NOWPOS		; we're at the beginning of line
	sta	CHRCNT		; clear the character count
gets$1:	call	getc		; get the next character
	jz	gets$1		; wait for it
	cpi	CR		; is it a carriage return?
	jz	gots		; yep, wrap it up

	if	UNIX
	cpi	UNIXEOF		; UNIX logout character?
	cz	end$xmit	; yep
	endif			; UNIX

	cpi	DELCC1		; is it a delete previous character #1?
	jz	delete$char	; yep, then delete the sucker
	cpi	DELCC2		; is it a delete previous character #2?
	jz	delete$char	; yep, then delete the sucker
	cpi	DELCBL1		; delete to beginning of line char #1
	jz	delete$bol	; yep
	cpi	DELCBL2		; delete to beginning of line char #2
	jz	delete$bol	; yep
	cpi	DELCEL1		; delete to end of line char #1?
	jz	delete$eol	; yep
	cpi	DELCEL2		; delete to end of line char #2?
	jz	delete$eol	; yep
	cpi	DELCBW1		; delete to beginning of word?
	jz	delete$bow	; yep
	cpi	DL$CHAR		; delete line?
	jz	delete$line	; yep
	cpi	CL$CHAR		; character left?
	jz	cursor$left	; yep
	cpi	CR$CHAR		; character right?
	jz	cursor$right	; yep
	cpi	WL$CHAR		; word left?
	jz	word$left	; yep
	cpi	WR$CHAR		; word right?
	jz	word$right	; yep
	cpi	BL$CHAR		; beginning of line?
	jz	move$bol	; yep
	cpi	EL$CHAR		; end of line?
	jz	move$eol	; yep
	cpi	DC$CHAR		; delete next character?
	jz	delete$right	; yep
	cpi	PC$CHAR		; get previous command?
	jz	prev$command	; yep
	cpi	NC$CHAR		; get next command?
	jz	next$command	; yep
	cpi	TOGGLE		; insert/overstrike toggle?
	jz	insovr$toggle	; yep
	cpi	INTR		; interrupt character?
	cz	cintr		; yep
	mov	B,A		; save the character
	lda	INSOVR		; get the insert/overstrike mode byte
	cpi	INSERT		; insert mode?
	mov	A,B		; restore the character
	cnz	ovrc		; nope, overstrike the character
	cz	insc		; yep, insert the character
	jnz	gets$1		; get another character
gots:	lhld	BUFADR		; check for recall character
	mov	A,M		; get the first character
	cpi	RECALL		; recall history(s)?
	jnz	norecal		; nope
	lda	CHRCNT		; yep, get the character count
	cpi	1		; recall all?
	jz	recall$history	; yep
	cpi	2		; recall one?
	jz	recall$one	; yep
norecal:lda	CHRCNT		; buffer gotten, get character count
	mvi	D,0		;
	mov	E,A		;
	dad	D		; point to next character
	lda	MAXCHR		; is it past the end-of-buffer?
	sub	E		;
	rz			; yep
	mvi	M,EOS		; nope, set current character to EOS char
	ret			; and return

	if	UNIX
end$xmit:
	mov	B,A		; save the character
	lda	NOWPOS		; are we at the beginning of line?
	ora	A		;
	mov	A,B		; restore character
	rnz			; nope

	lda	CHRCNT		; empty line?
	ora	A		;
	mov	A,B		; restore character
	rnz			; nope

	mvi	B,0		; initialize the character counter
	lhld	BUFADR		; get the buffer address
	lxi	D,logout	; print logout message

put$logout:
	ldax	D		; get a logout message character
	cpi	EOS		; end of string?
	jz	ex$2		; yep
	mov	M,A		; nope, move to buffer

	call	putc		; and show it

	inx	H		; bump up to pointer
	inx	D		; bump up from pointer
	inr	B		; bump up counter
	jmp	put$logout	;

ex$2:	mov	A,B		; get the character count
	sta	CHRCNT		; and store
	pop	PSW		; fix stack
	jmp	gots		; and done
	endif

cintr:	mov	B,A		; save the character
	lda	NOWPOS		; are we at the beginning of the line?
	ora	A		;
	mov	A,B		; restore the character
	rnz			; return if not

	call	insc		;  show interrupt char it and...
	jmp	WBOOT		; warm boot

delete$char:
	call	delc		; delete the character
	jmp	gets$1		; get another character

delete$bow:
	call	delbw		; delete to beginning of word
	jmp	gets$1		; get another character

delete$bol:
	call	delbl		; delete to beginning of line
	jmp	gets$1		; get another character

delete$eol:
	call	delel		; delete to end of line
	jmp	gets$1		; get another character

delete$line:
	call	cright		; move to end-of-line
	jnz	delete$line	;
	jmp	delete$bol	; and delete to beginning ofline

delete$right:
	call	cright		; move cursor right
	jnz	delete$char	; and delete a character if we can
	jmp	gets$1		; else back again

cursor$left:
	call	cleft		; move cursor left
	jmp	gets$1		;

cursor$right:
	call	cright		; move cursor right
	jmp	gets$1		;

word$left:
	call	wleft		; move word left
	jmp	gets$1		;

word$right:
	call	wright		; move word right
	jmp	gets$1		;

move$bol:
	call	cleft		; move a character left
	jnz	move$bol	; 'til at beginning of line
	jmp	gets$1		;

move$eol:
	call	cright		; move a character right
	jnz	move$eol	; 'til at end of line
	jmp	gets$1		;

prev$command:
	lda	BACKUP		; backed up thru all history buffers?
	mov	C,A		;
	lda	ACTCMD		;
	inr	A		;
	sub	C		;
	jz	delete$line	; yep, just delete line
	mov	A,C		; nope, bump up backup counter
	inr	A		;
	sta	BACKUP		;
	lhld	PHBUF		; get the prev/next history buffer pointer
	call	pcmd		; point to previous command
	jmp	pn$command	;

next$command:
	lda	BACKUP		; get history backup counter
	ora	A		; have we backed up any?
	jz	delete$line	; nope, just delete line
	dcr	A		; bump down backup counter
	sta	BACKUP		;
	lhld	PHBUF		; get the pre/next history buffer pointer
	call	ncmd		; point to next command if need be

pn$command:
	shld	PHBUF		; store buffer pointer
	lda	BACKUP		; pointing at current buffer?
	ora	A		;
	jz	delete$line	; yep, then just delete the line
	mov	C,A		; past all history buffers?
	lda	ACTCMD		;
	sub	C		;
	jc	delete$line	; yep, then just delete the line
pnc$1:	call	cright		; move to end of line
	jnz	pnc$1		;
pnc$2:	call	delc		; delete to beginning of line
	jnz	pnc$2		;

	lhld	PHBUF		; point to start of this history buffer
	lda	MAXCHR		; get maximum # of characters to move
	mov	B,A		; and save

pnc$3:	mov	A,M		; get a character
	cpi	EOS		; end of string?
	jz	pnc$4		; yep
	push	H		; nope, save registers
	push	B		;
	call	insc		; insert a character
	pop	B		; restore registers
	pop	H		;
	inx	H		; point to next character
	dcr	B		; bump down character counter
	jnz	pnc$3		; merry-go-round time
pnc$4:	jmp	gets$1		; done

insovr$toggle:
	lda	INSOVR		; toggle the insert/overstrike mode byte
	xri	0FFH		;
	sta	INSOVR		;
	jmp	gets$1		;

recall$one:
	inx	H		; point to history to recall
	mov	A,M		; get the number
	dcx	H		; repair the damage
	cpi	'1'		; check for history number
	jc	norecal		; nope
	cpi	'9' + 1		;
	jnc	norecal		; nope
	sui	'0'		; de-ascii it
	mov	B,A		; and save
	lda	ACTCMD		; get the number of active commands
	sub	B		; recall a non-active command?
	jc	delete$line	; yep
	inr	A		; add offset
	sta	BACKUP		; and update the backup counter
	lhld	CHBUF		; point to the current command
ro$1:	dcr	A		; bump down counter
	cnz	pcmd		; point to previous command (if need be)
	jnz	ro$1		; merry-go-round time
	shld	PHBUF		; store in previous buffer pointer
	jmp	pn$command	; and fetch

recall$history:
	call	putnl		; put a newline

	lda	ACTCMD		; get number of active history buffers
	ora	A		; any?
	jz	nocmd		; nope

	lhld	CHBUF		; get the current history buffer
	dcr	A		; bump down by one
	jz	rh$2		; we're pointing at the current buffer

rh$1:	call	pcmd		; point to previous comand
	dcr	A		; bump down counter
	jnz	rh$1		; merry-go-round time

rh$2:	lda	ACTCMD		; get number of active history buffers (again)
	mov	B,A		; save it
	mvi	C,1		; initialize number counter
rh$3:	mvi	A,'0'		; show the history buffer number
	add	C		;
	call	putc		;
	mvi	A,' '		;
	call	putc		;
	call	puts		; show the history buffer
	call	ncmd		; point to the next command
	inr	C		; bump up history buffer number counter
	dcr	B		; bump down active command counter
	cnz	putnl		; put a newline if need be
	jnz	rh$3		; merry-go-round time

nocmd:	lhld	BUFADR		; create an empty line
	mvi	M,EOS		;
	dcx	H		; and null character count
	mvi	M,0		;
	jmp	nulhist		;

delc:	lda	NOWPOS		; where am i in this line?
	ora	A		; any characters to delete?
	rz			; nope, then just return

	lhld	BUFADR		; point to the beginning of buffer
	mvi	D,0		; add current character count
	mov	E,A		;
	dcx	D		;
	dad	D		; point to previous character
	push	H		;
	pop	D		;
	inx	D		; point to current character in line

	lda	NOWPOS		; calculate number of chars to shift
	mov	C,A		;
	lda	CHRCNT		;
	sub	C		; at end of line?
	jz	delc$3		; yep

	mov	B,A		; number of character to move
	push	H		; save pointer to previous character
	push	B		; and save it

	mvi	A,BS		; move back a character
	call	putc		;
	mov	A,M		; was it a control character?
	sta	LSTCHR		; save it
	cpi	' '		;
	mvi	A,BS		; get ready for it
	cc	putc		; backspace again if need be

delc$1:	ldax	D		; get a character
	mov	M,A		; put a character
	call	putctrl		; show new character
	inx	H		; bump up from pointer
	inx	D		; bump up to pointer
	dcr	B		; bump down counter
	jnz	delc$1		; merry-go-round time

	lda	LSTCHR		; was deleted character CTRL?
	cpi	' '		;
	mvi	A,' '		;
	cc	putc		;
	mvi	A,' '		; kill last character (on screen)
	call	putc		;
	mov	A,M		; was it a CTRL character?
	cpi	' '		;
	mvi	A,' '		;
	cc	putc		; kill another character if need be
	mvi	A,BS		;
	call	putc		;
	mov	A,M		; was it a CTRL character?
	cpi	' '		;
	mvi	A,BS		;
	cc	putc		; backspace another character if need be
	lda	LSTCHR		; was delete character CTRL?
	cpi	' '		;
	mvi	A,BS		;
	cc	putc		; backspace again if need be

	pop	B		; get number of characters shifted
	pop	H		; point to current character

delc$2:	mvi	A,BS		; move back a character
	call	putc		;
	mov	A,M		; was it a control character?
	cpi	' '		;
	mvi	A,BS		; get ready for it
	cc	putc		; yep, also backup for "^"
	inx	H		; bump up pointer
	dcr	B		; bump down counter
	jnz	delc$2		; merry-go-round time
	jmp	delc$4		;

delc$3:	mvi	A,BS		; delete the character from the screen
	call	putc		;
	mvi	A,' '		;
	call	putc		;
	mvi	A,BS		;
	call	putc		;
	mov	A,M		; was character a CTRL character?
	cpi	' '		;
	jnc	delc$4		;
	mvi	A,BS		; delete the another character if need be
	call	putc		;
	mvi	A,' '		;
	call	putc		;
	mvi	A,BS		;
	call	putc		;

delc$4:	lda	NOWPOS		; update current postion
	dcr	A		;
	sta	NOWPOS		;
	lda	CHRCNT		; update character count
	dcr	A		;
	sta	CHRCNT		;
	ori	1		; reset ZERO
	ret			;

insc:	push	PSW		; save the character

	lda	CHRCNT		; get total character count
	mov	C,A		;

	lhld	BUFADR		; point to the beginning of buffer
	mvi	D,0		; add next character count
	mov	E,C		;
	dad	D		; point to next free character in line
	push	H		;
	pop	D		;
	dcx	D		; point to last character in line

	lda	MAXCHR		; at end of buffer?
	sub	C		;
	jnz	insc$1		; nope
	mvi	A,BELL		; yep, get ready for it
	call	putc		; beep
	pop	PSW		; restore stack
	ret			; and return

insc$1:	lda	NOWPOS		; calculate number of chars to shift
	mov	C,A		;
	lda	CHRCNT		;
	sub	C		; at end of line?
	jz	insc$5		; yep

	mov	B,A		; number of character to move
	push	B		; and save it

insc$2:	ldax	D		; get a character
	mov	M,A		; put a character
	dcx	H		; bump down from pointer
	dcx	D		; bump down to pointer
	dcr	B		; bump down counter
	jnz	insc$2		; merry-go-round time

	pop	B		; get number of characters shifted
	pop	PSW		; restore current character

	mov	M,A		; stuff new characer buffer

	push	H		; save the pointer
	push	B		; save the number of character shifted

	inr	B		; bump up to include new character

insc$3:	mov	A,M		; get a characater
	call	putctrl		; show a character
	inx	H		; bump up pointer
	dcr	B		; bump down counter
	jnz	insc$3		; merry-go-round time

	pop	B		; restore the counter
	pop	H		; restore the pointer
	inx	H		; point to next character

insc$4:	mvi	A,BS		; backspace a character
	call	putc		;
	mov	A,M		; was it a control character?
	cpi	' '		;
	mvi	A,BS		; get ready for it
	cc	putc		; yep, also backup for "^"
	inx	H		; bump up pointer
	dcr	B		; bump down counter
	jnz	insc$4		; merry-go-round time
	jmp	insc$6		;

insc$5:	pop	PSW		; get the character
	mov	M,A		; store in buffer
	call	putctrl		; and show it

insc$6:	lda	NOWPOS		; update current postion
	inr	A		;
	sta	NOWPOS		;
	lda	CHRCNT		; update character count
	inr	A		;
	sta	CHRCNT		;
	ret			;

ovrc:	push	PSW		; save the status
	push	PSW		; save the character

	lda	NOWPOS		; get total character count
	mov	C,A		;

	lhld	BUFADR		; point to the beginning of buffer
	mvi	D,0		; add next character count
	mov	E,C		;
	dad	D		; point to next free character in line

	mov	A,M		; get the character to overstrike
	sta	LSTCHR		; and save it

	pop	PSW		; restore the character
	mov	M,A		; overstrike the character
	call	putctrl		; and show it

	lda	CHRCNT		; at end of line?
	sub	C		;
	jz	ovrc$7		; yep

	mov	B,A		; nope, save difference

	mov	A,M		; get the character (again)
	cpi	' '		; CTRL character?
	jc	ovrc$4		; yep

	lda	LSTCHR		; nope, is overstruck character also non-CTRL?
	cpi	' '		;
	jnc	ovrc$8		; yep, then we're done

	dcr	B		; nope, calculate number of characters to shift
	jz	ovrc$2		; overstiking last character, no need to move
	inx	H		; point to next character

	push	H		; save pointer
	push	B		; save counter

ovrc$1:	mov	A,M		; get a character
	call	putctrl		; and put it
	inx	H		; bump up pointer
	dcr	B		; bump down counter
	jnz	ovrc$1		; merry-go-round time

	pop	B		; restore counter
	pop	H		; restore pointer

ovrc$2:	mvi	A,' '		; wipe out last character
	call	putc		;
	mvi	A,BS		; and backspace
	call	putc		;
	mov	A,B		; at end of line?
	ora	A		;
	jz	ovrc$8		; done for overstriking last character

ovrc$3:	mvi	A,BS		; backspace a character
	call	putc		;
	mov	A,M		; was it a CTRL character?
	cpi	' '		;
	mvi	A,BS		; prepare for it
	cc	putc		; backspace again if need be
	inx	H		; bump up pointer
	dcr	B		; bump down counter
	jnz	ovrc$3		; merry-go-round time
	jmp	ovrc$8		; done

ovrc$4:	lda	LSTCHR		; is overstruck character also CTRL?
	cpi	' '		;
	jc	ovrc$8		; yep, then we're done

	dcr	B		; nope, calculate number of characters to shift
	inx	H		; point to next character

	push	H		; save pointer
	push	B		; save counter

ovrc$5:	mov	A,M		; get a character
	call	putctrl		; and put it
	inx	H		; bump up pointer
	dcr	B		; bump down counter
	jnz	ovrc$5		; merry-go-round time

	pop	B		; restore counter
	pop	H		; restore pointer

ovrc$6:	mvi	A,BS		; backspace a character
	call	putc		;
	mov	A,M		; was it a CTRL character?
	cpi	' '		;
	mvi	A,BS		; prepare for it
	cc	putc		; backspace again if need be
	inx	H		; bump up pointer
	dcr	B		; bump down counter
	jnz	ovrc$6		; merry-go-round time
	jmp	ovrc$8		; done

ovrc$7:	lda	CHRCNT		; update character count
	inr	A		;
	sta	CHRCNT		;

ovrc$8:	lda	NOWPOS		; update cursor position
	inr	A		;
	sta	NOWPOS		;
	pop	PSW		; restore status
	ret			;

delbw:	lda	NOWPOS		; where am i in this line?
	ora	A		; any characters to delete?
	mov	B,A		; save it
	rz			; nope, then just return

	lhld	BUFADR		; point to the beginning of buffer
	mvi	D,0		; point to current character
	mov	E,A		;
	dcx	D		;
	dad	D		;

	mvi	C,0		; clear number of visible characters deleted
	mvi	E,0		; clear number of characters deleted

delbw$1:mov	A,M		; get the current character
	call	isspace		; is it white space (word delimitor)?
	jnz	delbw$2		; nope, we're at the end of (or inside) a word
	mvi	A,BS		; yep, move back a character
	call	putc		;
	inr	C		; bump up visible characters deleted
	inr	E		; bump up number of characters deleted
	dcx	H		; bump down pointer
	dcr	B		; bump down counter
	jnz	delbw$1		; merry go round time
	jmp	delbw$4		; deleted entire line

delbw$2:mov	A,M		; get the current character
	call	isspace		; is it white space (word delimtor)?
	jz	delbw$4		; yep, we're at the begining of a word
	mvi	A,BS		; nope, move back a character
	call	putc		;
	inr	C		; bump up visible characters deleted
	inr	E		; bump up number of characters deleted
	mov	A,M		; was it a control character?
	cpi	' '		;
	jnc	delbw$3		; nope
	mvi	A,BS		; yep, backspace again
	call	putc		;
	inr	C		; bump up visible characters
delbw$3:dcx	H		; bump down pointer
	dcr	B		; bump down counter
	jnz	delbw$2		; merry go round time

delbw$4:mov	A,C		; save the number of visible chars deleted
	sta	LSTCHR		;

	mov	A,E		; save the number of characters deleted
	sta	TEMP		;

	lda	NOWPOS		; get current cursor position

	push	H		; save pointer
	lhld	BUFADR		; point to the beginning of buffer
	mvi	D,0		;
	mov	E,A		;
	dad	D		; point to new first character
	xchg			;
	pop	H		; restore pointer
	inx	H		; point to beginning of deleted word

	lda	NOWPOS		; calculate number of chars to shift
	mov	C,A		;
	lda	CHRCNT		;
	sub	C		;
	jz	delbw$6		; none
	mov	B,A		;

delbw$5:ldax	D		; get a character
	mov	M,A		; put a character
	call	putctrl		; show it
	inx	H		; bump up to pointer
	inx	D		; bump up from pointer
	dcr	B		; bump down counter
	jnz	delbw$5		; merry-go-round time

delbw$6:lda	LSTCHR		; get number of characters to blanks out
	mov	B,A		;
delbw$7:mvi	A,' '		;
	call	putc		; blank 'em
	dcr	B		;
	jnz	delbw$7		;

	lda	LSTCHR		; get number of characters to backspace
	mov	B,A		;
delbw$8:mvi	A,BS		;
	call	putc		; backspace 'em
	dcr	B		;
	jnz	delbw$8		;

	dcx	H		; point to end of line

	lda	NOWPOS		; calculate number of chars to shift
	mov	C,A		;
	lda	CHRCNT		;
	sub	C		;
	jz	delbw$A		; none
	mov	B,A		;

delbw$9:mvi	A,BS		; backspace a character
	call	putc		;
	mov	A,M		; was it a control character?
	cpi	' '		;
	mvi	A,BS		; get ready for it
	cc	putc		; backspace again if need be
	dcx	H		; point to previous character
	dcr	B		; bump down counter
	jnz	delbw$9		; merry-go-round time

delbw$A:lda	TEMP		; get number of characters deleted
	mov	C,A		;
	lda	NOWPOS		; update cursor position
	sub	C		;
	sta	NOWPOS		;
	lda	CHRCNT		; update character count
	sub	C		;
	sta	CHRCNT		;
	ret			;

delbl:	lda	NOWPOS		; where am i in this line?
	ora	A		; any characters to delete?
	mov	B,A		; save it
	rz			; nope, then just return

	lhld	BUFADR		; point to the beginning of buffer

	lda	NOWPOS		; calculate number of chars to shift
	mov	C,A		;
	lda	CHRCNT		;
	sub	C		; at end of line?
	jz	delbl$7		; yep

	mvi	C,0		; clear number of visible characters deleted

delbl$1:mvi	A,BS		; move back a character
	call	putc		;
	inr	C		; bump up visible characters deleted
	mov	A,M		; was it a control character?
	cpi	' '		;
	jnc	delbl$2		; nope
	mvi	A,BS		; yep, backspace again
	call	putc		;
	inr	C		; bump up visible characters
delbl$2:inx	H		; bump up pointer
	dcr	B		; bump down counter
	jnz	delbl$1		; merry go round time

	mov	A,C		; save the number of visible chars deleted
	sta	LSTCHR		;

	lda	NOWPOS		; get current cursor position

	lhld	BUFADR		; point to the beginning of buffer
	mvi	D,0		;
	mov	E,A		;
	dad	D		; point to new first character
	xchg			;
	lhld	BUFADR		; point to beginning of buffer

	lda	NOWPOS		; calculate number of chars to shift
	mov	C,A		;
	lda	CHRCNT		;
	sub	C		;
	mov	B,A		;

delbl$3:ldax	D		; get a character
	mov	M,A		; put a character
	call	putctrl		; show it
	inx	H		; bump up to pointer
	inx	D		; bump up from pointer
	dcr	B		; bump down counter
	jnz	delbl$3		; merry-go-round time

	lda	LSTCHR		; get number of characters to blanks out
	mov	B,A		;
delbl$4:mvi	A,' '		;
	call	putc		; blank 'em
	dcr	B		;
	jnz	delbl$4		;

	lda	LSTCHR		; get number of characters to backspace
	mov	B,A		;
delbl$5:mvi	A,BS		;
	call	putc		; backspace 'em
	dcr	B		;
	jnz	delbl$5		;

	lhld	BUFADR		; point to beginning of line

	lda	NOWPOS		; calculate number of chars to shift
	mov	C,A		;
	lda	CHRCNT		;
	sub	C		;
	mov	B,A		;

delbl$6:mvi	A,BS		; backspace a character
	call	putc		;
	mov	A,M		; was it a control character?
	cpi	' '		;
	mvi	A,BS		; get ready for it
	cc	putc		; backspace again if need be
	inx	H		; point to next character
	dcr	B		; bump down counter
	jnz	delbl$6		; merry-go-round time
	jmp	delbl$9		;

delbl$7:call	delc		; delete a character
	jnz	delbl$7		; keep going 'til done

delbl$9:lda	NOWPOS		; update current postion
	mov	C,A		;
	xra	A		;
	sta	NOWPOS		;
	lda	CHRCNT		; update character count
	sub	C		;
	sta	CHRCNT		;
	ret			;

delel:	lda	NOWPOS		; at end of line?
	mov	C,A		;
	lda	CHRCNT		;
	sub	C		;
	mov	B,A		; and save
	rz			; yep, then just return

	lhld	BUFADR		; get buffer address
	mvi	D,0		;
	mov	E,C		;
	dad	D		; point to character after new last character

	push	H		; save pointer
	push	B		; save counter

delel$1:mvi	A,' '		; blank a character
	call	putc		;
	mov	A,M		; was it a CTRL character?
	cpi	' '		;
	mvi	A,' '		;
	cc	putc		; blank another character if need be
	inx	H		; bump up pointer
	dcr	B		; bump down counter
	jnz	delel$1		; merry-go-round time

	pop	B		; restore pointer
	pop	H		; restore counter

delel$2:mvi	A,BS		; backspace a charactera
	call	putc		;
	mov	A,M		; was it a CTRL character?
	cpi	' '		;
	mvi	A,BS		;
	cc	putc		; backspace another character if need be
	inx	H		; bump up pointer
	dcr	B		; bump down counter
	jnz	delel$2		; merry-go-round time

delel$9:lda	NOWPOS		; update current postion
	sta	CHRCNT		; update character count
	ret			;

cleft:	lda	NOWPOS		; whera am i in this line?
	ora	A		; at beginning of line?
	rz			; yep

	dcr	A		; remove offset
	lhld	BUFADR		; point to the beginning of buffer
	mvi	D,0		; add current character count
	mov	E,A		;
	dad	D		;

	mvi	A,BS		; yep, move cursor left
	call	putc		;
	mov	A,M		; was it a CTRL character?
	cpi	' '		;
	mvi	A,BS		;
	cc	putc		; backspace again if need be

	lda	NOWPOS		; decrement current cursor postion
	dcr	A		;
	sta	NOWPOS		;
	ori	1		; reset ZERO
	ret			;

cright:	lda	NOWPOS		; at end of line?
	mov	C,A		;
	lda	CHRCNT		;
	sub	C		;
	rz			; yep

	lhld	BUFADR		; point to the beginning of buffer
	mvi	D,0		; add next character count
	mov	E,C		;
	dad	D		;

	mov	A,M		; get the character
	call	putctrl		; and put it

	lda	NOWPOS		; increment current cursor postion
	inr	A		;
	sta	NOWPOS		;
	ori	1		; reset ZERO
	ret			;

wleft:	call	cleft		; move left a character
	rz			; return if at beginning of line
	dcx	H		; point to previous character
	mov	A,M		; get the character
	call	isspace		; is it white space?
	jnz	wleft		; nope
	ret			; yep

wright:	call	cright		; move right a character
	rz			; return if at end of line
	mov	A,M		; get the character
	call	isspace		; is it white space?
	jnz	wright		; nope
	ret			; yep

pcmd:	push	D		; save registers
	push	B		;
	push	PSW		;
	lxi	D,-HISTSIZ	; get the buffer size
	dad	D		; point to previous history command
	push	H		; save it
	xchg			;
	lhld	BHBUF		; get pointer to first history buffer
	xchg			;
	mov	A,E		; subtract
	cma			;
	mov	E,A		;
	mov	A,D		;
	cma			;
	mov	D,A		;
	inx	D		;
	dad	D		;
	jc	pcmd$1		; okee
	pop	H		; nope, throw it away
	lhld	EHBUF		; else wrap around to last history buffer
	push	H		;
pcmd$1:	pop	H		; setup <HL> reg
	pop	PSW		; restore registers
	pop	B		;
	pop	D		;
	ret			;

ncmd:	push	B		; save registers
	push	B		;
	push	PSW		;
	lxi	D,HISTSIZ	; get the buffer size
	dad	D		; point to previous history command
	push	H		; save it
	xchg			; put in <DE>
	lhld	EHBUF		; get pointer to last history buffer
	mov	A,E		; subtract
	cma			;
	mov	E,A		;
	mov	A,D		;
	cma			;
	mov	D,A		;
	inx	D		;
	dad	D		;
	jc	ncmd$1		; okee
	pop	H		; nope, throw it away
	lhld	BHBUF		; else wrap around to first history buffer
	push	H		; and back on stack
ncmd$1:	pop	H		; setup <HL> registers
	pop	PSW		; restore registers
	pop	B		;
	pop	D		;
	ret			;

putnl:	push	PSW		; save status
	mvi	A,CR		; echo newline
	call	putc		;
	mvi	A,LF		;
	call	putc		;
	pop	PSW		; restore status
	ret			;

isspace:cpi	' '		; is white space?
	rz			;
	cpi	TAB		;
	rz			;
	cpi	NULL		;
	ret			;

strcpy:	push	H		; save registers
	push	D		;
	push	PSW		;
	mvi	C,0		; zero the character counter
strc$1:	mov	A,M		; get a character
	stax	D		; put a character
	cpi	EOS		; end of string?
	jz	strc$2		; yep
	inx	H		; nope, bump up from pointer
	inx	D		; bump up to pointer
	inr	C		; bump up moved character counter
	dcr	B		; bump down character counter
	jnz	strc$1		; merry-go-round time
strc$2:	pop	PSW		; restore registers
	pop	D		;
	pop	H		;
	ret			;

chknxt:	mvi	A,EOS		; assume no next command
	sta	NXTCMD		;
	lhld	BUFADR		; point to the command line
	mov	A,M		; get the first character
	cpi	CMDSEP1		; does it begin with a separator?
	rz			; yep, assume to be a comment
	cpi	CMDSEP2		; does it begin with a separator?
	rz			; yep, assume to be a comment
	mvi	C,0		; nope, zero the character counter
chkn$1:	mov	A,M		; get a character
	cpi	EOS		; end of string?
	rz			; yep
	cpi	CMDSEP1		; end of command?
	jz	chkn$2		; yep
	cpi	CMDSEP2		; end of command?
	jz	chkn$2		; yep
	inx	H		; nope, bump up pointer
	inr	C		; bump up moved character counter
	dcr	B		; bump down character counter
	jnz	chkn$1		; merry-go-round time
	ret			; command line all gone

chkn$2:	push	H		; yep, save the pointer
	dcx	H		; point to last character of first command
chkn$3:	mov	A,M		; now trim off trailing white space
	call	isspace		; is it white space?
	jnz	chkn$4		; nope
	dcx	H		; bump down pointer
	dcr	C		; bump down counter
	jnz	chkn$3		; get previous character

chkn$4:	inx	H		; make this new end of string
	mvi	M,EOS		;
	pop	H		; point back to CMDSEP character
	inx	H		; point to first character in next command
chkn$5:	mov	A,M		; now trim off beginning white space
	cpi	EOS		; end of string?
	rz			; yep, then there's no next command
	call	isspace		; is it white space?
	jnz	chkn$6		; nope, got first character of next command
	inx	H		; bump up pointer
	dcr	B		; bump down counter
	jnz	chkn$5		; merry-go-round time
	ret			; command line all gone

chkn$6:	xchg			; save pointer to next command
	lxi	H,NXTCMD	; point to next command
	xchg			; it's the destination
	lda	MAXCHR		; get maximum number of chars in command line
	mov	B,A		;
	push	B		; save first command character count
	call	strcpy		; and copy it
	pop	B		; restore first command character count
	ret			;

chkcom:	lhld	BUFADR		; point to the command line
	mov	A,M		; get the first character
	cpi	COMCHR1		; does it begin with a comment character?
	jz	chkc$1		; yep, assume to be a comment
	cpi	COMCHR2		; does it begin with a separator?
	rnz			; nope, not a comment line
chkc$1:	xra	A		; yep return a null command
	mov	M,A		; null out the buffer
	sta	CHRCNT		; null out the counter
	ret			;

	if	CPM3
rsxtest:ldax	D		; get the RSX function
	cpi	clrbuf		; clear the buffers?
	jz	clrbuff		; yep
	cpi	inirsx		; initialize the RSX?
	jnz	next		; nope

	lda	VIRGIN		; get the initialization flag
	ora	A		; virgin call?
	jz	initrsx		; yep, try and intialize
	mvi	A,0FFH		; nope, remove this RSX
	sta	remove		;
	inr	A		; reset virgin flag
	sta	VIRGIN		;
	lxi	D,unldmsg	; say bye, bye
	mvi	C,putline	;
	call	next		;
	xra	A		; set the zero
	ret			; and return

initrsx:mvi	A,0FFH		; set the remove flag
	sta	remove		;
	call	next		; another live history RSX?
	ora	A		;
	rz			; yep, then return
	sta	VIRGIN		; nope, show we're initialized
	xra	A		; clear the remove flag
	sta	remove		;
	lxi	D,loadmsg	;
	mvi	C,putline	;
	call	next		; Say that we are active

clrbuff:lxi	H,HIST1		; point to first history buffer
	shld	CHBUF		; it's now current
	mvi	A,IODEF		; get Insert/Overstrike flag default
	sta	INSOVR		; set the flag
	xra	A		; clear the number of active commands
	sta	ACTCMD		;
	ret			; return with zero set
	endif			; CPM3

history:xra	A		;
	sta	BACKUP		; clear the backup counter
	xchg			; <HL> = history buffer pointer
	mov	A,M		; store the buffer maximum length
	ora	A		; is it zero?
	jnz	nonzero		; nope
	mvi	A,1		; yep, it's now one
nonzero:sta	MAXCHR		;
	inx	H		; bump past maxchar
	inx	H		; bump past charcount
	shld	BUFADR		; store it
	lxi	H,HIST1		; use all history buffers
	shld	BHBUF		;
	lxi	H,HIST9		;
	shld	EHBUF		;
	mvi	A,9		;
	sta	MAXCMD		;
	lda	ACTCMD		; fudge # of active history commands?
	mov	C,A		;
	lda	MAXCMD		;
	mov	B,A		;
	sub	C		;
	jnc	actok		; nope
	mov	A,B		; yep
	sta	ACTCMD		;
actok:
	if	(NOT CPM3)
	call	chkex		; check for EX
	jz	nonext		; EX active
	endif			; (NOT CPM3)

	lda	NXTCMD		; is there a pending (next) command?
	cpi	EOS		;
	jz	nonext		; nope
	lhld	BUFADR		; it's the destination
	xchg			;
	lxi	H,NXTCMD	; move the pending command
	lda	MAXCHR		; get the maximum number of chars to moe
	mov	B,A		;
mvnext:	mov	A,M		; get a character
	stax	D		; put a character
	cpi	EOS		; end of string?
	jz	gotcmd		; yep
	call	putc		; nope, show it
	inx	H		; bump up from pointer
	inx	D		; bump up to pointer
	dcr	B		; bump down character counter
	jnz	mvnext		; merry-go-round time
	jmp	gotcmd		; fake it out
nonext:	lhld	CHBUF		; bump up previous/next history buffer pointer
	call	ncmd		;
	shld	PHBUF		;
	call	gets		; get a string
	call	chkcom		; check for a comment line
	lda	CHRCNT		; null command line?
	mov	C,A		; get a copy of line length just in case
	ora	A		;
	jz	skpchk		; yep, skip all this mess
	lhld	CHBUF		; nope, bump up current history buffer pointer
	call	ncmd		;
	shld	CHBUF		;
	xchg			; it's the destination
	lhld	BUFADR		; point to returned buffer
	lda	MAXCHR		; get the maximum number of chars to move
	mov	B,A		;
	call	strcpy		; move it
	lda	ACTCMD		; bump up active command counter
	inr	A		;
	sta	ACTCMD		;

gotcmd:	lda	MAXCHR		; get the maximum number of chars to move
	mov	B,A		;
	call	chknxt		; check for next command

skpchk:	lhld	BUFADR		; point to returned buffer
	dcx	H		; point to character count byte
	mov	M,C		; return trimmed character count

skpall:	mvi	A,CR		; put a carriage return
	call	putc		;
	ret			;

BEGDAT:
BHBUF:	dw	0		; beginning of history buffers
EHBUF:	dw	0		; end of history buffers
CHBUF:	dw	0		; current history buffer
PHBUF:	dw	0		; pointer to history buffers (for ^W/^Z)
BUFADR:	dw	0		; buffer address

	if	(NOT CPM3)
BBIOS:	dw	0		; BIOS image of the jmp BDOS vector
	endif			; (NOT CPM3)

MAXCHR:	db	0		; maximum number of chars in buffer
CHRCNT:	db	0		; number of chars entered
NOWPOS:	db	0		; current position in the line
LSTCHR:	db	0		; last character deleted buffer
TEMP:	db	0		; temporary storage
MAXCMD:	db	0		; maximum number of history commands
ACTCMD:	db	0		; active history commands
BACKUP:	db	0		; history backup counter
INSOVR:	db	IODEF		; 0 = insert mode, FF = overstrike mode

	if	CPM3
VIRGIN:	db	0		; initialization (virgin) flag

loadmsg:db	'History RSX loaded - 9 x 40 byte buffers.',13,10
	db	'! = List. !<n> = Recall #n. Wordstar editing sequences.',13,10
	db	'  ^UX = Del line left, ^KN = Del line rgt, ^Y = Del line.',13,10
	db	'Source = _New Dual SD Card and ZFDC S-100 Card Builds/',13,10
	db	'  New History RSXs for CPM3/History for CPM 2.2 and 3.',13,10,'$'

unldmsg:db	'History RSX unloaded','$'
	endif			; CPM3

	if	UNIX
logout:	db	'BYE',EOS	; translate UNIX EOF char to this string
	endif			; UNIX

NXTCMD:	db	EOS		; empty the next command buffer
	ds	HISTSIZ-1	; next command buffer
HIST1:	ds	HISTSIZ		; history buffers
HIST2:	ds	HISTSIZ		;
HIST3:	ds	HISTSIZ		;
HIST4:	ds	HISTSIZ		;
HIST5:	ds	HISTSIZ		;
HIST6:	ds	HISTSIZ		;
HIST7:	ds	HISTSIZ		;
HIST8:	ds	HISTSIZ		;
HIST9:	ds	HISTSIZ		;

stack	ds	42		; 20 level stack
ENDCOD:

	end

