; Alias command file - Load into memory (in its RSX module) via "AliasLdr.com"

; List this file which you are reading. 
; From the CCP you can also use "LstAlias" and "AliasNam"
'ALIASES', 'TYPE', 'aliases.cmd'

; The primary "go-to" directory lister. /B = list system files. 
'DIR', 'D23', '%1 /B'

;  Show directories from all active user areas and system files
'DIRU', 'D23', '%2 /U /B'

; Long directory listing (sorted) incl size of each file + system files
'DIRS', '3DIR', '%1'

; X-Dir III v2 by Richard Conn. "xdir //" for options
'DIR2', 'XDIR', '%1 /AA'
;'xdir /OG = Group by extension/filename
'DIR2G', 'XDIR' ,'%2 /G /AA'
; xdir /U = Show all user areas
'DIR2U', 'XDIR', '%2 /U /AA'

; A complex directory lister by Richard Collett
; Show help via "l2-45 ::"
; Note: CPM3 needs double spaces after the filename
'DIR3', 'l2-45', ' %2 A'
; List across all user areas
'DIR3U', 'l2-45', ' *:%2 A'

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
