; $ID:	A_CDOM_MANNINO_DEMO.PRO,	2014-12-18	$

 PRO A_CDOM_MANNINO_DEMO, Rrs490=Rrs490,Rrs555=Rrs555, 	$; SeaWiFS
										 Rrs488=Rrs488,Rrs551=Rrs551, 			$; MODIS
										 LWN=LWN, $
 										 ERROR=error
;+
; NAME:
; 	A_CDOM_MANNINO_DEMO
;
; PURPOSE:
;		This Program is a DEMO for the Mannino A_CDOM355 algorithm
;
; CATEGORY:
;		ALGORITHM
;
; CALLING SEQUENCE:		 ;
;		A_CDOM_MANNINO_DEMO
;
; INPUTS:
;		NONE
;

; OUTPUTS:
;		A postscript plot
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)
;
; MODIFICATION HISTORY:
;			Written March 19, 2007 by A. Mannino & J.O'Reilly (Jay.O'Reilly@NOAA.GOV)
;
;-
;	****************************************************************************************************
	ROUTINE_NAME='A_CDOM_MANNINO_DEMO'



	RRS490 = INTERVAL([0.01,30],0.01)
	RRS555 = REPLICATE(1.0,N_ELEMENTS(RRS490))


	A_CDOM_355 = A_CDOM_MANNINO(Rrs490=Rrs490,Rrs555=Rrs555,/LWN)

	PSPRINT,/HALF,/COLOR, FILENAME=ROUTINE_NAME+'.PS'
	PAL_36
	PLOT, RRS490/RRS555, A_CDOM_355, color = 21,/YSTYLE
	PSPRINT


  filesA=FILELIST('D:\WORK\SAVE\!S*-EC-*NLW_490*.SAVE')
  filesB=FILELIST('D:\WORK\SAVE\!S*-EC-*NLW_555*.SAVE')
  FILES = [FILESA,FILESB]
  FA=FILE_ALL(FILESA)
  FB=FILE_ALL(FILESB)
  FN=FILE_ALL(FILES)

  SETS = WHERE_SETS((FA.PERIOD+FA.MAP), (FB.PERIOD+FB.MAP))
 ; SPREAD,SETS
	OK=WHERE(SETS.N EQ 2,COUNT)
	IF COUNT EQ 0 THEN STOP
	SETS=SETS(OK)
	FOR NTH=0,N_ELEMENTS(SETS)-1 DO BEGIN
		ASET = SETS(NTH)
		SUBS=WHERE_SETS_SUBS(ASET)
		_FILES=FILES(SUBS)
		LIST, _FILES
		NLW_490 = STRUCT_SD_READ(_FILES(0),STRUCT=STRUCT_NLW490)
		NLW_555 = STRUCT_SD_READ(_FILES(1),STRUCT=STRUCT_NLW555)
		A_CDOM_355 = A_CDOM_MANNINO(Rrs490=NLW_490,Rrs555=NLW_555,/LWN)
ok=where(nlw_490 gt 0 and nlw_490 ne missings(nlw_490) and nlw_555 gt 0 and nlw_555 ne missings(nlw_555))
		R=NLW_490 & R(*)=MISSINGS(R)
		R(OK) = nlw_490(OK)/nlw_555(OK)
		bimage=SD_SCALES(R,PROD='RATIO_10',/DATA2BIN)
		PAL_SW3 & SLIDEW, BIMAGE
    FN=FILE_ALL(_FILES(0))
    FULLNAME=REPLACE(_FILES(0),'NLW_490','RATIO_10')

	STRUCT_SD_WRITE,    FULLNAME,           IMAGE=R, 		$
												PROD='RATIO_10', 				  ASTAT=ASTAT, 	AMATH=AMATH

	STRUCT_SD_2PNG,FULLNAME,/ADD_COLORBAR,/ADDDATE,/OVERWRITE,COLORBAR_TITLE='Lwn490:Lwn555'

	ENDFOR

STOP
PRINT,MINMAX(A_CDOM_355,/FIN)
END; #####################  End of Routine ################################



