*&---------------------------------------------------------------------*
*& Include          ZFURKAN_STUDENT_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form FRM_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_init .
  button1 = 'Öğrenci Ekle'.
  button2 = 'Ders Ekle'.
  button3 = 'Not Kaydet'.

  IF mtable IS INITIAL.
    CLEAR: p_liste1, p_liste3.
  ENDIF.
  PERFORM frm_dropdown.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_ATS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_ats .
  PERFORM ogr_ekle.
  PERFORM ders_ekle.
  PERFORM save_not.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form OGR_EKLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ogr_ekle .
  CASE sy-ucomm.
    WHEN 'BUT1'.
      CALL FUNCTION 'ZFKN_OGR_SAVE'
        EXPORTING
          iv_ogrid  = p_ogrid
          iv_ograd  = p_ograd
          iv_ogrsyd = p_ogrsyd.

  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DERS_EKLE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ders_ekle .
  CASE sy-ucomm.
    WHEN 'BUT2'.
      CALL FUNCTION 'ZFKN_ADD_COURSE'
        EXPORTING
          iv_ogrid  = p_liste1
          iv_course = p_liste2.

  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_NOT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_not.
  CASE sy-ucomm.
    WHEN 'BUT3'.

      CALL FUNCTION 'ZFKN_ADD_NOTE'
        EXPORTING
          iv_ogrid  = p_liste3
          iv_course = p_liste4
          iv_note1  = p_not1
          iv_note2  = p_not2.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_ATS_OUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_ats_out .
  LOOP AT SCREEN.
    CASE 'X'.
      WHEN p_rad1.
        IF screen-group1 EQ 'M2'OR screen-group1 EQ 'B2' OR screen-group1 EQ 'B3'
          OR screen-name CS 'P_LISTE1' OR screen-name CS 'P_LISTE2'
          OR screen-name CS 'P_LISTE3' OR screen-name CS 'P_LISTE4'.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
      WHEN p_rad2.
        IF screen-group1 EQ 'M1' OR screen-group1 EQ 'M2' OR screen-group1 EQ 'B3'
          OR screen-name CS 'P_LISTE3' OR screen-name CS 'P_LISTE4'
          OR screen-group1 CS 'B1'.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
      WHEN p_rad3.
        IF screen-group1 EQ 'M1' OR screen-group1 EQ 'B1' OR screen-group1 EQ 'B2'
          OR screen-name CS 'P_LISTE1' OR screen-name CS 'P_LISTE2'.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_DROPDOWN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_dropdown .

  SELECT ogr_id FROM zfkn_student INTO TABLE v_search.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'P_LISTE1'
      values = v_search.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'P_LISTE3'
      values = v_search.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data.
SELECT * FROM zfkn_student INTO CORRESPONDING FIELDS OF TABLE mtable.

WRITE: / '**************************************************************************'.
WRITE: / 'Öğrenci Bilgileri'.
WRITE: / '--------------------------------------------------------------------------'.
WRITE: / 'Öğrenci Id', 20 'Öğrenci Adı', 40 'Öğrenci Soyadı'.
WRITE: / '--------------------------------------------------------------------------'.

LOOP AT mtable INTO gs_student.

  WRITE: / gs_student-ogr_id, 20 gs_student-ogr_ad, 40 gs_student-ogr_syd.

  SELECT * FROM zfkn_lessons INTO CORRESPONDING FIELDS OF TABLE gt_lesson WHERE ogr_id = gs_student-ogr_id.

  WRITE: / '--------------------------------------------------------------------------'.
  WRITE: / 'Ders Id', 20 'Ders Tanımı', 40 'Note1', 60 'Note2', 80 'Durum'.
  WRITE: / '------------------------------------------------------------------------------------------'.

  LOOP AT gt_lesson INTO gs_lesson.
    DATA: lv_text   TYPE string,
          lv_text2 TYPE string,
          lv_result TYPE f.

    " Dersin başarı durumunu hesapla
    lv_result = ( gs_lesson-note1 * 40 + gs_lesson-note2 * 60 ) / 100.

    IF lv_result >= 65 .
      lv_text = 'Başarılı'.
    ELSE.
      lv_text = 'Başarısız'.
    ENDIF.

    " Dersin durumunu kaydet
    gs_lesson-durum = lv_text.

    IF gs_lesson-les_name EQ 01.
      lv_text2 = 'Türkçe'.
    ELSEIF gs_lesson-les_name EQ 02.
      lv_text2 = 'Matematik'.
    ELSEIF gs_lesson-les_name EQ 03.
      lv_text2 = 'Tarih'.
    ELSEIF gs_lesson-les_name EQ 04.
      lv_text2 = 'Bilgisayara Giriş'.
    ENDIF.

    gs_lesson-d_tanim = lv_text2.
    " Ekrana yazdır
    WRITE: / gs_lesson-les_name, 20 lv_text2, 40 gs_lesson-note1, 60 gs_lesson-note2, 80 lv_text.
    SKIP.
  ENDLOOP.
  SKIP.
  WRITE: '******************************************************************************'.
ENDLOOP.

ENDFORM.