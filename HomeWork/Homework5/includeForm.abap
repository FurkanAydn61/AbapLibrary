*&---------------------------------------------------------------------*
*& Include          ZFKN_OGR_HW_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
CLASS lcl_user_command DEFINITION.
  PUBLIC SECTION.
    METHODS: handle_user_command
      IMPORTING
        iv_command  TYPE sy-ucomm
        iv_selfield TYPE slis_selfield.
ENDCLASS.

CLASS lcl_user_command IMPLEMENTATION.
  METHOD handle_user_command.
    DATA: lt_fields TYPE STANDARD TABLE OF sval,
          ls_fields TYPE sval,
          lv_ret    TYPE string,
          lv_exist  TYPE abap_bool,
          lv_rows   TYPE lvc_s_roid,
          lv_index  TYPE i.

    CASE iv_command.
      WHEN '&ADD'.
        DATA: ls_std TYPE zfkn_student.

        CLEAR lt_fields.
        " Öğrenci ID alanı
        ls_fields-tabname = 'ZFKN_STUDENT'.
        ls_fields-fieldname = 'OGR_ID'.
        APPEND ls_fields TO lt_fields.

        " Öğrenci Adı alanı
        CLEAR ls_fields.
        ls_fields-tabname = 'ZFKN_STUDENT'.
        ls_fields-fieldname = 'OGR_AD'.
        APPEND ls_fields TO lt_fields.

        " Öğrenci Soyadı alanı
        CLEAR ls_fields.
        ls_fields-tabname = 'ZFKN_STUDENT'.
        ls_fields-fieldname = 'OGR_SYD'.
        APPEND ls_fields TO lt_fields.


        CALL FUNCTION 'POPUP_GET_VALUES'
          EXPORTING
            popup_title     = 'Öğrenci Ekleme'
            start_column    = '5'
            start_row       = '5'
          IMPORTING
            returncode      = lv_ret
          TABLES
            fields          = lt_fields
          EXCEPTIONS
            error_in_fields = 1
            OTHERS          = 2.

        IF lv_ret IS INITIAL.
          LOOP AT lt_fields INTO DATA(ls_stdadd).
            CASE ls_stdadd-fieldname.
              WHEN 'OGR_ID'.
                ls_std-ogr_id = ls_stdadd-value.

              WHEN 'OGR_AD'.
                ls_std-ogr_ad = ls_stdadd-value.

              WHEN 'OGR_SYD'.
                ls_std-ogr_syd = ls_stdadd-value.
            ENDCASE.
          ENDLOOP.
          " Öğrenci kaydetme fonksiyonunu çağırma

            CALL FUNCTION 'ZFKN_OGR_SAVE'
            EXPORTING
              iv_ogrid  = ls_std-ogr_id
              iv_ograd  = ls_std-ogr_ad
              iv_ogrsyd = ls_std-ogr_syd.

          APPEND ls_std TO gt_list.

          CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
            IMPORTING
              e_grid = go_grid.

          IF go_grid IS BOUND.
            CALL METHOD go_grid->refresh_table_display
              EXPORTING
                is_stable = gs_stbl.
          ENDIF.
        ENDIF.

      WHEN '&OGRDEL'.

        DATA: lv_answer TYPE c LENGTH 1.

        READ TABLE gt_list INDEX iv_selfield-tabindex INTO DATA(ls_row).
        IF sy-subrc EQ 0.
          CALL FUNCTION 'ENQUEUE_EZ_STUDENT'
            EXPORTING
              mode_zfkn_student = 'E'
              mandt             = sy-mandt
              ogr_id            = ls_row-ogr_id
              x_ogr_id          = ' '
              _scope            = '2'
              _wait             = ' '
              _collect          = ' '
            EXCEPTIONS
              foreign_lock      = 1
              system_failure    = 2
              OTHERS            = 3.
          IF sy-subrc EQ 1.
            MESSAGE TEXT-005 TYPE 'I' DISPLAY LIKE 'E'.
          ELSE.

            gs_list-ogr_id = ls_row-ogr_id.

            CLEAR: ls_fields.
            ls_fields-tabname = 'ZFKN_STUDENT'.
            ls_fields-fieldname = 'OGR_ID'.
            ls_fields-value = gs_list-ogr_id.
            APPEND ls_fields TO lt_fields.
