*&---------------------------------------------------------------------*
PROGRAM zfi_p_unilever_update.

INCLUDE zfi_p_unilever_update_clsdat.
INCLUDE zfi_p_unilever_update_frmdat.

LOAD-OF-PROGRAM.
  _controller = NEW lcl_controller( )->instantiate_app(
    EXPORTING
      iv_model = lcl_controller=>mc_model
      iv_view  = lcl_controller=>mc_view ).

INITIALIZATION.
  _controller->mo_model->initialization_dat( ).

AT SELECTION-SCREEN OUTPUT.

_controller->at_selection_screen_output( ).

START-OF-SELECTION.
  _controller->start_of_selection( ).

END-OF-SELECTION.
  _controller->end_of_selection( ).