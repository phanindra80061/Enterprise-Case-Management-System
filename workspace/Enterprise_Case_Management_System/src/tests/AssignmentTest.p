/*-------------------------------------------------------------------------
    File        : AssignmentTest.p
    Description : Test driver for Assignment module
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE hService          AS HANDLE    NO-UNDO.
DEFINE VARIABLE lSuccess          AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lFound            AS LOGICAL   NO-UNDO.
DEFINE VARIABLE cMessage          AS CHARACTER NO-UNDO.
DEFINE VARIABLE cCaseMasterId     AS CHARACTER NO-UNDO.
DEFINE VARIABLE iEmployeeId       AS INTEGER   NO-UNDO.
DEFINE VARIABLE dAssignedDate     AS DATE      NO-UNDO.
DEFINE VARIABLE cAssignmentStatus AS CHARACTER NO-UNDO.


RUN assignment/AssignmentService.p
    PERSISTENT SET hService.


/* =========================================================
   CREATE ASSIGNMENT
   CASE-M-001 -> Employee 101
   ========================================================= */

RUN CreateAssignment IN hService (
    1,
    "CASE-M-001",
    101,
    OUTPUT lSuccess,
    OUTPUT cMessage
).

MESSAGE "CREATE ASSIGNMENT:" cMessage
    VIEW-AS ALERT-BOX INFORMATION.


/* =========================================================
   READ ASSIGNMENT
   ========================================================= */

RUN GetAssignment IN hService (
    1,
    OUTPUT lFound,
    OUTPUT cCaseMasterId,
    OUTPUT iEmployeeId,
    OUTPUT dAssignedDate,
    OUTPUT cAssignmentStatus,
    OUTPUT cMessage
).

IF lFound THEN
    MESSAGE
        "ASSIGNMENT DETAILS" SKIP
        "Assignment ID: 1" SKIP
        "Case:" cCaseMasterId SKIP
        "Employee:" iEmployeeId SKIP
        "Assigned Date:" dAssignedDate SKIP
        "Status:" cAssignmentStatus
        VIEW-AS ALERT-BOX INFORMATION.
ELSE
    MESSAGE cMessage
        VIEW-AS ALERT-BOX WARNING.


/* =========================================================
   CLEANUP PROCEDURE
   ========================================================= */

IF VALID-HANDLE(hService) THEN
    DELETE PROCEDURE hService.