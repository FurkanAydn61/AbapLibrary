*&---------------------------------------------------------------------*
*& Report ZABAP_EGT_DDOWN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egt_ddown.
TYPE-POOLS: vrm.


DATA: gt_list TYPE vrm_values.
DATA: gs_list TYPE vrm_value.
DATA: gt_values  TYPE TABLE OF dynpread,
      gwa_values TYPE dynpread.

DATA: gv_selected_value(10) TYPE c.


PARAMETERS: list TYPE c AS LISTBOX VISIBLE LENGTH 20.

INITIALIZATION.

  CLEAR: gs_list.
  gs_list-key = '1'.
  gs_list-text = 'Product'.
  APPEND gs_list TO gt_list.

  CLEAR: gs_list.
  gs_list-key = '2'.
  gs_list-text = 'Collection'.
  APPEND gs_list TO gt_list.

  CLEAR: gs_list.
  gs_list-key = '3'.
  gs_list-text = 'Color'.
  APPEND gs_list TO gt_list.

  CLEAR: gs_list.
  gs_list-key = '4'.
  gs_list-text = 'Count'.
  APPEND gs_list TO gt_list.



  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'LIST'
      values          = gt_list
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.



AT SELECTION-SCREEN ON list.
  CLEAR: gwa_values, gt_values.
  REFRESH gt_values.
  gwa_values-fieldname = 'LIST'.
  APPEND gwa_values TO gt_values.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = sy-cprog
      dynumb             = sy-dynnr
      translate_to_upper = 'X'
    TABLES
      dynpfields         = gt_values.

  READ TABLE gt_values INDEX 1 INTO gwa_values.
  IF sy-subrc  EQ 0 AND gwa_values-fieldname IS NOT INITIAL.
     READ TABLE gt_list INTO gs_list WITH KEY key = gwa_values-fieldvalue.
     IF SY-subrc EQ 0.
        gv_selected_value = gs_list-text.
     ENDIF.
  ENDIF.


START-OF-SELECTION.

WRITE: / gv_selected_value.