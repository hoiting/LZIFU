$ VERIFY = 'F$VERIFY(0)'
$!
$!  FIND_ALL_DIR is a VMS command file that supports the IDL routine of the
$!  same name.  It takes two parameters.
$!
$!		P1	Character string denoting where the command file, so
$!			that this routine can call itself.
$!
$!		P2	The next directory to search, one level lower.  If not
$!			passed, then the current directory is used.
$!
$	FILE_SPEC = "*.DIR;0"
$	OLD_DEFAULT = F$LOGICAL("SYS$DISK") + F$DIRECTORY()
$	NEW_DEFAULT = OLD_DEFAULT
$	IF P2 .NES. "" THEN NEW_DEFAULT = P2
$	SET DEFAULT 'NEW_DEFAULT'
$	WRITE SYS$OUTPUT NEW_DEFAULT
$!
$ LOOP:
$	ENTRY = F$SEARCH(FILE_SPEC)
$	IF ENTRY .EQS. "" THEN GOTO DONE
$	OUTLINE = F$PARSE(ENTRY,,,"NAME")
$	NEXT_DIR = NEW_DEFAULT - "]" + "." + OUTLINE + "]"
$	@'P1' 'P1' 'NEXT_DIR' NEXT
$	GOTO LOOP
$!
$ DONE:
$	SET DEFAULT 'OLD_DEFAULT'
$	VERIFY = F$VERIFY(VERIFY)