*
            CALL FUNCTION 'POPUP_GET_VALUES'
              EXPORTING
                popup_title     = 'Öğrenci Silme İşlemi'
                start_column    = '5'
                start_row       = '5'
              IMPORTING
                returncode      = lv_ret
              TABLES
                fields          = lt_fields
              EXCEPTIONS
                error_in_fields = 1
                OTHERS          = 2.
            IF lv_ret IS INITIAL.
              READ TABLE lt_fields WITH KEY tabname = 'ZFKN_STUDENT' fieldname = 'OGR_ID' TRANSPORTING NO FIELDS.
              IF sy-subrc EQ 0.
                WRITE: ls_fields-value.
              ENDIF.

              LOOP AT lt_fields INTO DATA(lv_del).
                IF lv_del-fieldname EQ 'OGR_ID'.
                  ls_row-ogr_id = lv_del-value.
                ENDIF.
              ENDLOOP.

              CALL FUNCTION 'POPUP_TO_CONFIRM'
                EXPORTING
                  titlebar       = 'İşlem gerçekleştiriliyor'
                  text_question  = 'İşlemi tamamlamak istediğinize emin misiniz?'
                  text_button_1  = 'Evet'
                  icon_button_1  = 'ICON_CHECKED'
                  text_button_2  = 'Hayır'
                  icon_button_2  = 'ICON_CANCEL'
                  default_button = '1'
                  popup_type     = 'ICON_MESSAGE_QUESTION'
                IMPORTING
                  answer         = lv_answer.
              IF lv_answer EQ 1.

                CALL FUNCTION 'ZFKN_DEL_STUDENT'
                  EXPORTING
                    iv_stdid = ls_row-ogr_id.
                IF sy-subrc EQ 0.
