*& Include          ZABAP_FA_TUTORIAL_008_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_1001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1001 OUTPUT.
 SET PF-STATUS '1001'.

 go_alv_operation->get_data( ).
 go_alv_operation->set_fcat( ).
 go_alv_operation->set_layout( ).
 go_alv_operation->display_alv( ).


ENDMODULE.