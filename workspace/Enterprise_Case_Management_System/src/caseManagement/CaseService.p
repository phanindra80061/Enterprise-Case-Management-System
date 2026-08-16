/*-------------------------------------------------------------------------
    File        : CaseService.p
    Description : Case business/service layer
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.


PROCEDURE CreateCase:

    DEFINE INPUT PARAMETER ipCaseMasterId    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseNumber      AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseTitle       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseDescription AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseStatus      AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipPriority        AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipCustomerId      AS INTEGER   NO-UNDO.

    DEFINE OUTPUT PARAMETER opSuccess AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE lExists     AS LOGICAL NO-UNDO.

    ASSIGN
        opSuccess = FALSE
        opMessage = "".

    /* ---------------- Validation ---------------- */

    IF ipCaseMasterId = ? OR TRIM(ipCaseMasterId) = "" THEN DO:
        opMessage = "Case Master ID is required.".
        RETURN.
    END.

    IF ipCaseNumber = ? OR TRIM(ipCaseNumber) = "" THEN DO:
        opMessage = "Case number is required.".
        RETURN.
    END.

    IF ipCaseTitle = ? OR TRIM(ipCaseTitle) = "" THEN DO:
        opMessage = "Case title is required.".
        RETURN.
    END.

    IF ipCaseDescription = ? OR TRIM(ipCaseDescription) = "" THEN DO:
        opMessage = "Case description is required.".
        RETURN.
    END.

    IF ipCustomerId <= 0 THEN DO:
        opMessage = "Valid Customer ID is required.".
        RETURN.
    END.

    IF ipCaseStatus <> "Open"
       AND ipCaseStatus <> "In Progress"
       AND ipCaseStatus <> "Closed" THEN DO:

        opMessage = "Status must be Open, In Progress, or Closed.".
        RETURN.

    END.

    IF ipPriority <> "Low"
       AND ipPriority <> "Medium"
       AND ipPriority <> "High"
       AND ipPriority <> "Critical" THEN DO:

        opMessage = "Priority must be Low, Medium, High, or Critical.".
        RETURN.

    END.


    RUN caseManagement/CaseRepository.p
        PERSISTENT SET hRepository.


    /* Customer must exist */

    RUN CustomerExists IN hRepository (
        ipCustomerId,
        OUTPUT lExists
    ).

    IF NOT lExists THEN DO:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        opMessage = "Customer does not exist.".
        RETURN.

    END.


    /* Case ID must be unique */

    RUN CaseExistsById IN hRepository (
        TRIM(ipCaseMasterId),
        OUTPUT lExists
    ).

    IF lExists THEN DO:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        opMessage = "Case Master ID already exists.".
        RETURN.

    END.


    /* Case Number must be unique */

    RUN CaseExistsByNumber IN hRepository (
        TRIM(ipCaseNumber),
        OUTPUT lExists
    ).

    IF lExists THEN DO:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        opMessage = "Case number already exists.".
        RETURN.

    END.


    /* ---------------- Persistence ---------------- */

    DO ON ERROR UNDO, THROW:

        RUN CreateCase IN hRepository (
            TRIM(ipCaseMasterId),
            TRIM(ipCaseNumber),
            TRIM(ipCaseTitle),
            TRIM(ipCaseDescription),
            TRIM(ipCaseStatus),
            TRIM(ipPriority),
            ipCustomerId
        ).

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = TRUE
            opMessage = "Case created successfully.".

    END.

    CATCH err AS Progress.Lang.Error:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = FALSE
            opMessage = err:GetMessage(1).

    END CATCH.

END PROCEDURE.



