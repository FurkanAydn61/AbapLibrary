REPORT ZMM_R111.

INCLUDE ZMM_R111_T01. "top
INCLUDE ZMM_R111_S01. "selection screen
INCLUDE ZMM_R111_C01. "main
INCLUDE ZMM_R111_C02. "event handler
INCLUDE ZMM_R111_C03. "screen
INCLUDE ZMM_R111_M01. "module pbo/pai

INITIALIZATION.
  lcl_main=>init( ).

AT SELECTION-SCREEN OUTPUT.
  lcl_main=>at_ss_output( ).

AT SELECTION-SCREEN.
  lcl_main=>at_ss( ).

START-OF-SELECTION.
  lcl_main=>start( ).

END-OF-SELECTION.
  lcl_main=>end( ).