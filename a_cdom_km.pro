; $Id:	a_cdom_km.pro,	March 19 2010	$

 FUNCTION  A_CDOM_KM , LWN443=LWN443,LWN510=LWN510, NOTES=NOTES, RRS=RRS, COEFFS=coeffs
;+
; NAME:
;       A_CDOM_KM  'Colored Dissolved Organic Matter, Kahru & Mitchell'
;
; PURPOSE:
;       Compute  Absorbance of CDOM at 300nm for SeaWiFS
;
;       Reference:
;       Kahru and Mitchel, 2001
;                       Seasonal and nonseasonal variability of satellite-derived chlorophyll and colored dissolved
;                       organic matter concentration in the California Current
;                       JGR Vol. 106(C2),2517:2529.
; CATEGORY:
;       Empirical ACDOM(300) Algorithm
;
; CALLING SEQUENCE:
;       ACDOM_300 = A_CDOM_KM(LWN443,LWN510)
;
; INPUTS:
;       LWN for 443 nm,   510nm,
;
;
; KEYWORD PARAMETERS:
;       NOTES :  Optional output from program.  Notes contains a text string which describes the
;                        equation which may be used (plotted) by the calling program.
;
;
; OTHER PROGRAMS USED:
;      MISSINGS.PRO     : Checks for missing data code
;
; OUTPUTS:
;       Acdom_KM concentration (m-1)
;
; SIDE EFFECTS:
;       Negative calculations are changed to infinite in the output array.
;
; RESTRICTIONS:
;       Input data must be positive and finite
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Program Written by:  J.E.O'Reilly, Jan 31, 2002
;       May 20, 2008, T.Ducas change resulting array from double to float
;-


; **********************************************
; **********************************************
; Algorithm Name
  notes =  'ACDOM_KM'

; m.kahru march 2005
; cc_cdom300_443_510 =[-0.393,-0.872]
; cc_cdom300_443_520 =[-0.411,-0.703]


  IF KEYWORD_SET(RRS) THEN STOP ; MUST ADD CODE TO CONVERT THE RRS DATA TO LWN

; =================>
; Equation Coefficients:
  a = [-0.393,-0.872]

  IF KEYWORD_SET(COEFFS) THEN RETURN, A

; ===================>
; Check for 2 input arrays
  IF N_PARAMS() LT 2 THEN MESSAGE,'ERROR: MUST INPUT LWN443,Rrs510 arrays'

; initialize ACDOM array
   ACDOM = DOUBLE(LWN443)
   ACDOM(*) = MISSINGS(ACDOM)

; ===================>
; Check for missing data
  OK = WHERE(LWN443 NE MISSINGS(LWN443) AND $
             LWN510 NE MISSINGS(LWN510) AND $

             LWN443 GT 0d              AND $
             LWN510 GT 0d              AND $

             FINITE(LWN443)             AND $

             FINITE(LWN510)        , count)



	IF COUNT LT 1 THEN BEGIN
  	PRINT,'NO VALID INPUT DATA, returning MISSINGS '
  	RETURN, FLOAT(ACDOM)
  ENDIF




    _LWN443 = DOUBLE(LWN443)
    _LWN510 = DOUBLE(LWN510)



; ====================>
; R = Log base 10 of Band Ratio

  R = ALOG10(_LWN443(OK)/ _LWN510(OK) )

; ====================>
; Calculate CDOM concentration

  ACDOM(OK) = 10.0^(a(0) + a(1)*R)

; ==================>
; Now replace Any Negative Values With Missing Code
  bad = WHERE(ACDOM  LE 0.0 , count_bad)
  IF count_bad GE 1 THEN ACDOM(bad)  = MISSINGS(ACDOM)

; ==================>
; Return chlorophyll array to calling program
  RETURN,FLOAT(ACDOM)

  END ; end of program
; *********************************************************
; *********************************************************

