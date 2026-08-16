/*-------------------------------------------------------------------------
    File        : EmployeeService.p
    Description : Employee business/service layer
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.


PROCEDURE CreateEmployee:

    DEFINE INPUT PARAMETER ipEmployeeId  AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipFirstName   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipLastName    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipEmail       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipPhone       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipDepartment  AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipDesignation AS CHARACTER NO-UNDO.

    DEFINE OUTPUT PARAMETER opSuccess AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE lExists     AS LOGICAL NO-UNDO.

    ASSIGN
        opSuccess = FALSE
        opMessage = "".

    IF ipEmployeeId <= 0 THEN DO:
        opMessage = "Employee ID must be greater than zero.".
        RETURN.
    END.

    IF ipFirstName = ? OR TRIM(ipFirstName) = "" THEN DO:
        opMessage = "First name is required.".
        RETURN.
    END.

    IF ipLastName = ? OR TRIM(ipLastName) = "" THEN DO:
        opMessage = "Last name is required.".
        RETURN.
    END.

    IF ipEmail = ? OR
       TRIM(ipEmail) = "" OR
       INDEX(ipEmail, "@") = 0 THEN DO:

        opMessage = "Enter a valid email address.".
        RETURN.
    END.

    IF ipPhone = ? OR TRIM(ipPhone) = "" THEN DO:
        opMessage = "Phone number is required.".
        RETURN.
    END.

    IF ipDepartment = ? OR TRIM(ipDepartment) = "" THEN DO:
        opMessage = "Department is required.".
        RETURN.
    END.

    IF ipDesignation = ? OR TRIM(ipDesignation) = "" THEN DO:
        opMessage = "Designation is required.".
        RETURN.
    END.

    RUN employee/EmployeeRepository.p
        PERSISTENT SET hRepository.

    RUN EmployeeExistsById IN hRepository (
        ipEmployeeId,
        OUTPUT lExists
    ).

    IF lExists THEN DO:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        opMessage = "Employee ID already exists.".
        RETURN.

    END.

    RUN EmployeeExistsByEmail IN hRepository (
        TRIM(ipEmail),
        OUTPUT lExists
    ).

    IF lExists THEN DO:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        opMessage = "Employee email already exists.".
        RETURN.

    END.

    DO ON ERROR UNDO, THROW:

        RUN CreateEmployee IN hRepository (
            ipEmployeeId,
            TRIM(ipFirstName),
            TRIM(ipLastName),
            TRIM(ipEmail),
            TRIM(ipPhone),
            TRIM(ipDepartment),
            TRIM(ipDesignation)
        ).

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = TRUE
            opMessage = "Employee created successfully.".

    END.

    CATCH err AS Progress.Lang.Error:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = FALSE
            opMessage = err:GetMessage(1).

    END CATCH.

END PROCEDURE.


PROCEDURE GetEmployee:

    DEFINE INPUT PARAMETER ipEmployeeId AS INTEGER NO-UNDO.

    DEFINE OUTPUT PARAMETER opFound       AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opFirstName   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opLastName    AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opEmail       AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opPhone       AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opDepartment  AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opDesignation AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage     AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE NO-UNDO.

    ASSIGN
        opFound   = FALSE
        opMessage = "".

    IF ipEmployeeId <= 0 THEN DO:
        opMessage = "Invalid Employee ID.".
        RETURN.
    END.

    RUN employee/EmployeeRepository.p
        PERSISTENT SET hRepository.

    RUN GetEmployeeById IN hRepository (
        ipEmployeeId,
        OUTPUT opFound,
        OUTPUT opFirstName,
        OUTPUT opLastName,
        OUTPUT opEmail,
        OUTPUT opPhone,
        OUTPUT opDepartment,
        OUTPUT opDesignation
    ).

    IF VALID-HANDLE(hRepository) THEN
        DELETE PROCEDURE hRepository.

    IF opFound THEN
        opMessage = "Employee found.".
    ELSE
        opMessage = "Employee not found.".

END PROCEDURE.


PROCEDURE UpdateEmployee:

    DEFINE INPUT PARAMETER ipEmployeeId  AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipFirstName   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipLastName    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipEmail       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipPhone       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipDepartment  AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipDesignation AS CHARACTER NO-UNDO.

    DEFINE OUTPUT PARAMETER opSuccess AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE lUpdated    AS LOGICAL NO-UNDO.

    ASSIGN
        opSuccess = FALSE
        opMessage = "".

    IF ipEmployeeId <= 0 THEN DO:
        opMessage = "Invalid Employee ID.".
        RETURN.
    END.

    IF ipFirstName = ? OR TRIM(ipFirstName) = "" THEN DO:
        opMessage = "First name is required.".
        RETURN.
    END.

    IF ipLastName = ? OR TRIM(ipLastName) = "" THEN DO:
        opMessage = "Last name is required.".
        RETURN.
    END.

    IF ipEmail = ? OR
       TRIM(ipEmail) = "" OR
       INDEX(ipEmail, "@") = 0 THEN DO:

        opMessage = "Enter a valid email address.".
        RETURN.
    END.

    IF ipPhone = ? OR TRIM(ipPhone) = "" THEN DO:
        opMessage = "Phone number is required.".
        RETURN.
    END.

    IF ipDepartment = ? OR TRIM(ipDepartment) = "" THEN DO:
        opMessage = "Department is required.".
        RETURN.
    END.

    IF ipDesignation = ? OR TRIM(ipDesignation) = "" THEN DO:
        opMessage = "Designation is required.".
        RETURN.
    END.

    RUN employee/EmployeeRepository.p
        PERSISTENT SET hRepository.

    DO ON ERROR UNDO, THROW:

        RUN UpdateEmployee IN hRepository (
            ipEmployeeId,
            TRIM(ipFirstName),
            TRIM(ipLastName),
            TRIM(ipEmail),
            TRIM(ipPhone),
            TRIM(ipDepartment),
            TRIM(ipDesignation),
            OUTPUT lUpdated
        ).

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        IF lUpdated THEN
            ASSIGN
                opSuccess = TRUE
                opMessage = "Employee updated successfully.".
        ELSE
            opMessage = "Employee not found.".

    END.

    CATCH err AS Progress.Lang.Error:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = FALSE
            opMessage = err:GetMessage(1).

    END CATCH.

END PROCEDURE.


PROCEDURE DeleteEmployee:

    DEFINE INPUT PARAMETER ipEmployeeId AS INTEGER NO-UNDO.

    DEFINE OUTPUT PARAMETER opSuccess AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE lDeleted    AS LOGICAL NO-UNDO.

    ASSIGN
        opSuccess = FALSE
        opMessage = "".

    IF ipEmployeeId <= 0 THEN DO:
        opMessage = "Invalid Employee ID.".
        RETURN.
    END.

    RUN employee/EmployeeRepository.p
        PERSISTENT SET hRepository.

    DO ON ERROR UNDO, THROW:

        RUN DeleteEmployee IN hRepository (
            ipEmployeeId,
            OUTPUT lDeleted
        ).

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        IF lDeleted THEN
            ASSIGN
                opSuccess = TRUE
                opMessage = "Employee deleted successfully.".
        ELSE
            opMessage = "Employee not found.".

    END.

    CATCH err AS Progress.Lang.Error:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = FALSE
            opMessage = err:GetMessage(1).

    END CATCH.

END PROCEDURE.