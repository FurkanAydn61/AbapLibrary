*& Report ZABAP_EGITIM_039
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_039.

INCLUDE zabap_egitim_039_top.
INCLUDE zabap_egitim_039_cls.
INCLUDE zabap_egitim_039_pbo.
INCLUDE zabap_egitim_039_pai.
INCLUDE zabap_egitim_039_frm.

START-OF-SELECTION.

PERFORM get_data.
PERFORM set_fcat.
PERFORM set_layout.


CALL SCREEN 0100.