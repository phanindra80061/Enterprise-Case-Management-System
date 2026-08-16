/*-------------------------------------------------------------------------
    File        : CustomerDelete.p
    Description : Customer deletion entry procedure
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER ipCustomerId AS INTEGER NO-UNDO.

DEFINE VARIABLE hService AS HANDLE    NO-UNDO.
DEFINE VARIABLE lSuccess AS LOGICAL   NO-UNDO.
DEFINE VARIABLE cMessage AS CHARACTER NO-UNDO.

RUN customer/CustomerService.p
    PERSISTENT SET hService.

RUN DeleteCustomer IN hService (
    ipCustomerId,
    OUTPUT lSuccess,
    OUTPUT cMessage
).

DELETE PROCEDURE hService.

IF lSuccess THEN
    MESSAGE cMessage
        VIEW-AS ALERT-BOX INFORMATION.
ELSE
    MESSAGE cMessage
        VIEW-AS ALERT-BOX ERROR.