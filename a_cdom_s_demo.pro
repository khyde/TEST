; $ID:	A_CDOM_S_DEMO.PRO,	2014-12-18	$
;########################################################################################################
 PRO A_CDOM_S_DEMO, DIR_OUT=DIR_OUT
;+
; NAME:
;

;		THIS PROGRAM DEMONSTRATES VARIOUS SPECTRAL MODELS OF CDOM ABSORPTION SPECTRA

; MODIFICATION HISTORY:
;		WRITTEN JAN 31, 2005 BY J.O'REILLY, 28 TARZWELL DRIVE, NMFS, NOAA 02882 (JAY.O'REILLY@NOAA.GOV)
;		MAY 4,2013,JOR FORMATTING; ADDED PSTART,PDONE,PFILE;DO_FRISK_KM_CODE
;		JUN 20,2014,JOR, IF NONE(DIR_OUT) THEN DIR_OUT = !S.TEMP
;########################################################################################################
;-
;****************************
ROUTINE_NAME  = 'A_CDOM_S_DEMO'
;***************************
; SKIP
PSTART
IF NONE(DIR_OUT) THEN DIR_OUT = !S.TEMP
;	===> CONSTANTS
	BACKGROUND_COLOR= 34
	WLS = FINDGEN(351) + 350


;SSSSS     SWITCHES     SSSSS

	DO_SPECTRAL_S_MODELS  = 1
	DO_ESTIMATE_A_CDOM	  = 1
	DO_FRISK_KM_CODE      = 1



;	********************************************
	IF DO_SPECTRAL_S_MODELS GE 1 THEN BEGIN
;	********************************************
		A_CDOM_412 = 0.20

	 	S = [0.010, 0.016, 0.023]

;		===> DEFAULT OUTPUT DIRECTORY

;		===> POSTSCRIPT FILE NAME
		PSFILE = DIR_OUT + 'SPECTRAL_S_MODELS.PS' & PFILE,PSFILE,/W

;		===> COLORS, THICK, AND LINESTYLES
	  COLOR_ACDOM_TWARDOWSKI 	= 27
	  THICK_ACDOM_TWARDOWSKI 	= 7
	  LINESTYLE_ACDOM_TWARDOWSKI 	= 0
		LABELS_ACDOM= ['(TWARDOWSKI ET AL. 2004)']

	  COLORS_S = [8,10,21]
	  LABELS_S = 'S = '+ NUM2STR(S,FORMAT='(F10.3)')
	  THICK_S  = [7,7,7]
	  LINESTYLE_S = [0,0,0]
	  !P.CHARTHICK=3


		LABELS = [LABELS_ACDOM, LABELS_S]
		COLORS = [COLOR_ACDOM_TWARDOWSKI,COLORS_S]
		THICKS = [THICK_ACDOM_TWARDOWSKI,THICK_S]
	  LINESTYLE = [LINESTYLE_ACDOM_TWARDOWSKI,LINESTYLE_S]

;		===> SET UP THE POSTSCRIPT DEVICE
	 	PSPRINT,FILENAME=PSFILE,/FULL,/COLOR,/TIMES
	 	!P.MULTI = [0,1,2]
	 	PAL_36
	 	FONT_TIMES


;		****************
;		***** PLOT *****
;		****************
		PLOT, WLS, [0.0,0.6], XTITLE= 'WAVELENGTH '+UNITS('LAM'),/XSTYLE,YTITLE= 'CDOM '+UNITS('ABS'),/NODATA,$
	  XCHARSIZE=1.25,YCHARSIZE=1.25,XTHICK=4, YTHICK=2,YMINOR=1
	  BACKGROUND,/PLOT,COLOR=BACKGROUND_COLOR
	  GRIDS,COLOR=35,THICK=4,FRAME=4


