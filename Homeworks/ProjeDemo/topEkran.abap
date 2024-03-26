*&---------------------------------------------------------------------*
*& Include          ZABAP_EGITIM_DEMO_PROJECTTOP
*&---------------------------------------------------------------------*
*Her iki tabloyu birleştirebilmek için bir types oluşturduk
TYPES: BEGIN OF gtp_bilgi,
         pers_id    TYPE zabap_egitim_deneme_persid_de,
         pers_ad    TYPE zabap_egitim_deneme_perad_de,
         pers_soyad TYPE zabap_egitim_deneme_persyad_de,
         pers_cins  TYPE zabap_egitim_deneme_persc_de,
         pers_sal   TYPE zabap_egitim_deneme_perssal_de,
       END OF gtp_bilgi.
*Personel bilgi tablosu için bir types oluşturduk
TYPES: BEGIN OF gp_den,
         pers_id    TYPE zabap_egitim_deneme_persid_de,
         pers_ad    TYPE zabap_egitim_deneme_perad_de,
         pers_soyad TYPE zabap_egitim_deneme_persyad_de,
         pers_cins  TYPE zabap_egitim_deneme_persc_de,
       END OF gp_den.
*Personel maaş tablosu için bir types oluşturduk.
TYPES: BEGIN OF gm_info,
         pers_id  TYPE zabap_egitim_deneme_persid_de,
         pers_sal TYPE zabap_egitim_deneme_perssal_de,
       END OF gm_info.


DATA: gt_pers TYPE TABLE OF zabap_egt_pers_t,
      gt_pma  TYPE TABLE OF zabap_egt_perm_t.

DATA: gs_pers TYPE zabap_egt_pers_t,
      gs_maas TYPE zabap_egt_perm_t.

* Her iki tablonun types ını değerlere atadık.
DATA: gtt_pers TYPE TABLE OF gtp_bilgi,
      gss_pers TYPE gtp_bilgi.

* Personel bilgi tablosunun types ını değerlere atadık.
DATA: gtp_den TYPE TABLE OF gp_den,
      gsp_den TYPE gp_den.

* Personel Maaş tablosunun types ın değerlere atadık

DATA: gmt_den TYPE TABLE OF gm_info,
      gms_den TYPE gm_info.