/*-------------------------------------------------------------------------
    File        : CaseDetailsJson.p
    Description : Converts Case Details ProDataSet to JSON
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.


/* =========================================================
   TEMP-TABLES
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


/* =========================================================
   PRODATASET
   ========================================================= */

DEFINE DATASET dsCaseDetails FOR
    ttCase,
    ttCustomer,
    ttAssignment,
    ttEmployee,
    ttNotes,
    ttAttachment.


/* =========================================================
   PARAMETERS
   ========================================================= */

DEFINE INPUT  PARAMETER ipCaseMasterId AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER opJson         AS LONGCHAR  NO-UNDO.


/* =========================================================
   VARIABLES
   ========================================================= */

DEFINE VARIABLE hCaseDetails AS HANDLE NO-UNDO.


/* =========================================================
   BUILD CASE DETAILS DATASET
   ========================================================= */

/* Start CaseDetailsDataSet.p as a persistent procedure */
RUN proDataSets/CaseDetailsDataSet.p
    PERSISTENT SET hCaseDetails.

/* Call its internal GetCaseDetails procedure */
RUN GetCaseDetails IN hCaseDetails (
    INPUT ipCaseMasterId,
    OUTPUT DATASET dsCaseDetails BY-REFERENCE
).


/* =========================================================
   CLEAN UP PERSISTENT PROCEDURE
   ========================================================= */

DELETE PROCEDURE hCaseDetails.


/* =========================================================
   CONVERT PRODATASET TO JSON
   ========================================================= */

DATASET dsCaseDetails:WRITE-JSON(
    "LONGCHAR",
    opJson,
    TRUE
).