;		===> COMPUTE AND PLOT CDOM ABSORPTION VIA TWARDOWSKI
		ACDOM_TWARDOWSKI 	= A_CDOM_TWARDOWSKI(A_CDOM_412, WLS=WLS)
		OPLOT, WLS, ACDOM_TWARDOWSKI, THICK = THICK_ACDOM_TWARDOWSKI, COLOR=COLOR_ACDOM_TWARDOWSKI, LINESTYLE=LINESTYLE_ACDOM_TWARDOWSKI
		OPLOT, WLS, ACDOM_TWARDOWSKI, THICK = 1, COLOR=0, LINESTYLE=1
		EQUATION = A_CDOM_TWARDOWSKI(/EQUATION)
		LABELS(0) = EQUATION + '  ' + LABELS(0)

    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
		FOR _S = 0,N_ELEMENTS(S)-1 DO BEGIN
			ACDOM = A_CDOM_412*EXP(-S(_S)*(WLS-412))
			OPLOT, WLS, ACDOM,COLOR=COLORS_S(_S),THICK=THICK_S(_S)
			OPLOT, WLS, ACDOM,COLOR=0,THICK=0,LINESTYLE=0
		ENDFOR;FOR _S = 0,N_ELEMENTS(S)-1 DO BEGIN
		;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

		EQUATION = 'A!DCDOM(!ML!X)!N = A!DCDOM(412)!N EXP(-S (!ML!X-412))!X!N'
	  LABELS(2) = EQUATION + '  ' + LABELS(2)

		LEGEND,/TOP,/RIGHT,/DATA,LABELS,COLORS=COLORS, PSYM=PSYM, LINESTYLE= LINESTYLE,$
	    				PSPACING=2,SPACING=LEG_SPACING,MARGIN=LEG_MARGIN,THICK=THICKS,$
	    				 /BOX,/VERTICAL,/CLEAR,BACKGROUND_COLOR=BACKGROUND_COLOR,CHARSIZE=1.25


		LINESTYLE(0) = 1
		LEGEND,/TOP,/RIGHT,/DATA,LABELS,COLORS=0, PSYM=PSYM, LINESTYLE= LINESTYLE,$
	    				 PSPACING=2,SPACING=LEG_SPACING,MARGIN=LEG_MARGIN,THICK=1,$
	    				  /BOX,/VERTICAL, CHARSIZE=1.25


		FRAME,/PLOT,COLOR=0,THICK=4
		PSPRINT



; IMAGE_TRIM,PSFILE,DPI=600,/OVERWRITE
	ENDIF;IF DO_SPECTRAL_S_MODELS GE 1 THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||


;	*******************************************
	IF DO_ESTIMATE_A_CDOM GE 1 THEN BEGIN
;	*******************************************
;		MIDSHELF VALUE FROM 8 YEAR MEAN
		A_CDOM_355 = 0.40
		S_WL       = 355 ; NM

;		===> A.MANNINO PER. COMM USE S OF ABOUT 0.02 OR PERHAPS 0.023
	 	S = [0.021]

;		===> DEFAULT OUTPUT DIRECTORY
		IF N_ELEMENTS(DIR_OUT) NE 1 THEN DIR_OUT = 'D:\IDL\PLOTS\' ELSE DIR_OUT = DIR_OUT

;		===> POSTSCRIPT FILE NAME
		PSFILE = DIR_OUT + '_A_CDOM_SPECTRUM.PS' & PFILE,PSFILE,/W

;		===> COLORS, THICK, AND LINESTYLES
	  COLOR_ACDOM_TWARDOWSKI 	= 27
	  THICK_ACDOM_TWARDOWSKI 	= 7
	  LINESTYLE_ACDOM_TWARDOWSKI 	= 0
		LABELS_ACDOM= ['(TWARDOWSKI ET AL. 2004)']
		COLORS_S = [21]
	  LABELS_S = 'S = '+ NUM2STR(S,FORMAT='(F10.3)')
	  THICK_S  = [7 ]
	  LINESTYLE_S = [0 ]
	  !P.CHARTHICK=3
;		===> SET UP THE POSTSCRIPT DEVICE
	 	PSPRINT,FILENAME=PSFILE,/FULL,/COLOR,/TIMES
	 	!P.MULTI = [0,1,2]
	 	PAL_36
	 	FONT_TIMES

