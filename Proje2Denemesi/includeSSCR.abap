*&---------------------------------------------------------------------*
*& Include          Z_ABAP_EGITIM_SSCR
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  SELECTION-SCREEN BEGIN OF BLOCK bl0 WITH FRAME TITLE TEXT-000.

  PARAMETERS: p_perso AS CHECKBOX USER-COMMAND ussr1,
              p_perm  AS CHECKBOX USER-COMMAND ussr2.

  SELECTION-SCREEN END OF BLOCK bl0.

  SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_id  TYPE zabap_egt_pers_t-pers_id MODIF ID m1,
              p_adi TYPE zabap_egt_pers_t-pers_ad MODIF ID m1,
              p_syd TYPE zabap_egt_pers_t-pers_soyad MODIF ID m1,
              p_cns TYPE zabap_egt_pers_t-pers_cins MODIF ID m1,
              p_sal TYPE zabap_egt_perm_t-pers_sal MODIF ID m1.
  SELECTION-SCREEN END OF BLOCK bl1.

  SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-002.
  PARAMETERS : p_add AS CHECKBOX USER-COMMAND usr1,
               p_del AS CHECKBOX USER-COMMAND usr2,
               p_upd AS CHECKBOX USER-COMMAND usr3.

  SELECTION-SCREEN END OF BLOCK bl2.



AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    CASE 'X'.
      WHEN p_perso.
        IF screen-name CS 'P_SAL'.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
      WHEN p_perm.
        IF screen-name CS 'P_ADI' OR screen-name CS 'P_SYD' OR screen-name CS 'P_CNS'.
           screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.
*  LOOP AT SCREEN. "Güncelle butonuna bastığı zaman bloklamak istediiğimiz parametre için kullanıyoruz."
*    CASE 'X'.
*      WHEN p_del.
*        IF screen-name CS 'P_SYD' OR screen-name CS 'P_CNS'.
*          screen-input = 0."Koşulda seçilen parametreyi blokluyor."
*        ENDIF.
*        MODIFY SCREEN.
*      WHEN p_upd.
*        IF screen-name CS 'P_CNS'.
*          screen-input = 0.
*        ENDIF.
*        MODIFY SCREEN.
*    ENDCASE.
*  ENDLOOP.
AT SELECTION-SCREEN.
  gs_customer2-pers_id = p_id.
  gs_customer2-pers_sal = p_sal.
*  gs_customer-pers_id = p_id.
*  gs_customer-pers_ad = p_ad.
*  gs_customer-pers_soyad = p_syd.
*  gs_customer-pers_cins = p_cns.

  CASE sy-ucomm."Checkboxlardan personel ve maaş kısmını kontrol ettik"
    WHEN 'USSR1'.
      p_perso = abap_true.
      CLEAR: p_perm.
    WHEN 'USSR2'.
      p_perm = abap_true.
      CLEAR: p_perso.

  ENDCASE.

  CASE sy-ucomm."Checkboxlardan sadece birinin kontrol edilebilmesi için gerçekleştirdik"
    WHEN 'USR1'.
      p_add = abap_true.
      CLEAR: p_del ,p_upd.
    WHEN 'USR2'.
      p_del = abap_true.
      CLEAR: p_add , p_upd.
    WHEN 'USR3'.
      p_upd = abap_true.
      CLEAR: p_add, p_del.
  ENDCASE.



END-OF-SELECTION.

  CASE 'X'.
    WHEN p_add.
      INSERT INTO zabap_egt_perm_t VALUES gs_customer2.
      MESSAGE 'Tabloya Insert işlemi gerçekleşti' TYPE 'I' DISPLAY LIKE 'S'.
    WHEN p_del.

    WHEN p_upd.

  ENDCASE.
*  CASE 'X'.
*    WHEN p_add.
*      INSERT INTO zabap_egt_pers_t VALUES gs_customer.
*      MESSAGE 'Tabloya Insert işlemi gerçekleşti' TYPE 'I' DISPLAY LIKE 'S'.
*    WHEN p_del.
*      DELETE FROM zabap_egt_pers_t WHERE pers_id = p_id.
*      MESSAGE 'Silme işlemi gerçekleştirildi.' TYPE 'I' DISPLAY LIKE 'S'.
*    WHEN p_upd.
*      UPDATE zabap_egt_pers_t SET pers_ad = p_ad
*      WHERE pers_id EQ p_id.
*      MESSAGE 'Tabloda istediğiniz veri Update edildi.' TYPE 'I' DISPLAY LIKE 'S'.
*  ENDCASE.