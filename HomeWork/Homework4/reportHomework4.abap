*&---------------------------------------------------------------------*
*& Report ZFURKAN_STUDENT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfurkan_student.


INCLUDE zfurkan_student_top.
INCLUDE zfurkan_student_frm.

INITIALIZATION.

  PERFORM frm_init.

AT SELECTION-SCREEN OUTPUT.

  PERFORM frm_ats_out.

AT SELECTION-SCREEN.
  PERFORM frm_ats.

END-OF-SELECTION.

PERFORM get_data.