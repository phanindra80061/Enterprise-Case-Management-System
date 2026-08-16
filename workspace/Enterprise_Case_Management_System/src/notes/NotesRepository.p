/*-------------------------------------------------------------------------
    File        : NotesRepository.p
    Description : Handles Notes database operations
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.


PROCEDURE NoteExistsById:

    DEFINE INPUT  PARAMETER ipNotesId AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER opExists  AS LOGICAL NO-UNDO.

    FIND FIRST notes
        WHERE notes.notesId = ipNotesId
        NO-LOCK
        NO-ERROR.

    opExists = AVAILABLE notes.

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


PROCEDURE CreateNote:

    DEFINE INPUT PARAMETER ipNotesId      AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseMasterId AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipEmployeeId   AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipNoteText     AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hAuditRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE iAuditLogId      AS INTEGER NO-UNDO.

    DO TRANSACTION ON ERROR UNDO, THROW:

        CREATE notes.

        ASSIGN
            notes.notesId      = ipNotesId
            notes.caseMasterId = TRIM(ipCaseMasterId)
            notes.employeeId   = ipEmployeeId
            notes.noteText     = TRIM(ipNoteText)
            notes.createdDate  = TODAY
            notes.updatedDate  = TODAY.

        /* Audit */

        iAuditLogId = 1000000 + ipNotesId.

        RUN audit/AuditRepository.p
            PERSISTENT SET hAuditRepository.

        RUN CreateAuditLog IN hAuditRepository (
            iAuditLogId,
            "notes",
            ipNotesId,
            "CREATE",
            "SYSTEM"
        ).

        IF VALID-HANDLE(hAuditRepository) THEN
            DELETE PROCEDURE hAuditRepository.

    END.

END PROCEDURE.


PROCEDURE GetNoteById:

    DEFINE INPUT PARAMETER ipNotesId AS INTEGER NO-UNDO.

    DEFINE OUTPUT PARAMETER opFound        AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opCaseMasterId AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opEmployeeId   AS INTEGER   NO-UNDO.
    DEFINE OUTPUT PARAMETER opNoteText     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opCreatedDate  AS DATE      NO-UNDO.

    ASSIGN
        opFound        = FALSE
        opCaseMasterId = ""
        opEmployeeId   = 0
        opNoteText     = ""
        opCreatedDate  = ?.

    FIND FIRST notes
        WHERE notes.notesId = ipNotesId
        NO-LOCK
        NO-ERROR.

    IF AVAILABLE notes THEN
        ASSIGN
            opFound        = TRUE
            opCaseMasterId = notes.caseMasterId
            opEmployeeId   = notes.employeeId
            opNoteText     = notes.noteText
            opCreatedDate  = notes.createdDate.

END PROCEDURE.


PROCEDURE UpdateNote:

    DEFINE INPUT PARAMETER ipNotesId  AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipNoteText AS CHARACTER NO-UNDO.

    DEFINE OUTPUT PARAMETER opUpdated AS LOGICAL NO-UNDO.

    opUpdated = FALSE.

    DO TRANSACTION ON ERROR UNDO, THROW:

        FIND FIRST notes
            WHERE notes.notesId = ipNotesId
            EXCLUSIVE-LOCK
            NO-ERROR.

        IF NOT AVAILABLE notes THEN
            RETURN.

        ASSIGN
            notes.noteText    = TRIM(ipNoteText)
            notes.updatedDate = TODAY
            opUpdated         = TRUE.

    END.

END PROCEDURE.