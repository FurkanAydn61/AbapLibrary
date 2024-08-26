9000

PROCESS BEFORE OUTPUT.
MODULE ts_control_active_tab_set.
  CALL SUBSCREEN tsa_1
  INCLUDING g_ts_control-prog g_ts_control-subscreen.
MODULE pbo.
PROCESS AFTER INPUT.
CALL SUBSCREEN: tsa_1.
MODULE ts_control_active_tab_get.
MODULE pai.

9001

PROCESS BEFORE OUTPUT.
MODULE init.
MODULE pbo.
PROCESS AFTER INPUT.
MODULE pai.


9002

PROCESS BEFORE OUTPUT.
MODULE pbo.
PROCESS AFTER INPUT.
MODULE pai.