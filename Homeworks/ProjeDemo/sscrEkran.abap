*&---------------------------------------------------------------------*
*& Include          ZABAP_EGITIM_DEMO_PROJECTSSCR
*&---------------------------------------------------------------------*

START-OF-SELECTION.

  SELECTION-SCREEN BEGIN OF BLOCK bl0 WITH FRAME TITLE TEXT-000.

  PARAMETERS: p_prs AS CHECKBOX USER-COMMAND usr1,
              p_maa AS CHECKBOX USER-COMMAND usr2.
  SELECTION-SCREEN END OF BLOCK bl0.

  SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_id  TYPE zabap_egitim_deneme_persid_de MODIF ID m1,
              p_adi TYPE zabap_egitim_deneme_perad_de MODIF ID m1,
              p_syd TYPE zabap_egitim_deneme_persyad_de MODIF ID m1,
              p_cns TYPE zabap_egitim_deneme_persc_de MODIF ID m1,
              p_sal TYPE zabap_egitim_deneme_perssal_de MODIF ID m1.
  SELECTION-SCREEN END OF BLOCK bl1.

  SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-002.
  PARAMETERS : p_add  AS CHECKBOX USER-COMMAND uc1,
               p_del  AS CHECKBOX USER-COMMAND uc2,
               p_upd  AS CHECKBOX USER-COMMAND uc3,
               p_view AS CHECKBOX USER-COMMAND uc4,
               p_info AS CHECKBOX USER-COMMAND uc5,
               p_mbil AS CHECKBOX USER-COMMAND uc6.

  SELECTION-SCREEN END OF BLOCK bl2.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN."Seçilen parametreye göre hangi ekranlarını görüneceğini belirledik"
    CASE 'X'.
      WHEN p_prs.
        IF screen-name CS 'P_SAL'.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
      WHEN p_maa.
        IF screen-name CS 'P_ADI' OR screen-name CS 'P_SYD' OR screen-name CS 'P_CNS'.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.

  LOOP AT SCREEN."Seçilen checkbox a göre bloklanacak kısmı belirledik."
    CASE 'X'.
      WHEN p_upd.
        IF p_prs EQ abap_true AND screen-name CS 'P_CNS'.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
      WHEN p_del.
        IF p_prs EQ abap_true AND screen-name CS 'P_CNS' OR screen-name CS 'P_SYD' .
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.

AT SELECTION-SCREEN.
  gs_pers-pers_id = p_id.
  gs_pers-pers_ad = p_adi.
  gs_pers-pers_soyad = p_syd.
  gs_pers-pers_cins = p_cns.
  gs_maas-pers_id = p_id.
  gs_maas-pers_sal = p_sal.

  CASE sy-ucomm. "Checkboxlardan sadece birinin kontrol edilebilmesi için gerçekleştirdik"
    WHEN 'USR1'.
      p_prs = abap_true.
      CLEAR: p_maa.
    WHEN 'USR2'.
      p_maa = abap_true.
      CLEAR: p_prs.
  ENDCASE.

  CASE sy-ucomm."Checkboxlardan sadece birinin kontrol edilebilmesi için gerçekleştirdik"
    WHEN 'UC1'.
      p_add = abap_true.
      CLEAR: p_del ,p_upd,p_view,p_info,p_mbil.
    WHEN 'UC2'.
      p_del = abap_true.
      CLEAR: p_add , p_upd,p_view,p_info,p_mbil.
    WHEN 'UC3'.
      p_upd = abap_true.
      CLEAR: p_add, p_del,p_view,p_info,p_mbil.
    WHEN 'UC4'.
      p_view = abap_true.
      CLEAR: p_add, p_del, p_upd,p_info,p_mbil.
    WHEN 'UC5'.
      p_info = abap_true.
      CLEAR: p_add, p_del, p_upd,p_view ,p_mbil.
    WHEN 'UC6'.
      p_mbil = abap_true.
      CLEAR: p_add, p_del, p_upd, p_view,p_info.
  ENDCASE.


