*&---------------------------------------------------------------------*
*& Include          ZABAP_FA_TUTORIAL_008_CLS
*&---------------------------------------------------------------------*

CLASS cl_event_receiver DEFINITION.

  PUBLIC SECTION.
    METHODS handle_hotspot_click               "HOTSPOT_CLICK"
        FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING
        e_row_id
        e_column_id.

    METHODS handle_hotspot_click2
        FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING
        e_row_id
        e_column_id.

    METHODS handle_data_changed
        FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING
        er_data_changed
        e_onf4
        e_onf4_before
        e_onf4_after
        e_ucomm.


    METHODS handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING
        e_object
        e_interactive.

    METHODS handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING
        e_ucomm.
*

ENDCLASS.

CLASS lcl_events DEFINITION.
  PUBLIC SECTION.
    METHODS initialization.
    METHODS at_selection_screen_output.
    METHODS at_selection_screen.

ENDCLASS.

CLASS lcl_alv_operations DEFINITION.
  PUBLIC SECTION.
    METHODS get_data.
    METHODS set_fcat.
    METHODS set_layout.
    METHODS display_alv.


ENDCLASS.



CLASS cl_event_receiver IMPLEMENTATION.


  METHOD handle_hotspot_click.
    IF p_list  EQ 'D'.
      READ TABLE gt_cus_master INTO gs_cus_master INDEX e_row_id.
      LOOP AT gt_cus_master INTO DATA(ls_cus_master).
        IF sy-tabix EQ e_row_id.
          ls_cus_master-icon = icon_radiobutton.
        ELSE.
          ls_cus_master-icon = icon_wd_radio_button_empty.
        ENDIF.
        MODIFY gt_cus_master FROM ls_cus_master TRANSPORTING icon.
      ENDLOOP.

      READ TABLE gt_cus_master INTO gs_cus_master INDEX e_row_id.
      CLEAR: gt_cus_detail.
      LOOP AT gt_cus_all_detail INTO DATA(lv_cus_detail).
        IF lv_cus_detail-kunnr EQ gs_cus_master-kunnr.
          APPEND lv_cus_detail TO gt_cus_detail.
        ENDIF.
      ENDLOOP.

    ELSE.
      READ TABLE gt_sel_master INTO gs_sel_master INDEX e_row_id.
      LOOP AT gt_sel_master INTO DATA(ls_sel_master).
        IF sy-tabix EQ e_row_id.
          ls_sel_master-icon = icon_radiobutton.
        ELSE.
          ls_sel_master-icon = icon_wd_radio_button_empty.
        ENDIF.
        MODIFY gt_sel_master FROM ls_sel_master TRANSPORTING icon.
      ENDLOOP.

      READ TABLE gt_sel_master INTO gs_sel_master INDEX e_row_id.
      CLEAR: gt_sel_detail.
      LOOP AT gt_sel_all_detail INTO DATA(lv_sel_detail).
        IF lv_sel_detail-lifnr EQ gs_sel_master-lifnr.
          APPEND lv_sel_detail TO gt_sel_detail.
        ENDIF.
      ENDLOOP.

    ENDIF.
    CALL METHOD go_alv->refresh_table_display.
    CALL METHOD go_alv2->refresh_table_display.

  ENDMETHOD.

  METHOD handle_hotspot_click2.
    IF p_list EQ 'D'.
      READ TABLE gt_cus_detail INTO gs_cus_detail INDEX e_row_id.
      SET PARAMETER ID 'BLN' FIELD gs_cus_detail-belnr.
      SET PARAMETER ID 'BUK' FIELD gs_cus_detail-bukrs.
      SET PARAMETER ID 'GJR' FIELD gs_cus_detail-gjahr.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
    ELSE.
      READ TABLE gt_sel_detail INTO gs_sel_detail INDEX e_row_id.
      SET PARAMETER ID 'BLN' FIELD gs_sel_detail-belnr.
      SET PARAMETER ID 'BUK' FIELD gs_sel_detail-bukrs.
      SET PARAMETER ID 'GJR' FIELD gs_sel_detail-gjahr.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
    ENDIF.

  ENDMETHOD.


  METHOD handle_data_changed.
    DATA: ls_modi TYPE lvc_s_modi,
          lv_mes  TYPE char200.

    IF p_list EQ 'D'.
      LOOP AT er_data_changed->mt_good_cells INTO ls_modi.
        READ TABLE gt_cus_master INTO gs_cus_master INDEX ls_modi-row_id.
      ENDLOOP.
      TRY.
          gs_cus_master-dscnt = ( gs_cus_master-wrbtr * ls_modi-value ) / 100.
          IF ls_modi-value < 0 OR ls_modi-value > 100.
            CALL METHOD er_data_changed->add_protocol_entry
              EXPORTING
                i_msgid     = 'ZFKN'                 " Message ID
                i_msgty     = 'E'                " Message Type
                i_msgno     = '002'                 " Message No.
                i_fieldname = 'RATES'                 " Field Name
                i_row_id    = ls_modi-row_id.                 " RowID

          ELSE.
            er_data_changed->modify_cell(
              EXPORTING
                i_row_id    = ls_modi-row_id                 " Row ID
                i_tabix     = ls_modi-tabix                 " Row Index
                i_fieldname = 'DSCNT'                 " Field Name
                i_value     = gs_cus_master-dscnt                 " Value
            ).
          ENDIF.

        CATCH cx_sy_conversion_error.
          CALL METHOD er_data_changed->add_protocol_entry
            EXPORTING
              i_msgid     = 'ZFKN'                 " Message ID
              i_msgty     = 'E'                " Message Type
              i_msgno     = '003'                 " Message No.
              i_fieldname = 'RATES'                 " Field Name
              i_row_id    = ls_modi-row_id.                 " RowID
      ENDTRY.
    ELSE.
      LOOP AT er_data_changed->mt_good_cells INTO ls_modi.
        READ TABLE gt_sel_master INTO gs_sel_master INDEX ls_modi-row_id.
      ENDLOOP.
      TRY.
          gs_sel_master-dscnt = ( gs_sel_master-wrbtr * ls_modi-value ) / 100.
          IF ls_modi-value < 0 OR ls_modi-value > 100 .
            CALL METHOD er_data_changed->add_protocol_entry
              EXPORTING
                i_msgid     = 'ZFKN'                 " Message ID
                i_msgty     = 'E'                 " Message Type
                i_msgno     = '003'                 " Message No.
                i_fieldname = 'RATES'                 " Field Name
                i_row_id    = ls_modi-row_id.                " RowID
          ELSE.
            er_data_changed->modify_cell(
              EXPORTING
                i_row_id    = ls_modi-row_id                 " Row ID
                i_tabix     = ls_modi-tabix                " Row Index
                i_fieldname = 'DSCNT'                 " Field Name
                i_value     = gs_sel_master-dscnt                 " Value
            ).
          ENDIF.

        CATCH cx_sy_conversion_error.
          CALL METHOD er_data_changed->add_protocol_entry
            EXPORTING
              i_msgid     = 'ZFKN'                " Message ID
              i_msgty     = 'E'               " Message Type
              i_msgno     = '003'                " Message No.
              i_fieldname = 'RATES'               " Field Name
              i_row_id    = ls_modi-row_id.                " RowID
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD handle_toolbar.
    DATA: ls_button TYPE stb_button.
    CLEAR: ls_button.
    ls_button-function = '&PDF'.
    ls_button-text = 'PDF'.
    ls_button-quickinfo = 'PDF al'.
    ls_button-icon = '@IT@'.
    ls_button-disabled = abap_false.
    APPEND ls_button TO e_object->mt_toolbar.


    DATA: ls_button_exc TYPE stb_button.
    CLEAR: ls_button_exc.
    ls_button_exc-function = '&EXC'.
    ls_button_exc-text = 'Excel'.
    ls_button_exc-quickinfo = 'Excel Al'.
    ls_button_exc-icon = '@J2@'.
    ls_button-disabled = abap_false.
    APPEND ls_button_exc TO e_object->mt_toolbar.


  ENDMETHOD.

  METHOD handle_user_command.
    CASE e_ucomm.
      WHEN '&PDF'.
        DATA: gv_fname      TYPE rs38l_fnam,
              gs_control    TYPE ssfctrlop,
              gs_output_opt TYPE ssfcompop.
        gs_control-no_dialog = abap_true.
        gs_control-preview = abap_true.
        gs_output_opt-tddest = 'LP01'.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZFKN_SF_001'
