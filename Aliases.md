# Command Aliases Mechanism

What I really wanted in my revised CP/M3 CCP was a command alias mechanism similar to that offered by the ZCPR3 and Z3Plus systems. That lead me to writing a fairly complex and entirely new custom command alias mechanism which is both fast and has a minimal memory footprint.

The aliases are defined in a plain text file named "Aliases.cmd" which are held and "served" by the Alias RSX memory-resident module.

The aliases are loaded into memory at startup (such as in the *Profile.sub* CP/M3 start-up script) using *AliasLdr.com* program which itself then loads the Aliases.cmd text file. What this program does is to parse the Aliases.cmd file and place it into a memory efficient data array held and served by the corresponding RSX module (which resides in high memory below the BDOS). In CP/M 3 the CCP does not reside in memory at all times (as it does with CP/M 2.2) but rather is loaded at 0x100 if and when user interaction is desired. As such, the new CCP3-RCL9 program implements an Alias command translator which calls into this RSX to obtain a pointer to the pre-parsed Alias command list then does command line substitution as needed. 

An example aliases.cmd file:

; Aliases command file
'DIR',     'D23',     '%1'
'DIR2U',     'XDIR',     '%2 /U'
'DIR2G',     'XDIR' ,    '%2 /G'
'DIR3',     'l2-45',     ' *:%2'
'DIRS',     '3DIR',     '%1'
'DEL',     'ERA',     '%1'
'TYPE',     'QL',     '%1'

The Distribution directory includes a copy of my own Aliases.cmd file. 

Based on my personal experience I chose to implement two different command line option replacement mechanisms, %1 and %2.

- %1 = This uses a blind 1:1 copy of the option list provided on the CCP command line.

- %2 = It is similar to %1 but it will insert the wildcard expression "*.*" if no arguments are provided with the entered command. Some CP/M programs only accept arguments at the end of the command line and hence need a wildcard expression to be provided (such as with the DIR2U example in the list above).

Note: my command alias mechanism only works with single commands entered on a command line and not with multiple commands delineated with a "!" separator. 

The filename can be provided in the following manner, as examples: <filename>, <filename.com>, <A0:filename> or <0A:filename.com>

If the user typed a filename extension and the alias command has no period of its own then the extension is carried over (DIR2U.COM -> XDIR.com). If the alias command already has an extension then that one is used.
