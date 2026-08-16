/*------------------------------------------------------------------------
    File        : EmployeeTest.p
    Description : Create and verify Employee 102
------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE hService     AS HANDLE    NO-UNDO.
DEFINE VARIABLE lSuccess     AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lFound       AS LOGICAL   NO-UNDO.
DEFINE VARIABLE cMessage     AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFirstName   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLastName    AS CHARACTER NO-UNDO.
DEFINE VARIABLE cEmail       AS CHARACTER NO-UNDO.
DEFINE VARIABLE cPhone       AS CHARACTER NO-UNDO.
DEFINE VARIABLE cDepartment  AS CHARACTER NO-UNDO.
DEFINE VARIABLE cDesignation AS CHARACTER NO-UNDO.


RUN employee/EmployeeService.p
    PERSISTENT SET hService.


/* =========================================================
   CREATE EMPLOYEE 102
   ========================================================= */

RUN CreateEmployee IN hService (
    102,
    "Sarah",
    "Johnson",
    "sarah.johnson@example.com",
    "5735556789",
    "Claims",
    "Claims Adjuster",
    OUTPUT lSuccess,
    OUTPUT cMessage
).

MESSAGE "CREATE EMPLOYEE 102:" cMessage
    VIEW-AS ALERT-BOX INFORMATION.


/* =========================================================
   VERIFY EMPLOYEE 102
   ========================================================= */

RUN GetEmployee IN hService (
    102,
    OUTPUT lFound,
    OUTPUT cFirstName,
    OUTPUT cLastName,
    OUTPUT cEmail,
    OUTPUT cPhone,
    OUTPUT cDepartment,
    OUTPUT cDesignation,
    OUTPUT cMessage
).

IF lFound THEN
    MESSAGE
        "Employee ID: 102" SKIP
        "Name:" cFirstName + " " + cLastName SKIP
        "Email:" cEmail SKIP
        "Phone:" cPhone SKIP
        "Department:" cDepartment SKIP
        "Designation:" cDesignation
        VIEW-AS ALERT-BOX INFORMATION.
ELSE
    MESSAGE cMessage
        VIEW-AS ALERT-BOX WARNING.


/* =========================================================
   CLEANUP
   ========================================================= */

IF VALID-HANDLE(hService) THEN
    DELETE PROCEDURE hService.