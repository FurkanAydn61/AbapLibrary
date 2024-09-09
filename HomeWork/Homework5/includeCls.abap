*&---------------------------------------------------------------------*
*& Include          ZFKN_OGR_HW_CLS
*&---------------------------------------------------------------------*

CLASS lcl_event DEFINITION.
  PUBLIC SECTION.
    METHODS initialization.
    METHODS at_selection_screen.


ENDCLASS.

CLASS lcl_alv_operations DEFINITION.
  PUBLIC SECTION.
    METHODS get_data.
    METHODS set_layout.
    METHODS set_fcat.
    METHODS display_alv.

ENDCLASS.



CLASS lcl_event IMPLEMENTATION.
  METHOD initialization.


    CREATE OBJECT go_alv_operations.
    CREATE OBJECT go_command.
    button1 = '@0S@Öğrencileri Listele'.

  ENDMETHOD.




  METHOD at_selection_screen.

    CASE sy-ucomm.
      WHEN 'ONLI'.
      WHEN 'BUT1'.
        go_alv_operations->get_data( ).
        go_alv_operations->set_layout( ).
        go_alv_operations->set_fcat( ).
        go_alv_operations->display_alv( ).
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.



CLASS lcl_alv_operations IMPLEMENTATION.
  METHOD get_data.
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
      ORDER BY std~ogr_id DESCENDING, les~les_name ASCENDING
      INTO CORRESPONDING FIELDS OF TABLE @gt_list.


    LOOP AT gt_list INTO DATA(ls_list).
      " Başlangıçta her kayda boş radyo düğmesi ekle
      ls_list-radio = icon_wd_radio_button_empty.

      " Notlar var mı kontrol et ve durumu hesapla
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
      ELSE.
        " Notlar eksikse durumu boş bırak
        ls_list-durum = ''.
        MODIFY gt_list FROM ls_list TRANSPORTING radio durum.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD set_layout.
    CLEAR: gs_layout.
    gs_layout-zebra = abap_true.
    gs_layout-cwidth_opt = abap_true.
  ENDMETHOD.

  METHOD set_fcat.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = 'ZFKN_OGR_S'
      CHANGING
        ct_fieldcat            = gt_fcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.

    LOOP AT gt_fcat INTO gs_fcat.
      IF gs_fcat-fieldname IS NOT INITIAL.
        CASE gs_fcat-fieldname.
          WHEN 'RADIO'.
            gs_fcat-reptext = 'Seçim'.
            gs_fcat-just = 'C'.
            gs_fcat-hotspot = abap_true.
          WHEN 'DURUM'.
            gs_fcat-reptext = 'Başarılı/Başarısız'.
        ENDCASE.
        MODIFY gt_fcat FROM gs_fcat.
        IF sy-subrc <> 0.
          " Hata işleme
          MESSAGE 'Field catalog güncellenirken bir hata oluştu.' TYPE 'E'.
        ENDIF.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.


  METHOD display_alv.

    CLEAR: gs_events.
    gs_events-name = slis_ev_pf_status_set.
    gs_events-form = 'PF_STATUS_SET'.
    APPEND gs_events TO gt_events.

    CLEAR: gs_events.
    gs_events-name = slis_ev_top_of_page.
    gs_events-form = 'TOP_OF_PAGE'.
    APPEND gs_events TO gt_events.

    CLEAR: gs_events.
    gs_events-name = slis_ev_end_of_list.
    gs_events-form = 'END_OF_LIST'.
    APPEND gs_events TO gt_events.

*    gs_sort-spos = 1.
*    gs_sort-fieldname = 'OGR_ID'.
*    gs_sort-up = abap_true.
*    APPEND gs_sort TO gt_sort.
*
*
*    gs_sort-spos = 2.
*    gs_sort-fieldname = 'LES_NAME'.
*    gs_sort-down = abap_true.
*    APPEND gs_sort TO gt_sort.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
      EXPORTING
        i_callback_program      = sy-repid
        i_callback_user_command = 'USER_COMMAND'
        is_layout_lvc           = gs_layout
        it_fieldcat_lvc         = gt_fcat
*       i_save                  = 'A'
        it_sort_lvc             = gt_sort
*       is_variant              = gs_variant
        it_events               = gt_events
      TABLES
        t_outtab                = gt_list.

  ENDMETHOD.

ENDCLASS.