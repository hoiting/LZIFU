		     On-Line Documentation Routines


The routines in this library were designed to help give the user more
access to on-line help.  One such is the routine DOC_MENU, which acts
like the standard DOC_LIBRARY routine.  However, this version, if called
without any parameters, allows interactive use through menus.
Documentation from any routine found in !PATH can be displayed with
DOC_MENU.

An even better routine for X-windows users is XDOC, which is a
widget-based routine browser.  Not only the documentation, but also the
source code itself, can be displayed.  On VAX/VMS computers, one must be
running WIDL to use SCANPATH.


The routine CHKARG will return the arguments of a named procedure.

The IDL procedure PURPOSE will produce a list of the program names and the
one-line entries after "PURPOSE" in the routine's documentation header.


The procedure CHECK_CONFLICT will check and report if there are any duplicate
file names in the IDL search path.

A random selection of the one-liners can be produced by TFTD which can also 
search for particular strings within the one-liner.


See CDS software note #22 for further details

----------------------------------------------------------------------------
As of 21-Apr-95 contents are:
 
 
 
Directory:  /sohos1/cds/soft/util/help/
 
CATEGORY          - List procedure/function names and categories.
CHECK_CONFLICT    - To check any conflict of IDL procedure/function names.
CHKARG            - Determine calling arguments of procedure or function.
DHELP             - Diagnostic HELP (activated only when DEBUG reaches DLEVEL)
DOC               - Obsolete -- use XDOC instead
DOC_MENU          - Extract documentation template of one or more procedures.
DPRINT            - Diagnostic PRINT (activated only when DEBUG reaches DLEVEL)
EXIST             - To See if variable Exists
FILL_CATEGORY     - Load save file with current categories
FILL_TFTD         - Load save file with current one-liners
GET_LIB()         - Place elements of !PATH into a string array..
GET_MOD()         - Extract list of procedure modules.
GET_PROC()        - Extract procedure from a library or directory.
GREP()            - Search for string through a string array (cf grep in Perl)
IDL_ROUTINE       - Create a string array of names of all IDL internal routines
PATH_EXPAND       - Expands VMS logical names in a search path.
PEEK              - Search and print IDL routine.
PURPOSE           - List procedure/function names and purposes.
RD_ASCII          - Read sequential ASCII file
SCANPATH          - Widget prog. for reading documentation within IDL procedures
SP_COMMON         - Contains common blocks used by SCANPATH.
STRIP_ARG         - Strip argument and keyword calls from an IDL program.
STRIP_DOC         - Strip internal documentation from an IDL program.
TEST_OPEN         - Test open a file to determine existence and/or write access
TFTD              - Search for a string in header documentation.
WHICH             - Search for and print file or routine in IDL !path
XDOC              - Front end to online documentation software.
