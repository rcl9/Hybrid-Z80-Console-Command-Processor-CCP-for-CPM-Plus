# Named Directories in the CCP

The revised CCP3-RCL9 command processor implements ZCPR3-like named directories through the mechanism borrowed from the CCP+ v1.05 processor written by Jim Lopushinsky. 

The directory mapping is set by the *ROOT.DIR* text file.

I am providing a ZIP file copy of Jim's original CCP+ v1.05 system for archival reference purposes.

SETDIR.COM	- RSX that loads and serves the directory names to my CCP.
ROOT.DIR	- The text file which holds the directory name mappings

Note: Jim's original *SetDIR.mac* source program is broken when it comes to the deletion of the RSX module, based on my own Alias loader RSX development experience. I have made those correction in my revised *SetDIR.mac* code and provided a new runtime binary.

To load in the ROOT.DIR file, just execute "SetDIR.com" in your startup CP/M3 *Profile.sub* file. To unload the RSX, execute *SetDIR off*. 

A longer explanation is provided in the *History.man* help file.

| Key Sequence        |  Description |
|:----------- |:----------------------------------------- |
| !	| List the history buffers (up to 9) |
| !n	| Recall buffer # n |
| ^W | Recall previous history command |
| ^Z | Recall next history command |
| ^V | Toggle between insert and overstrike mode |
| ^H, Rub	| Delete previous character |
| ^G | Delete next character  |
| ^J | Delete previous word |
| ^UX | Delete to beginning of line |
| ^KN | Delete to end of line |
| ^Y | Delete entire line |
| ^S | Move cursor left one character |
| ^D | Move cursor right one characte |
| ^A | Move cursor left one word |
| ^F | Move cursor right one word  |
| ^B | Move cursor to beginning of line |
| ^T | Move cursor to end of line |
