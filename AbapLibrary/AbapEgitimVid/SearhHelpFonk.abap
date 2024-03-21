*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_SH_002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egitim_sh_002.


TYPES: BEGIN OF gty_list,
       PERS_ID TYPE ZABAP_EGITIM_EMPLOYEE_ID_DE,
       PERS_AD TYPE ZFURKAN_PERSAD_DE,
       PERS_SOY TYPE ZFURKAN_PERSSOYAD_DE,
       END OF gty_list.

DATA:gt_list TYPE TABLE OF gty_list,
       gt_return_tab TYPE TABLE OF DDSHRETVAL,
       gt_mapping TYPE TABLE OF dselc,
       gs_mapping TYPE dselc.
"      FIELD_TAB STRUCTURE  DFIES OPTIONAL
"      RETURN_TAB STRUCTURE  DDSHRETVAL OPTIONAL
"      DYNPFLD_MAPPING STRUCTURE  DSELC OPTIONAL->Çoklu data aktarımı için kullanıcaz



PARAMETERS: p_id  TYPE int4,
            p_ad  TYPE char30,
            p_syd TYPE char40.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_id.


  SELECT * FROM ZABAP_EGT_005
    INTO CORRESPONDING FIELDS OF TABLE gt_list.


   gs_mapping-fldname = 'F0001'."Return tabdaki kolon name"
   gs_mapping-dyfldname = 'P_ID'.
   APPEND gs_mapping TO gt_mapping.

   gs_mapping-fldname = 'F0002'."Return tabdaki kolon name"
   gs_mapping-dyfldname = 'P_AD'.
   APPEND gs_mapping TO gt_mapping.

   gs_mapping-fldname = 'F0003'."Return tabdaki kolon name"
   gs_mapping-dyfldname = 'P_SYD'.
   APPEND gs_mapping TO gt_mapping.



  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'PERS_ID '
      dynpprog        = sy-repid
      dynpnr          = SY-DYNNR
      dynprofield     = 'P_ID '
      value_org       = 'S'
    TABLES
      value_tab       = gt_list
      return_tab      = gt_return_tab
      dynpfld_mapping = gt_mapping
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


START-OF-SELECTION.