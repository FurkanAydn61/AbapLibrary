*&---------------------------------------------------------------------*
*& Include          ZABAP_FA_TUTORIAL_008_EVN
*&---------------------------------------------------------------------*




INITIALIZATION.

CREATE OBJECT go_events.


go_events->initialization( ).

AT SELECTION-SCREEN OUTPUT.

  go_events->at_selection_screen_output( )..

AT SELECTION-SCREEN.

  go_events->at_selection_screen( ).