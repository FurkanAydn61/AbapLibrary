REPORT zfa_ole2_template.

TABLES: sscrfields, sflight.

TYPES: BEGIN OF ty_t_excel_template,
         carrid    TYPE s_carr_id,
         connid    TYPE s_conn_id,
         countryfr TYPE	land1,
         cityfrom  TYPE  s_from_cit,
         airpfrom  TYPE s_fromairp,
         countryto TYPE	land1,
         cityto    TYPE s_to_city,
         airpto    TYPE s_toairp,
       END OF ty_t_excel_template.
DATA : lt_excel_format TYPE TABLE OF ty_t_excel_template,
       ls_excel_format TYPE ty_t_excel_template.

DATA: gt_spfli TYPE TABLE OF spfli.

" Selection-Screen Parameters
PARAMETERS : p_carrid   TYPE s_carr_id.

SELECTION-SCREEN : FUNCTION KEY 1.

INITIALIZATION.
  " Selection Screen Sample Excel Button with icon
  sscrfields-functxt_01 = '@J2@Excel Sample File'.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN'FC01'.
      SELECT
         carrid
         connid
         countryfr
         cityfrom
         airpfrom
         countryto
         cityto
         airpto
        FROM spfli INTO CORRESPONDING FIELDS OF TABLE gt_spfli WHERE carrid = p_carrid.
      PERFORM create_excel_format.
  ENDCASE.

FORM create_excel_format.

  DATA: excel    TYPE ole2_object,
        workbook TYPE ole2_object,
        sheet    TYPE ole2_object,
        cell     TYPE ole2_object,
        row      TYPE ole2_object.

  CREATE OBJECT excel 'EXCEL.APPLICATION'.

*  Create an Excel workbook Object.
  CALL METHOD OF excel 'WORKBOOKS' = workbook.

*  Put Excel in background
  SET PROPERTY OF excel 'VISIBLE' = 0 .

*  Put Excel in front.
  SET PROPERTY OF excel 'VISIBLE' = 1 .

  CALL METHOD OF workbook 'add'.

  CALL METHOD OF excel 'Worksheets' = sheet EXPORTING #1 = 1.

  CALL METHOD OF sheet 'Activate'.

  " Excel Raw Header Line
  CALL METHOD OF excel 'RANGE' = cell EXPORTING #1 = 'A1'.
  SET PROPERTY OF cell 'VALUE' = 'Hav.Şirket Kısa Tanım'.

  CALL METHOD OF excel 'RANGE' = cell EXPORTING #1 = 'B1'.
  SET PROPERTY OF cell 'VALUE' = 'Uçuş Bağlantısı Kodu'.

  CALL METHOD OF excel 'RANGE' = cell EXPORTING #1 = 'C1'.
  SET PROPERTY OF cell 'VALUE' = 'Ülke Bölge Anahtarı'.

  CALL METHOD OF excel 'RANGE' = cell EXPORTING #1 = 'D1'.
  SET PROPERTY OF cell 'VALUE' = 'Kalkış Yapılan Kent'.

  CALL METHOD OF excel 'RANGE' = cell EXPORTING #1 = 'E1'.
  SET PROPERTY OF cell 'VALUE' = 'Kalkış Havaalanı'.

  CALL METHOD OF excel 'RANGE' = cell EXPORTING #1 = 'F1'.
  SET PROPERTY OF cell 'VALUE' = 'Ülke Bölge Anahtarı'.

  CALL METHOD OF excel 'RANGE' = cell EXPORTING #1 = 'G1'.
  SET PROPERTY OF cell 'VALUE' = 'Gideceği Şehir'.

  CALL METHOD OF excel 'RANGE' = cell EXPORTING #1 = 'H1'.
  SET PROPERTY OF cell 'VALUE' = 'Varış Havaalanı'.

  LOOP AT gt_spfli ASSIGNING FIELD-SYMBOL(<fs_spfli>).
    ls_excel_format-carrid    = <fs_spfli>-carrid.
    ls_excel_format-connid    = <fs_spfli>-connid.
    ls_excel_format-countryfr = <fs_spfli>-countryfr.
    ls_excel_format-cityfrom  = <fs_spfli>-cityfrom.
    ls_excel_format-airpfrom  = <fs_spfli>-airpfrom.
    ls_excel_format-countryto = <fs_spfli>-countryto.
    ls_excel_format-cityto    = <fs_spfli>-cityto.
    ls_excel_format-airpto    = <fs_spfli>-airpto.
    APPEND ls_excel_format TO lt_excel_format.
  ENDLOOP.
  " Append Excel Sample Data to Internal Table.
  LOOP AT lt_excel_format INTO ls_excel_format.
    CALL METHOD OF excel 'ROWS' = row EXPORTING #1 = '2'.
    CALL METHOD OF row 'INSERT' NO FLUSH.

    CALL METHOD OF excel 'RANGE' = cell EXPORTING #1 = 'A2'.
    SET PROPERTY OF cell 'VALUE' = ls_excel_format-carrid NO FLUSH.

    CALL METHOD OF excel 'RANGE' = cell EXPORTING #1 = 'B2'.
    SET PROPERTY OF cell 'VALUE' = ls_excel_format-connid NO FLUSH.

    CALL METHOD OF excel 'RANGE' = cell EXPORTING #1 = 'C2'.
    SET PROPERTY OF cell 'VALUE' = ls_excel_format-countryfr NO FLUSH.

    CALL METHOD OF excel 'RANGE' = cell EXPORTING #1 = 'D2'.
    SET PROPERTY OF cell 'VALUE' = ls_excel_format-cityfrom NO FLUSH.

    CALL METHOD OF excel 'RANGE' = cell EXPORTING #1 = 'E2'.
    SET PROPERTY OF cell 'VALUE' = ls_excel_format-airpfrom NO FLUSH.

    CALL METHOD OF excel 'RANGE' = cell EXPORTING #1 = 'F2'.
    SET PROPERTY OF cell 'VALUE' = ls_excel_format-countryto NO FLUSH.

    CALL METHOD OF excel 'RANGE' = cell EXPORTING #1 = 'G2'.
    SET PROPERTY OF cell 'VALUE' = ls_excel_format-cityto NO FLUSH.

    CALL METHOD OF excel 'RANGE' = cell EXPORTING #1 = 'H2'.
    SET PROPERTY OF cell 'VALUE' = ls_excel_format-airpto NO FLUSH.

  ENDLOOP.

  CALL METHOD OF excel 'SAVE'.
  CALL METHOD OF excel 'QUIT'.

*  Free all objects
  FREE OBJECT cell.
  FREE OBJECT workbook.
  FREE OBJECT excel.
  excel-handle = -1.
  FREE OBJECT row.
ENDFORM.