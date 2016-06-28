
function call_external_info, routine, shared, entry, $
       shared_ext=shared_ext, entry_prefix=entry_prefix, $
       load=load
;+
; Name: call_external_info
;
; Purpose: return system dependent info required by call_external
;
; Input Parameters:
; routine - optional - routine name to use in defining
; outputs 'shared' and 'entry'
;
; Output:
; function returns call_external status (1=supported, 0=not supported)
;
; Output Parameters:
; (only defined if routine supplied as first parameter)
; shared - shared name (1st call_external input parameter)
; entry - entry name (2nd call_external input parameter)
;
; Keyword Parameters:
; NOTE - if routine is supplied as first parameter, the outputs
; are the call_external names ( share_ext='ROUTINE'+[extension] )
; shared_ext - extension name of shared object (usually 'so')
; entry_prefix - prefix added to object ('_' on some systems)
;
; History:
; Circa mid 1998 - S.L.Freeland - originally for trace jpeg decomp->ssw
; 17-May-2004 - S.L.Freeland - Mac OS X / darwin ppc hooks
; 25-SEP-2006 - H.P. Warren - Mac OS X / darwin intel
; 18-SEP-2007 - M. Shimojo - 64bits Linux / x86_64
; 27-Jan-2008 - Zarro (ADNET) - added Win32_x86 support
;
; ----------- derived from c_only.pro in rsi external/sharelib ----------
entry_prefix=''
shared_ext='' ; init to null

case !version.arch of
           'i386': shared_ext = 'so' ;darwin/intel
'sparc': shared_ext = 'so' ;Sun or Solaris
'hp_pa': shared_ext = 'sl' ;HP
'hp9000s300': begin ;HP 9000s300 series
shared_ext = 'sl'
entry_prefix = '_'
            endcase
'ibmr2': shared_ext = 'a' ;IBM RS6000
         

           'alpha': shared_ext = 'so' ;Dec OSF1
'x86_64': shared_ext = 'so' ;x86_64 and 64bits Linux
'x86': begin
        if os_family() eq 'Windows' then shared_ext='dll' else $
         shared_ext = 'so' ;Data General Aviion
       end
           'mipseb' :begin ;SGI IRIX, or MIPS, or Ultix

;; Call_External is only supported on IRIX version 5.1.
;; Check that this is the operating system in use.
                if file_exist('/usr/lib/libC.so') and !version.os eq "IRIX" then $
shared_ext = 'so' else box_message,$
                        "Operating System version does not support CALL_EXTERNAL"
endcase
            'ppc': begin
                shared_ext='so'
            endcase
ELSE: box_message,"Sorry, User must add correct entry name"
endcase

if data_chk(routine,/scalar,/string) then begin
   shared=routine+'.'+shared_ext
   entry=entry_prefix+routine
endif

status= (shared_ext ne '')
return, status
end
