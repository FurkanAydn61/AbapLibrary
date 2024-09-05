FUNCTION zfkn_ogr_save.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_OGRID) TYPE  ZFKN_DE_OGRID
*"     VALUE(IV_OGRAD) TYPE  ZFKN_DE_OGRAD
*"     VALUE(IV_OGRSYD) TYPE  ZFKN_DE_OGRSYD
*"----------------------------------------------------------------------
  DATA: string TYPE char100.
  DATA: it_split TYPE TABLE OF char100 WITH HEADER LINE.
  DATA: gs_ogr TYPE zfkn_student.
  IF iv_ogrid IS INITIAL OR iv_ograd IS INITIAL OR iv_ogrsyd IS INITIAL.
    MESSAGE TEXT-001 TYPE 'E'.
  ELSE.
    SELECT SINGLE * FROM ZFKN_STUDENT INTO gs_ogr WHERE ogr_id = iv_ogrid.
      IF sy-subrc <> 0.
      CLEAR: gs_ogr.
      MOVE iv_ograd TO string.
      SPLIT string AT space INTO TABLE  it_split.
      CLEAR: string.
      LOOP AT it_split.
      TRANSLATE it_split TO LOWER CASE.
      TRANSLATE it_split+0(1) TO UPPER CASE.
      CONCATENATE string it_split INTO string SEPARATED BY space.
      ENDLOOP.
      MOVE string+1 TO iv_ograd.
      TRANSLATE iv_ogrsyd+0 TO UPPER CASE.
      gs_ogr-ogr_id = iv_ogrid.
      gs_ogr-ogr_ad = iv_ograd.
      gs_ogr-ogr_syd = iv_ogrsyd.
      INSERT INTO zfkn_student VALUES gs_ogr.
      MESSAGE TEXT-002 TYPE 'I'.
      ELSE.
        MESSAGE TEXT-003 TYPE 'I'.
      ENDIF.
  ENDIF.






ENDFUNCTION.