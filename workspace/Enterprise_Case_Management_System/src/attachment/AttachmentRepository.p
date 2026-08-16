/*-------------------------------------------------------------------------
    File        : AttachmentRepository.p
    Description : Handles Attachment database operations
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.


PROCEDURE AttachmentExistsById:

    DEFINE INPUT  PARAMETER ipAttachmentId AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER opExists       AS LOGICAL NO-UNDO.

    FIND FIRST attachment
        WHERE attachment.attachmentId = ipAttachmentId
        NO-LOCK
        NO-ERROR.

    opExists = AVAILABLE attachment.

END PROCEDURE.


PROCEDURE CaseExists:

    DEFINE INPUT  PARAMETER ipCaseMasterId AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opExists       AS LOGICAL   NO-UNDO.

    FIND FIRST caseMaster
        WHERE caseMaster.caseMasterId = TRIM(ipCaseMasterId)
        NO-LOCK
        NO-ERROR.

    opExists = AVAILABLE caseMaster.

END PROCEDURE.


PROCEDURE EmployeeExists:

    DEFINE INPUT  PARAMETER ipEmployeeId AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER opExists     AS LOGICAL NO-UNDO.

    FIND FIRST employee
        WHERE employee.employeeId = ipEmployeeId
        NO-LOCK
        NO-ERROR.

    opExists = AVAILABLE employee.

END PROCEDURE.


PROCEDURE CreateAttachment:

    DEFINE INPUT PARAMETER ipAttachmentId AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseMasterId AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipEmployeeId   AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipFileName     AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipFilePath     AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hAuditRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE iAuditLogId      AS INTEGER NO-UNDO.

    DO TRANSACTION ON ERROR UNDO, THROW:

        CREATE attachment.

        ASSIGN
            attachment.attachmentId = ipAttachmentId
            attachment.caseMasterId = TRIM(ipCaseMasterId)
            attachment.employeeId   = ipEmployeeId
            attachment.fileName     = TRIM(ipFileName)
            attachment.filePath     = TRIM(ipFilePath)
            attachment.createdDate  = TODAY
            attachment.updatedDate  = TODAY.

        /* Audit */
        iAuditLogId = 1100000 + ipAttachmentId.

        RUN audit/AuditRepository.p
            PERSISTENT SET hAuditRepository.

        RUN CreateAuditLog IN hAuditRepository (
            iAuditLogId,
            "attachment",
            ipAttachmentId,
            "CREATE",
            "SYSTEM"
        ).

        IF VALID-HANDLE(hAuditRepository) THEN
            DELETE PROCEDURE hAuditRepository.

    END.

END PROCEDURE.


PROCEDURE GetAttachmentById:

    DEFINE INPUT PARAMETER ipAttachmentId AS INTEGER NO-UNDO.

    DEFINE OUTPUT PARAMETER opFound        AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opCaseMasterId AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opEmployeeId   AS INTEGER   NO-UNDO.
    DEFINE OUTPUT PARAMETER opFileName     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opFilePath     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opCreatedDate  AS DATE      NO-UNDO.

    ASSIGN
        opFound        = FALSE
        opCaseMasterId = ""
        opEmployeeId   = 0
        opFileName     = ""
        opFilePath     = ""
        opCreatedDate  = ?.

    FIND FIRST attachment
        WHERE attachment.attachmentId = ipAttachmentId
        NO-LOCK
        NO-ERROR.

    IF AVAILABLE attachment THEN
        ASSIGN
            opFound        = TRUE
            opCaseMasterId = attachment.caseMasterId
            opEmployeeId   = attachment.employeeId
            opFileName     = attachment.fileName
            opFilePath     = attachment.filePath
            opCreatedDate  = attachment.createdDate.

END PROCEDURE.