*&---------------------------------------------------------------------*
*& Report ZABAP_EGT_READ_TABLE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGT_READ_TABLE.

DATA: gt_scarr TYPE TABLE OF scarr,
      gs_scarr TYPE scarr.



START-OF-SELECTION.


SELECT * FROM scarr INTO TABLE gt_scarr.

************Index kullanımı fazla tercih edilmez
*READ TABLE gt_scarr INTO gs_scarr INDEX 4.

WRITE: gs_scarr.

******************************************
**************KEY KULLANIMI***************
*READ TABLE gt_scarr INTO gs_scarr WITH KEY carrid = 'AZ'.
*READ TABLE gt_scarr INTO gs_scarr WITH KEY carrname = 'Alitalia'.
*Birden fazl koşul kullanılarak çalıştırılabilir. Read Table mantığı equal mantığı ile aynıdır.
READ TABLE gt_scarr INTO gs_scarr WITH KEY currcode = 'EUR'
                                           carrname = 'Alitalia'.
WRITE: gs_scarr.