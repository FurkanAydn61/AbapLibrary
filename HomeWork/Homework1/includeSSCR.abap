*&---------------------------------------------------------------------*
*& Include          ZABAP_EGITIM_DEMO_PROJECT_SSCR
*&---------------------------------------------------------------------*

AT SELECTION-SCREEN OUTPUT.

LOOP AT SCREEN.
 CASE 'X'.
 	WHEN p_cbox1.
    IF screen-name CS 'P_NUM2' OR screen-name CS 'P_NUM3'.
        screen-active = 0.
    ENDIF.
    MODIFY SCREEN.
 	WHEN p_cbox2.
    IF screen-name CS 'P_NUM3'.
       screen-active = 0.
    ENDIF.
    MODIFY SCREEN.
 	WHEN p_cbox3.
    IF p_rad1 EQ abap_true AND screen-name CS 'P_NUM2'.
       screen-active = 0.
    ENDIF.
    MODIFY SCREEN.
 ENDCASE.
 ENDLOOP.

 AT SELECTION-SCREEN.

  CASE sy-ucomm.
    WHEN 'CM1'.
       p_cbox1 = abap_true.
      CLEAR: p_cbox2, p_cbox3.
    WHEN 'CM2'.
       p_cbox2 = abap_true.
      CLEAR: p_cbox1, p_cbox3.

    WHEN 'CM3'.
      p_cbox3 = abap_true.
      CLEAR: p_cbox2, p_cbox1.
  ENDCASE.

  CASE 'X'.
    WHEN p_cbox1.
      IF p_rad1 EQ abap_true.
        CALL FUNCTION 'ZABAP_EGITIM_FMAL'
          EXPORTING
            iv_kkenar       = p_num1
            iv_sec          = 'K'
         IMPORTING
           EV_ALAN         = gv_alan
                  .
        IF sy-subrc EQ 0.
        gv_text = 'Alanı: ' && gv_alan.
        CLEAR: p_num1.
        ENDIF.
      ELSEIF p_rad2 EQ abap_true.
       CALL FUNCTION 'ZABAP_EGITIM_FMCV'
         EXPORTING
           iv_edge1       = p_num1
           iv_cho         = 'K'
        IMPORTING
          IV_CEVRE       = gv_cevre
                 .
       IF sy-subrc EQ 0.
       gv_text = 'Çevresi : ' && gv_cevre.
       CLEAR: p_num1.
       ENDIF.
      ENDIF.
    WHEN p_cbox2 .

      IF p_rad1 EQ abap_true.

        CALL FUNCTION 'ZABAP_EGITIM_FMAL'
          EXPORTING
            iv_kkenar       = p_num1
            iv_ukenar       = p_num2
*           IV_YUKSEK       =
            iv_sec          = 'D'
         IMPORTING
           EV_ALAN         = gv_alan
          CHANGING
          CV_EQ           =  gv_mes
          EXCEPTIONS
          CV_EQ           = 1
          OTHERS          = 2
                 .
        IF sy-subrc EQ 0.
        gv_text = 'Alanı :' && gv_alan.
        ELSEIF sy-subrc EQ 1.
          CLEAR: p_num1, p_num2.
        MESSAGE 'Kısa kenar uzun kenardan büyük olamaz' TYPE 'E' DISPLAY LIKE 'I'.
        ENDIF.
      ELSEIF p_rad2 EQ abap_true.
        CALL FUNCTION 'ZABAP_EGITIM_FMCV'
          EXPORTING
            iv_edge1       = p_num1
            iv_edge2       = p_num2
            iv_cho         = 'D'
         IMPORTING
           iv_cevre        = gv_cevre
         CHANGING
         CV_EQ             = gv_mes
         EXCEPTIONS
         CV_EQ             = 1
         OTHERS            = 2
                  .
        IF sy-subrc EQ 0.
        gv_text = 'Çevresi :' && gv_cevre.

        ELSEIF sy-subrc EQ 1.
        CLEAR:p_num1, p_num2.
        MESSAGE 'Kısa kenarın uzunluğu uzun kenardan büyük olamaz' TYPE 'E' DISPLAY LIKE 'I'.

        ENDIF.
      ENDIF.


    WHEN p_cbox3.
    IF p_rad1 EQ abap_true.
      CALL FUNCTION 'ZABAP_EGITIM_FMAL'
        EXPORTING
          iv_kkenar       = p_num1
*         IV_UKENAR       =
          IV_YUKSEK       = p_num3
          iv_sec          = 'U'
       IMPORTING
         EV_ALAN         = gv_alan
                .
      IF sy-subrc EQ 0.
      gv_text = 'Alanı :' && gv_alan.
      CLEAR: p_num1,p_num2.
      ENDIF.
    ELSEIF p_rad2 EQ abap_true.
      CALL FUNCTION 'ZABAP_EGITIM_FMCV'
        EXPORTING
          iv_edge1       = p_num1
          iv_edge2       = p_num2
          iv_edge3       = p_num3
          iv_cho         = 'U'
       IMPORTING
          iv_cevre       = gv_cevre
        CHANGING
          CV_EQ           =  gv_mes
          EXCEPTIONS
          CV_EQ           = 1
          OTHERS          = 2
                .
      IF sy-subrc EQ 0.
      gv_text = 'Çevresi :' && gv_cevre.
      ELSEIF sy-subrc EQ 1.
       CLEAR:p_num1 , p_num2 , p_num3.
      MESSAGE 'Kısa kenarın büyüklüğü uzun kenardan fazla olamaz' TYPE 'E' DISPLAY LIKE 'I'.
      ENDIF.
    ENDIF.
  ENDCASE.

  START-OF-SELECTION.
WRITE: gv_text.