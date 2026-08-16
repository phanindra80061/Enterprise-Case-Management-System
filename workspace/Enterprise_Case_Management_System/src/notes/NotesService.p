/*-------------------------------------------------------------------------
    File        : NotesService.p
    Description : Handles Notes business rules
-------------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.


PROCEDURE CreateNote:

    DEFINE INPUT PARAMETER ipNotesId      AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipCaseMasterId AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER ipEmployeeId   AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipNoteText     AS CHARACTER NO-UNDO.

    DEFINE OUTPUT PARAMETER opSuccess AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE lExists     AS LOGICAL NO-UNDO.

    ASSIGN
        opSuccess = FALSE
        opMessage = "".

    /* Basic validation */

    IF ipNotesId <= 0 THEN DO:
        opMessage = "Note ID must be greater than zero.".
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

    IF ipNoteText = ? OR TRIM(ipNoteText) = "" THEN DO:
        opMessage = "Note text is required.".
        RETURN.
    END.

    IF LENGTH(TRIM(ipNoteText)) > 500 THEN DO:
        opMessage = "Note cannot exceed 500 characters.".
        RETURN.
    END.

    RUN notes/NotesRepository.p
        PERSISTENT SET hRepository.


    /* Duplicate note */

    RUN NoteExistsById IN hRepository (
        ipNotesId,
        OUTPUT lExists
    ).

    IF lExists THEN DO:

        DELETE PROCEDURE hRepository.

        opMessage = "Note ID already exists.".
        RETURN.

    END.


    /* Validate Case */

    RUN CaseExists IN hRepository (
        TRIM(ipCaseMasterId),
        OUTPUT lExists
    ).

    IF NOT lExists THEN DO:

        DELETE PROCEDURE hRepository.

        opMessage = "Case does not exist.".
        RETURN.

    END.


    /* Validate Employee */

    RUN EmployeeExists IN hRepository (
        ipEmployeeId,
        OUTPUT lExists
    ).

    IF NOT lExists THEN DO:

        DELETE PROCEDURE hRepository.

        opMessage = "Employee does not exist.".
        RETURN.

    END.


    /* Save */

    DO ON ERROR UNDO, THROW:

        RUN CreateNote IN hRepository (
            ipNotesId,
            TRIM(ipCaseMasterId),
            ipEmployeeId,
            TRIM(ipNoteText)
        ).

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = TRUE
            opMessage = "Note created successfully.".

    END.

    CATCH err AS Progress.Lang.Error:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = FALSE
            opMessage = err:GetMessage(1).

    END CATCH.

END PROCEDURE.


PROCEDURE GetNote:

    DEFINE INPUT PARAMETER ipNotesId AS INTEGER NO-UNDO.

    DEFINE OUTPUT PARAMETER opFound        AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opCaseMasterId AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opEmployeeId   AS INTEGER   NO-UNDO.
    DEFINE OUTPUT PARAMETER opNoteText     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opCreatedDate  AS DATE      NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage      AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE NO-UNDO.

    ASSIGN
        opFound   = FALSE
        opMessage = "".

    RUN notes/NotesRepository.p
        PERSISTENT SET hRepository.

    RUN GetNoteById IN hRepository (
        ipNotesId,
        OUTPUT opFound,
        OUTPUT opCaseMasterId,
        OUTPUT opEmployeeId,
        OUTPUT opNoteText,
        OUTPUT opCreatedDate
    ).

    IF VALID-HANDLE(hRepository) THEN
        DELETE PROCEDURE hRepository.

    IF opFound THEN
        opMessage = "Note found.".
    ELSE
        opMessage = "Note not found.".

END PROCEDURE.


PROCEDURE UpdateNote:

    DEFINE INPUT PARAMETER ipNotesId  AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER ipNoteText AS CHARACTER NO-UNDO.

    DEFINE OUTPUT PARAMETER opSuccess AS LOGICAL   NO-UNDO.
    DEFINE OUTPUT PARAMETER opMessage AS CHARACTER NO-UNDO.

    DEFINE VARIABLE hRepository AS HANDLE  NO-UNDO.
    DEFINE VARIABLE lUpdated    AS LOGICAL NO-UNDO.

    ASSIGN
        opSuccess = FALSE
        opMessage = "".

    IF ipNoteText = ? OR TRIM(ipNoteText) = "" THEN DO:
        opMessage = "Note text is required.".
        RETURN.
    END.

    IF LENGTH(TRIM(ipNoteText)) > 500 THEN DO:
        opMessage = "Note cannot exceed 500 characters.".
        RETURN.
    END.

    RUN notes/NotesRepository.p
        PERSISTENT SET hRepository.

    DO ON ERROR UNDO, THROW:

        RUN UpdateNote IN hRepository (
            ipNotesId,
            TRIM(ipNoteText),
            OUTPUT lUpdated
        ).

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        IF lUpdated THEN
            ASSIGN
                opSuccess = TRUE
                opMessage = "Note updated successfully.".
        ELSE
            opMessage = "Note not found.".

    END.

    CATCH err AS Progress.Lang.Error:

        IF VALID-HANDLE(hRepository) THEN
            DELETE PROCEDURE hRepository.

        ASSIGN
            opSuccess = FALSE
            opMessage = err:GetMessage(1).

    END CATCH.

END PROCEDURE.