;		****************
;		***** PLOT *****
;		****************
		PLOT, WLS, [0.0,0.4], XTITLE= 'WAVELENGTH '+UNITS('LAM'),/XSTYLE,YTITLE= 'CDOM '+UNITS('ABS'),/NODATA,$
	  XCHARSIZE=1.25,YCHARSIZE=1.25,XTHICK=4, YTHICK=2,YMINOR=1
	  BACKGROUND,/PLOT,COLOR=BACKGROUND_COLOR
	  GRIDS,COLOR=35,THICK=4,FRAME=4

    LABELS = ''

    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
		FOR _S = 0,N_ELEMENTS(S)-1 DO BEGIN
			ACDOM = A_CDOM_355 *EXP(-S(_S)*(WLS-S_WL))
			OPLOT, WLS, ACDOM,COLOR=COLORS_S(_S),THICK=THICK_S(_S)
			OPLOT, WLS, ACDOM,COLOR=0,THICK=0,LINESTYLE=0
  		EQUATION = 'A!DCDOM(!ML!X)!N = A!DCDOM('+STRTRIM(S_WL,2)+')!N EXP(-S (!ML!X-'+STRTRIM(S_WL,2)+'))!X!N'
  	  LABELS  = EQUATION + '!C!CS='+NUM2STR(S(_S),TRIM=2)  
  		COLORS = [COLORS_S]
  		THICKS = [2]
  	  LINESTYLE = [0]  
  	  LEG_MARGIN = 2
  		LEGEND,/TOP,/RIGHT,/DATA,LABELS,COLORS=COLORS, PSYM=PSYM, LINESTYLE= LINESTYLE,$
  	    				PSPACING=2,SPACING=LEG_SPACING,MARGIN=LEG_MARGIN,THICK=THICKS,$
  	    				 /BOX,/VERTICAL,/CLEAR,BACKGROUND_COLOR=BACKGROUND_COLOR,CHARSIZE=1.25  
  		LINESTYLE(0) = 1
  		LEGEND,/TOP,/RIGHT,/DATA,LABELS,COLORS=0, PSYM=PSYM, LINESTYLE= LINESTYLE,$
  	    				 PSPACING=2,SPACING=LEG_SPACING,MARGIN=LEG_MARGIN,THICK=1,$
  	    				  /BOX,/VERTICAL, CHARSIZE=1.25  
  		FRAME,/PLOT,COLOR=0,THICK=4
  		PSPRINT
  		OK=WHERE(WLS EQ 500)
  		PRINT,'ABSORPTION BY CDOM AT 500NM   ' + STRTRIM(ACDOM(OK),2) + UNITS('A_CDOM',/NO_NAME)  		
  		;;IMAGE_TRIM,PSFILE
   ENDFOR;FOR _S = 0,N_ELEMENTS(S)-1 DO BEGIN
   ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
   
	ENDIF;IF DO_ESTIMATE_A_CDOM GE 1 THEN BEGIN
	;||||||||||||||||||||||||||||||||||||||||||


;*****************************	
IF DO_FRISK_KM_CODE GE 1 THEN BEGIN
;*****************************
; FROM PP_SAT_MAIN:
  TITLE = "IF STRUCT.ALG EQ 'KM' THEN ACDOM_SAT(OK_ALL) = ACDOM_SAT(OK_ALL)*EXP(-0.021*(443-300))"
  A_CDOM_443 = INTERVAL([.01,.5],.01)
  A_CDOM_300 =  A_CDOM_443*EXP(-0.021*(443-300))	
  PSFILE = DIR_OUT + 'DO_FRISK_KM_CODE.PS' & PFILE,PSFILE,/W
  PNGFILE = DIR_OUT + 'DO_FRISK_KM_CODE.PNG' & PFILE,PNGFILE,/W
  PAL_36,R,G,B
;  PSPRINT,FILENAME=PSFILE,/FULL,/COLOR,/TIMES
  SET_PMULTI
  FONT_TIMES
  ZWIN,[1000,1000]
  ERASE,35
  XTITLE = 'A_CDOM_443' + UNITS('A_CDOM',/NO_NAME)
  YTITLE = 'A_CDOM_300'+ UNITS('A_CDOM',/NO_NAME)
  ;TITLE= 'HELLO'
  PLOT,A_CDOM_443,A_CDOM_300,XTITLE = XTITLE,YTITLE = YTITLE,COLOR = 0,THICK = 5,CHARSIZE=2.5,/NODATA,TITLE='',/NOERASE
  OPLOT,A_CDOM_443,A_CDOM_300,COLOR = 26,THICK = 7
  LABELS  = "A_CDOM_300 = !C A_CDOM_443*EXP(-0.021*(443-300))"  
  COLORS = [26]
  THICKS = [3]
  LINESTYLE = 1 
  LEG_MARGIN = 1
  LEG_CHARSIZE = 5
  LEG_SPACING = 4
  PSPACING=5
  BOX = 0
  BACKGROUND_COLOR=255 
 ; LEGEND,/TOP,/RIGHT,/DATA,LABELS,COLORS=COLORS, PSYM=PSYM, LINESTYLE= LINESTYLE,$
 ;         PSPACING=PSPACING,SPACING=LEG_SPACING,MARGIN=LEG_MARGIN,THICK=THICKS,$
 ;         BOX= BOX,/VERTICAL,/CLEAR,BACKGROUND_COLOR=BACKGROUND_COLOR,CHARSIZE=LEG_CHARSIZE 
 ;         LINESTYLE = 0

  FRAME,/PLOT,COLOR=0,THICK=4
  ONE2ONE,COLOR = 0,LINESTYLE = 1
  XYOUTS,0.25,0.97,TITLE,/NORMAL,CHARSIZE = 1.75,ALIGN = 0.25,COLOR = 21
;  PSPRINT
IM = TVRD()
ZWIN
WRITE_PNG,PNGFILE,IM,R,G,B
ENDIF;IF DO_FRISK_KM_CODE GE 1 THEN BEGIN
;|||||||||||||||||||||||||||||||||||

	
	
PDONE
END; #####################  END OF ROUTINE ################################



