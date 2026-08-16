/*-------------------------------------------------------------------------
    File        : CustomerCreate.p
    Description : Customer creation entry procedure
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER ipCustomerId  AS INTEGER   NO-UNDO.
DEFINE INPUT PARAMETER ipFirstName   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER ipLastName    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER ipEmail       AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER ipPhone       AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER ipDateOfBirth AS DATE      NO-UNDO.
DEFINE INPUT PARAMETER ipStatus      AS CHARACTER NO-UNDO.

DEFINE VARIABLE hService AS HANDLE    NO-UNDO.
DEFINE VARIABLE lSuccess AS LOGICAL   NO-UNDO.
DEFINE VARIABLE cMessage AS CHARACTER NO-UNDO.

RUN customer/CustomerService.p
    PERSISTENT SET hService.

RUN CreateCustomer IN hService (
    ipCustomerId,
    ipFirstName,
    ipLastName,
    ipEmail,
    ipPhone,
    ipDateOfBirth,
    ipStatus,
    OUTPUT lSuccess,
    OUTPUT cMessage
).

IF VALID-HANDLE(hService) THEN
    DELETE PROCEDURE hService.

IF lSuccess THEN
    MESSAGE cMessage
        VIEW-AS ALERT-BOX INFORMATION.
ELSE
    MESSAGE cMessage
        VIEW-AS ALERT-BOX ERROR.