*Öğrenci başarıyla silindiyse tabloyu güncelle
                  DELETE gt_list WHERE ogr_id = ls_row-ogr_id.
                  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
                    IMPORTING
                      e_grid = go_grid.

                  IF go_grid IS BOUND.
                    CALL METHOD go_grid->refresh_table_display
                      EXPORTING
                        is_stable = gs_stbl.                " With Stable Rows/Columns
                  ENDIF.
                ELSE.
                  MESSAGE 'Silme işlemi başarısız' TYPE 'E'.
                ENDIF.
              ELSEIF lv_answer EQ 2.
                MESSAGE 'Silme işlemi iptal edildi' TYPE 'I' DISPLAY LIKE 'E'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      WHEN '&UPD'.
        DATA: lv_cevap TYPE c LENGTH 1.
        READ TABLE gt_list INDEX iv_selfield-tabindex INTO DATA(lss_row).
        IF sy-subrc EQ 0.
          CALL FUNCTION 'ENQUEUE_EZ_STUDENT'
            EXPORTING
              mode_zfkn_student = 'E'
              mandt             = sy-mandt
              ogr_id            = lss_row-ogr_id
              x_ogr_id          = ' '
              _scope            = '2'
              _wait             = ' '
              _collect          = ' '
            EXCEPTIONS
              foreign_lock      = 1
              system_failure    = 2
              OTHERS            = 3.
          IF sy-subrc EQ 1.
            MESSAGE TEXT-005 TYPE 'I' DISPLAY LIKE 'E'.
          ELSE.
            gs_list-ogr_id = lss_row-ogr_id.
            gs_list-ogr_ad = lss_row-ogr_ad.
            gs_list-ogr_syd = lss_row-ogr_syd.
            CLEAR: ls_fields.
            ls_fields-tabname = 'ZFKN_STUDENT'.
            ls_fields-fieldname = 'OGR_ID'.
            ls_fields-value = gs_list-ogr_id.
            APPEND ls_fields TO lt_fields.

            CLEAR: ls_fields.
            ls_fields-tabname = 'ZFKN_STUDENT'.
            ls_fields-fieldname = 'OGR_AD'.
            ls_fields-value = gs_list-ogr_ad.
            APPEND ls_fields TO lt_fields.

            CLEAR: ls_fields.
            ls_fields-tabname = 'ZFKN_STUDENT'.
            ls_fields-fieldname = 'OGR_SYD'.
            ls_fields-value = gs_list-ogr_syd.
            APPEND ls_fields TO lt_fields.

            CALL FUNCTION 'POPUP_GET_VALUES'
              EXPORTING
                popup_title     = 'Öğrenci Güncelle'
                start_column    = '5'
                start_row       = '5'
              IMPORTING
                returncode      = lv_ret
              TABLES
                fields          = lt_fields
              EXCEPTIONS
                error_in_fields = 1
                OTHERS          = 2.
            IF lv_ret IS INITIAL.
              READ TABLE lt_fields WITH KEY tabname = 'ZFKN_STUDENT' fieldname = 'OGR_ID' TRANSPORTING NO FIELDS.
              IF sy-subrc EQ 0.
                WRITE: ls_fields-value.
              ENDIF.

              READ TABLE lt_fields WITH KEY tabname = 'ZFKN_STUDENT' fieldname = 'OGR_AD' TRANSPORTING NO FIELDS.
              IF sy-subrc EQ 0.
                WRITE: ls_fields-value.
              ENDIF.

              READ TABLE lt_fields WITH KEY tabname = 'ZFKN_STUDENT' fieldname = 'OGR_SYD' TRANSPORTING NO FIELDS.
              IF sy-subrc EQ 0.
                WRITE: ls_fields-value.
              ENDIF.

              LOOP AT lt_fields INTO DATA(ls_field).
                IF ls_field-fieldname = 'OGR_AD'.
                  lss_row-ogr_ad = ls_field-value.
                ELSEIF ls_field-fieldname = 'OGR_SYD'.
                  lss_row-ogr_syd = ls_field-value.
                ELSEIF ls_field-fieldname = 'OGR_ID'.
                  lss_row-ogr_id = ls_field-value.
                ENDIF.
              ENDLOOP.

              CALL FUNCTION 'POPUP_TO_CONFIRM'
                EXPORTING
                  titlebar       = 'İşlem Gerçekleştiriliyor !'
                  text_question  = 'Öğrenci güncelleme işlemi tamamlansın mı?'
                  text_button_1  = 'Güncelle'
                  icon_button_1  = 'ICON_CHECKED'
                  text_button_2  = 'Hayır'
                  icon_button_2  = 'ICON_CANCEL'
                  default_button = '1'
                  popup_type     = 'ICON_MESSAGE_QUESTION'
                IMPORTING
                  answer         = lv_cevap.
              IF lv_cevap EQ 1.

                CALL FUNCTION 'ZFKN_UPDATE_STD'
                  EXPORTING
                    iv_stdid = lss_row-ogr_id
                    iv_name  = lss_row-ogr_ad
                    iv_sname = lss_row-ogr_syd.

                MODIFY gt_list FROM lss_row INDEX iv_selfield-tabindex.

                CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
                  IMPORTING
                    e_grid = go_grid.

                IF go_grid IS BOUND.
                  CALL METHOD go_grid->refresh_table_display.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN '&LESUPD'.
        DATA: lv_cvp TYPE c LENGTH 1.

        READ TABLE gt_list INDEX iv_selfield-tabindex INTO DATA(lv_row).
        IF sy-subrc EQ 0.
          CALL FUNCTION 'ENQUEUE_EZ_STUDENT'
            EXPORTING
              mode_zfkn_student = 'E'
              mandt             = sy-mandt
              ogr_id            = lv_row-ogr_id
              x_ogr_id          = ' '
              _scope            = '2'
              _wait             = ' '
              _collect          = ' '
            EXCEPTIONS
              foreign_lock      = 1
              system_failure    = 2
              OTHERS            = 3.
          IF sy-subrc EQ 1.
            MESSAGE TEXT-005 TYPE 'I' DISPLAY LIKE 'E'.
          ELSE.

            gs_list-ogr_id = lv_row-ogr_id.
            gs_list-les_name = lv_row-les_name.

            CLEAR: ls_fields.
            ls_fields-tabname = 'ZFKN_LESSONS'.
            ls_fields-fieldname = 'OGR_ID'.
            ls_fields-value = gs_list-ogr_id.
            APPEND ls_fields TO lt_fields.

            CLEAR: ls_fields.
            ls_fields-tabname = 'ZFKN_LESSONS'.
            ls_fields-fieldname = 'LES_NAME'.
            ls_fields-value = gs_list-les_name.
            APPEND ls_fields TO lt_fields.

            CLEAR: ls_fields.
            ls_fields-tabname = 'ZFKN_LESSONS'.
            ls_fields-fieldname = 'NOTE1'.
            APPEND ls_fields TO lt_fields.

            CLEAR: ls_fields.
            ls_fields-tabname = 'ZFKN_LESSONS'.
            ls_fields-fieldname = 'NOTE2'.
            APPEND ls_fields TO lt_fields.

            CALL FUNCTION 'POPUP_GET_VALUES'
              EXPORTING
                popup_title     = 'Ders Notu Güncelle'
                start_column    = '5'
                start_row       = '5'
              IMPORTING
                returncode      = lv_ret
              TABLES
                fields          = lt_fields
              EXCEPTIONS
                error_in_fields = 1
                OTHERS          = 2.
            IF lv_ret IS INITIAL.
              READ TABLE lt_fields WITH KEY tabname = 'ZFKN_LESSONS' fieldname = 'OGR_ID' TRANSPORTING NO FIELDS.
              IF sy-subrc EQ 0.
                WRITE: ls_fields-value.
              ENDIF.

              READ TABLE lt_fields WITH KEY tabname = 'ZFKN_LESSONS' fieldname = 'LES_NAME' TRANSPORTING NO FIELDS.
              IF sy-subrc EQ 0.
                WRITE: ls_fields-value.

                LOOP AT lt_fields INTO DATA(lv_addnote).
                  CASE lv_addnote-fieldname.
                    WHEN 'OGR_ID'.
                      lv_row-ogr_id = lv_addnote-value.
                    WHEN 'LES_NAME'.
                      lv_row-les_name = lv_addnote-value.
                    WHEN 'NOTE1'.
                      lv_row-note1 = lv_addnote-value.
                    WHEN 'NOTE2'.
                      lv_row-note2 = lv_addnote-value.
                  ENDCASE.
                ENDLOOP.
              ENDIF.

              CALL FUNCTION 'POPUP_TO_CONFIRM'
                EXPORTING
                  titlebar       = 'İşlem Gerçekleştirliyor ?'
                  text_question  = 'Ders Notu güncelleme işlemi gerçekleştirilsin mi?'
                  text_button_1  = 'Evet'(001)
                  icon_button_1  = 'ICON_CHECKED'
                  text_button_2  = 'Hayır'(002)
                  icon_button_2  = 'ICON_CANCEL'
                  default_button = '1'
                  popup_type     = 'ICON_MESSAGE_QUESTION'
                IMPORTING
                  answer         = lv_cvp.
              IF lv_cvp EQ 1.

                CALL FUNCTION 'ZFKN_ADD_NOTE'
                  EXPORTING
                    iv_ogrid  = lv_row-ogr_id
                    iv_course = lv_row-les_name
                    iv_note1  = lv_row-note1
                    iv_note2  = lv_row-note2.

                MODIFY gt_list FROM lv_row INDEX iv_selfield-tabindex.

                CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
                  IMPORTING
                    e_grid = go_grid.

                IF go_grid IS BOUND.
                  CALL METHOD go_grid->refresh_table_display.
                ENDIF.

              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      WHEN '&LESADD'.
        READ TABLE gt_list INDEX  iv_selfield-tabindex INTO DATA(lvv_row).
        IF sy-subrc EQ 0.
          gs_list-ogr_id = lvv_row-ogr_id.
          CLEAR: ls_fields.
          ls_fields-tabname = 'ZFKN_LESSONS'.
          ls_fields-fieldname = 'OGR_ID'.
          ls_fields-value = gs_list-ogr_id.
          APPEND ls_fields TO lt_fields.

          CLEAR:ls_fields.

          ls_fields-tabname = 'ZFKN_LESSONS'.
          ls_fields-fieldname = 'LES_NAME'.
          APPEND ls_fields TO lt_fields.

          CALL FUNCTION 'POPUP_GET_VALUES'
            EXPORTING
              popup_title     = 'Ders Ekle Pop Up Ekranı'
              start_column    = '5'
              start_row       = '5'
            IMPORTING
              returncode      = lv_ret
            TABLES
              fields          = lt_fields
            EXCEPTIONS
              error_in_fields = 1
              OTHERS          = 2.
          IF lv_ret IS INITIAL.

            DATA:lv_ans TYPE c LENGTH 1.

            READ TABLE lt_fields WITH KEY tabname = 'ZFKN_LESSONS' fieldname = 'OGR_ID' TRANSPORTING NO FIELDS.
            IF sy-subrc EQ 0.
              WRITE: ls_fields-value.
            ENDIF.

            LOOP AT lt_fields INTO DATA(lv_course).
              CASE lv_course-fieldname.
                WHEN 'OGR_ID'.
                  lvv_row-ogr_id = lv_course-value.
                WHEN 'LES_NAME'.
                  lvv_row-les_name = lv_course-value.
              ENDCASE.
            ENDLOOP.
            CALL FUNCTION 'POPUP_TO_CONFIRM'
              EXPORTING
                titlebar       = 'İşlem Gerçekleştirliyor ?'
                text_question  = 'Ders ekleme işlemi gerçekleştirilsin mi?'
                text_button_1  = 'Evet'(001)
                icon_button_1  = 'ICON_CHECKED'
                text_button_2  = 'Hayır'(002)
                icon_button_2  = 'ICON_CANCEL'
                default_button = '1'
                popup_type     = 'ICON_MESSAGE_QUESTION'
              IMPORTING
                answer         = lv_ans.
            IF lv_ans EQ 1.

              CALL FUNCTION 'ZFKN_ADD_COURSE'
                EXPORTING
                  iv_ogrid  = lvv_row-ogr_id
                  iv_course = lvv_row-les_name.

              MODIFY gt_list FROM lvv_row INDEX iv_selfield-tabindex.

              CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
                IMPORTING
                  e_grid = go_grid.

              IF go_grid IS BOUND.
                CALL METHOD go_grid->refresh_table_display
                  EXPORTING
                    is_stable = gs_stbl. "Radiobuttonlar yer değiştiriyorda fakat hep 1.satırın verilerini gösteriyordu"
              ENDIF.
            ELSEIF lv_ans EQ 2.
              MESSAGE 'Ekleme işlemi iptal edildi' TYPE 'I' DISPLAY LIKE 'E'.
            ENDIF.

          ENDIF.
        ENDIF.
      WHEN '&IC1'."Radiobutton kullanım için kullandım"
        gs_stbl-col = 'X'.
        gs_stbl-row = 'X'.
        READ TABLE gt_list INDEX iv_selfield-tabindex INTO DATA(ls_selected_row).
        IF sy-subrc = 0.
          gs_list-ogr_id = ls_selected_row-ogr_id.
          gs_list-ogr_ad = ls_selected_row-ogr_ad.
          gs_list-ogr_syd = ls_selected_row-ogr_syd.
          gs_list-les_name = ls_selected_row-les_name.
          gs_list-note1 = ls_selected_row-note1.
          gs_list-note2 = ls_selected_row-note2.
          LOOP AT gt_list INTO DATA(s_row).
            IF s_row-ogr_id = ls_selected_row-ogr_id. " Burada ogr_id'ye göre karşılaştırma yapıyoruz
              s_row-radio = icon_radiobutton.
            ELSE.
              s_row-radio = icon_wd_radio_button_empty.
            ENDIF.
            MODIFY gt_list FROM s_row.
          ENDLOOP.

          CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
            IMPORTING
              e_grid = go_grid.

          IF go_grid IS BOUND.
            CALL METHOD go_grid->refresh_table_display
              EXPORTING
                is_stable = gs_stbl.                  " With Stable Rows/Columns
          ENDIF.

          " Seçilen satırın verilerini gs_list'e atama
          gs_list = ls_selected_row.
        ENDIF.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
