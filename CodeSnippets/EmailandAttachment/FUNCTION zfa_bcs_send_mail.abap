FUNCTION zfa_bcs_send_mail.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(SUBJECT) TYPE  SO_OBJ_DES
*"     REFERENCE(MESSAGE_BODY) TYPE  BCSY_TEXT
*"     REFERENCE(ATTACHMENTS) TYPE  RMPS_T_POST_CONTENT OPTIONAL
*"     REFERENCE(SENDER_UID) TYPE  SYUNAME OPTIONAL
*"     REFERENCE(RECIPIENT_UID) TYPE  SYUNAME OPTIONAL
*"     REFERENCE(SENDER_MAIL) TYPE  ADR6-SMTP_ADDR OPTIONAL
*"     REFERENCE(RECIPIENT_MAIL) TYPE  ADR6-SMTP_ADDR OPTIONAL
*"     REFERENCE(I_TYPE) TYPE  SO_OBJ_TP OPTIONAL
*"  EXPORTING
*"     REFERENCE(RESULT) TYPE  BOOLEAN
*"  TABLES
*"      RECIPIENTS STRUCTURE  ADR6 OPTIONAL
*"----------------------------------------------------------------------
  "Data Declaration

  DATA: lo_sender TYPE REF TO if_sender_bcs VALUE IS INITIAL,
        l_send    TYPE adr6-smtp_addr,
        l_rec     TYPE adr6-smtp_addr.

  DATA: itab     TYPE TABLE OF sval,
        ls_itab  TYPE sval,
        i_return.
  DATA: lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.

  DATA: lx_document_bcs    TYPE REF TO cx_document_bcs VALUE IS INITIAL,
        attachment_subject TYPE so_obj_des.

  DATA: lo_recipient TYPE REF TO if_recipient_bcs VALUE IS INITIAL.
  DATA: ls_recipient  LIKE LINE OF recipients,
        ls_attachment LIKE LINE OF attachments.

  DATA: lv_recipient_uid  TYPE syuname,
        lv_recipient_mail TYPE adr6-smtp_addr.

*Prepare Mail Object
  CLASS cl_bcs DEFINITION LOAD.
  lo_send_request = cl_bcs=>create_persistent( ).
*Message body and subject
  DATA: lv_type TYPE so_obj_tp.
  IF i_type IS INITIAL.
    lv_type = 'RAW'.
  ELSE.
    lv_type = i_type.
  ENDIF.
  DATA: lo_document TYPE REF TO cl_document_bcs VALUE IS INITIAL.
  lo_document = cl_document_bcs=>create_document(
                  i_type          = i_type
                  i_subject       = subject
                  i_text         = message_body ).

*Send Attachment
  LOOP AT attachments INTO ls_attachment.
    attachment_subject = ls_attachment-subject.
    TRY.
        lo_document->add_attachment(
        EXPORTING
          i_attachment_type     = ls_attachment-objtp
          i_attachment_subject  = attachment_subject
          i_att_content_hex     = ls_attachment-cont_hex
        ).
      CATCH cx_document_bcs INTO lx_document_bcs.
    ENDTRY.
  ENDLOOP.
*Pass the document to send request
  lo_send_request->set_document( lo_document ).
  TRY.
      IF sender_mail IS NOT INITIAL.
        lo_sender = cl_cam_address_bcs=>create_internet_address( sender_mail ).
      ELSEIF sender_uid IS NOT INITIAL.
        lo_sender = cl_sapuser_bcs=>create( sender_uid ).
      ELSE.
        lo_sender = cl_sapuser_bcs=>create( sy-uname ).
      ENDIF.
*Set Sender
      lo_send_request->set_sender(
      EXPORTING
      i_sender = lo_sender ).
    CATCH cx_address_bcs.
      RETURN.
  ENDTRY.
*Set recipients

  IF recipients[] IS INITIAL.

    IF recipient_mail IS NOT INITIAL.
      lo_recipient = cl_cam_address_bcs=>create_internet_address( recipient_mail ).
    ELSEIF recipient_uid IS NOT INITIAL.
      lo_recipient = cl_sapuser_bcs=>create( recipient_uid ).
    ELSE.
      lo_recipient = cl_sapuser_bcs=>create( sy-uname ).
    ENDIF.

    lo_send_request->add_recipient(
    EXPORTING
      i_recipient  = lo_recipient                  " Recipient of Message
      i_express    = 'X'                 " Send As Express Message
    ).
  ELSE.
    LOOP AT  recipients INTO ls_recipient.
      IF ls_recipient-r3_user IS NOT INITIAL.
        lv_recipient_uid = ls_recipient-r3_user.
        lo_recipient = cl_sapuser_bcs=>create( lv_recipient_uid ).
      ELSEIF ls_recipient-smtp_addr IS NOT INITIAL.
        lv_recipient_mail = ls_recipient-smtp_addr.
        lo_recipient = cl_cam_address_bcs=>create_internet_address( lv_recipient_mail ).
      ENDIF.

      lo_send_request->add_recipient(
        i_recipient  = lo_recipient
        i_express    = 'X'
      ).
    ENDLOOP.
  ENDIF.

  TRY.
**Send email
      lo_send_request->send(
        EXPORTING
          i_with_error_screen = 'X'
        RECEIVING
          result              =  result ).
      COMMIT WORK.
      WAIT UP TO 1 SECONDS.
    CATCH cx_send_req_bcs.
      result = ''.
  ENDTRY.

ENDFUNCTION.