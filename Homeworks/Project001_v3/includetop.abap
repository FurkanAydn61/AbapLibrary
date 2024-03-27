*&---------------------------------------------------------------------*
*& Include          ZABAP_EGT_SEKIL_CL_TOP
*&---------------------------------------------------------------------*

DATA: gv_cevre TYPE int4,
      gv_alan TYPE int4,
      gv_text TYPE char100.


DATA: go_kno TYPE REF TO ZABAP_CL_SEKIL_AL.


CREATE OBJECT: go_kno.