END-OF-SELECTION.

  CASE 'X'."Insert Delete Update işlemlerini formladık"
    WHEN p_add.
      IF p_prs EQ abap_true.
        PERFORM inserttablepers USING p_id
                                      p_adi
                                      p_syd
                                      p_cns.
      ELSE.
        PERFORM inserttablesal USING p_id
                                     p_sal.
      ENDIF.
    WHEN p_del.
      IF p_prs EQ abap_true.
        PERFORM deltablepers USING p_id
                                   p_adi.
      ELSE.
        PERFORM  deltablesal USING p_id
                                   p_sal.
      ENDIF.
    WHEN p_upd.
      IF p_prs EQ abap_true.
        PERFORM updtablepers USING p_id
                                   p_adi
                                   p_syd.
      ELSE.
        PERFORM updtablesal USING p_id
                                  p_sal.
      ENDIF.
    WHEN p_view .
      "Tablomuzu açılan ekranda farklı bir screende iki tabloyu görüntülemek için kullanıyoruz"
      SELECT
        zabap_egt_pers_t~pers_id
        zabap_egt_pers_t~pers_ad
        zabap_egt_pers_t~pers_soyad
        zabap_egt_pers_t~pers_cins
        zabap_egt_perm_t~pers_sal
        FROM zabap_egt_pers_t  "Types yapısı oluşturduk tablomuzun bilgilerine göre data elementlerini alarak daha internal table a attık"
        INNER JOIN zabap_egt_perm_t
        ON zabap_egt_pers_t~pers_id EQ zabap_egt_perm_t~pers_id
        INTO CORRESPONDING FIELDS OF TABLE gtt_pers.  "CORRESPONDING FIELDS OF: Mandt kolonuna alamassak bile bunu yazarak hata mesajı olana yeteri uzunlukta değil errorunu engelleriz "

      LOOP AT gtt_pers INTO gss_pers."Ekrana tablomuzu yazdırıyoruz"
        WRITE : / gss_pers-pers_id, gss_pers-pers_ad, gss_pers-pers_soyad, gss_pers-pers_cins,gss_pers-pers_sal.
      ENDLOOP.
    WHEN p_info.
* Tablomuzu açılan ekranda sadece personel bilgi tablosunu görüntülemek için ayrı bir inernel table oluşturmamız gerekti.
      SELECT
      zabap_egt_pers_t~pers_id
       zabap_egt_pers_t~pers_ad
       zabap_egt_pers_t~pers_soyad
       zabap_egt_pers_t~pers_cins
        FROM zabap_egt_pers_t INTO CORRESPONDING FIELDS OF TABLE gtp_den.
      LOOP AT gtp_den INTO gsp_den.
        WRITE: / gsp_den-pers_id, gsp_den-pers_ad, gsp_den-pers_soyad, gsp_den-pers_cins.
      ENDLOOP.

     WHEN p_mbil.

       SELECT
        zabap_egt_perm_t~pers_id
        zabap_egt_perm_t~pers_sal
        FROM zabap_egt_perm_t  INTO CORRESPONDING FIELDS OF TABLE gmt_den.
     LOOP AT gmt_den INTO gms_den.
     WRITE: / gms_den-pers_id, gms_den-pers_sal.
     ENDLOOP.
  ENDCASE.


*  CASE 'X'.
*    WHEN p_add.
*      IF p_prs EQ abap_true.
*        INSERT INTO zabap_egt_pers_t VALUES gs_pers.
*        MESSAGE 'Tabloya insert işleminiz gerçekleştirildi.' TYPE 'I' DISPLAY LIKE 'S'.
*      ELSE.
*        INSERT INTO zabap_egt_perm_t VALUES gs_maas.
*        MESSAGE 'Tabloya insert işleminiz gerçekleştirildi.' TYPE 'I' DISPLAY LIKE 'S'.
*      ENDIF.
*    WHEN p_del.
*      IF p_prs EQ abap_true.
*        DELETE FROM zabap_egt_pers_t WHERE pers_id = p_id.
*        MESSAGE 'Silme işlemi başarıyla gerçekleştirildi.' TYPE 'I' DISPLAY LIKE 'S'.
*      ELSE.
*        DELETE FROM zabap_egt_perm_t WHERE pers_id = p_id.
*        MESSAGE 'Silme eyleminiz başarıyla gerçekleştirildi' TYPE 'I' DISPLAY LIKE 'S'.
*      ENDIF.
*    WHEN p_upd.
*      IF p_prs EQ abap_true.
*        UPDATE zabap_egt_pers_t SET pers_ad = p_adi
*        WHERE pers_id = p_id.
*        MESSAGE 'Güncelleme işleminiz başarıyla gerçekleşti.' TYPE 'I' DISPLAY LIKE 'S'.
*      ELSE.
*        UPDATE zabap_egt_perm_t SET pers_sal = p_sal
*        WHERE pers_id = p_id.
*        MESSAGE 'Update işleminiz gerçekleşti' TYPE 'I' DISPLAY LIKE 'S'.
*      ENDIF.
*  ENDCASE.