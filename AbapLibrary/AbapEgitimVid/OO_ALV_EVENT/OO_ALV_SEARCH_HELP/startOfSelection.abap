*& Report ZABAP_EGITIM_037
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_037.

INCLUDE ZABAP_EGITIM_037_top.
INCLUDE ZABAP_EGITIM_037_cls.
INCLUDE ZABAP_EGITIM_037_pbo.
INCLUDE ZABAP_EGITIM_037_pai.
INCLUDE ZABAP_EGITIM_037_frm.

START-OF-SELECTION.

PERFORM get_data.
perform set_fcat.
perform set_layout.

CALL SCREEN 0100.