*           VARIANT            = ' '
*           DIRECT_CALL        = ' '
          IMPORTING
            fm_name            = gv_fname
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.

        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
        IF p_list EQ 'D'.

        ELSE.

        ENDIF.

      WHEN '&EXC'.
        DATA: excel    TYPE ole2_object,
              workbook TYPE ole2_object,
              sheet    TYPE ole2_object,
              cell     TYPE ole2_object,
              row      TYPE ole2_object.

        IF p_list EQ 'D'.
          TYPES: BEGIN OF ty_t_excel_sample,
                   bukrs TYPE bukrs,
                   butxt TYPE butxt,
                   kunnr TYPE kunnr,
                   name1 TYPE name1,
                   waers TYPE waers,
                   wrbtr TYPE zfkn_dec,
                   rates TYPE char50,
                   dscnt TYPE zfkn_dec,
                 END OF ty_t_excel_sample.

          TYPES: BEGIN OF ty_cus_detail,
                   bukrs TYPE  bukrs,
                   belnr TYPE  belnr_d,
                   gjahr TYPE  gjahr,
                   buzei TYPE  buzei,
                   budat TYPE  budat,
                   bldat TYPE  bldat,
                   waers TYPE  waers,
                   kunnr TYPE  kunnr,
                   wrbtr TYPE  wrbtr,
                 END OF ty_cus_detail.



          DATA: lt_excel_format TYPE TABLE OF ty_t_excel_sample,
                ls_excel_format TYPE ty_t_excel_sample.

          DATA: lt_cus_exc TYPE TABLE OF ty_cus_detail,
                ls_cus_exc TYPE ty_cus_detail.

* Excel uygulamasını oluştur
          CREATE OBJECT excel 'EXCEL.APPLICATION'.

* Excel çalışma kitabı nesnesini oluştur
          CALL METHOD OF excel 'WORKBOOKS' = workbook.

* Excel'i arka planda çalıştır
          SET PROPERTY OF excel 'VISIBLE' = 0.

* Excel'i öne getir
          SET PROPERTY OF excel 'VISIBLE' = 1.

* Yeni bir çalışma kitabı ekle
          CALL METHOD OF workbook 'add'.

