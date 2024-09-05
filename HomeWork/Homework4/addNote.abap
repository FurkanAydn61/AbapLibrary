FUNCTION zfkn_add_note.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_OGRID) TYPE  ZFKN_DE_OGRID
*"     REFERENCE(IV_COURSE) TYPE  ZFKN_DE_DERS
*"     REFERENCE(IV_NOTE1) TYPE  ZFKN_DE_OGRS001
*"     REFERENCE(IV_NOTE2) TYPE  ZFKN_DE_OGRS002
*"----------------------------------------------------------------------
  DATA: gs_course TYPE zfkn_lessons.

  IF iv_ogrid IS INITIAL OR iv_course IS INITIAL.
    MESSAGE TEXT-004 TYPE 'E'.
  ELSE.
    DATA: is_found TYPE abap_bool.

    is_found = abap_false.
    SELECT SINGLE * FROM zfkn_lessons INTO gs_course
      WHERE ogr_id = iv_ogrid AND les_name = iv_course.
    IF sy-subrc = 0.
      is_found = abap_true.
    ENDIF.
    IF is_found = abap_true.
    IF iv_note1 IS INITIAL OR iv_note2 IS INITIAL.
      MESSAGE TEXT-008 TYPE 'E'.
    ELSEIF iv_note1 > 100 OR iv_note2 > 100.
      MESSAGE TEXT-007 TYPE 'E'.
    ELSE.
      IF iv_note1 IS NOT INITIAL.
        CLEAR: gs_course.
        gs_course-note1 = iv_note1.
        UPDATE zfkn_lessons SET note1 = gs_course-note1
        WHERE ogr_id = iv_ogrid AND les_name = iv_course.
      ENDIF.
      IF iv_note2 IS NOT INITIAL.
        CLEAR: gs_course.
        gs_course-note2 = iv_note2.
        UPDATE zfkn_lessons SET note2 = gs_course-note2
        WHERE ogr_id = iv_ogrid AND les_name = iv_course.
      ENDIF.
      MESSAGE TEXT-010 TYPE 'I'.
    ENDIF.
    ELSE.
      MESSAGE TEXT-009 TYPE 'E'.
  ENDIF.
  ENDIF.

ENDFUNCTION.