PROCEDURE GetCase:

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
    DEFINE OUTPUT PARAMETER opMessage         AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE NO-UNDO.

    ASSIGN
        opFound   = FALSE
        opMessage = "".

    IF ipCaseMasterId = ? OR TRIM(ipCaseMasterId) = "" THEN DO:
        opMessage = "Case Master ID is required.".
        RETURN.
    END.

    RUN caseManagement/CaseRepository.p
        PERSISTENT SET hRepository.

    RUN GetCaseById IN hRepository (
        TRIM(ipCaseMasterId),
        OUTPUT opFound,
        OUTPUT opCaseNumber,
        OUTPUT opCaseTitle,
        OUTPUT opCaseDescription,
        OUTPUT opCaseStatus,
        OUTPUT opPriority,
        OUTPUT opCustomerId,
        OUTPUT opCreatedDate,
        OUTPUT opUpdatedDate
    ).

    IF VALID-HANDLE(hRepository) THEN
        DELETE PROCEDURE hRepository.

    IF opFound THEN
        opMessage = "Case found.".
    ELSE
        opMessage = "Case not found.".

END PROCEDURE.



PROCEDURE UpdateCase:

    DEFINE INPUT PARAMETER ipCaseMasterId    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseTitle       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseDescription AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseStatus      AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipPriority        AS CHARACTER NO-UNDO.

    DEFINE OUTPUT PARAMETER opSuccess AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE lUpdated    AS LOGICAL NO-UNDO.

    ASSIGN
        opSuccess = FALSE
        opMessage = "".

    IF ipCaseMasterId = ? OR TRIM(ipCaseMasterId) = "" THEN DO:
        opMessage = "Case Master ID is required.".
        RETURN.
    END.

    IF ipCaseTitle = ? OR TRIM(ipCaseTitle) = "" THEN DO:
        opMessage = "Case title is required.".
        RETURN.
    END.

    IF ipCaseDescription = ? OR TRIM(ipCaseDescription) = "" THEN DO:
        opMessage = "Case description is required.".
        RETURN.
    END.

    IF ipCaseStatus <> "Open"
       AND ipCaseStatus <> "In Progress"
       AND ipCaseStatus <> "Closed" THEN DO:

        opMessage = "Invalid case status.".
        RETURN.

    END.

    IF ipPriority <> "Low"
       AND ipPriority <> "Medium"
       AND ipPriority <> "High"
       AND ipPriority <> "Critical" THEN DO:

        opMessage = "Invalid priority.".
        RETURN.

    END.


    RUN caseManagement/CaseRepository.p
        PERSISTENT SET hRepository.

    DO ON ERROR UNDO, THROW:

        RUN UpdateCase IN hRepository (
            TRIM(ipCaseMasterId),
            TRIM(ipCaseTitle),
            TRIM(ipCaseDescription),
            TRIM(ipCaseStatus),
            TRIM(ipPriority),
            OUTPUT lUpdated
        ).

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        IF lUpdated THEN
            ASSIGN
                opSuccess = TRUE
                opMessage = "Case updated successfully.".
        ELSE
            opMessage = "Case not found.".

    END.

    CATCH err AS Progress.Lang.Error:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = FALSE
            opMessage = err:GetMessage(1).

    END CATCH.

END PROCEDURE.



PROCEDURE DeleteCase:

    DEFINE INPUT PARAMETER ipCaseMasterId AS CHARACTER NO-UNDO.

    DEFINE OUTPUT PARAMETER opSuccess AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE lDeleted    AS LOGICAL NO-UNDO.

    ASSIGN
        opSuccess = FALSE
        opMessage = "".

    IF ipCaseMasterId = ? OR TRIM(ipCaseMasterId) = "" THEN DO:
        opMessage = "Case Master ID is required.".
        RETURN.
    END.

    RUN caseManagement/CaseRepository.p
        PERSISTENT SET hRepository.

    DO ON ERROR UNDO, THROW:

        RUN DeleteCase IN hRepository (
            TRIM(ipCaseMasterId),
            OUTPUT lDeleted
        ).

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        IF lDeleted THEN
            ASSIGN
                opSuccess = TRUE
                opMessage = "Case deleted successfully.".
        ELSE
            opMessage = "Case not found.".

    END.

    CATCH err AS Progress.Lang.Error:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = FALSE
            opMessage = err:GetMessage(1).

    END CATCH.

END PROCEDURE.