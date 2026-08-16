/*-------------------------------------------------------------------------
    File        : AssignmentRepository.p
    Description : Assignment database persistence layer
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.


PROCEDURE AssignmentExistsById:

    DEFINE INPUT  PARAMETER ipAssignmentId AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER opExists       AS LOGICAL NO-UNDO.

    FIND FIRST assignment
        WHERE assignment.assignmentId = ipAssignmentId
        NO-LOCK
        NO-ERROR.

    opExists = AVAILABLE assignment.

END PROCEDURE.


PROCEDURE CaseExists:

    DEFINE INPUT  PARAMETER ipCaseMasterId AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opExists       AS LOGICAL   NO-UNDO.

    FIND FIRST caseMaster
        WHERE caseMaster.caseMasterId = TRIM(ipCaseMasterId)
        NO-LOCK
        NO-ERROR.

    opExists = AVAILABLE caseMaster.

END PROCEDURE.


PROCEDURE EmployeeExists:

    DEFINE INPUT  PARAMETER ipEmployeeId AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER opExists     AS LOGICAL NO-UNDO.

    FIND FIRST employee
        WHERE employee.employeeId = ipEmployeeId
        NO-LOCK
        NO-ERROR.

    opExists = AVAILABLE employee.

END PROCEDURE.


PROCEDURE ActiveAssignmentExists:

    DEFINE INPUT  PARAMETER ipCaseMasterId AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opExists       AS LOGICAL   NO-UNDO.

    FIND FIRST assignment
        WHERE assignment.caseMasterId = TRIM(ipCaseMasterId)
          AND assignment.assignmentStatus = "Active"
        NO-LOCK
        NO-ERROR.

    opExists = AVAILABLE assignment.

END PROCEDURE.


PROCEDURE GetAssignmentById:

    DEFINE INPUT PARAMETER ipAssignmentId AS INTEGER NO-UNDO.

    DEFINE OUTPUT PARAMETER opFound            AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opCaseMasterId     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opEmployeeId       AS INTEGER   NO-UNDO.
    DEFINE OUTPUT PARAMETER opAssignedDate     AS DATE      NO-UNDO.
    DEFINE OUTPUT PARAMETER opAssignmentStatus AS CHARACTER NO-UNDO.

    ASSIGN
        opFound            = FALSE
        opCaseMasterId     = ""
        opEmployeeId       = 0
        opAssignedDate     = ?
        opAssignmentStatus = "".

    FIND FIRST assignment
        WHERE assignment.assignmentId = ipAssignmentId
        NO-LOCK
        NO-ERROR.

    IF AVAILABLE assignment THEN
        ASSIGN
            opFound            = TRUE
            opCaseMasterId     = assignment.caseMasterId
            opEmployeeId       = assignment.employeeId
            opAssignedDate     = assignment.assignedDate
            opAssignmentStatus = assignment.assignmentStatus.

END PROCEDURE.


PROCEDURE CreateAssignment:

    DEFINE INPUT PARAMETER ipAssignmentId AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseMasterId AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipEmployeeId   AS INTEGER   NO-UNDO.

    DEFINE VARIABLE hAuditRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE iAuditLogId      AS INTEGER NO-UNDO.

    DO TRANSACTION ON ERROR UNDO, THROW:

        CREATE assignment.

        ASSIGN
            assignment.assignmentId     = ipAssignmentId
            assignment.caseMasterId     = TRIM(ipCaseMasterId)
            assignment.employeeId       = ipEmployeeId
            assignment.assignedDate     = TODAY
            assignment.assignmentStatus = "Active"
            assignment.createdDate      = TODAY
            assignment.updatedDate      = TODAY.

        iAuditLogId = 700000 + ipAssignmentId.

        RUN audit/AuditRepository.p
            PERSISTENT SET hAuditRepository.

        RUN CreateAuditLog IN hAuditRepository (
            iAuditLogId,
            "assignment",
            ipAssignmentId,
            "CREATE",
            "SYSTEM"
        ).

        IF VALID-HANDLE(hAuditRepository) THEN
            DELETE PROCEDURE hAuditRepository.

    END.

END PROCEDURE.


PROCEDURE ReassignEmployee:

    DEFINE INPUT PARAMETER ipAssignmentId AS INTEGER NO-UNDO.
    DEFINE INPUT PARAMETER ipEmployeeId   AS INTEGER NO-UNDO.

    DEFINE OUTPUT PARAMETER opUpdated AS LOGICAL NO-UNDO.

    DEFINE VARIABLE hAuditRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE iAuditLogId      AS INTEGER NO-UNDO.

    opUpdated = FALSE.

    DO TRANSACTION ON ERROR UNDO, THROW:

        FIND FIRST assignment
            WHERE assignment.assignmentId = ipAssignmentId
            EXCLUSIVE-LOCK
            NO-ERROR.

        IF NOT AVAILABLE assignment THEN
            RETURN.

        ASSIGN
            assignment.employeeId       = ipEmployeeId
            assignment.assignedDate     = TODAY
            assignment.assignmentStatus = "Active"
            assignment.updatedDate      = TODAY.

        iAuditLogId = 800000 + ipAssignmentId.

        RUN audit/AuditRepository.p
            PERSISTENT SET hAuditRepository.

        RUN CreateAuditLog IN hAuditRepository (
            iAuditLogId,
            "assignment",
            ipAssignmentId,
            "REASSIGN",
            "SYSTEM"
        ).

        IF VALID-HANDLE(hAuditRepository) THEN
            DELETE PROCEDURE hAuditRepository.

        opUpdated = TRUE.

    END.

END PROCEDURE.


PROCEDURE CloseAssignment:

    DEFINE INPUT  PARAMETER ipAssignmentId AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER opUpdated      AS LOGICAL NO-UNDO.

    DEFINE VARIABLE hAuditRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE iAuditLogId      AS INTEGER NO-UNDO.

    opUpdated = FALSE.

    DO TRANSACTION ON ERROR UNDO, THROW:

        FIND FIRST assignment
            WHERE assignment.assignmentId = ipAssignmentId
            EXCLUSIVE-LOCK
            NO-ERROR.

        IF NOT AVAILABLE assignment THEN
            RETURN.

        ASSIGN
            assignment.assignmentStatus = "Closed"
            assignment.updatedDate      = TODAY.

        iAuditLogId = 900000 + ipAssignmentId.

        RUN audit/AuditRepository.p
            PERSISTENT SET hAuditRepository.

        RUN CreateAuditLog IN hAuditRepository (
            iAuditLogId,
            "assignment",
            ipAssignmentId,
            "CLOSE",
            "SYSTEM"
        ).

        IF VALID-HANDLE(hAuditRepository) THEN
            DELETE PROCEDURE hAuditRepository.

        opUpdated = TRUE.

    END.

END PROCEDURE.