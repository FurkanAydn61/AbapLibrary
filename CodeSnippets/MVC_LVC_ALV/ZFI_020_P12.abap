*&---------------------------------------------------------------------*
*& Program ZFI_020_P12
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
PROGRAM zfi_020_p12.

INCLUDE zfi_020_p12_clsdat.
INCLUDE zfi_020_p12_frmdat.

LOAD-OF-PROGRAM.
  _controller = NEW lcl_controller( )->instantiate_app(
    EXPORTING
      iv_model = lcl_controller=>mc_model
      iv_view  = lcl_controller=>mc_view ).

INITIALIZATION.
  _controller->initialization( ).

AT SELECTION-SCREEN.
  _controller->at_selection_screen(
    EXCEPTIONS
      handle_error = 1
      OTHERS       = 2 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  _controller->at_selection_screen_output( ).

START-OF-SELECTION.
  _controller->mo_model->retrieve_data(
    EXCEPTIONS
      handle_error = 1
      OTHERS       = 2 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
  ENDIF.

END-OF-SELECTION.
  _controller->alv_session(
    EXCEPTIONS
      handle_error = 1
      OTHERS       = 2 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
  ENDIF.