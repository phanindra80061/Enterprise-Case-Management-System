/*-------------------------------------------------------------------------
    File        : AttachmentService.p
    Description : Handles Attachment business rules
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.


PROCEDURE CreateAttachment:

    DEFINE INPUT PARAMETER ipAttachmentId AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseMasterId AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipEmployeeId   AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipFileName     AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipFilePath     AS CHARACTER NO-UNDO.

    DEFINE OUTPUT PARAMETER opSuccess AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE lExists     AS LOGICAL NO-UNDO.

    ASSIGN
        opSuccess = FALSE
        opMessage = "".

    /* Validation */

    IF ipAttachmentId <= 0 THEN DO:
        opMessage = "Attachment ID must be greater than zero.".
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

    IF ipFileName = ? OR TRIM(ipFileName) = "" THEN DO:
        opMessage = "File name is required.".
        RETURN.
    END.

    IF ipFilePath = ? OR TRIM(ipFilePath) = "" THEN DO:
        opMessage = "File path is required.".
        RETURN.
    END.

    RUN attachment/AttachmentRepository.p
        PERSISTENT SET hRepository.


    /* Duplicate attachment */

    RUN AttachmentExistsById IN hRepository (
        ipAttachmentId,
        OUTPUT lExists
    ).

    IF lExists THEN DO:
        DELETE PROCEDURE hRepository.
        opMessage = "Attachment ID already exists.".
        RETURN.
    END.


    /* Validate case */

    RUN CaseExists IN hRepository (
        TRIM(ipCaseMasterId),
        OUTPUT lExists
    ).

    IF NOT lExists THEN DO:
        DELETE PROCEDURE hRepository.
        opMessage = "Case does not exist.".
        RETURN.
    END.


    /* Validate employee */

    RUN EmployeeExists IN hRepository (
        ipEmployeeId,
        OUTPUT lExists
    ).

    IF NOT lExists THEN DO:
        DELETE PROCEDURE hRepository.
        opMessage = "Employee does not exist.".
        RETURN.
    END.


    /* Persist attachment */

    DO ON ERROR UNDO, THROW:

        RUN CreateAttachment IN hRepository (
            ipAttachmentId,
            TRIM(ipCaseMasterId),
            ipEmployeeId,
            TRIM(ipFileName),
            TRIM(ipFilePath)
        ).

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = TRUE
            opMessage = "Attachment created successfully.".

    END.

    CATCH err AS Progress.Lang.Error:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = FALSE
            opMessage = err:GetMessage(1).

    END CATCH.

END PROCEDURE.


PROCEDURE GetAttachment:

    DEFINE INPUT PARAMETER ipAttachmentId AS INTEGER NO-UNDO.

    DEFINE OUTPUT PARAMETER opFound        AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opCaseMasterId AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opEmployeeId   AS INTEGER   NO-UNDO.
    DEFINE OUTPUT PARAMETER opFileName     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opFilePath     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opCreatedDate  AS DATE      NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage      AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE NO-UNDO.

    ASSIGN
        opFound   = FALSE
        opMessage = "".

    RUN attachment/AttachmentRepository.p
        PERSISTENT SET hRepository.

    RUN GetAttachmentById IN hRepository (
        ipAttachmentId,
        OUTPUT opFound,
        OUTPUT opCaseMasterId,
        OUTPUT opEmployeeId,
        OUTPUT opFileName,
        OUTPUT opFilePath,
        OUTPUT opCreatedDate
    ).

    IF VALID-HANDLE(hRepository) THEN
        DELETE PROCEDURE hRepository.

    IF opFound THEN
        opMessage = "Attachment found.".
    ELSE
        opMessage = "Attachment not found.".

END PROCEDURE.