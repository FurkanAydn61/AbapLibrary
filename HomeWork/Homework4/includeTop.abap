*&---------------------------------------------------------------------*
*& Include          ZFURKAN_STUDENT_TOP
*&---------------------------------------------------------------------*

TYPES: BEGIN OF student,
         ogr_id  TYPE zfkn_de_ogrid,
         ogr_ad  TYPE zfkn_de_ograd,
         ogr_syd TYPE zfkn_de_ogrsyd,
       END OF student.

TYPES: BEGIN OF lesson,
         ogr_id   TYPE zfkn_de_ogrid,
         les_name TYPE zfkn_de_ders,
         note1    TYPE zfkn_de_ogrs001,
         note2    TYPE zfkn_de_ogrs002,
         durum TYPE char20,
         d_tanım TYPE char30,
       END OF lesson.



DATA: result TYPE f.

DATA: gs_student TYPE student,
      mtable     TYPE STANDARD TABLE OF student,
      gt_lesson  TYPE TABLE OF  lesson,
      gs_lesson  TYPE lesson,
      v_search   TYPE TABLE OF vrm_value.



SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_rad1 RADIOBUTTON GROUP gr1 USER-COMMAND usr1,
            p_rad2 RADIOBUTTON GROUP gr1 DEFAULT 'X',
            p_rad3 RADIOBUTTON GROUP gr1.

SELECTION-SCREEN END OF BLOCK bl1.

SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK bl2.
PARAMETERS:
  p_liste1 TYPE zfkn_de_ogrid AS LISTBOX VISIBLE LENGTH 10 DEFAULT '01' USER-COMMAND list,
  p_liste2 TYPE zfkn_de_ders AS LISTBOX VISIBLE LENGTH 10 DEFAULT '01' USER-COMMAND list,
  p_liste3 TYPE zfkn_de_ogrid AS LISTBOX VISIBLE LENGTH 10 DEFAULT '01' USER-COMMAND list,
  p_liste4 TYPE zfkn_de_ders AS LISTBOX VISIBLE LENGTH 10 DEFAULT '01' USER-COMMAND list,
  p_ogrid  TYPE zfkn_de_ogrid MODIF ID m1,
  p_ograd  TYPE zfkn_de_ograd MODIF ID m1,
  p_ogrsyd TYPE zfkn_de_ogrsyd MODIF ID m1,
  p_not1   TYPE zfkn_de_ogrs001 MODIF ID m2,
  p_not2   TYPE zfkn_de_ogrs002 MODIF ID m2.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN PUSHBUTTON  /1(15) button1 USER-COMMAND but1 MODIF ID b1.
SELECTION-SCREEN PUSHBUTTON  /1(15) button2 USER-COMMAND but2 MODIF ID b2.
SELECTION-SCREEN PUSHBUTTON  /1(15) button3 USER-COMMAND but3 MODIF ID b3.
*SELECTION-SCREEN PUSHBUTTON /1(15) button4 USER-COMMAND but4 MODIF ID b4.
SELECTION-SCREEN END OF BLOCK bl2.