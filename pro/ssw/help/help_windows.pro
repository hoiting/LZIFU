;+
;   Name:    help_windows
;
;   Purpose: Print help text for starting SolarSoft under Windows
;
;   Input Parameters:
;   Calling Examples:
;               help_windows
;   Calls:
;   Keyword Parameters:
;   Restrictions:
;   History:
;           12-May-2000  rdb  Created
;-
;

pro  help_windows

text = rd_tfile(concat_dir('$SSW/gen/idl/help/','windows_howto.txt'))
prstr,text

end