* İlk çalışma sayfasını seç
          CALL METHOD OF excel 'Worksheets' = sheet EXPORTING #1 = 1.
          CALL METHOD OF sheet 'Activate'.

* Excel başlık satırını ekle

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = 1 #2 = 1.
          SET PROPERTY OF cell 'VALUE' = 'Şirket Kodu'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = 1 #2 = 2.
          SET PROPERTY OF cell 'VALUE' = 'Şirket Adı'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = 1 #2 = 3.
          SET PROPERTY OF cell 'VALUE' = 'Müşteri No'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = 1 #2 = 4.
          SET PROPERTY OF cell 'VALUE' = 'Name1'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = 1 #2 = 5.
          SET PROPERTY OF cell 'VALUE' = 'PB'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = 1 #2 = 6.
          SET PROPERTY OF cell 'VALUE' = 'İskonto'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = 1 #2 = 7.
          SET PROPERTY OF cell 'VALUE' = 'Oran'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = 1 #2 = 8.
          SET PROPERTY OF cell 'VALUE' = 'İskonto Tutarı'.

* Örnek veri ekle
          LOOP AT gt_cus_master INTO DATA(lv_cus_master).
            ls_excel_format-bukrs = lv_cus_master-bukrs.
            ls_excel_format-butxt = lv_cus_master-butxt.
            ls_excel_format-kunnr = lv_cus_master-kunnr.
            ls_excel_format-name1 = lv_cus_master-name1.
            ls_excel_format-waers = lv_cus_master-waers.
            ls_excel_format-wrbtr = lv_cus_master-wrbtr.
            ls_excel_format-rates = lv_cus_master-rates.
            ls_excel_format-dscnt = lv_cus_master-dscnt.
            APPEND ls_excel_format TO lt_excel_format.
          ENDLOOP.

* Excel veri satırlarını ekle
          DATA(lv_row) = 2.
          LOOP AT lt_excel_format INTO ls_excel_format.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 1.
            SET PROPERTY OF cell 'VALUE' = ls_excel_format-bukrs.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 2.
            SET PROPERTY OF cell 'VALUE' = ls_excel_format-butxt.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 3.
            SET PROPERTY OF cell 'VALUE' = ls_excel_format-kunnr.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 4.
            SET PROPERTY OF cell 'VALUE' = ls_excel_format-name1.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 5.
            SET PROPERTY OF cell 'VALUE' = ls_excel_format-waers.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 6.
            SET PROPERTY OF cell 'VALUE' = ls_excel_format-wrbtr.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 7.
            SET PROPERTY OF cell 'VALUE' = ls_excel_format-rates.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 8.
            SET PROPERTY OF cell 'VALUE' = ls_excel_format-dscnt.

            lv_row = lv_row + 1.
          ENDLOOP.

* Toplamları hesapla ve ekle
          DATA(lv_total_wrbtr) = 0.
          DATA(lv_total_dscnt) = 0.

          LOOP AT lt_excel_format INTO ls_excel_format.
            lv_total_wrbtr = lv_total_wrbtr + ls_excel_format-wrbtr.
            lv_total_dscnt = lv_total_dscnt + ls_excel_format-dscnt.
          ENDLOOP.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 5.
          SET PROPERTY OF cell 'VALUE' = 'Toplam'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 6.
          SET PROPERTY OF cell 'VALUE' = lv_total_wrbtr.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 8.
          SET PROPERTY OF cell 'VALUE' = lv_total_dscnt.


          lv_row = lv_row + 2.

*Excel başlık satırlarını ekle

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 1.
          SET PROPERTY OF cell 'VALUE' = 'Şirket Kodu'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 2.
          SET PROPERTY OF cell 'VALUE' = 'Belge No'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 3.
          SET PROPERTY OF cell 'VALUE' = 'Yıl'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 4.
          SET PROPERTY OF cell 'VALUE' = 'Kalem'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 5.
          SET PROPERTY OF cell 'VALUE' = 'Kayıt Tarihi'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 6.
          SET PROPERTY OF cell 'VALUE' = 'Belge Tarihi'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 7.
          SET PROPERTY OF cell 'VALUE' = 'PB'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 8.
          SET PROPERTY OF cell 'VALUE' = 'Müşteri Numarası'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 9.
          SET PROPERTY OF cell 'VALUE' = 'Tutar'.


          lv_row = lv_row + 1.
          LOOP AT gt_cus_detail INTO DATA(lv_cus_detail).
            ls_cus_exc-bukrs = lv_cus_detail-bukrs.
            ls_cus_exc-belnr = lv_cus_detail-belnr.
            ls_cus_exc-gjahr = lv_cus_detail-gjahr.
            ls_cus_exc-buzei = lv_cus_detail-buzei.
            ls_cus_exc-budat = lv_cus_detail-budat.
            ls_cus_exc-bldat = lv_cus_detail-bldat.
            ls_cus_exc-waers = lv_cus_detail-waers.
            ls_cus_exc-kunnr = lv_cus_detail-kunnr.
            ls_cus_exc-wrbtr = lv_cus_detail-wrbtr.
            APPEND ls_cus_exc TO lt_cus_exc.
          ENDLOOP.


