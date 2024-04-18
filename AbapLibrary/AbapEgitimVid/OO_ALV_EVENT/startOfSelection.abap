*&---------------------------------------------------------------------*
*& Report ZABAP_EGT_OOALV_EVENT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egt_ooalv_event.

INCLUDE zabap_egt_ooalv_event_top.
INCLUDE zabap_egt_ooalv_event_cls.
INCLUDE zabap_egt_ooalv_event_pbo.
INCLUDE zabap_egt_ooalv_event_pai.
INCLUDE zabap_egt_ooalv_event_frm.



START-OF-SELECTION.


PERFORM get_data.
PERFORM set_fcat.
PERFORM set_layout.

CALL SCREEN 0100.