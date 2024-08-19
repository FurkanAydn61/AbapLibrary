REPORT zfkn_excel.

INCLUDE zfkn_excel_top.
INCLUDE zfkn_excel_frm.




START-OF-SELECTION.

  PERFORM get_data.

  IF gt_list[] IS NOT INITIAL.
    PERFORM excel_instantiate.
    PERFORM download_to_excel.
  ENDIF.




*********************************************

*& Include          ZFKN_EXCEL_TOP
*&---------------------------------------------------------------------*
TYPES: BEGIN OF tp_list,
         bukrs TYPE bsid-bukrs,
         kunnr TYPE bsid-kunnr,
         zuonr TYPE bsid-zuonr,
         budat TYPE bsid-budat,
         waers TYPE bsid-waers,
         dmbtr TYPE bsid-dmbtr,
       END OF tp_list.

"Internal table and work area

DATA: gt_list TYPE STANDARD TABLE OF tp_list,
      gs_list TYPE tp_list.

"for selection screen select option declaration

DATA: gv_kunnr TYPE bsid-kunnr.

"for excel functionality

DATA: lr_excel_structure      TYPE REF TO data,
      lo_source_table_descr   TYPE REF  TO cl_abap_tabledescr,
      lo_table_row_descriptor TYPE REF TO cl_abap_structdescr,
      lv_content              TYPE xstring,
      lt_binary_tab           TYPE TABLE OF sdokcntasc,
      lv_length               TYPE i,
      lv_filename             TYPE string,
      lv_path                 TYPE string,
      lv_fullpath             TYPE string.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_kunnr FOR gv_kunnr.
SELECTION-SCREEN END OF BLOCK b1.



*****************************************************


FORM get_data .
  SELECT bukrs
         kunnr
         zuonr
         budat
         waers
         dmbtr
    FROM bsid
    INTO CORRESPONDING FIELDS OF TABLE gt_list
    WHERE kunnr IN s_kunnr.
ENDFORM.


FORM excel_instantiate .
  "Create data reference
  GET REFERENCE OF gt_list INTO lr_excel_structure.
  DATA(lo_itab_service) = cl_salv_itab_services=>create_for_table_ref( lr_excel_structure  ).

  lo_source_table_descr ?= cl_abap_tabledescr=>describe_by_data_ref( lr_excel_structure ).
  lo_table_row_descriptor ?= lo_source_table_descr->get_table_line_type( ).

  "excel instantiate

  DATA(lo_tool_xls) = cl_salv_export_tool_ats_xls=>create_for_excel( r_data = lr_excel_structure ).

  "Add columns to sheet

  DATA(lo_config) = lo_tool_xls->configuration( ).

  lo_config->add_column(
    EXPORTING
      header_text          = 'Company Code'
      field_name           = 'BUKRS'
      display_type         = if_salv_bs_model_column=>uie_text_view ).

  lo_config->add_column(
  EXPORTING
    header_text          = 'Customer ID'
    field_name           = 'KUNNR'
    display_type         = if_salv_bs_model_column=>uie_text_view ).

  lo_config->add_column(
  EXPORTING
    header_text          = 'Assignment NO'
    field_name           = 'ZUONR'
    display_type         = if_salv_bs_model_column=>uie_text_view ).

  lo_config->add_column(
  EXPORTING
    header_text          = 'Posting Date'
    field_name           = 'BUDAT'
    display_type         = if_salv_bs_model_column=>uie_text_view ).

  lo_config->add_column(
  EXPORTING
    header_text          = 'Currency'
    field_name           = 'WAERS'
    display_type         = if_salv_bs_model_column=>uie_text_view ).

  lo_config->add_column(
  EXPORTING
    header_text          = 'Amount'
    field_name           = 'DMBTR'
    display_type         = if_salv_bs_model_column=>uie_text_view ).

  "get excel in xstring

  TRY.
      lo_tool_xls->read_result(
        IMPORTING content = lv_content ).
    CATCH cx_root.

  ENDTRY.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = lv_content
    IMPORTING
      output_length = lv_length
    TABLES
      binary_tab    = lt_binary_tab.

ENDFORM.

FORM download_to_excel .

  CONCATENATE 'Customer Open Items' sy-datum sy-uzeit INTO lv_filename SEPARATED BY '_'.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title      = 'Enter File Name'                 " Window Title
      default_extension = 'XLSX'                 " Default Extension
      default_file_name = lv_filename                " Default File Name
    CHANGING
      filename          = lv_filename                " File Name to Save
      path              = lv_path                " Path to File
      fullpath          = lv_fullpath.                  " Path + File Name

  IF lv_fullpath IS NOT INITIAL.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        bin_filesize            = lv_length
        filename                = lv_fullpath
        filetype                = 'BIN'
      TABLES
        data_tab                = lt_binary_tab
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        OTHERS                  = 22.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ELSE.

      CALL METHOD cl_gui_frontend_services=>execute
        EXPORTING
          document               = lv_fullpath                 " Path+Name to Document
*         application            =                  " Path and Name of Application
*         parameter              =                  " Parameter for Application
*         default_directory      =                  " Default Directory
*         maximized              =                  " Show Window Maximized
*         minimized              =                  " Show Window Minimized
*         synchronous            =                  " When 'X': Runs the Application in Synchronous Mode
*         operation              = 'OPEN'           " Reserved: Verb for ShellExecute
        exceptions
          cntl_error             = 1                " Control error
          error_no_gui           = 2                " No GUI available
          bad_parameter          = 3                " Incorrect parameter combination
          file_not_found         = 4                " File not found
          path_not_found         = 5                " Path not found
          file_extension_unknown = 6                " Could not find application for specified extension
          error_execute_failed   = 7                " Could not execute application or document
          synchronous_failed     = 8                " Cannot Call Application Synchronously
          not_supported_by_gui   = 9                " GUI does not support this
          others                 = 10.
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

    ENDIF.


  ENDIF.


ENDFORM.