*2.tablonun verilerini ekle
          LOOP AT lt_cus_exc INTO ls_cus_exc.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 1.
            SET PROPERTY OF cell 'VALUE' = ls_cus_exc-bukrs.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 2.
            SET PROPERTY OF cell 'VALUE' = ls_cus_exc-belnr.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 3.
            SET PROPERTY OF cell 'VALUE' = ls_cus_exc-gjahr.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 4.
            SET PROPERTY OF cell 'VALUE' = ls_cus_exc-buzei.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 5.
            SET PROPERTY OF cell 'VALUE' = ls_cus_exc-budat.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 6.
            SET PROPERTY OF cell 'VALUE' = ls_cus_exc-bldat.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 7.
            SET PROPERTY OF cell 'VALUE' = ls_cus_exc-waers.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 8.
            SET PROPERTY OF cell 'VALUE' = ls_cus_exc-kunnr.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 9.
            SET PROPERTY OF cell 'VALUE' = ls_cus_exc-wrbtr.

            lv_row = lv_row + 1.
          ENDLOOP.

          DATA(lv_top_cus) = 0.

          LOOP AT lt_cus_exc INTO ls_cus_exc.
            lv_top_cus = lv_top_cus + ls_cus_exc-wrbtr.
          ENDLOOP.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 7.
          SET PROPERTY OF cell 'VALUE' = ls_cus_exc-waers.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = lv_row #2 = 9.
          SET PROPERTY OF cell 'VALUE' = lv_top_cus.


          CALL METHOD OF excel 'SAVE'.
          CALL METHOD OF excel 'QUIT'.
*Free ALL
          FREE OBJECT cell.
          FREE  OBJECT workbook.
          FREE OBJECT excel.
          excel-handle = -1.
          FREE OBJECT row.

        ELSE.
          TYPES: BEGIN OF ty_sel_excel,
                   bukrs TYPE  bukrs,
                   butxt TYPE  butxt,
                   lifnr TYPE  lifnr,
                   name1 TYPE  name1,
                   waers TYPE  waers,
                   wrbtr TYPE  zfkn_dec,
                   rates TYPE  char50,
                   dscnt TYPE  zfkn_dec,

                 END OF ty_sel_excel.

          TYPES: BEGIN OF ty_detail_excel,
                   bukrs TYPE  bukrs,
                   belnr TYPE  belnr_d,
                   gjahr TYPE  gjahr,
                   buzei TYPE  buzei,
                   budat TYPE  budat,
                   bldat TYPE  bldat,
                   waers TYPE  waers,
                   lifnr TYPE  lifnr,
                   wrbtr TYPE  wrbtr,
                 END OF ty_detail_excel.

          DATA: lt_sel_format TYPE TABLE OF ty_sel_excel,
                ls_sel_format TYPE ty_sel_excel.

          DATA: lt_detail_excel TYPE TABLE OF ty_detail_excel,
                ls_detail_excel TYPE ty_detail_excel.

          CREATE OBJECT excel 'EXCEL.APPLICATION'.

* Excel uygulamasını oluştur
          CREATE OBJECT excel 'EXCEL.APPLICATION'.

* Excel çalışma kitabı nesnesini oluştur
          CALL METHOD OF excel 'WORKBOOKS' = workbook.

* Excel'i arka planda çalıştır
          SET PROPERTY OF excel 'VISIBLE' = 0.

* Excel'i öne getir
          SET PROPERTY OF excel 'VISIBLE' = 1.

* Yeni bir çalışma kitabı ekle
          CALL METHOD OF workbook 'add'.

* İlk çalışma sayfasını seç
          CALL METHOD OF excel 'Worksheets' = sheet EXPORTING #1 = 1.
          CALL METHOD OF sheet 'Activate'.

* Excel başlık satırını ekle
          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = 1 #2 = 1.
          SET PROPERTY OF cell 'VALUE' = 'Şirket Kodu'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = 1 #2 = 2.
          SET PROPERTY OF cell 'VALUE' = 'Şirket Adı'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = 1 #2 = 3.
          SET PROPERTY OF cell 'VALUE' = 'Müşteri No'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = 1 #2 = 4.
          SET PROPERTY OF cell 'VALUE' = 'Name1'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = 1 #2 = 5.
          SET PROPERTY OF cell 'VALUE' = 'PB'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = 1 #2 = 6.
          SET PROPERTY OF cell 'VALUE' = 'İskonto'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = 1 #2 = 7.
          SET PROPERTY OF cell 'VALUE' = 'Oran'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = 1 #2 = 8.
          SET PROPERTY OF cell 'VALUE' = 'İskonto Tutarı'.

*Excel Sample Row
          LOOP AT gt_sel_master INTO DATA(lv_sel_master).
            ls_sel_format-bukrs = lv_sel_master-bukrs.
            ls_sel_format-butxt = lv_sel_master-butxt.
            ls_sel_format-lifnr = lv_sel_master-lifnr.
            ls_sel_format-name1 = lv_sel_master-name1.
            ls_sel_format-waers = lv_sel_master-waers.
            ls_sel_format-wrbtr = lv_sel_master-wrbtr.
            ls_sel_format-rates = lv_sel_master-rates.
            ls_sel_format-dscnt = lv_sel_master-dscnt.
            APPEND ls_sel_format TO lt_sel_format.
          ENDLOOP.
