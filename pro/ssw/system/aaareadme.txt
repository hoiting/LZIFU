			 System Independence Utilities
			 -----------------------------

Files in this directory provide utilities for performing functions which allow
for system independence.  There are three main subcategories within this
directory.


			  Operating System Utilities
			  --------------------------

Routines such as CONCAT_DIR and BREAK_FILE provide basic tools for making
programs which are operating system independent.


			      Unix Tape Utilities
			      -------------------

These procedures are intended to emulate in Unix the intrinsic tape routines
available in the VMS version of IDL.  The following routines are available:

	REWIND		Rewinds the tape
	SKIPF		Skips files or records
	TAPRD		Reads tape blocks
	TAPWRT		Writes tape blocks
	WEOF		Writes an End-of-file mark

In addition, there is the routine CHECK_TAPE_DRV which is an internal routine
used by the other routines.

Also, the routine DISMOUNT emulates the Unix command of that name.  Although
this is not a standard IDL function, it is available as separate LINKIMAGE
software for VMS.  The Unix equivalent closes the file unit open on the tape
drive, and optionally unloads the tape.  Errors can result if the tape is
unloaded manually instead of using DISMOUNT.

These procedures are intended to emulate their VMS equivalents as closely as
possible, so that software can be written which is portable between VMS and
Unix platforms.  Towards that end, it was decided to reference tape drives by
number as is done in VMS.

In VMS, the tape drive numbers 0-9 translate into names "MT0", "MT1", etc.
These can be associated with actual tape drives through the use of logical
names, e.g.

	$ DEFINE MT0 $1$MUA0

In Unix, with this software, the same thing is done, except that environment
variables are used in place of logical names, e.g.

	> setenv MT0 /dev/nrst0

As always in Unix, case is important.  Thus, if the above environment variable
is set, then when the software refers to tape 0, the tape drive /dev/nrst0 is
used.

This software requires IDL version 3.1 or later.


			   Changing Graphics Devices
			   -------------------------

These routines form the part of the SERTS subroutine library pertaining to
switching back and forth between graphics devices.  The philosophy behind these
routines is to be able to switch from one device to another, and to be in the
same state as when last using that device.  That way one could be working in
both Tektronix and PostScript modes, switching back and forth between them
making plots and overplots, and everything would work.  One could also be using
hardware fonts in one and software fonts in the other.

The routines used to switch between modes are:

	TEK		- Tektronix 4000 series terminal
	TEKxxxx		- Tektronix 4100 series (or above) terminal
	REGIS		- Regis terminal
	PS		- PostScript plot file
	QMS		- QMS plot file
	PCL		- HP LaserJet (PCL) plot file
	SUNVIEW		- SunView
	XWIN		- X-windows display or terminal
	WIN		- Microsoft Windows display

These routines will only work if used exclusively to change the plotting
device.  Internally they use the routine SETPLOT, but this would not normally
be used directly.

One can also place multiple plots on the same screen, and switch between them,
using the routine SETVIEW.  When switching between graphics devices, the view
must be defined separately for each graphics device, but the view will be
preserved when switching back and forth.  Using SETWINDOW instead of WSET will
also allow the view and the plotting parameters to be preserved when switching
between windows.

SETSCALE can be used to force the same scale to be used for both the X and Y
plot axes.  Currently, it is recommended that one calls SETSCALE to set the
scale, generates the plot, and then calls SETSCALE again to reset the system
variables to the values they had before the scale was set.  The routines
SETPLOT, SETWINDOW, and SETVIEW will automatically reset SETSCALE.  Even after
disabling the SETSCALE parameters, additional graphics functions such as OPLOT
will still be possible.

The routines devoted to PostScript, i.e. PS, PSCLOSE, and PSPLOT, are also
designed to work together.  Only these routines should be used to control the
format and state of the PostScript file.  If the optional QMS device driver is
present, then these comments also apply to QMS, QMCLOSE and QMPLOT.  The same
goes for the PCL routines.

These routines also use the special system variables !BCOLOR and !ASPECT.
These system variables are defined in the procedure DEVICELIB.  It is suggested
that the command DEVICELIB be placed in the user's IDL_STARTUP file.
