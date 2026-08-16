/*-------------------------------------------------------------------------
    File        : CaseRepository.p
    Description : Case database persistence layer
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.


PROCEDURE CaseExistsById:

    DEFINE INPUT  PARAMETER ipCaseMasterId AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opExists       AS LOGICAL   NO-UNDO.

    FIND FIRST caseMaster
        WHERE caseMaster.caseMasterId = TRIM(ipCaseMasterId)
        NO-LOCK
        NO-ERROR.

    opExists = AVAILABLE caseMaster.

END PROCEDURE.


PROCEDURE CaseExistsByNumber:

    DEFINE INPUT  PARAMETER ipCaseNumber AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opExists     AS LOGICAL   NO-UNDO.

    FIND FIRST caseMaster
        WHERE caseMaster.caseNumber = TRIM(ipCaseNumber)
        NO-LOCK
        NO-ERROR.

    opExists = AVAILABLE caseMaster.

END PROCEDURE.


PROCEDURE CustomerExists:

    DEFINE INPUT  PARAMETER ipCustomerId AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER opExists     AS LOGICAL NO-UNDO.

    FIND FIRST customer
        WHERE customer.customerId = ipCustomerId
        NO-LOCK
        NO-ERROR.

    opExists = AVAILABLE customer.

END PROCEDURE.


PROCEDURE GetCaseById:

    DEFINE INPUT PARAMETER ipCaseMasterId AS CHARACTER NO-UNDO.

    DEFINE OUTPUT PARAMETER opFound           AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opCaseNumber      AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opCaseTitle       AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opCaseDescription AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opCaseStatus      AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opPriority        AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opCustomerId      AS INTEGER   NO-UNDO.
    DEFINE OUTPUT PARAMETER opCreatedDate     AS DATE      NO-UNDO.
    DEFINE OUTPUT PARAMETER opUpdatedDate     AS DATE      NO-UNDO.

    ASSIGN
        opFound           = FALSE
        opCaseNumber      = ""
        opCaseTitle       = ""
        opCaseDescription = ""
        opCaseStatus      = ""
        opPriority        = ""
        opCustomerId      = 0
        opCreatedDate     = ?
        opUpdatedDate     = ?.

    FIND FIRST caseMaster
        WHERE caseMaster.caseMasterId = TRIM(ipCaseMasterId)
        NO-LOCK
        NO-ERROR.

    IF AVAILABLE caseMaster THEN
        ASSIGN
            opFound           = TRUE
            opCaseNumber      = caseMaster.caseNumber
            opCaseTitle       = caseMaster.caseTitle
            opCaseDescription = caseMaster.caseDescription
            opCaseStatus      = caseMaster.caseStatus
            opPriority        = caseMaster.priority
            opCustomerId      = caseMaster.customerId
            opCreatedDate     = caseMaster.createdDate
            opUpdatedDate     = caseMaster.updatedDate.

END PROCEDURE.


PROCEDURE CreateCase:

    DEFINE INPUT PARAMETER ipCaseMasterId    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseNumber      AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseTitle       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseDescription AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseStatus      AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipPriority        AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipCustomerId      AS INTEGER   NO-UNDO.

    DEFINE VARIABLE hAuditRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE iAuditLogId      AS INTEGER NO-UNDO.

    DO TRANSACTION ON ERROR UNDO, THROW:

        CREATE caseMaster.

        ASSIGN
            caseMaster.caseMasterId    = TRIM(ipCaseMasterId)
            caseMaster.caseNumber      = TRIM(ipCaseNumber)
            caseMaster.caseTitle       = TRIM(ipCaseTitle)
            caseMaster.caseDescription = TRIM(ipCaseDescription)
            caseMaster.caseStatus      = TRIM(ipCaseStatus)
            caseMaster.priority        = TRIM(ipPriority)
            caseMaster.customerId      = ipCustomerId
            caseMaster.createdDate     = TODAY
            caseMaster.updatedDate     = TODAY.

        /*
           Temporary audit ID.
           We will replace this globally with a DB sequence.
        */
        iAuditLogId = 400000 + ipCustomerId.

        RUN audit/AuditRepository.p
            PERSISTENT SET hAuditRepository.

        RUN CreateAuditLog IN hAuditRepository (
            iAuditLogId,
            "caseMaster",
            ipCustomerId,
            "CREATE",
            "SYSTEM"
        ).

        IF VALID-HANDLE(hAuditRepository) THEN
            DELETE PROCEDURE hAuditRepository.

    END.

END PROCEDURE.


PROCEDURE UpdateCase:

    DEFINE INPUT PARAMETER ipCaseMasterId    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseTitle       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseDescription AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseStatus      AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipPriority        AS CHARACTER NO-UNDO.

    DEFINE OUTPUT PARAMETER opUpdated AS LOGICAL NO-UNDO.

    DEFINE VARIABLE hAuditRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE iAuditLogId      AS INTEGER NO-UNDO.

    opUpdated = FALSE.

    DO TRANSACTION ON ERROR UNDO, THROW:

        FIND FIRST caseMaster
            WHERE caseMaster.caseMasterId = TRIM(ipCaseMasterId)
            EXCLUSIVE-LOCK
            NO-ERROR.

        IF NOT AVAILABLE caseMaster THEN
            RETURN.

        ASSIGN
            caseMaster.caseTitle       = TRIM(ipCaseTitle)
            caseMaster.caseDescription = TRIM(ipCaseDescription)
            caseMaster.caseStatus      = TRIM(ipCaseStatus)
            caseMaster.priority        = TRIM(ipPriority)
            caseMaster.updatedDate     = TODAY.

        iAuditLogId = 500000 + caseMaster.customerId.

        RUN audit/AuditRepository.p
            PERSISTENT SET hAuditRepository.

        RUN CreateAuditLog IN hAuditRepository (
            iAuditLogId,
            "caseMaster",
            caseMaster.customerId,
            "UPDATE",
            "SYSTEM"
        ).

        IF VALID-HANDLE(hAuditRepository) THEN
            DELETE PROCEDURE hAuditRepository.

        opUpdated = TRUE.

    END.

END PROCEDURE.


PROCEDURE DeleteCase:

    DEFINE INPUT  PARAMETER ipCaseMasterId AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opDeleted      AS LOGICAL   NO-UNDO.

    DEFINE VARIABLE hAuditRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE iAuditLogId      AS INTEGER NO-UNDO.
    DEFINE VARIABLE iCustomerId      AS INTEGER NO-UNDO.

    opDeleted = FALSE.

    DO TRANSACTION ON ERROR UNDO, THROW:

        FIND FIRST caseMaster
            WHERE caseMaster.caseMasterId = TRIM(ipCaseMasterId)
            EXCLUSIVE-LOCK
            NO-ERROR.

        IF NOT AVAILABLE caseMaster THEN
            RETURN.

        iCustomerId = caseMaster.customerId.
        iAuditLogId = 600000 + iCustomerId.

        RUN audit/AuditRepository.p
            PERSISTENT SET hAuditRepository.

        RUN CreateAuditLog IN hAuditRepository (
            iAuditLogId,
            "caseMaster",
            iCustomerId,
            "DELETE",
            "SYSTEM"
        ).

        DELETE caseMaster.

        IF VALID-HANDLE(hAuditRepository) THEN
            DELETE PROCEDURE hAuditRepository.

        opDeleted = TRUE.

    END.

END PROCEDURE.