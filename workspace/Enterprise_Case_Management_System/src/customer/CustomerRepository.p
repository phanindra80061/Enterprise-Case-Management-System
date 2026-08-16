/*-------------------------------------------------------------------------
    File        : CustomerRepository.p
    Description : Customer database persistence layer
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.


PROCEDURE CustomerExistsById:

    DEFINE INPUT  PARAMETER ipCustomerId AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER opExists     AS LOGICAL NO-UNDO.

    FIND FIRST customer
        WHERE customer.customerId = ipCustomerId
        NO-LOCK
        NO-ERROR.

    opExists = AVAILABLE customer.

END PROCEDURE.


PROCEDURE CustomerExistsByEmail:

    DEFINE INPUT  PARAMETER ipEmail  AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opExists AS LOGICAL   NO-UNDO.

    FIND FIRST customer
        WHERE customer.email = TRIM(ipEmail)
        NO-LOCK
        NO-ERROR.

    opExists = AVAILABLE customer.

END PROCEDURE.


PROCEDURE GetCustomerById:

    DEFINE INPUT PARAMETER ipCustomerId AS INTEGER NO-UNDO.

    DEFINE OUTPUT PARAMETER opFound       AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opFirstName   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opLastName    AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opEmail       AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opPhone       AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opDateOfBirth AS DATE      NO-UNDO.
    DEFINE OUTPUT PARAMETER opStatus      AS CHARACTER NO-UNDO.

    ASSIGN
        opFound       = FALSE
        opFirstName   = ""
        opLastName    = ""
        opEmail       = ""
        opPhone       = ""
        opDateOfBirth = ?
        opStatus      = "".

    FIND FIRST customer
        WHERE customer.customerId = ipCustomerId
        NO-LOCK
        NO-ERROR.

    IF AVAILABLE customer THEN
        ASSIGN
            opFound       = TRUE
            opFirstName   = customer.firstName
            opLastName    = customer.lastName
            opEmail       = customer.email
            opPhone       = customer.phone
            opDateOfBirth = customer.dateOfBirth
            opStatus      = customer.customerStatus.

END PROCEDURE.


PROCEDURE CreateCustomer:

    DEFINE INPUT PARAMETER ipCustomerId  AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipFirstName   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipLastName    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipEmail       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipPhone       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipDateOfBirth AS DATE      NO-UNDO.
    DEFINE INPUT PARAMETER ipStatus      AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hAuditRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE iAuditLogId      AS INTEGER NO-UNDO.

    DO TRANSACTION ON ERROR UNDO, THROW:

        CREATE customer.

        ASSIGN
            customer.customerId     = ipCustomerId
            customer.firstName      = ipFirstName
            customer.lastName       = ipLastName
            customer.email          = ipEmail
            customer.phone          = ipPhone
            customer.dateOfBirth    = ipDateOfBirth
            customer.customerStatus = ipStatus
            customer.createdDate    = TODAY
            customer.updatedDate    = TODAY.

        /* Temporary ID strategy until DB sequence is introduced */
        iAuditLogId = ipCustomerId + 1000.

        RUN audit/AuditRepository.p
            PERSISTENT SET hAuditRepository.

        RUN CreateAuditLog IN hAuditRepository (
            iAuditLogId,
            "customer",
            ipCustomerId,
            "CREATE",
            "SYSTEM"
        ).

        IF VALID-HANDLE(hAuditRepository) THEN
            DELETE PROCEDURE hAuditRepository.

    END.

END PROCEDURE.


PROCEDURE UpdateCustomer:

    DEFINE INPUT PARAMETER ipCustomerId AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipFirstName  AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipLastName   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipEmail      AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipPhone      AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipStatus     AS CHARACTER NO-UNDO.

    DEFINE OUTPUT PARAMETER opUpdated AS LOGICAL NO-UNDO.

    DEFINE VARIABLE hAuditRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE iAuditLogId      AS INTEGER NO-UNDO.

    opUpdated = FALSE.

    DO TRANSACTION ON ERROR UNDO, THROW:

        FIND FIRST customer
            WHERE customer.customerId = ipCustomerId
            EXCLUSIVE-LOCK
            NO-ERROR.

        IF NOT AVAILABLE customer THEN
            RETURN.

        ASSIGN
            customer.firstName      = ipFirstName
            customer.lastName       = ipLastName
            customer.email          = ipEmail
            customer.phone          = ipPhone
            customer.customerStatus = ipStatus
            customer.updatedDate    = TODAY.

        iAuditLogId = ipCustomerId + 2000.

        RUN audit/AuditRepository.p
            PERSISTENT SET hAuditRepository.

        RUN CreateAuditLog IN hAuditRepository (
            iAuditLogId,
            "customer",
            ipCustomerId,
            "UPDATE",
            "SYSTEM"
        ).

        IF VALID-HANDLE(hAuditRepository) THEN
            DELETE PROCEDURE hAuditRepository.

        opUpdated = TRUE.

    END.

END PROCEDURE.


PROCEDURE DeleteCustomer:

    DEFINE INPUT PARAMETER ipCustomerId AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER opDeleted   AS LOGICAL NO-UNDO.

    DEFINE VARIABLE hAuditRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE iAuditLogId      AS INTEGER NO-UNDO.

    opDeleted = FALSE.

    DO TRANSACTION ON ERROR UNDO, THROW:

        FIND FIRST customer
            WHERE customer.customerId = ipCustomerId
            EXCLUSIVE-LOCK
            NO-ERROR.

        IF NOT AVAILABLE customer THEN
            RETURN.

        iAuditLogId = ipCustomerId + 3000.

        RUN audit/AuditRepository.p
            PERSISTENT SET hAuditRepository.

        RUN CreateAuditLog IN hAuditRepository (
            iAuditLogId,
            "customer",
            ipCustomerId,
            "DELETE",
            "SYSTEM"
        ).

        DELETE customer.

        IF VALID-HANDLE(hAuditRepository) THEN
            DELETE PROCEDURE hAuditRepository.

        opDeleted = TRUE.

    END.

END PROCEDURE.