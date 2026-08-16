/*-------------------------------------------------------------------------
    File        : EmployeeRepository.p
    Description : Employee database persistence layer
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.


PROCEDURE EmployeeExistsById:

    DEFINE INPUT  PARAMETER ipEmployeeId AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER opExists     AS LOGICAL NO-UNDO.

    FIND FIRST employee
        WHERE employee.employeeId = ipEmployeeId
        NO-LOCK
        NO-ERROR.

    opExists = AVAILABLE employee.

END PROCEDURE.


PROCEDURE EmployeeExistsByEmail:

    DEFINE INPUT  PARAMETER ipEmail  AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opExists AS LOGICAL   NO-UNDO.

    FIND FIRST employee
        WHERE employee.email = TRIM(ipEmail)
        NO-LOCK
        NO-ERROR.

    opExists = AVAILABLE employee.

END PROCEDURE.


PROCEDURE GetEmployeeById:

    DEFINE INPUT PARAMETER ipEmployeeId AS INTEGER NO-UNDO.

    DEFINE OUTPUT PARAMETER opFound       AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opFirstName   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opLastName    AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opEmail       AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opPhone       AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opDepartment  AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opDesignation AS CHARACTER NO-UNDO.

    ASSIGN
        opFound       = FALSE
        opFirstName   = ""
        opLastName    = ""
        opEmail       = ""
        opPhone       = ""
        opDepartment  = ""
        opDesignation = "".

    FIND FIRST employee
        WHERE employee.employeeId = ipEmployeeId
        NO-LOCK
        NO-ERROR.

    IF AVAILABLE employee THEN
        ASSIGN
            opFound       = TRUE
            opFirstName   = employee.firstName
            opLastName    = employee.lastName
            opEmail       = employee.email
            opPhone       = employee.phone
            opDepartment  = employee.department
            opDesignation = employee.designation.

END PROCEDURE.


PROCEDURE CreateEmployee:

    DEFINE INPUT PARAMETER ipEmployeeId  AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipFirstName   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipLastName    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipEmail       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipPhone       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipDepartment  AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipDesignation AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hAuditRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE iAuditLogId      AS INTEGER NO-UNDO.

    DO TRANSACTION ON ERROR UNDO, THROW:

        CREATE employee.

        ASSIGN
            employee.employeeId  = ipEmployeeId
            employee.firstName   = ipFirstName
            employee.lastName    = ipLastName
            employee.email       = ipEmail
            employee.phone       = ipPhone
            employee.department  = ipDepartment
            employee.designation = ipDesignation
            employee.createdDate = TODAY
            employee.updatedDate = TODAY.

        /* Temporary audit ID strategy */
        iAuditLogId = 100000 + ipEmployeeId.

        RUN audit/AuditRepository.p
            PERSISTENT SET hAuditRepository.

        RUN CreateAuditLog IN hAuditRepository (
            iAuditLogId,
            "employee",
            ipEmployeeId,
            "CREATE",
            "SYSTEM"
        ).

        IF VALID-HANDLE(hAuditRepository) THEN
            DELETE PROCEDURE hAuditRepository.

    END.

END PROCEDURE.


PROCEDURE UpdateEmployee:

    DEFINE INPUT PARAMETER ipEmployeeId  AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipFirstName   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipLastName    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipEmail       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipPhone       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipDepartment  AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipDesignation AS CHARACTER NO-UNDO.

    DEFINE OUTPUT PARAMETER opUpdated AS LOGICAL NO-UNDO.

    DEFINE VARIABLE hAuditRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE iAuditLogId      AS INTEGER NO-UNDO.

    opUpdated = FALSE.

    DO TRANSACTION ON ERROR UNDO, THROW:

        FIND FIRST employee
            WHERE employee.employeeId = ipEmployeeId
            EXCLUSIVE-LOCK
            NO-ERROR.

        IF NOT AVAILABLE employee THEN
            RETURN.

        ASSIGN
            employee.firstName   = ipFirstName
            employee.lastName    = ipLastName
            employee.email       = ipEmail
            employee.phone       = ipPhone
            employee.department  = ipDepartment
            employee.designation = ipDesignation
            employee.updatedDate = TODAY.

        iAuditLogId = 200000 + ipEmployeeId.

        RUN audit/AuditRepository.p
            PERSISTENT SET hAuditRepository.

        RUN CreateAuditLog IN hAuditRepository (
            iAuditLogId,
            "employee",
            ipEmployeeId,
            "UPDATE",
            "SYSTEM"
        ).

        IF VALID-HANDLE(hAuditRepository) THEN
            DELETE PROCEDURE hAuditRepository.

        opUpdated = TRUE.

    END.

END PROCEDURE.


PROCEDURE DeleteEmployee:

    DEFINE INPUT PARAMETER ipEmployeeId AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER opDeleted   AS LOGICAL NO-UNDO.

    DEFINE VARIABLE hAuditRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE iAuditLogId      AS INTEGER NO-UNDO.

    opDeleted = FALSE.

    DO TRANSACTION ON ERROR UNDO, THROW:

        FIND FIRST employee
            WHERE employee.employeeId = ipEmployeeId
            EXCLUSIVE-LOCK
            NO-ERROR.

        IF NOT AVAILABLE employee THEN
            RETURN.

        iAuditLogId = 300000 + ipEmployeeId.

        RUN audit/AuditRepository.p
            PERSISTENT SET hAuditRepository.

        RUN CreateAuditLog IN hAuditRepository (
            iAuditLogId,
            "employee",
            ipEmployeeId,
            "DELETE",
            "SYSTEM"
        ).

        DELETE employee.

        IF VALID-HANDLE(hAuditRepository) THEN
            DELETE PROCEDURE hAuditRepository.

        opDeleted = TRUE.

    END.

END PROCEDURE.