REPORT zabap_bal_log.

DATA: l_s_log       TYPE bal_s_log,
      lv_log_handle TYPE balloghndl,
      lt_log_handle TYPE bal_t_logh,
      l_s_msg       TYPE bal_s_msg.

l_s_log-extnumber = 'Log'.
l_s_log-aluser = sy-uname.
l_s_log-alprog = sy-repid.

CALL FUNCTION 'BAL_LOG_CREATE'
  EXPORTING
    i_s_log      = l_s_log
  IMPORTING
    e_log_handle = lv_log_handle
  EXCEPTIONS
    OTHERS       = 2.

CLEAR: l_s_msg.
l_s_msg-msgty = 'E'. "E,W,I,S"
l_s_msg-msgid = 'M8'.
l_s_msg-msgno = '003'.
l_s_msg-msgv1 = 'XYZ'.
l_s_msg-msgv2 = ''.
l_s_msg-msgv3 = ''.
l_s_msg-msgv4 = ''.

CALL FUNCTION 'BAL_LOG_MSG_ADD'
  EXPORTING
    i_log_handle  = lv_log_handle
    i_s_msg       = l_s_msg
  EXCEPTIONS
    log_not_found = 1
    OTHERS        = 4.

CLEAR: l_s_msg.
l_s_msg-msgty = 'S'. "E,W,I,S"
l_s_msg-msgid = 'M8'.
l_s_msg-msgno = '007'.
l_s_msg-msgv1 = 'Test123'.
l_s_msg-msgv2 = ''.
l_s_msg-msgv3 = ''.
l_s_msg-msgv4 = ''.

CALL FUNCTION 'BAL_LOG_MSG_ADD'
  EXPORTING
    i_log_handle  = lv_log_handle
    i_s_msg       = l_s_msg
  EXCEPTIONS
    log_not_found = 1
    OTHERS        = 4.

REFRESH lt_log_handle.
APPEND lv_log_handle TO lt_log_handle.

CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
  EXPORTING
    i_t_log_handle = lt_log_handle
  EXCEPTIONS
    OTHERS         = 5.