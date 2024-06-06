REPORT zabap_tutorial_007.

PARAMETERS: p_file TYPE localfile OBLIGATORY.
CONSTANTS: c_ext_xls TYPE string VALUE '*.xls'.

DATA: lt_fieldcatalog TYPE  slis_t_fieldcat_alv,
      ls_fieldcatalog TYPE slis_fieldcat_alv,
      gd_layout    TYPE slis_layout_alv.

TYPES: BEGIN OF ty_excel,
         matnr TYPE matnr,
         plant TYPE werks_d,
         bldat TYPE bldat,
         budat TYPE budat,
       END OF ty_excel.

DATA: lt_excel TYPE TABLE OF ty_excel,
      ls_excel TYPE ty_excel.

TYPES: BEGIN OF ty_rows,
         row TYPE numc4,
       END OF ty_rows.
DATA: lt_rows TYPE TABLE OF ty_rows.
FIELD-SYMBOLS: <wa_row> TYPE ty_rows.

TYPES: BEGIN OF ty_filetable,
         filename TYPE char1024,
       END OF ty_filetable.

DATA: lt_filetable TYPE TABLE OF ty_filetable,
      lx_filetable TYPE ty_filetable.

DATA: lv_return_code TYPE i.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Excel File Upload'                 " Title Of File Open Dialog
      default_extension       = c_ext_xls                " Default Extension
    CHANGING
      file_table              = lt_filetable                 " Table Holding Selected Files
      rc                      = lv_return_code                 " Return Code, Number of Files or -1 If Error Occurred
    EXCEPTIONS
      file_open_dialog_failed = 1                " "Open File" dialog failed
      cntl_error              = 2                " Control error
      error_no_gui            = 3                " No GUI available
      not_supported_by_gui    = 4                " GUI does not support this
      OTHERS                  = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  READ TABLE lt_filetable INTO lx_filetable INDEX 1.
  p_file = lx_filetable-filename.

START-OF-SELECTION.
  DATA: lt_tmp_exc TYPE TABLE OF alsmex_tabline.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_file
      i_begin_col             = 1
      i_begin_row             = 3
      i_end_col               = 1000
      i_end_row               = 1000
    TABLES
      intern                  = lt_tmp_exc[]
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF lines( lt_tmp_exc ) > 0.
    DATA: wa_tmp_excel TYPE alsmex_tabline.
    MOVE-CORRESPONDING lt_tmp_exc TO lt_rows.
    SORT lt_rows BY row.
    DELETE ADJACENT DUPLICATES FROM lt_rows COMPARING row.
  ENDIF.

  LOOP AT lt_rows ASSIGNING <wa_row>.
    CLEAR : ls_excel , wa_tmp_excel.

    LOOP AT lt_tmp_exc INTO wa_tmp_excel
      WHERE row EQ <wa_row>-row.
      IF wa_tmp_excel-col EQ 1.
        ls_excel-matnr = wa_tmp_excel-value.
        CLEAR wa_tmp_excel-value.

      ELSEIF wa_tmp_excel-col EQ 2.
        ls_excel-plant = wa_tmp_excel-value.
        CLEAR wa_tmp_excel-value.

      ELSEIF wa_tmp_excel-col EQ 3.
        ls_excel-bldat = wa_tmp_excel-value.
        CLEAR wa_tmp_excel-value.

      ELSEIF wa_tmp_excel-col EQ 4.
        ls_excel-budat = wa_tmp_excel-value.
        CLEAR wa_tmp_excel-value.
      ENDIF.
    ENDLOOP.

    APPEND ls_excel TO lt_excel.
  ENDLOOP.

  IF lt_excel IS NOT INITIAL.
    PERFORM build_field_catalog.
    PERFORM build_layout.
    PERFORM display_alv_report.
  ENDIF.
*&---------------------------------------------------------------------*
*& Form BUILD_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_field_catalog .

  CLEAR: ls_fieldcatalog.
  ls_fieldcatalog-fieldname = 'MATNR'.
  ls_fieldcatalog-seltext_m = 'Malzeme Numarası'.
  APPEND ls_fieldcatalog TO lt_fieldcatalog.

  CLEAR: ls_fieldcatalog.
  ls_fieldcatalog-fieldname = 'PLANT'.
  ls_fieldcatalog-seltext_m = 'Üretim Yeri'.
  APPEND ls_fieldcatalog TO lt_fieldcatalog.

  CLEAR: ls_fieldcatalog.
  ls_fieldcatalog-fieldname = 'BLDAT'.
  ls_fieldcatalog-seltext_m = 'Belge Tarihi'.
  APPEND ls_fieldcatalog TO lt_fieldcatalog.

  CLEAR: ls_fieldcatalog.
  ls_fieldcatalog-fieldname = 'BUDAT'.
  ls_fieldcatalog-seltext_m = 'Kayıt Tarihi'.
  APPEND ls_fieldcatalog TO lt_fieldcatalog.

  endform.
*&---------------------------------------------------------------------*
*& Form BUILD_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_layout .
gd_layout-zebra = abap_true.
gd_layout-no_input = abap_true.
gd_layout-colwidth_optimize = abap_true.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_REPORT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv_report .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_CALLBACK_PROGRAM                = ' '
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE  =
*     I_GRID_SETTINGS                   =
      is_layout     = gd_layout
      it_fieldcat   = lt_fieldcatalog
*     IT_EXCLUDING  =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT       =
*     IT_FILTER     =
*     IS_SEL_HIDE   =
*     I_DEFAULT     = 'X'
*     I_SAVE        = ' '
    tables
      t_outtab      = lt_excel
    exceptions
      program_error = 1
      others        = 2.
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.