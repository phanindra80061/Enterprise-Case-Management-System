/*-------------------------------------------------------------------------
    File        : AttachmentTest.p
    Description : Test driver for Attachment module
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE hService      AS HANDLE    NO-UNDO.
DEFINE VARIABLE lSuccess      AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lFound        AS LOGICAL   NO-UNDO.
DEFINE VARIABLE cMessage      AS CHARACTER NO-UNDO.
DEFINE VARIABLE cCaseMasterId AS CHARACTER NO-UNDO.
DEFINE VARIABLE iEmployeeId   AS INTEGER   NO-UNDO.
DEFINE VARIABLE cFileName     AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFilePath     AS CHARACTER NO-UNDO.
DEFINE VARIABLE dCreatedDate  AS DATE      NO-UNDO.


RUN attachment/AttachmentService.p
    PERSISTENT SET hService.


/* CREATE */

RUN CreateAttachment IN hService (
    1,
    "CASE-M-001",
    101,
    "Customer_ID.pdf",
    "C:\ECMS\attachments\Customer_ID.pdf",
    OUTPUT lSuccess,
    OUTPUT cMessage
).

MESSAGE "CREATE ATTACHMENT:" cMessage
    VIEW-AS ALERT-BOX INFORMATION.


/* READ */

RUN GetAttachment IN hService (
    1,
    OUTPUT lFound,
    OUTPUT cCaseMasterId,
    OUTPUT iEmployeeId,
    OUTPUT cFileName,
    OUTPUT cFilePath,
    OUTPUT dCreatedDate,
    OUTPUT cMessage
).

IF lFound THEN
    MESSAGE
        "ATTACHMENT DETAILS" SKIP
        "Attachment ID: 1" SKIP
        "Case:" cCaseMasterId SKIP
        "Uploaded By:" iEmployeeId SKIP
        "File:" cFileName SKIP
        "Path:" cFilePath SKIP
        "Created:" dCreatedDate
        VIEW-AS ALERT-BOX INFORMATION.
ELSE
    MESSAGE cMessage
        VIEW-AS ALERT-BOX WARNING.


IF VALID-HANDLE(hService) THEN
    DELETE PROCEDURE hService.