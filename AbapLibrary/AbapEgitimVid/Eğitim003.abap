*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egitim_003.

DATA: gv_persid    TYPE zfurkan_persid_de,
      gv_persad    TYPE zfurkan_persad_de,
      gv_perssoyad TYPE zfurkan_perssoyad_de,
      gv_perscins  TYPE zfurkan_perscins_de,
      gs_pers_t    TYPE zfurkan_pers_t,
      gt_pers_t    TYPE TABLE OF zfurkan_pers_t."Internal Table"
*SELECT
*UPDATE
*INSERT
*DELETE
*MODIFY


***************SELECT SORGUSU*********************
*********INTERNAL TABLE SELECT SORGUSU************
*SELECT * FROM zfurkan_pers_t
*  INTO TABLE gt_pers_t.
*
*SELECT * FROM zfurkan_pers_t
*  INTO TABLE gt_pers_t
*  WHERE pers_id EQ 1.
**********STRUCTURE YAPISI SELECT SORGUSU**********
*SELECT SINGLE * FROM zfurkan_pers_t
*  INTO gs_pers_t.
********TEK BİR KOLON ÇEKMEK***********************
* SELECT SINGLE PERS_ID FROM zfurkan_pers_t
*   INTO gv_persid.
* SELECT SINGLE PERS_AD FROM zfurkan_pers_t
*   INTO gv_persad.
* SELECT SINGLE PERS_SOYAD FROM zfurkan_pers_t
*   INTO gv_perssoyad.
* SELECT SINGLE PERS_CINS FROM zfurkan_pers_t
*   INTO gv_perscins.

*************UPDATE SORGUSU*****************
*UPDATE zfurkan_pers_t SET pers_ad = 'BERKAY'
* WHERE pers_id EQ 2.
*WRITE : 'Update komutu çalıştırıldı'.
*UPDATE zfurkan_pers_t SET pers_soyad = 'KAP'
* WHERE pers_id EQ 2.
*WRITE: 'Update 2 komutu çalıştırıldı'.

**************INSERT SORGUSU********************
*gs_pers_t-pers_id = 3.
*gs_pers_t-pers_ad = 'BARAN'.
*gs_pers_t-pers_soyad = 'AYTEKİN'.
*gs_pers_t-pers_cins = 'E'.
*
*INSERT zfurkan_pers_t FROM gs_pers_t.
*
*WRITE : 'Insert komutu çalıştırıldı'.

***************DELETE SORGUSU**********************
*DELETE FROM zfurkan_pers_t WHERE pers_id EQ 2.
*
*WRITE: 'Delete sorgsusu çalıştırıldı.'.

**************MODIFY SORGUSU***********************
*INSERT VE UPDATE KARIŞIMI OLARAK KULLANILIR

*gs_pers_t-pers_id = 4.
*gs_pers_t-pers_ad = 'AYLİN'.
*gs_pers_t-pers_soyad = 'AYDIN'.
*gs_pers_t-pers_cins = 'K'.
*MODIFY zfurkan_pers_t FROM gs_pers_t.
*
*WRITE: 'Modify komutu çalıştırıldı'.


*gs_pers_t-pers_id = 5.
*gs_pers_t-pers_ad = 'SULTAN'.
*gs_pers_t-pers_soyad = 'AYDIN'.
*gs_pers_t-pers_cins = 'K'.
*
*INSERT zfurkan_pers_t FROM gs_pers_t.
*
*WRITE: 'INSERT KOMUTU ÇALIŞTIRILDI'.

UPDATE zfurkan_pers_t SET pers_soyad = 'TÜRKMEN '
WHERE pers_id EQ 5.

WRITE : 'UPDATE KOMUTU ÇALIŞTIRILDI'.