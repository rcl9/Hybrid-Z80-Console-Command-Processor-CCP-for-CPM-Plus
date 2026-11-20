; Alias command file - Load into memory (in its RSX module) via "AliasLdr.com"

; List this file which you are reading. 
; From the CCP you can also use "LstAlias" and "AliasNam"
'ALIASES', 'TYPE', 'aliases.cmd'

'DIR', 'D23', '%1'

;  Show directories from all active user areas
'DIRU', 'D23', '%2 /U'

; Long directory listing (sorted) incl size of each file
'DIRS', '3DIR', '%1'
; 3dir in traditional sorted filename-name only listing mode
'DIRS2', '3DIR', '[COLS] %1'

; X-Dir III v2 by Richard Conn. "xdir //" for options
; XDIR can be very slow if there are a lot of files across many user areas
'DIR2', 'XDIR', '%1'
;'xdir /OG = Group by extension/filename
'DIR2G', 'XDIR' ,'%2 /G'
; xdir /U = Show all user areas
'DIR2U', 'XDIR', '%2 /U'

; A complex directory lister by Richard Collett
; Show help via "l2-45 ::"
; Note: CPM3 needs double spaces after the filename
'DIR3', 'l2-45', ' %1'
; List across all user areas
'DIR3U', 'l2-45', ' *:%2'

; UNIX "disk free" for logged drives
'DF', '3SHOW', '%1'

; Erase and delete without confirmation
;	'ERA', 'TY4ERA', '%1'
;	'DEL', 'TY4ERA', '%1'
'DEL', 'ERA', '%1'

; The "go to" rename program. Refer to .doc file.
'REN', 'RENAME37', '%1'

; Z80 Turbo Sweep file manipulation program v1.4 (Aug 1987).
'SW', 'ZSW', '%1'

; List size of TPA
'TPA', 'TPASIZE', '%1'

; Recommended as the best over-all file viewer.
; It combines some of the best features of the popular CP/M, ZCPR3, and MS-DOS
; utilities LUX, LT, VLU, and LIST62 with unique features of its own, including
; hex display mode and a unique, fast access, file reference by number system.
'TYPE', 'QL', '%1'

; An extended disk status program. Refer to the help file for functionality.
'STAT', 'SSTAT', '%1'
