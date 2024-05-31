REPORT zfurkan_bal_log.

DATA: l_s_log       TYPE bal_s_log,
      lv_log_handle TYPE balloghndl,
      lt_log_handle TYPE bal_t_logh,
      l_s_msg       TYPE bal_s_msg.

l_s_log-extnumber = 'Log'.
l_s_log-aluser = sy-uname.
l_s_log-alprog = sy-repid.

CALL FUNCTION 'BAL_LOG_CREATE'
  EXPORTING
    i_s_log      = l_s_log                 " Log header data
  IMPORTING
    e_log_handle = lv_log_handle                 " Log handle
  EXCEPTIONS
    OTHERS       = 2.

CLEAR l_s_msg.

l_s_msg-msgty = 'E'.
l_s_msg-msgid = 'M8'.
l_s_msg-msgno = '003'.
l_s_msg-msgv1 = 'XYZ'.
l_s_msg-msgv2 = ''.
l_s_msg-msgv3 = ''.
l_s_msg-msgv4 = ''.

CALL FUNCTION 'BAL_LOG_MSG_ADD'
  EXPORTING
    i_s_msg       = l_s_msg
    i_log_handle  = lv_log_handle
  EXCEPTIONS
    log_not_found = 0
    OTHERS        = 1.

CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
  EXPORTING
*   I_S_DISPLAY_PROFILE                 =
    i_t_log_handle = lt_log_handle
*   I_T_MSG_HANDLE =
*   I_S_LOG_FILTER =
*   I_S_MSG_FILTER =
*   I_T_LOG_CONTEXT_FILTER              =
*   I_T_MSG_CONTEXT_FILTER              =
*   I_AMODAL       = ' '
  exceptions
    others         = 5.