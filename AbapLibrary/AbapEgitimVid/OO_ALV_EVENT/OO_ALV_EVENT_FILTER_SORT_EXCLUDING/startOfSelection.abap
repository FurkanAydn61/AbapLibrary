*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_040
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egitim_040.


INCLUDE zabap_egitim_040_top.
INCLUDE zabap_egitim_040_cls.
INCLUDE zabap_egitim_040_pbo.
INCLUDE zabap_egitim_040_pai.
INCLUDE zabap_egitim_040_frm.

START-OF-SELECTION.


  PERFORM get_data.
  PERFORM set_fcat.
  PERFORM set_layout.


  CALL SCREEN 0100.