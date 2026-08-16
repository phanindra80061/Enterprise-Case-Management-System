/*-------------------------------------------------------------------------
    File        : AuditRepository.p
    Description : Audit database persistence layer
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.


PROCEDURE CreateAuditLog:

    DEFINE INPUT PARAMETER ipAuditLogId  AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipTableName   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipRecordId    AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipAction      AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipPerformedBy AS CHARACTER NO-UNDO.

    CREATE auditLog.

    ASSIGN
        auditLog.auditLogId    = ipAuditLogId
        auditLog.tableName     = ipTableName
        auditLog.recordId      = ipRecordId
        auditLog.action        = ipAction
        auditLog.performedBy   = ipPerformedBy
        auditLog.performedDate = TODAY.

END PROCEDURE.


PROCEDURE GetAuditLogById:

    DEFINE INPUT PARAMETER ipAuditLogId AS INTEGER NO-UNDO.

    DEFINE OUTPUT PARAMETER opFound       AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opTableName   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opRecordId    AS INTEGER   NO-UNDO.
    DEFINE OUTPUT PARAMETER opAction      AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opPerformedBy AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opDate        AS DATE      NO-UNDO.

    FIND FIRST auditLog
        WHERE auditLog.auditLogId = ipAuditLogId
        NO-LOCK
        NO-ERROR.

    IF AVAILABLE auditLog THEN
        ASSIGN
            opFound       = TRUE
            opTableName   = auditLog.tableName
            opRecordId    = auditLog.recordId
            opAction      = auditLog.action
            opPerformedBy = auditLog.performedBy
            opDate        = auditLog.performedDate.
    ELSE
        opFound = FALSE.

END PROCEDURE.