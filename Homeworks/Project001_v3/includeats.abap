*&---------------------------------------------------------------------*
*& Include          ZABAP_EGT_SEKIL_CL_ATS
*&---------------------------------------------------------------------*

INITIALIZATION.

LOOP AT SCREEN.
  IF screen-group1 = 'M1'.
    screen-active = 0.
  ENDIF.
  MODIFY SCREEN.
  ENDLOOP.

AT SELECTION-SCREEN OUTPUT.

LOOP AT SCREEN.
 CASE 'X'.
 	WHEN p_cbox1.
    IF screen-name CS 'P_NUM2' OR screen-name CS 'P_NUM3'.
        screen-active = 0.
    ENDIF.
    MODIFY SCREEN.
 	WHEN p_cbox2.
    IF screen-name CS 'P_NUM3'.
       screen-active = 0.
    ENDIF.
    MODIFY SCREEN.
 	WHEN p_cbox3.
    IF p_rad1 EQ abap_true AND screen-name CS 'P_NUM2'.
       screen-active = 0.
    ENDIF.
    MODIFY SCREEN.
 ENDCASE.
 ENDLOOP.


  AT SELECTION-SCREEN.

  CASE sy-ucomm.
    WHEN 'CM1'.
       p_cbox1 = abap_true.
      CLEAR: p_cbox2, p_cbox3.
    WHEN 'CM2'.
       p_cbox2 = abap_true.
      CLEAR: p_cbox1, p_cbox3.

    WHEN 'CM3'.
      p_cbox3 = abap_true.
      CLEAR: p_cbox2, p_cbox1.
  ENDCASE.