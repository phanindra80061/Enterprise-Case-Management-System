/*-------------------------------------------------------------------------
    File        : NotesTest.p
    Description : Test driver for Notes module
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE hService      AS HANDLE    NO-UNDO.
DEFINE VARIABLE lSuccess      AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lFound        AS LOGICAL   NO-UNDO.
DEFINE VARIABLE cMessage      AS CHARACTER NO-UNDO.
DEFINE VARIABLE cCaseMasterId AS CHARACTER NO-UNDO.
DEFINE VARIABLE iEmployeeId   AS INTEGER   NO-UNDO.
DEFINE VARIABLE cNoteText     AS CHARACTER NO-UNDO.
DEFINE VARIABLE dCreatedDate  AS DATE      NO-UNDO.


RUN notes/NotesService.p
    PERSISTENT SET hService.


/* =========================================================
   CREATE NOTE
   ========================================================= */

RUN CreateNote IN hService (
    1,
    "CASE-M-001",
    101,
    "Customer contacted regarding required case documentation.",
    OUTPUT lSuccess,
    OUTPUT cMessage
).

MESSAGE "CREATE NOTE:" cMessage
    VIEW-AS ALERT-BOX INFORMATION.


/* =========================================================
   READ NOTE
   ========================================================= */

RUN GetNote IN hService (
    1,
    OUTPUT lFound,
    OUTPUT cCaseMasterId,
    OUTPUT iEmployeeId,
    OUTPUT cNoteText,
    OUTPUT dCreatedDate,
    OUTPUT cMessage
).

IF lFound THEN
    MESSAGE
        "NOTE DETAILS" SKIP
        "Note ID: 1" SKIP
        "Case:" cCaseMasterId SKIP
        "Employee:" iEmployeeId SKIP
        "Date:" dCreatedDate SKIP
        "Note:" cNoteText
        VIEW-AS ALERT-BOX INFORMATION.
ELSE
    MESSAGE cMessage
        VIEW-AS ALERT-BOX WARNING.


/* =========================================================
   UPDATE NOTE
   ========================================================= */

RUN UpdateNote IN hService (
    1,
    "Customer contacted. Required documents were received and reviewed.",
    OUTPUT lSuccess,
    OUTPUT cMessage
).

MESSAGE "UPDATE NOTE:" cMessage
    VIEW-AS ALERT-BOX INFORMATION.


IF VALID-HANDLE(hService) THEN
    DELETE PROCEDURE hService.