FORM user_command USING p_ucomm LIKE sy-ucomm
                        ps_selfield TYPE slis_selfield.

  go_command->handle_user_command(
    EXPORTING
      iv_command  = p_ucomm
      iv_selfield = ps_selfield
  ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PF_STATUS_SET
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM pf_status_set USING p_extab TYPE slis_t_extab.
  SET PF-STATUS '0200'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM top_of_page .
  DATA: d_heading TYPE slis_t_listheader.

  d_heading = VALUE #( ( typ = 'H' info = 'Öğrenci Oluştur-Güncelle-Sil Programı' )
                       ( typ = 'S' info = |Kullanıcı Adı: { sy-uname } | )
                       ( typ = 'S' info = |Tarih / Saat : { sy-datum DATE = USER } / { sy-uzeit TIME = USER }| )
                       ( typ = 'S' info = |Kayıt Sayısı : { lines( gt_list ) }| ) ).

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = d_heading.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_alv .
  SELECT
    std~ogr_id,
    std~ogr_ad,
    std~ogr_syd,
    les~les_name,
    les~note1,
    les~note2
FROM zfkn_student AS std LEFT JOIN zfkn_lessons AS les
ON std~ogr_id EQ les~ogr_id
WHERE std~ogr_id IN @seo1
AND  std~ogr_ad IN @seo2
AND std~ogr_syd IN @seo3
INTO CORRESPONDING FIELDS OF TABLE @gt_list.


  LOOP AT gt_list INTO DATA(ls_list).

    IF ls_list-note1 IS NOT INITIAL AND ls_list-note2 IS NOT INITIAL.
      DATA: lv_result TYPE decimals,
            lv_num1   TYPE i,
            lv_num2   TYPE i.
      lv_num1 = ls_list-note1.
      lv_num2 = ls_list-note2.
      lv_result = ( lv_num1 * 40 ) / 100 + ( lv_num2 * 60 ) / 100.
      IF lv_result >= 70.
        ls_list-durum = 'Başarılı'.
      ELSE.
        ls_list-durum = 'Başarısız'.
      ENDIF.
      MODIFY gt_list FROM ls_list TRANSPORTING radio durum.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form END_OF_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM end_of_list .
  DATA: e_heading TYPE slis_t_listheader.

  e_heading = VALUE #( ( typ = 'S' info = |Kayıt Sayısı :{ lines( gt_list ) }| ) ).

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = e_heading.

ENDFORM.