*Append excel Sample Data to Internal Table
          DATA(ls_row) = 2.
          LOOP AT lt_sel_format INTO ls_sel_format.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 1.
            SET PROPERTY OF cell 'VALUE' = ls_sel_format-bukrs.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 2.
            SET PROPERTY OF cell 'VALUE' = ls_sel_format-butxt.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 3.
            SET PROPERTY OF cell 'VALUE' = ls_sel_format-lifnr.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 4.
            SET PROPERTY OF cell 'VALUE' = ls_sel_format-name1.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 5.
            SET PROPERTY OF cell 'VALUE' = ls_sel_format-waers.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 6.
            SET PROPERTY OF cell 'VALUE' = ls_sel_format-wrbtr.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 7.
            SET PROPERTY OF cell 'VALUE' = ls_sel_format-rates.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 8.
            SET PROPERTY OF cell 'VALUE' = ls_sel_format-dscnt.

            ls_row = ls_row + 1.
          ENDLOOP.

* toplamları hesapla ve ekle
          DATA(lv_tot_wrbtr) = 0.
          DATA(lv_tot_dscnt) = 0.

          LOOP AT lt_sel_format INTO ls_sel_format.
            lv_tot_wrbtr = lv_tot_wrbtr + ls_sel_format-wrbtr.
            lv_tot_dscnt = lv_tot_dscnt + ls_sel_format-dscnt.
          ENDLOOP.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 5.
          SET PROPERTY OF cell 'VALUE' = 'Toplam'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 6.
          SET PROPERTY OF cell 'VALUE' = lv_tot_wrbtr.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 8.
          SET PROPERTY OF cell 'VALUE' = lv_tot_dscnt.

          ls_row = ls_row + 2.

*Excel Başlık Satırlarını Ekle

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 1.
          SET PROPERTY OF cell 'VALUE' = 'Şirket Kodu'.


          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 2.
          SET PROPERTY OF cell 'VALUE' = 'Belge Numarası'.


          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 3.
          SET PROPERTY OF cell 'VALUE' = 'Yıl'.


          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 4.
          SET PROPERTY OF cell 'VALUE' = 'Kalem'.


          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 5.
          SET PROPERTY OF cell 'VALUE' = 'Kayıt Tarihi'.


          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 6.
          SET PROPERTY OF cell 'VALUE' = 'Belge Tarihi'.


          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 7.
          SET PROPERTY OF cell 'VALUE' = 'PB'.


          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 8.
          SET PROPERTY OF cell 'VALUE' = 'Müşteri Numarası'.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 9.
          SET PROPERTY OF cell 'VALUE' = 'Tutar'.

          ls_row = ls_row + 1.

          LOOP AT gt_sel_detail INTO DATA(lv_sel_excel).
            ls_detail_excel-bukrs = lv_sel_excel-bukrs.
            ls_detail_excel-belnr = lv_sel_excel-belnr.
            ls_detail_excel-gjahr = lv_sel_excel-gjahr.
            ls_detail_excel-buzei = lv_sel_excel-buzei.
            ls_detail_excel-budat = lv_sel_excel-budat.
            ls_detail_excel-bldat = lv_sel_excel-bldat.
            ls_detail_excel-waers = lv_sel_excel-waers.
            ls_detail_excel-lifnr = lv_sel_excel-lifnr.
            ls_detail_excel-wrbtr = lv_sel_excel-wrbtr.
            APPEND ls_detail_excel TO lt_detail_excel.
          ENDLOOP.

*Detail Tablosunun verilerini ekle

          LOOP AT lt_detail_excel INTO ls_detail_excel.
            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 1.
            SET PROPERTY OF cell 'VALUE' = ls_detail_excel-bukrs.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 2.
            SET PROPERTY OF cell 'VALUE' = ls_detail_excel-belnr.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 3.
            SET PROPERTY OF cell 'VALUE' = ls_detail_excel-gjahr.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 4.
            SET PROPERTY OF cell 'VALUE' = ls_detail_excel-buzei.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 5.
            SET PROPERTY OF cell 'VALUE' = ls_detail_excel-budat.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 6.
            SET PROPERTY OF cell 'VALUE' = ls_detail_excel-bldat.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 7.
            SET PROPERTY OF cell 'VALUE' = ls_detail_excel-waers.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 8.
            SET PROPERTY OF cell 'VALUE' = ls_detail_excel-lifnr.

            CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 9.
            SET PROPERTY OF cell 'VALUE' = ls_detail_excel-wrbtr.

            ls_row = ls_row + 1.
          ENDLOOP.


          DATA(lv_top_wrbtr) = 0.

          LOOP AT lt_detail_excel INTO ls_detail_excel.
           lv_top_wrbtr = lv_top_wrbtr + ls_detail_excel-wrbtr.
          ENDLOOP.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 7.
          SET PROPERTY OF cell 'Value' = ls_detail_excel-waers.

          CALL METHOD OF sheet 'Cells' = cell EXPORTING #1 = ls_row #2 = 9.
          SET PROPERTY OF cell 'VALUE' = lv_top_wrbtr.

          CALL METHOD OF excel 'SAVE'.
          CALL METHOD OF excel 'QUIT'.
*Free ALL
          FREE OBJECT cell.
          FREE  OBJECT workbook.
          FREE OBJECT excel.
          excel-handle = -1.
          FREE OBJECT row.

        ENDIF.

    ENDCASE.
  ENDMETHOD.


ENDCLASS.

