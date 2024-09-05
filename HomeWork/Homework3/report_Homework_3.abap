REPORT zabap_egt_realv_exp.

INCLUDE zabap_egt_realv_exp_top.
INCLUDE zabap_egt_realv_exp_frm.

START-OF-SELECTION.
  PERFORM get_data.
  PERFORM set_fc.
  PERFORM set_layout.
  PERFORM display_alv.