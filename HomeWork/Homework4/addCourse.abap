FUNCTION zfkn_add_course.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_OGRID) TYPE  ZFKN_DE_OGRID
*"     REFERENCE(IV_COURSE) TYPE  ZFKN_DE_DERS
*"----------------------------------------------------------------------
  DATA: gs_course TYPE zfkn_lessons.

  IF iv_ogrid IS INITIAL OR iv_course IS INITIAL.
    MESSAGE TEXT-004 TYPE 'E'.
  ELSE.
    DATA: is_found TYPE abap_bool.

    is_found = abap_false.
    SELECT SINGLE * FROM zfkn_lessons INTO gs_course WHERE
     ogr_id = iv_ogrid
     AND les_name = iv_course.

    IF sy-subrc = 0.
      is_found = abap_true.
    ENDIF.

    IF is_found = abap_true.
      MESSAGE TEXT-006 TYPE 'E'.
    ELSE.
      CLEAR:gs_course.
      gs_course-ogr_id = iv_ogrid.
      gs_course-les_name = iv_course.
      INSERT INTO zfkn_lessons VALUES gs_course.
      MESSAGE TEXT-005 TYPE 'I'.
    ENDIF.

  ENDIF.


ENDFUNCTION.