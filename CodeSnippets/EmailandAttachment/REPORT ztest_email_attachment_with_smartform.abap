REPORT ztest_email_attachment.

CONSTANTS:
lc_sfname TYPE tdsfname VALUE 'ZTEST_SMARTFORM'. "Name of Smartform

"Object References
DATA: lo_bcs         TYPE REF TO cl_bcs,
      lo_doc_bcs     TYPE REF TO cl_document_bcs,
      lo_recep       TYPE REF TO if_recipient_bcs,
      lo_sapuser_bcs TYPE REF TO cl_sapuser_bcs,
      lo_cx_bcx      TYPE REF TO cx_bcs.

"Internal Tables.
DATA: lt_otfdata        TYPE ssfcrescl,
      lt_binary_content TYPE solix_tab,
      lt_text           TYPE bcsy_text,
      lt_pdf_tab        TYPE STANDARD TABLE OF tline,
      lt_otf            TYPE STANDARD TABLE OF itcoo.

"Work Areas
DATA: ls_ctrlop TYPE ssfctrlop,
      ls_outopt TYPE ssfcompop.

"Variables
DATA: lv_bin_filesize TYPE so_obj_len,
      lv_sent_to_all  TYPE os_boolean,
      lv_bin_xstr     TYPE xstring,
      lv_fname        TYPE rs38l_fnam,
      lv_string_text  TYPE string.

CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    formname           = lc_sfname
  IMPORTING
    fm_name            = lv_fname
  EXCEPTIONS
    no_form            = 1
    no_function_module = 2
    OTHERS             = 3.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

"Control Parameters
ls_ctrlop-getotf    = 'X'.
ls_ctrlop-no_dialog = 'X'.
ls_ctrlop-preview   = space.

"Output Options
ls_outopt-tdnoprev  = 'X'.
ls_outopt-tddest    = 'LOCL'.
ls_outopt-tdnoprint = 'X'.

CALL FUNCTION lv_fname
  EXPORTING
    control_parameters = ls_ctrlop
    output_options     = ls_outopt
  IMPORTING
    job_output_info    = lt_otfdata
  EXCEPTIONS
    formatting_error   = 1
    internal_error     = 2
    send_error         = 3
    user_canceled      = 4
    OTHERS             = 5.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.


lt_otf[] = lt_otfdata-otfdata[].

CALL FUNCTION 'CONVERT_OTF'
  EXPORTING
    format                = 'PDF'
  IMPORTING
    bin_filesize          = lv_bin_filesize
    bin_file              = lv_bin_xstr
  TABLES
    otf                   = lt_otf[]
    lines                 = lt_pdf_tab[]
  EXCEPTIONS
    err_max_linewidth     = 1
    err_format            = 2
    err_conv_not_possible = 3
    OTHERS                = 4.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

***Xstring to binary
CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
  EXPORTING
    buffer     = lv_bin_xstr
  TABLES
    binary_tab = lt_binary_content.

TRY.
*     -------- create persistent send request ------------------------
    lo_bcs = cl_bcs=>create_persistent( ).

    "First line
    CONCATENATE 'Dear Colleague' cl_abap_char_utilities=>newline INTO lv_string_text.
    APPEND lv_string_text TO lt_text.
    CLEAR lv_string_text.
    "Second line
    CONCATENATE 'Please find attached a test smartform.'
     cl_abap_char_utilities=>newline INTO lv_string_text.
    APPEND lv_string_text TO lt_text.
    CLEAR lv_string_text.
    "Third line
    APPEND 'Best Regards,' TO lt_text.
    "Fourth line
    APPEND 'Systems Administrator.' TO lt_text.
*---------------------------------------------------------------------
*-----------------&      Create Document     *------------------------
*---------------------------------------------------------------------
    lo_doc_bcs = cl_document_bcs=>create_document(
                    i_type    = 'RAW'
                    i_text    = lt_text[]
                    i_length  = '12'
                    i_subject = 'Test Email' ).   "Subject of the Email

*---------------------------------------------------------------------
*-----------------&   Add attachment to document     *----------------
*---------------------------------------------------------------------
*     BCS expects document content here e.g. from document upload
*     binary_content = ...
    CALL METHOD lo_doc_bcs->add_attachment
      EXPORTING
        i_attachment_type    = 'PDF'
        i_attachment_size    = lv_bin_filesize
        i_attachment_subject = 'Test Email'
        i_att_content_hex    = lt_binary_content.

*     add document to send request
    CALL METHOD lo_bcs->set_document( lo_doc_bcs ).

    lo_recep = cl_cam_address_bcs=>create_internet_address(
                                             'test@test123.com' ).

    "Add recipient with its respective attributes to send request
    CALL METHOD lo_bcs->add_recipient
      EXPORTING
        i_recipient = lo_recep
        i_express   = 'X'.

    CALL METHOD lo_bcs->set_send_immediately
      EXPORTING
        i_send_immediately = 'X'.

*---------------------------------------------------------------------
*-----------------&   Send the email    *-----------------------------
*---------------------------------------------------------------------
    CALL METHOD lo_bcs->send(
      EXPORTING
        i_with_error_screen = 'X'
      RECEIVING
        result              = lv_sent_to_all ).

    IF lv_sent_to_all IS NOT INITIAL.
      COMMIT WORK.
    ENDIF.


*---------------------------------------------------------------------
*-----------------&   Exception Handling     *------------------------
*---------------------------------------------------------------------
  CATCH cx_bcs INTO lo_cx_bcx.
    "Appropriate Exception Handling
    WRITE: 'Exception:', lo_cx_bcx->error_type.
ENDTRY.