CLASS lcl_alv_operations IMPLEMENTATION.
  METHOD get_data.
    IF p_list EQ 'D'.
      SELECT * FROM bkpf INNER JOIN bseg ON
        bkpf~bukrs = bseg~bukrs AND
        bkpf~belnr = bseg~belnr AND
        bkpf~gjahr = bseg~gjahr
        LEFT OUTER JOIN  t001
        ON t001~bukrs = bkpf~bukrs
        LEFT OUTER JOIN kna1
        ON kna1~kunnr = bseg~kunnr
        WHERE bseg~kunnr IN @seo_cus
        AND bkpf~bukrs EQ @p_rad1
        AND bkpf~gjahr EQ @p_rad2
        AND bkpf~monat EQ @p_rad3
        AND bseg~koart EQ 'D'
        ORDER BY bseg~kunnr
        INTO CORRESPONDING FIELDS OF TABLE @gt_cus_all_detail.

      LOOP AT gt_cus_all_detail INTO DATA(ls_cus_detail).

        DATA(ls_cus_master) = VALUE zfkn_cus_master(
            bukrs = ls_cus_detail-bukrs
            butxt = ls_cus_detail-butxt
            kunnr = ls_cus_detail-kunnr
            name1 = ls_cus_detail-name1
            waers = ls_cus_detail-waers
            wrbtr = ls_cus_detail-wrbtr
            rates = ''
            dscnt = 0
        ).

        IF sy-tabix EQ 1.
          ls_cus_master-icon = icon_radiobutton.

        ELSE.
          ls_cus_master-icon = icon_wd_radio_button_empty.
        ENDIF.
        COLLECT ls_cus_master INTO gt_cus_master.
      ENDLOOP.

      READ TABLE gt_cus_master INTO gs_cus_master INDEX 1.
      LOOP AT gt_cus_all_detail INTO DATA(lv_cus_detail).
        IF lv_cus_detail-kunnr EQ gs_cus_master-kunnr.
          APPEND lv_cus_detail TO gt_cus_detail.
        ENDIF.
      ENDLOOP.

      TYPES: BEGIN OF gty_cus_mv,
               bukrs TYPE zfkn_cus_table-bukrs,
               kunnr TYPE zfkn_cus_table-kunnr,
               rates TYPE zfkn_cus_table-rates,
             END OF gty_cus_mv.

      DATA: gt_cus_mv TYPE TABLE OF gty_cus_mv.
      SELECT * FROM zfkn_cus_table INTO CORRESPONDING FIELDS OF TABLE gt_cus_mv.

      LOOP AT gt_cus_master INTO DATA(lss_cus_master).
        LOOP AT gt_cus_mv INTO DATA(ls_cus_mv).
          IF lss_cus_master-kunnr EQ ls_cus_mv-kunnr AND lss_cus_master-bukrs EQ ls_cus_mv-bukrs.
            lss_cus_master-rates = ls_cus_mv-rates.
            MODIFY gt_cus_master FROM lss_cus_master.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      LOOP AT gt_cus_master INTO ls_cus_master.
        IF ls_cus_master-rates IS INITIAL.
          ls_cus_master-rates = '2.0'.
          ls_cus_master-dscnt = ( ls_cus_master-wrbtr * 2 ) / 100.
        ELSE.
          DATA: lv_rates TYPE p DECIMALS 2.
          lv_rates = ls_cus_master-rates.
          ls_cus_master-dscnt = ( ls_cus_master-wrbtr * lv_rates ) / 100.
        ENDIF.
        MODIFY gt_cus_master FROM ls_cus_master.
      ENDLOOP.

    ELSE.
      SELECT * FROM bkpf INNER JOIN bseg ON
        bkpf~bukrs = bseg~bukrs
        AND bkpf~belnr = bseg~belnr
        AND bkpf~gjahr = bseg~gjahr
        LEFT OUTER JOIN t001
        ON t001~bukrs = bkpf~bukrs
        LEFT OUTER JOIN lfa1
        ON lfa1~lifnr = bseg~lifnr
        WHERE bseg~koart EQ 'K'
        AND bseg~lifnr IN @seo_sel
        AND bkpf~bukrs EQ @p_rad1
        AND bkpf~gjahr EQ @p_rad2
        AND bkpf~monat EQ @p_rad3 INTO CORRESPONDING FIELDS OF TABLE @gt_sel_all_detail.

      LOOP AT gt_sel_all_detail INTO DATA(ls_sel_detail).

        DATA(ls_sel_master) = VALUE zfkn_sel_master(
            bukrs = ls_sel_detail-bukrs
            butxt = ls_sel_detail-butxt
            lifnr = ls_sel_detail-lifnr
            name1 = ls_sel_detail-name1
            waers = ls_sel_detail-waers
            wrbtr = ls_sel_detail-wrbtr
            rates = ''
            dscnt = 0
        ).
        IF sy-tabix EQ 1.
          ls_sel_master-icon = icon_radiobutton.
        ELSE.
          ls_sel_master-icon = icon_wd_radio_button_empty.

        ENDIF.
        COLLECT ls_sel_master INTO gt_sel_master.
      ENDLOOP.

      READ TABLE gt_sel_master INTO gs_sel_master INDEX 1.
      LOOP AT  gt_sel_all_detail INTO DATA(lv_sel_detail).
        IF lv_sel_detail-lifnr EQ gs_sel_detail-lifnr.
          APPEND lv_sel_detail TO gt_sel_detail.
        ENDIF.
      ENDLOOP.

      TYPES: BEGIN OF gty_sel_mv,
               bukrs TYPE zfkn_sel_table-bukrs,
               lifnr TYPE zfkn_sel_table-lifnr,
               rates TYPE zfkn_sel_table-rates,
             END OF gty_sel_mv.

      DATA: gt_sel_mv TYPE TABLE OF gty_sel_mv.

      SELECT * FROM zfkn_sel_table INTO CORRESPONDING FIELDS OF TABLE gt_sel_mv.

      LOOP AT gt_sel_master INTO DATA(lss_sel_master).
        LOOP AT gt_sel_mv INTO DATA(ls_sel_mv).
          IF lss_sel_master-lifnr EQ ls_sel_mv-lifnr AND lss_sel_master-bukrs EQ ls_sel_mv-bukrs.
            lss_sel_master-rates = ls_sel_mv-rates.
            MODIFY gt_sel_master FROM lss_sel_master.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      LOOP AT gt_sel_master INTO ls_sel_master.
        IF ls_sel_master-rates IS INITIAL.
          ls_sel_master-rates = '2.0'.
          ls_sel_master-dscnt = ( ls_sel_master-wrbtr * 2 ) / 100.
        ELSE.
          DATA: lv_rates2 TYPE p DECIMALS 2.
          lv_rates2 = ls_sel_master-rates.
          ls_sel_master-dscnt = ( ls_sel_master-wrbtr * lv_rates2 ) / 100.
        ENDIF.
        MODIFY gt_sel_master FROM ls_sel_master.
      ENDLOOP.


    ENDIF.
  ENDMETHOD.

  METHOD set_fcat.
    IF p_list EQ 'D'.


      gs_fcat2-fieldname = ''.

      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name = 'ZFKN_CUS_DETAIL'
        CHANGING
          ct_fieldcat      = gt_fcat2.

      LOOP AT gt_fcat2 INTO gs_fcat2.
        gs_fcat2-col_opt = abap_true.
        IF gs_fcat2-fieldname = 'BUTXT' OR gs_fcat2-fieldname = 'NAME1'.
          DELETE gt_fcat2 INDEX sy-tabix.
        ELSEIF gs_fcat2-fieldname EQ 'BELNR'.
          gs_fcat2-hotspot = abap_true.
          MODIFY gt_fcat2 FROM gs_fcat2.
        ELSEIF gs_fcat2-fieldname EQ 'WRBTR'.
          gs_fcat2-do_sum = abap_true.
          MODIFY gt_fcat2 FROM gs_fcat2.
        ENDIF.
      ENDLOOP.



      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name = 'ZFKN_CUS_MASTER'
        CHANGING
          ct_fieldcat      = gt_fcat.

      LOOP AT gt_fcat INTO gs_fcat.
        IF gs_fcat-fieldname EQ 'RATES'.
          gs_fcat-edit = abap_true.
          MODIFY gt_fcat FROM gs_fcat.
        ELSEIF gs_fcat-fieldname EQ 'ICON'.
          gs_fcat-reptext = 'Seçim'.
          gs_fcat-hotspot = abap_true.
          gs_fcat-just = 'C'.
          MODIFY gt_fcat FROM gs_fcat.
        ELSEIF gs_fcat-fieldname EQ 'WRBTR'.
          gs_fcat-do_sum = abap_true.
          MODIFY gt_fcat FROM gs_fcat.
        ENDIF.
      ENDLOOP.


    ELSE.
      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name = 'ZFKN_SEL_DETAIL'
        CHANGING
          ct_fieldcat      = gt_fcat2.

      LOOP AT gt_fcat2 INTO gs_fcat2.
        gs_fcat2-col_opt = abap_true.

        IF gs_fcat2-fieldname = 'BUTXT' OR gs_fcat2-fieldname = 'NAME1'.
          DELETE gt_fcat2 INDEX sy-tabix.
        ELSEIF gs_fcat2-fieldname EQ 'BELNR'.
          gs_fcat2-hotspot = abap_true.
          MODIFY gt_fcat2 FROM gs_fcat2.
        ELSEIF gs_fcat2-fieldname EQ 'WRBTR'.
          gs_fcat2-do_sum = abap_true.
          MODIFY gt_fcat2 FROM gs_fcat2.
        ENDIF.
      ENDLOOP.



      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name = 'ZFKN_SEL_MASTER'
        CHANGING
          ct_fieldcat      = gt_fcat.

      LOOP AT gt_fcat INTO gs_fcat.
        IF gs_fcat-fieldname EQ 'RATES'.
          gs_fcat-edit = abap_true.
          MODIFY gt_fcat FROM gs_fcat.
        ELSEIF gs_fcat-fieldname EQ 'ICON'.
          gs_fcat-hotspot = abap_true.
          gs_fcat-just = 'C'.
          MODIFY gt_fcat FROM gs_fcat.
        ELSEIF gs_fcat-fieldname EQ 'WRBTR'.
          gs_fcat-do_sum = abap_true.
          MODIFY gt_fcat FROM gs_fcat.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD set_layout.
    CLEAR: gs_layout.
    gs_layout-cwidth_opt = abap_true.
    gs_layout-zebra = abap_true.
  ENDMETHOD.

  METHOD display_alv.
    CREATE OBJECT go_cust
      EXPORTING
        container_name = 'CC_ALV'.                 " Name of the Screen CustCtrl Name to Link Container To

    CREATE OBJECT go_splitter
      EXPORTING
        parent  = go_cust                   " Parent Container
        rows    = 2                   " Number of Rows to be displayed
        columns = 1.                    " Number of Columns to be Displayed

    CALL METHOD go_splitter->get_container
      EXPORTING
        row       = 1                 " Row
        column    = 1                 " Column
      RECEIVING
        container = go_gui1.                " Container

    CALL METHOD go_splitter->get_container
      EXPORTING
        row       = 2                  " Row
        column    = 1                 " Column
      RECEIVING
        container = go_gui2.                  " Container

    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_gui1.                  " Parent Container

    CREATE OBJECT go_alv2
      EXPORTING
        i_parent = go_gui2.                  " Parent Container

    CREATE OBJECT go_event_receiver.


    SET HANDLER go_event_receiver->handle_hotspot_click FOR go_alv.
    SET HANDLER go_event_receiver->handle_hotspot_click2 FOR go_alv2.
    SET HANDLER go_event_receiver->handle_data_changed FOR go_alv.
    SET HANDLER go_event_receiver->handle_toolbar FOR go_alv.
    SET HANDLER go_event_receiver->handle_user_command FOR go_alv.



    IF p_list EQ 'D'.
      CALL METHOD go_alv->set_table_for_first_display
        EXPORTING
          is_layout       = gs_layout                 " Layout
        CHANGING
          it_outtab       = gt_cus_master                 " Output Table
          it_fieldcatalog = gt_fcat.                  " Field Catalog
      CALL METHOD go_alv2->set_table_for_first_display
        EXPORTING
          is_layout       = gs_layout                  " Layout
        CHANGING
          it_outtab       = gt_cus_detail                 " Output Table
          it_fieldcatalog = gt_fcat2.                 " Field Catalog
    ELSE.
      CALL METHOD go_alv->set_table_for_first_display
        EXPORTING
          is_layout       = gs_layout                 " Layout
        CHANGING
          it_outtab       = gt_sel_master                 " Output Table
          it_fieldcatalog = gt_fcat.                  " Field Catalog

      CALL METHOD go_alv2->set_table_for_first_display
        EXPORTING
          is_layout       = gs_layout                 " Layout
        CHANGING
          it_outtab       = gt_sel_detail                 " Output Table
          it_fieldcatalog = gt_fcat2.                  " Field Catalog

    ENDIF.

    CALL METHOD go_alv->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.               " Event ID
  ENDMETHOD.

