REPORT zabap_tutorial_007.

SELECTION-SCREEN BEGIN OF BLOCK bl1.
PARAMETERS: p_cbox1 AS CHECKBOX USER-COMMAND cm1,
            p_cbox2 AS CHECKBOX USER-COMMAND cm2,
            p_cbox3 AS CHECKBOX USER-COMMAND cm3.

SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2.
PARAMETERS: p_field1 TYPE string MODIF ID m1,
            p_field2 TYPE string MODIF ID m1,
            p_field  TYPE string MODIF ID m1.

SELECTION-SCREEN END OF BLOCK bl2.

SELECTION-SCREEN SKIP 2.

SELECTION-SCREEN PUSHBUTTON  2(10) but1 USER-COMMAND cli1.

INITIALIZATION.

  but1 = 'Cancel'.

  LOOP AT SCREEN.
    IF screen-group1 = 'M1'.
      screen-input = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.


AT SELECTION-SCREEN.

  CASE sy-ucomm.
    WHEN 'CM1'.
      p_cbox1 = abap_true.
      CLEAR: p_cbox2, p_cbox3.
      p_field1 = 'Selected'.
      CLEAR: p_field2,p_field.
    WHEN 'CM2'.
      p_cbox2 = abap_true.
      CLEAR: p_cbox1,p_cbox3.
      p_field2 = 'Selected !'.
      CLEAR: p_field,p_field1.
    WHEN 'CM3'.
      p_cbox3 = abap_true.
      CLEAR: p_cbox1,p_cbox2.
      p_field = 'Selected !'.
      CLEAR: p_field2,p_field1.
    WHEN 'CLI1'.
      LEAVE PROGRAM.
  ENDCASE.