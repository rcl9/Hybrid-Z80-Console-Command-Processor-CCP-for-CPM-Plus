# Command History Recall Mechanisms

Rather than write a new CP/M 3 command history recall mechanism myself I am giving you the choice to consider using either of these two:

- Hist+ (Hist.com) by Jim Lopushinsky (2048 byte memory usage), July 25 1986, for CP/M 3.

- HISTORY (Hist30.com) by  Stuart Rose (2816 byte memory usage), Nov 6 1986, for CP/M 2.2 and 3.

*Hist30.com* has many more keyboard editing functions compared to *Hist.com* but I've personally opted for the latter due to its overall simplicity and slightly smaller memory footprint. I had actually used the *Hist30* program as my history recall program from 1986 to 1990+ on my CP/M 3 based Cypher Z80/68k computer. 

I have modified and recompiled the *Hist.com* source code to use a different set of command sequences and for a smaller 192 byte memory buffer. Likewise, I have recompiled *Hist30.com* with smaller command buffers (40 bytes * 9 buffers) to save on TPA memory.

## Keyboard Mapping Sequences for *Hist.com*

| Key Sequence | Description  |
|:------------ |:------------ |
| Control-L    | Recall list  |
| Control-Q    | Move up      |
| Control-Z    | Move down    |
| Control-X    | Delete left  |
| Control-K    | Delete right |

## Keyboard Mapping Sequences for *Hist30.com*

A longer explanation is provided in the *History.man* help file.

| Key Sequence | Description                               |
|:------------ |:----------------------------------------- |
| !            | List the history buffers (up to 9)        |
| !n           | Recall buffer # n                         |
| ^W           | Recall previous history command           |
| ^Z           | Recall next history command               |
| ^V           | Toggle between insert and overstrike mode |
| ^H, Rub      | Delete previous character                 |
| ^G           | Delete next character                     |
| ^J           | Delete previous word                      |
| ^UX          | Delete to beginning of line               |
| ^KN          | Delete to end of line                     |
| ^Y           | Delete entire line                        |
| ^S           | Move cursor left one character            |
| ^D           | Move cursor right one character           |
| ^A           | Move cursor left one word                 |
| ^F           | Move cursor right one word                |
| ^B           | Move cursor to beginning of line          |
| ^T           | Move cursor to end of line                |
