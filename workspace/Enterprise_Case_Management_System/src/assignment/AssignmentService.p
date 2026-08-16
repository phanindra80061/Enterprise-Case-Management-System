/*-------------------------------------------------------------------------
    File        : AssignmentService.p
    Description : Assignment business/service layer
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.


PROCEDURE CreateAssignment:

    DEFINE INPUT PARAMETER ipAssignmentId AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseMasterId AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipEmployeeId   AS INTEGER   NO-UNDO.

    DEFINE OUTPUT PARAMETER opSuccess AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE lExists     AS LOGICAL NO-UNDO.

    ASSIGN
        opSuccess = FALSE
        opMessage = "".

    IF ipAssignmentId <= 0 THEN DO:
        opMessage = "Assignment ID must be greater than zero.".
        RETURN.
    END.

    IF ipCaseMasterId = ? OR TRIM(ipCaseMasterId) = "" THEN DO:
        opMessage = "Case Master ID is required.".
        RETURN.
    END.

    IF ipEmployeeId <= 0 THEN DO:
        opMessage = "Valid Employee ID is required.".
        RETURN.
    END.

    RUN assignment/AssignmentRepository.p
        PERSISTENT SET hRepository.


    /* Assignment ID validation */

    RUN AssignmentExistsById IN hRepository (
        ipAssignmentId,
        OUTPUT lExists
    ).

    IF lExists THEN DO:

        DELETE PROCEDURE hRepository.

        opMessage = "Assignment ID already exists.".
        RETURN.

    END.


    /* Case validation */

    RUN CaseExists IN hRepository (
        TRIM(ipCaseMasterId),
        OUTPUT lExists
    ).

    IF NOT lExists THEN DO:

        DELETE PROCEDURE hRepository.

        opMessage = "Case does not exist.".
        RETURN.

    END.


    /* Employee validation */

    RUN EmployeeExists IN hRepository (
        ipEmployeeId,
        OUTPUT lExists
    ).

    IF NOT lExists THEN DO:

        DELETE PROCEDURE hRepository.

        opMessage = "Employee does not exist.".
        RETURN.

    END.


    /* Only one active assignment per case */

    RUN ActiveAssignmentExists IN hRepository (
        TRIM(ipCaseMasterId),
        OUTPUT lExists
    ).

    IF lExists THEN DO:

        DELETE PROCEDURE hRepository.

        opMessage = "Case already has an active assignment.".
        RETURN.

    END.


    DO ON ERROR UNDO, THROW:

        RUN CreateAssignment IN hRepository (
            ipAssignmentId,
            TRIM(ipCaseMasterId),
            ipEmployeeId
        ).

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = TRUE
            opMessage = "Case assigned successfully.".

    END.

    CATCH err AS Progress.Lang.Error:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = FALSE
            opMessage = err:GetMessage(1).

    END CATCH.

END PROCEDURE.


PROCEDURE GetAssignment:

    DEFINE INPUT PARAMETER ipAssignmentId AS INTEGER NO-UNDO.

    DEFINE OUTPUT PARAMETER opFound            AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opCaseMasterId     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opEmployeeId       AS INTEGER   NO-UNDO.
    DEFINE OUTPUT PARAMETER opAssignedDate     AS DATE      NO-UNDO.
    DEFINE OUTPUT PARAMETER opAssignmentStatus AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage          AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE NO-UNDO.

    ASSIGN
        opFound   = FALSE
        opMessage = "".

    IF ipAssignmentId <= 0 THEN DO:
        opMessage = "Invalid Assignment ID.".
        RETURN.
    END.

    RUN assignment/AssignmentRepository.p
        PERSISTENT SET hRepository.

    RUN GetAssignmentById IN hRepository (
        ipAssignmentId,
        OUTPUT opFound,
        OUTPUT opCaseMasterId,
        OUTPUT opEmployeeId,
        OUTPUT opAssignedDate,
        OUTPUT opAssignmentStatus
    ).

    IF VALID-HANDLE(hRepository) THEN
        DELETE PROCEDURE hRepository.

    IF opFound THEN
        opMessage = "Assignment found.".
    ELSE
        opMessage = "Assignment not found.".

END PROCEDURE.


PROCEDURE ReassignEmployee:

    DEFINE INPUT PARAMETER ipAssignmentId AS INTEGER NO-UNDO.
    DEFINE INPUT PARAMETER ipEmployeeId   AS INTEGER NO-UNDO.

    DEFINE OUTPUT PARAMETER opSuccess AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE lExists     AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lUpdated    AS LOGICAL NO-UNDO.

    ASSIGN
        opSuccess = FALSE
        opMessage = "".

    IF ipAssignmentId <= 0 THEN DO:
        opMessage = "Invalid Assignment ID.".
        RETURN.
    END.

    IF ipEmployeeId <= 0 THEN DO:
        opMessage = "Invalid Employee ID.".
        RETURN.
    END.

    RUN assignment/AssignmentRepository.p
        PERSISTENT SET hRepository.

    RUN EmployeeExists IN hRepository (
        ipEmployeeId,
        OUTPUT lExists
    ).

    IF NOT lExists THEN DO:

        DELETE PROCEDURE hRepository.

        opMessage = "Employee does not exist.".
        RETURN.

    END.

    DO ON ERROR UNDO, THROW:

        RUN ReassignEmployee IN hRepository (
            ipAssignmentId,
            ipEmployeeId,
            OUTPUT lUpdated
        ).

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        IF lUpdated THEN
            ASSIGN
                opSuccess = TRUE
                opMessage = "Assignment updated successfully.".
        ELSE
            opMessage = "Assignment not found.".

    END.

    CATCH err AS Progress.Lang.Error:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = FALSE
            opMessage = err:GetMessage(1).

    END CATCH.

END PROCEDURE.


PROCEDURE CloseAssignment:

    DEFINE INPUT PARAMETER ipAssignmentId AS INTEGER NO-UNDO.

    DEFINE OUTPUT PARAMETER opSuccess AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE lUpdated    AS LOGICAL NO-UNDO.

    ASSIGN
        opSuccess = FALSE
        opMessage = "".

    IF ipAssignmentId <= 0 THEN DO:
        opMessage = "Invalid Assignment ID.".
        RETURN.
    END.

    RUN assignment/AssignmentRepository.p
        PERSISTENT SET hRepository.

    DO ON ERROR UNDO, THROW:

        RUN CloseAssignment IN hRepository (
            ipAssignmentId,
            OUTPUT lUpdated
        ).

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        IF lUpdated THEN
            ASSIGN
                opSuccess = TRUE
                opMessage = "Assignment closed successfully.".
        ELSE
            opMessage = "Assignment not found.".

    END.

    CATCH err AS Progress.Lang.Error:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = FALSE
            opMessage = err:GetMessage(1).

    END CATCH.

END PROCEDURE.