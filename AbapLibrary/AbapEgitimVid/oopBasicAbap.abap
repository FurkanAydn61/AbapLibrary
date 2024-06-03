*&---------------------------------------------------------------------*
*& Report ZABAP_FA_03
*&---------------------------------------------------------------------*
*& Abap içerisinde OOP yapısında 3 aşama bulunmaktadır.
*Class Definition, Class Implementation, Inheritance
*Class Definition içerisinde kodlamann erişim kıstaslarının belirlendiği 3 katman bulunmaktadır
* Public Section, Private Section, Protected Section
*&---------------------------------------------------------------------*

REPORT zabap_fa_03.

CLASS lcl_class DEFINITION.
  PUBLIC SECTION.
    METHODS: set IMPORTING VALUE(set_value) TYPE i,
      get EXPORTING VALUE(get_value) TYPE i.

  PROTECTED SECTION.
    METHODS increment.

  PRIVATE SECTION.

    DATA: count TYPE i.

ENDCLASS.

CLASS lcl_class IMPLEMENTATION.
  METHOD increment.
    count = count + 10.
    ENDMETHOD.
  METHOD set.
    count = set_value.
    increment( ).
    ENDMETHOD.
  METHOD get.
    get_value = count.
    ENDMETHOD.

ENDCLASS.

DATA: class_a TYPE REF TO lcl_class.
DATA: deger TYPE i.

START-OF-SELECTION.
 CREATE OBJECT class_a.
 class_a->set( set_value = 6 ).
 class_a->get(
   IMPORTING
     get_value = deger
 ).
 WRITE deger.