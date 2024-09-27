*&---------------------------------------------------------------------*
*& Report ZFA_SSHOT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfa_sshot.

PARAMETERS: lo_path LOWER CASE TYPE string DEFAULT 'C:\Users\Forcode\Desktop\Yeni klasör\screenshoot.png'.

DATA: lv_mime_type   TYPE string,
      lv_image_bytes TYPE xstring.

TRY.
    cl_gui_frontend_services=>get_screenshot(
  IMPORTING
    mime_type_str        = lv_mime_type
    image                = lv_image_bytes  ).

    DATA(it_raw_data) = cl_bcs_convert=>xstring_to_solix( iv_xstring = lv_image_bytes  ).

    cl_gui_frontend_services=>gui_download(
      EXPORTING
        filename                  =  lo_path                    " Name of file
        filetype                  = 'BIN'                " File type (ASCII, binary ...)
      CHANGING
        data_tab                  =  it_raw_data                    " Transfer table
    ).
  CATCH cx_root INTO DATA(e_txt).

ENDTRY.