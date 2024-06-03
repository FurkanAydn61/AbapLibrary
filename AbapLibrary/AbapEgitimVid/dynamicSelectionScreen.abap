REPORT zabap_tutorial_004.

TABLES:sscrfields.

SELECTION-SCREEN BEGIN OF BLOCK sel_screen_1 WITH FRAME TITLE TEXT-000.
PARAMETERS: p_matnr LIKE mara-matnr MODIF ID m1,
            p_ersda LIKE mara-ersda MODIF ID m1 DEFAULT sy-datum,
            p_ernam LIKE mara-ernam MODIF ID m1.

SELECTION-SCREEN END OF BLOCK sel_screen_1.

SELECTION-SCREEN BEGIN OF BLOCK sel_screen_2 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_matkl LIKE mara-matkl MODIF ID m2,
            p_mtart LIKE mara-mtart MODIF ID m2,
            p_aenam LIKE mara-aenam MODIF ID m2.

SELECTION-SCREEN END OF BLOCK sel_screen_2.


SELECTION-SCREEN BEGIN OF BLOCK change_screen .
PARAMETERS: p_change AS CHECKBOX DEFAULT space USER-COMMAND m1.
SELECTION-SCREEN END OF BLOCK change_screen.


SELECTION-SCREEN BEGIN OF SCREEN  2000 AS WINDOW.
SELECTION-SCREEN BEGIN OF BLOCK sel_screen_3 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_matkl2 LIKE mara-matkl MODIF ID m2,
            p_mtart2 LIKE mara-mtart MODIF ID m2,
            p_aenam2 LIKE mara-aenam MODIF ID m2.

SELECTION-SCREEN END OF BLOCK sel_screen_3.

SELECTION-SCREEN END OF SCREEN 2000.
SELECTION-SCREEN FUNCTION KEY 1.

CONSTANTS: c_selected TYPE c VALUE '1',
           c_canceled TYPE c VALUE '0'.

INITIALIZATION.

  sscrfields-functxt_01 = 'Report'.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'M1'.
        IF p_change IS  INITIAL.
          screen-invisible = c_canceled.
          screen-active    = c_selected.
          screen-required  = 2.
          MODIFY SCREEN.
          CLEAR : p_matkl,p_mtart ,p_aenam.
        ELSE.
          screen-invisible = c_selected .
          screen-active    = c_canceled .
          screen-required  = 2 .
          MODIFY SCREEN.
          CLEAR : p_ernam,p_ersda ,p_matnr.
        ENDIF.
      WHEN 'M2'.
        IF p_change  IS  INITIAL.
          screen-invisible = c_selected.
          screen-active    = c_canceled .
          MODIFY SCREEN.
        ELSE.
          screen-invisible = c_canceled.
          screen-active    = c_selected.
          screen-required  = 2.
          MODIFY SCREEN.
        ENDIF.
      ENDCASE.
    ENDLOOP.

AT SELECTION-SCREEN.

  IF sscrfields-ucomm = 'FC01'..
    CALL SELECTION-SCREEN 2000.
  ENDIF.

START-OF-SELECTION.
  WRITE:'Hello'.