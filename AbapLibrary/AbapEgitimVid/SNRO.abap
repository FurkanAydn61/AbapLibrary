*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_SNRO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_SNRO.

DATA : gt_emp TYPE TABLE OF ZABAP_EGT_EMP_T,
       gs_emp TYPE ZABAP_EGT_EMP_T.

START-OF-SELECTION.

PERFORM generate_emp_id.

FORM generate_emp_id .
  DATA: lv_message1 TYPE string,
      lv_status1 TYPE i.
CALL FUNCTION 'NUMBER_GET_NEXT'
  EXPORTING
    nr_range_nr                   = '01'
    object                        = 'ZSNRO_TEST'
 IMPORTING
   NUMBER                        = gs_emp-emp_id

 EXCEPTIONS
   INTERVAL_NOT_FOUND            = 1
   NUMBER_RANGE_NOT_INTERN       = 2
   OBJECT_NOT_FOUND              = 3
   QUANTITY_IS_0                 = 4
   QUANTITY_IS_NOT_1             = 5
   INTERVAL_OVERFLOW             = 6
   BUFFER_OVERFLOW               = 7
   OTHERS                        = 8
          .
IF sy-subrc <> 0.
    lv_message1 = 'Error occurred while generating customer ID'.
    MESSAGE lv_message1 TYPE 'E'.
    ELSE.
      INSERT INTO ZABAP_EGT_EMP_T VALUES gs_emp.
      WRITE: / 'Emp ID Generated: ', gs_emp-emp_id.
ENDIF.

ENDFORM.