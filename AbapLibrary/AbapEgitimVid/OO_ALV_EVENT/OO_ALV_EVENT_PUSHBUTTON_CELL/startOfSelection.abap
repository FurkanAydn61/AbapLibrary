*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_038
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egitim_038.

INCLUDE zabap_egitim_038_top.
INCLUDE zabap_egitim_038_cls.
INCLUDE zabap_egitim_038_pbo.
INCLUDE zabap_egitim_038_pai.
INCLUDE zabap_egitim_038_frm.

START-OF-SELECTION.

PERFORM get_data.
PERFORM set_fcat.
PERFORM set_layout.

CALL SCREEN 0100.