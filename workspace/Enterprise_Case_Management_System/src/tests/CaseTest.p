/*-------------------------------------------------------------------------
    File        : CaseTest.p
    Description : End-to-end test driver for Case module
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE hCaseService AS HANDLE    NO-UNDO.
DEFINE VARIABLE lSuccess     AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lFound       AS LOGICAL   NO-UNDO.
DEFINE VARIABLE cMessage     AS CHARACTER NO-UNDO.

DEFINE VARIABLE cCaseNumber      AS CHARACTER NO-UNDO.
DEFINE VARIABLE cCaseTitle       AS CHARACTER NO-UNDO.
DEFINE VARIABLE cCaseDescription AS CHARACTER NO-UNDO.
DEFINE VARIABLE cCaseStatus      AS CHARACTER NO-UNDO.
DEFINE VARIABLE cPriority        AS CHARACTER NO-UNDO.
DEFINE VARIABLE iCustomerId      AS INTEGER   NO-UNDO.
DEFINE VARIABLE dCreatedDate     AS DATE      NO-UNDO.
DEFINE VARIABLE dUpdatedDate     AS DATE      NO-UNDO.


/* =========================================================
   STEP 1 - Create customer used by this case
   ========================================================= */

RUN customer/CustomerCreate.p (
    10,
    "Robert",
    "Williams",
    "robert.williams@example.com",
    "5735559876",
    DATE(5, 15, 1985),
    "Active"
).


/* =========================================================
   STEP 2 - Start Case Service
   ========================================================= */

RUN caseManagement/CaseService.p
    PERSISTENT SET hCaseService.


/* =========================================================
   STEP 3 - Create Case
   ========================================================= */

RUN CreateCase IN hCaseService (
    "CASE-M-001",
    "ECMS-2026-0001",
    "Customer Claim Investigation",
    "Customer reported an issue requiring investigation.",
    "Open",
    "High",
    10,
    OUTPUT lSuccess,
    OUTPUT cMessage
).

MESSAGE "CREATE CASE:" cMessage
    VIEW-AS ALERT-BOX INFORMATION.


/* =========================================================
   STEP 4 - Read Case
   ========================================================= */

RUN GetCase IN hCaseService (
    "CASE-M-001",
    OUTPUT lFound,
    OUTPUT cCaseNumber,
    OUTPUT cCaseTitle,
    OUTPUT cCaseDescription,
    OUTPUT cCaseStatus,
    OUTPUT cPriority,
    OUTPUT iCustomerId,
    OUTPUT dCreatedDate,
    OUTPUT dUpdatedDate,
    OUTPUT cMessage
).

IF lFound THEN
    MESSAGE
        "CASE DETAILS" SKIP
        "Case Number:" cCaseNumber SKIP
        "Title:" cCaseTitle SKIP
        "Status:" cCaseStatus SKIP
        "Priority:" cPriority SKIP
        "Customer ID:" iCustomerId SKIP
        "Created:" dCreatedDate
        VIEW-AS ALERT-BOX INFORMATION.
ELSE
    MESSAGE cMessage
        VIEW-AS ALERT-BOX WARNING.


/* =========================================================
   STEP 5 - Update Case
   ========================================================= */

RUN UpdateCase IN hCaseService (
    "CASE-M-001",
    "Customer Claim Investigation",
    "Initial investigation completed and case is being reviewed.",
    "In Progress",
    "Critical",
    OUTPUT lSuccess,
    OUTPUT cMessage
).

MESSAGE "UPDATE CASE:" cMessage
    VIEW-AS ALERT-BOX INFORMATION.


/* =========================================================
   STEP 6 - Read Updated Case
   ========================================================= */

RUN GetCase IN hCaseService (
    "CASE-M-001",
    OUTPUT lFound,
    OUTPUT cCaseNumber,
    OUTPUT cCaseTitle,
    OUTPUT cCaseDescription,
    OUTPUT cCaseStatus,
    OUTPUT cPriority,
    OUTPUT iCustomerId,
    OUTPUT dCreatedDate,
    OUTPUT dUpdatedDate,
    OUTPUT cMessage
).

IF lFound THEN
    MESSAGE
        "UPDATED CASE" SKIP
        "Case Number:" cCaseNumber SKIP
        "Title:" cCaseTitle SKIP
        "Status:" cCaseStatus SKIP
        "Priority:" cPriority SKIP
        "Customer ID:" iCustomerId SKIP
        "Description:" cCaseDescription
        VIEW-AS ALERT-BOX INFORMATION.


/* =========================================================
   CLEANUP PROCEDURE
   ========================================================= */

IF VALID-HANDLE(hCaseService) THEN
    DELETE PROCEDURE hCaseService.