ENDCLASS.



CLASS lcl_events IMPLEMENTATION.

  METHOD initialization.
    CREATE OBJECT go_alv_operation.
    v_text = '@KG@ Genel Seçim'.
    v_text2 = '@45@ Çalıştırma Seçimi'.
    v_text3 = '@9P@ Alt Seçimler:'.
    v_text4 = '@AK@Bakım Ekranı'.
    but1 = '@10@Müşteri Bakım Görüntüle'.
    but2 = '@0Z@Müşteri Bakımı Değiştir'.
    but3 = '@10@Satıcı Bakımı Görüntüle'.
    but4 = '@0Z@Satıcı Bakımı Değiştir'.

  ENDMETHOD.

  METHOD at_selection_screen_output.

    CLEAR: it_vrm,wa_vrm.

    wa_vrm-key = 'D'.
    wa_vrm-text = 'Müşteri'.
    APPEND wa_vrm TO it_vrm.
    wa_vrm-key = 'K'.
    wa_vrm-text = 'Satıcı'.
    APPEND wa_vrm TO it_vrm.


    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = 'P_LIST'
        values          = it_vrm
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.


    LOOP AT SCREEN.
      CASE p_list.
        WHEN 'K'.
          IF screen-name CS 'SEO_CUS' OR screen-name CS 'BUT1' OR screen-name CS 'BUT2'.
            screen-active = 0.
          ELSEIF screen-name CS 'SEO_SEL'.
            screen-active = 1.

          ENDIF.
          MODIFY SCREEN.
        WHEN 'D'.
          IF screen-name CS 'SEO_SEL' OR screen-name CS 'BUT3' OR screen-name CS 'BUT4'.
            screen-active = 0.
          ENDIF.
          MODIFY SCREEN.
        WHEN OTHERS.
      ENDCASE.


    ENDLOOP.

  ENDMETHOD.

  METHOD at_selection_screen.
    CASE sy-ucomm.
      WHEN 'ONLI'.
        IF p_rad1 IS NOT INITIAL AND p_rad2 IS NOT INITIAL AND p_rad3 IS NOT INITIAL.
          CALL SCREEN 1001.
        ELSE.
          MESSAGE i001(zfkn).
          CALL SCREEN 1000.
        ENDIF.
      WHEN 'BUT1'.
        CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
          EXPORTING
            action                         = 'S'
            view_name                      = 'ZFKN_CUS_VIEW'
            no_warning_for_clientindep     = 'X'
            generate_maint_tool_if_missing = 'X'.


      WHEN 'BUT2'.
        CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
          EXPORTING
            action                         = 'U'
            view_name                      = 'ZFKN_CUS_VIEW'
            no_warning_for_clientindep     = 'X'
            generate_maint_tool_if_missing = 'X'.

      WHEN 'BUT3'.
        CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
          EXPORTING
            action                         = 'S'
            view_name                      = 'ZFKN_SEL_VIEW'
            no_warning_for_clientindep     = 'X'
            generate_maint_tool_if_missing = 'X'.
      WHEN 'BUT4'.
        CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
          EXPORTING
            action                         = 'U'
            view_name                      = 'ZFKN_SEL_VIEW'
            no_warning_for_clientindep     = 'X'
            generate_maint_tool_if_missing = 'X'.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.