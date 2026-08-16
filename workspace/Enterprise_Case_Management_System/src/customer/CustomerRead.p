/*-------------------------------------------------------------------------
    File        : CustomerRead.p
    Description : Customer read entry procedure
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER ipCustomerId AS INTEGER NO-UNDO.

DEFINE VARIABLE hService     AS HANDLE    NO-UNDO.
DEFINE VARIABLE lFound       AS LOGICAL   NO-UNDO.
DEFINE VARIABLE cFirstName   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLastName    AS CHARACTER NO-UNDO.
DEFINE VARIABLE cEmail       AS CHARACTER NO-UNDO.
DEFINE VARIABLE cPhone       AS CHARACTER NO-UNDO.
DEFINE VARIABLE dDateOfBirth AS DATE      NO-UNDO.
DEFINE VARIABLE cStatus      AS CHARACTER NO-UNDO.
DEFINE VARIABLE cMessage     AS CHARACTER NO-UNDO.

RUN customer/CustomerService.p
    PERSISTENT SET hService.

RUN GetCustomer IN hService (
    ipCustomerId,
    OUTPUT lFound,
    OUTPUT cFirstName,
    OUTPUT cLastName,
    OUTPUT cEmail,
    OUTPUT cPhone,
    OUTPUT dDateOfBirth,
    OUTPUT cStatus,
    OUTPUT cMessage
).

IF VALID-HANDLE(hService) THEN
    DELETE PROCEDURE hService.

IF lFound THEN
    MESSAGE
        "Customer ID:" ipCustomerId SKIP
        "Name:" cFirstName + " " + cLastName SKIP
        "Email:" cEmail SKIP
        "Phone:" cPhone SKIP
        "Date of Birth:" dDateOfBirth SKIP
        "Status:" cStatus
        VIEW-AS ALERT-BOX INFORMATION.
ELSE
    MESSAGE cMessage
        VIEW-AS ALERT-BOX WARNING.