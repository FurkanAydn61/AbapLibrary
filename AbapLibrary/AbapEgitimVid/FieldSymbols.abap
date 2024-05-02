*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_028
*&---------------------------------------------------------------------*
*&Field Symbol Yapısı
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_028.

DATA: gt_scarr TYPE TABLE OF scarr,
      gs_scarr TYPE scarr.

FIELD-SYMBOLS: <gfs_scarr> TYPE scarr.


START-OF-SELECTION.


SELECT * FROM scarr INTO TABLE gt_scarr.


* Yöntem 1*
*  LOOP AT gt_scarr INTO gs_scarr.
*    IF gs_scarr-carrid EQ 'LH'.
*      gs_scarr-carrname = 'Türk Hava Yolları'.
*      MODIFY gt_scarr FROM gs_scarr.
*    ENDIF.
*  ENDLOOP.

* Field Symbol Kullanımı
*LOOP AT gt_scarr ASSIGNING <gfs_scarr>.
*  IF <gfs_scarr>-carrid EQ 'LH'.
*     <gfs_scarr>-carrname = 'Türk Hava Yolları'.
*  ENDIF.
*  ENDLOOP.

*Read Table ve Field Symbol birlikte kullanımı

READ TABLE gt_scarr ASSIGNING <gfs_scarr> WITH KEY carrid = 'LH'.
<gfs_scarr>-carrname = 'Anadolu Jet'.


  BREAK-POINT.