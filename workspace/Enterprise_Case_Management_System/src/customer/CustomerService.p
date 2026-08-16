/*-------------------------------------------------------------------------
    File        : CustomerService.p
    Description : Customer business/service layer
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.


PROCEDURE CreateCustomer:

    DEFINE INPUT PARAMETER ipCustomerId  AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipFirstName   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipLastName    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipEmail       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipPhone       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipDateOfBirth AS DATE      NO-UNDO.
    DEFINE INPUT PARAMETER ipStatus      AS CHARACTER NO-UNDO.

    DEFINE OUTPUT PARAMETER opSuccess AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE lExists     AS LOGICAL NO-UNDO.

    ASSIGN
        opSuccess = FALSE
        opMessage = "".

    IF ipCustomerId <= 0 THEN DO:
        opMessage = "Customer ID must be greater than zero.".
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

    IF ipEmail = ? OR TRIM(ipEmail) = "" OR INDEX(ipEmail, "@") = 0 THEN DO:
        opMessage = "Enter a valid email address.".
        RETURN.
    END.

    IF ipPhone = ? OR LENGTH(TRIM(ipPhone)) <> 10 THEN DO:
        opMessage = "Phone number must contain 10 digits.".
        RETURN.
    END.

    IF ipDateOfBirth = ? OR ipDateOfBirth >= TODAY THEN DO:
        opMessage = "Enter a valid date of birth.".
        RETURN.
    END.

    IF ipStatus <> "Active" AND ipStatus <> "Inactive" THEN DO:
        opMessage = "Status must be Active or Inactive.".
        RETURN.
    END.

    RUN customer/CustomerRepository.p
        PERSISTENT SET hRepository.

    RUN CustomerExistsById IN hRepository (
        ipCustomerId,
        OUTPUT lExists
    ).

    IF lExists THEN DO:
        DELETE PROCEDURE hRepository.
        opMessage = "Customer ID already exists.".
        RETURN.
    END.

    RUN CustomerExistsByEmail IN hRepository (
        TRIM(ipEmail),
        OUTPUT lExists
    ).

    IF lExists THEN DO:
        DELETE PROCEDURE hRepository.
        opMessage = "Customer email already exists.".
        RETURN.
    END.

    DO ON ERROR UNDO, THROW:

        RUN CreateCustomer IN hRepository (
            ipCustomerId,
            TRIM(ipFirstName),
            TRIM(ipLastName),
            TRIM(ipEmail),
            TRIM(ipPhone),
            ipDateOfBirth,
            ipStatus
        ).

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = TRUE
            opMessage = "Customer created successfully.".

    END.

    CATCH err AS Progress.Lang.Error:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = FALSE
            opMessage = err:GetMessage(1).

    END CATCH.

END PROCEDURE.


PROCEDURE GetCustomer:

    DEFINE INPUT PARAMETER ipCustomerId AS INTEGER NO-UNDO.

    DEFINE OUTPUT PARAMETER opFound       AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opFirstName   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opLastName    AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opEmail       AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opPhone       AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opDateOfBirth AS DATE      NO-UNDO.
    DEFINE OUTPUT PARAMETER opStatus      AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage     AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE NO-UNDO.

    opFound = FALSE.

    IF ipCustomerId <= 0 THEN DO:
        opMessage = "Invalid Customer ID.".
        RETURN.
    END.

    RUN customer/CustomerRepository.p
        PERSISTENT SET hRepository.

    RUN GetCustomerById IN hRepository (
        ipCustomerId,
        OUTPUT opFound,
        OUTPUT opFirstName,
        OUTPUT opLastName,
        OUTPUT opEmail,
        OUTPUT opPhone,
        OUTPUT opDateOfBirth,
        OUTPUT opStatus
    ).

    IF VALID-HANDLE(hRepository) THEN
        DELETE PROCEDURE hRepository.

    IF opFound THEN
        opMessage = "Customer found.".
    ELSE
        opMessage = "Customer not found.".

END PROCEDURE.


PROCEDURE UpdateCustomer:

    DEFINE INPUT PARAMETER ipCustomerId AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipFirstName  AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipLastName   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipEmail      AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipPhone      AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipStatus     AS CHARACTER NO-UNDO.

    DEFINE OUTPUT PARAMETER opSuccess AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE lUpdated    AS LOGICAL NO-UNDO.

    ASSIGN
        opSuccess = FALSE
        opMessage = "".

    IF ipCustomerId <= 0 THEN DO:
        opMessage = "Invalid Customer ID.".
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

    IF ipEmail = ? OR TRIM(ipEmail) = "" OR INDEX(ipEmail, "@") = 0 THEN DO:
        opMessage = "Enter a valid email address.".
        RETURN.
    END.

    IF ipPhone = ? OR LENGTH(TRIM(ipPhone)) <> 10 THEN DO:
        opMessage = "Phone number must contain 10 digits.".
        RETURN.
    END.

    IF ipStatus <> "Active" AND ipStatus <> "Inactive" THEN DO:
        opMessage = "Status must be Active or Inactive.".
        RETURN.
    END.

    RUN customer/CustomerRepository.p
        PERSISTENT SET hRepository.

    DO ON ERROR UNDO, THROW:

        RUN UpdateCustomer IN hRepository (
            ipCustomerId,
            TRIM(ipFirstName),
            TRIM(ipLastName),
            TRIM(ipEmail),
            TRIM(ipPhone),
            ipStatus,
            OUTPUT lUpdated
        ).

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        IF lUpdated THEN
            ASSIGN
                opSuccess = TRUE
                opMessage = "Customer updated successfully.".
        ELSE
            opMessage = "Customer not found.".

    END.

    CATCH err AS Progress.Lang.Error:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = FALSE
            opMessage = err:GetMessage(1).

    END CATCH.

END PROCEDURE.


PROCEDURE DeleteCustomer:

    DEFINE INPUT PARAMETER ipCustomerId AS INTEGER NO-UNDO.

    DEFINE OUTPUT PARAMETER opSuccess AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE lDeleted    AS LOGICAL NO-UNDO.

    ASSIGN
        opSuccess = FALSE
        opMessage = "".

    IF ipCustomerId <= 0 THEN DO:
        opMessage = "Invalid Customer ID.".
        RETURN.
    END.

    RUN customer/CustomerRepository.p
        PERSISTENT SET hRepository.

    DO ON ERROR UNDO, THROW:

        RUN DeleteCustomer IN hRepository (
            ipCustomerId,
            OUTPUT lDeleted
        ).

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        IF lDeleted THEN
            ASSIGN
                opSuccess = TRUE
                opMessage = "Customer deleted successfully.".
        ELSE
            opMessage = "Customer not found.".

    END.

    CATCH err AS Progress.Lang.Error:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = FALSE
            opMessage = err:GetMessage(1).

    END CATCH.

END PROCEDURE.