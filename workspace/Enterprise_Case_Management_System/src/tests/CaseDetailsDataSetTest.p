/*-------------------------------------------------------------------------
    File        : CaseDetailsDataSetTest.p
    Description : Tests the Case Details ProDataSet
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE hDataSetService AS HANDLE NO-UNDO.


/* =========================================================
   TEMP-TABLE DEFINITIONS
   Must match CaseDetailsDataSet.p
   ========================================================= */

DEFINE TEMP-TABLE ttCase NO-UNDO
    FIELD caseMasterId    AS CHARACTER
    FIELD caseNumber      AS CHARACTER
    FIELD caseTitle       AS CHARACTER
    FIELD caseDescription AS CHARACTER
    FIELD caseStatus      AS CHARACTER
    FIELD priority        AS CHARACTER
    FIELD customerId      AS INTEGER
    FIELD createdDate     AS DATE
    FIELD updatedDate     AS DATE
    INDEX idxCase IS PRIMARY UNIQUE
        caseMasterId.


DEFINE TEMP-TABLE ttCustomer NO-UNDO
    FIELD customerId     AS INTEGER
    FIELD firstName      AS CHARACTER
    FIELD lastName       AS CHARACTER
    FIELD email          AS CHARACTER
    FIELD phone          AS CHARACTER
    FIELD customerStatus AS CHARACTER
    INDEX idxCustomer IS PRIMARY UNIQUE
        customerId.


DEFINE TEMP-TABLE ttAssignment NO-UNDO
    FIELD assignmentId     AS INTEGER
    FIELD caseMasterId     AS CHARACTER
    FIELD employeeId       AS INTEGER
    FIELD assignedDate     AS DATE
    FIELD assignmentStatus AS CHARACTER
    INDEX idxAssignment IS PRIMARY UNIQUE
        assignmentId
    INDEX idxAssignmentCase
        caseMasterId.


DEFINE TEMP-TABLE ttEmployee NO-UNDO
    FIELD employeeId  AS INTEGER
    FIELD firstName   AS CHARACTER
    FIELD lastName    AS CHARACTER
    FIELD email       AS CHARACTER
    FIELD department  AS CHARACTER
    FIELD designation AS CHARACTER
    INDEX idxEmployee IS PRIMARY UNIQUE
        employeeId.


DEFINE TEMP-TABLE ttNotes NO-UNDO
    FIELD notesId      AS INTEGER
    FIELD caseMasterId AS CHARACTER
    FIELD employeeId   AS INTEGER
    FIELD noteText     AS CHARACTER
    FIELD createdDate  AS DATE
    INDEX idxNotes IS PRIMARY UNIQUE
        notesId
    INDEX idxNotesCase
        caseMasterId.


DEFINE TEMP-TABLE ttAttachment NO-UNDO
    FIELD attachmentId AS INTEGER
    FIELD caseMasterId AS CHARACTER
    FIELD employeeId   AS INTEGER
    FIELD fileName     AS CHARACTER
    FIELD filePath     AS CHARACTER
    FIELD createdDate  AS DATE
    INDEX idxAttachment IS PRIMARY UNIQUE
        attachmentId
    INDEX idxAttachmentCase
        caseMasterId.


DEFINE DATASET dsCaseDetails FOR
    ttCase,
    ttCustomer,
    ttAssignment,
    ttEmployee,
    ttNotes,
    ttAttachment.


/* =========================================================
   CALL DATASET PROCEDURE
   ========================================================= */

RUN proDataSets/CaseDetailsDataSet.p PERSISTENT SET hDataSetService.

RUN GetCaseDetails IN hDataSetService (
    "CASE-M-001",
    OUTPUT DATASET dsCaseDetails
).


/* =========================================================
   DISPLAY CASE
   ========================================================= */

FIND FIRST ttCase NO-ERROR.

IF AVAILABLE ttCase THEN
    MESSAGE
        "CASE DETAILS" SKIP
        "Case ID:" ttCase.caseMasterId SKIP
        "Case Number:" ttCase.caseNumber SKIP
        "Title:" ttCase.caseTitle SKIP
        "Status:" ttCase.caseStatus SKIP
        "Priority:" ttCase.priority
        VIEW-AS ALERT-BOX INFORMATION.
ELSE
    MESSAGE "Case not found."
        VIEW-AS ALERT-BOX WARNING.


/* =========================================================
   DISPLAY CUSTOMER
   ========================================================= */

FIND FIRST ttCustomer NO-ERROR.

IF AVAILABLE ttCustomer THEN
    MESSAGE
        "CUSTOMER" SKIP
        "Customer ID:" ttCustomer.customerId SKIP
        "Name:" ttCustomer.firstName + " " + ttCustomer.lastName SKIP
        "Email:" ttCustomer.email
        VIEW-AS ALERT-BOX INFORMATION.


/* =========================================================
   DISPLAY ASSIGNMENTS
   ========================================================= */

FOR EACH ttAssignment:

    MESSAGE
        "ASSIGNMENT" SKIP
        "Assignment ID:" ttAssignment.assignmentId SKIP
        "Employee ID:" ttAssignment.employeeId SKIP
        "Status:" ttAssignment.assignmentStatus
        VIEW-AS ALERT-BOX INFORMATION.

END.


/* =========================================================
   DISPLAY NOTES
   ========================================================= */

FOR EACH ttNotes:

    MESSAGE
        "NOTE" SKIP
        "Note ID:" ttNotes.notesId SKIP
        "Employee:" ttNotes.employeeId SKIP
        "Text:" ttNotes.noteText
        VIEW-AS ALERT-BOX INFORMATION.

END.


/* =========================================================
   DISPLAY ATTACHMENTS
   ========================================================= */

FOR EACH ttAttachment:

    MESSAGE
        "ATTACHMENT" SKIP
        "Attachment ID:" ttAttachment.attachmentId SKIP
        "File:" ttAttachment.fileName SKIP
        "Path:" ttAttachment.filePath
        VIEW-AS ALERT-BOX INFORMATION.

END.


IF VALID-HANDLE(hDataSetService) THEN
    DELETE PROCEDURE hDataSetService.