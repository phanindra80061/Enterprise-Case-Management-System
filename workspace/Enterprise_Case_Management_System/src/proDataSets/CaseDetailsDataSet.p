/*-------------------------------------------------------------------------
    File        : CaseDetailsDataSet.p
    Description : Builds complete Case Details ProDataSet
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.


/* =========================================================
   CASE TEMP-TABLE
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


/* =========================================================
   CUSTOMER TEMP-TABLE
   ========================================================= */

DEFINE TEMP-TABLE ttCustomer NO-UNDO
    FIELD customerId     AS INTEGER
    FIELD firstName      AS CHARACTER
    FIELD lastName       AS CHARACTER
    FIELD email          AS CHARACTER
    FIELD phone          AS CHARACTER
    FIELD customerStatus AS CHARACTER
    INDEX idxCustomer IS PRIMARY UNIQUE
        customerId.


/* =========================================================
   ASSIGNMENT TEMP-TABLE
   ========================================================= */

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


/* =========================================================
   EMPLOYEE TEMP-TABLE
   ========================================================= */

DEFINE TEMP-TABLE ttEmployee NO-UNDO
    FIELD employeeId AS INTEGER
    FIELD firstName  AS CHARACTER
    FIELD lastName   AS CHARACTER
    FIELD email      AS CHARACTER
    FIELD department AS CHARACTER
    FIELD designation AS CHARACTER
    INDEX idxEmployee IS PRIMARY UNIQUE
        employeeId.


/* =========================================================
   NOTES TEMP-TABLE
   ========================================================= */

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


/* =========================================================
   ATTACHMENT TEMP-TABLE
   ========================================================= */

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
   BUILD DATASET
   ========================================================= */

PROCEDURE GetCaseDetails:

    DEFINE INPUT PARAMETER ipCaseMasterId AS CHARACTER NO-UNDO.

    DEFINE OUTPUT PARAMETER DATASET FOR dsCaseDetails.

    EMPTY TEMP-TABLE ttCase.
    EMPTY TEMP-TABLE ttCustomer.
    EMPTY TEMP-TABLE ttAssignment.
    EMPTY TEMP-TABLE ttEmployee.
    EMPTY TEMP-TABLE ttNotes.
    EMPTY TEMP-TABLE ttAttachment.


    /* -----------------------------------------------------
       CASE
       ----------------------------------------------------- */

    FIND FIRST caseMaster
        WHERE caseMaster.caseMasterId = TRIM(ipCaseMasterId)
        NO-LOCK
        NO-ERROR.

    IF NOT AVAILABLE caseMaster THEN
        RETURN.

    CREATE ttCase.

    BUFFER-COPY caseMaster TO ttCase.


    /* -----------------------------------------------------
       CUSTOMER
       ----------------------------------------------------- */

    FIND FIRST customer
        WHERE customer.customerId = caseMaster.customerId
        NO-LOCK
        NO-ERROR.

    IF AVAILABLE customer THEN DO:

        CREATE ttCustomer.

        ASSIGN
            ttCustomer.customerId     = customer.customerId
            ttCustomer.firstName      = customer.firstName
            ttCustomer.lastName       = customer.lastName
            ttCustomer.email          = customer.email
            ttCustomer.phone          = customer.phone
            ttCustomer.customerStatus = customer.customerStatus.

    END.


    /* -----------------------------------------------------
       ASSIGNMENT + EMPLOYEE
       ----------------------------------------------------- */

    FOR EACH assignment
        WHERE assignment.caseMasterId = ipCaseMasterId
        NO-LOCK:

        CREATE ttAssignment.

        BUFFER-COPY assignment TO ttAssignment.

        FIND FIRST employee
            WHERE employee.employeeId = assignment.employeeId
            NO-LOCK
            NO-ERROR.

        IF AVAILABLE employee
           AND NOT CAN-FIND(
               FIRST ttEmployee
               WHERE ttEmployee.employeeId = employee.employeeId
           )
        THEN DO:

            CREATE ttEmployee.

            ASSIGN
                ttEmployee.employeeId  = employee.employeeId
                ttEmployee.firstName   = employee.firstName
                ttEmployee.lastName    = employee.lastName
                ttEmployee.email       = employee.email
                ttEmployee.department  = employee.department
                ttEmployee.designation = employee.designation.

        END.

    END.


    /* -----------------------------------------------------
       NOTES
       ----------------------------------------------------- */

    FOR EACH notes
        WHERE notes.caseMasterId = ipCaseMasterId
        NO-LOCK:

        CREATE ttNotes.

        BUFFER-COPY notes TO ttNotes.

    END.


    /* -----------------------------------------------------
       ATTACHMENTS
       ----------------------------------------------------- */

    FOR EACH attachment
        WHERE attachment.caseMasterId = ipCaseMasterId
        NO-LOCK:

        CREATE ttAttachment.

        BUFFER-COPY attachment TO ttAttachment.

    END.

END PROCEDURE.