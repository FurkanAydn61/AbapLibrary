*& Report ZABAP_EGITIM_032
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egitim_032.


INCLUDE zabap_egitim_032_top.
INCLUDE zabap_egitim_032_pbo.
INCLUDE zabap_egitim_032_pai.
INCLUDE zabap_egitim_032_frm.

START-OF-SELECTION.
  PERFORM get_data.
  PERFORM set_fcat.
  PERFORM set_layout.


  CALL SCREEN 0100.