/*-------------------------------------------------------------------------
    File        : CaseDetailsJsonTest.p
    Description : Tests Case Details JSON serialization
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE lcJson AS LONGCHAR NO-UNDO.


RUN proDataSets/CaseDetailsJson.p (
    INPUT "CASE-M-001",
    OUTPUT lcJson
).


MESSAGE STRING(lcJson)
    VIEW-AS ALERT-BOX INFORMATION
    TITLE "Case Details JSON".