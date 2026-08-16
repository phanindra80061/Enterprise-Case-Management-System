/* ECMS PASOE REST WebHandler - consolidated */
USING Progress.Lang.*.
USING Progress.Json.ObjectModel.JsonObject.
USING OpenEdge.Web.WebResponseWriter.
USING OpenEdge.Net.HTTP.StatusCodeEnum.
USING OpenEdge.Web.WebHandler.
BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS Enterprise_Case_Management_SystemService INHERITS WebHandler:

METHOD OVERRIDE PROTECTED INTEGER HandleNotAllowedMethod(
    INPUT poRequest AS OpenEdge.Web.IWebRequest
):
    RETURN INTEGER(StatusCodeEnum:MethodNotAllowed).
END METHOD.

METHOD OVERRIDE PROTECTED INTEGER HandleNotImplemented(
    INPUT poRequest AS OpenEdge.Web.IWebRequest
):
    RETURN INTEGER(StatusCodeEnum:NotImplemented).
END METHOD.

METHOD OVERRIDE PROTECTED INTEGER HandleGet(INPUT poRequest AS OpenEdge.Web.IWebRequest):
    DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
    DEFINE VARIABLE oWriter AS OpenEdge.Web.WebResponseWriter NO-UNDO.
    DEFINE VARIABLE oBody AS OpenEdge.Core.String NO-UNDO.
    DEFINE VARIABLE oJson AS JsonObject NO-UNDO.
    DEFINE VARIABLE cUri AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cId AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iId AS INTEGER NO-UNDO.
    DEFINE VARIABLE lcJson AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE hSvc AS HANDLE NO-UNDO.
    DEFINE VARIABLE lFound AS LOGICAL NO-UNDO.
    DEFINE VARIABLE cMessage AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c1 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c2 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c3 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c4 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c5 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c6 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE i1 AS INTEGER NO-UNDO.
    DEFINE VARIABLE d1 AS DATE NO-UNDO.

    ASSIGN oResponse = NEW OpenEdge.Web.WebResponse()
           oJson = NEW JsonObject()
           cUri = STRING(poRequest:URI)
           cId = ENTRY(NUM-ENTRIES(cUri,"/"),cUri,"/").

    IF INDEX(cUri,"/cases/") > 0 THEN DO:
        RUN proDataSets/CaseDetailsJson.p(INPUT cId, OUTPUT lcJson).
        IF lcJson = ? OR LENGTH(STRING(lcJson)) = 0 THEN DO:
            oResponse:StatusCode = INTEGER(StatusCodeEnum:NotFound).
            oJson:Add("success",FALSE). oJson:Add("message","Case not found.").
            oBody = NEW OpenEdge.Core.String(oJson:GetJsonText()).
        END.
        ELSE DO:
            oResponse:StatusCode = INTEGER(StatusCodeEnum:OK).
            oBody = NEW OpenEdge.Core.String(STRING(lcJson)).
        END.
    END.
    ELSE IF INDEX(cUri,"/assignments/") > 0 THEN DO:
        iId = INTEGER(cId) NO-ERROR.
        IF ERROR-STATUS:ERROR OR iId <= 0 THEN DO:
            oResponse:StatusCode = INTEGER(StatusCodeEnum:BadRequest).
            oJson:Add("success",FALSE). oJson:Add("message","Invalid Assignment ID.").
        END.
        ELSE DO:
            RUN assignment/AssignmentService.p PERSISTENT SET hSvc.
            RUN GetAssignment IN hSvc(iId,OUTPUT lFound,OUTPUT c1,OUTPUT i1,OUTPUT d1,OUTPUT c2,OUTPUT cMessage).
            IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
            IF lFound THEN DO:
                oResponse:StatusCode = INTEGER(StatusCodeEnum:OK).
                oJson:Add("success",TRUE). oJson:Add("assignmentId",iId). oJson:Add("caseMasterId",c1).
                oJson:Add("employeeId",i1). oJson:Add("assignedDate",STRING(d1,"9999-99-99")).
                oJson:Add("assignmentStatus",c2). oJson:Add("message",cMessage).
            END.
            ELSE DO:
                oResponse:StatusCode = INTEGER(StatusCodeEnum:NotFound).
                oJson:Add("success",FALSE). oJson:Add("message",cMessage).
            END.
        END.
        oBody = NEW OpenEdge.Core.String(oJson:GetJsonText()).
    END.
    ELSE IF INDEX(cUri,"/employees/") > 0 THEN DO:
        iId = INTEGER(cId) NO-ERROR.
        IF ERROR-STATUS:ERROR OR iId <= 0 THEN DO:
            oResponse:StatusCode = INTEGER(StatusCodeEnum:BadRequest).
            oJson:Add("success",FALSE). oJson:Add("message","Invalid Employee ID.").
        END.
        ELSE DO:
            RUN employee/EmployeeService.p PERSISTENT SET hSvc.
            RUN GetEmployee IN hSvc(iId,OUTPUT lFound,OUTPUT c1,OUTPUT c2,OUTPUT c3,OUTPUT c4,OUTPUT c5,OUTPUT c6,OUTPUT cMessage).
            IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
            IF lFound THEN DO:
                oResponse:StatusCode = INTEGER(StatusCodeEnum:OK).
                oJson:Add("success",TRUE). oJson:Add("employeeId",iId). oJson:Add("firstName",c1). oJson:Add("lastName",c2).
                oJson:Add("email",c3). oJson:Add("phone",c4). oJson:Add("department",c5). oJson:Add("designation",c6). oJson:Add("message",cMessage).
            END.
            ELSE DO: oResponse:StatusCode = INTEGER(StatusCodeEnum:NotFound). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
        END.
        oBody = NEW OpenEdge.Core.String(oJson:GetJsonText()).
    END.
    ELSE IF INDEX(cUri,"/customers/") > 0 THEN DO:
        iId = INTEGER(cId) NO-ERROR.
        IF ERROR-STATUS:ERROR OR iId <= 0 THEN DO: oResponse:StatusCode = INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message","Invalid Customer ID."). END.
        ELSE DO:
            RUN customer/CustomerService.p PERSISTENT SET hSvc.
            RUN GetCustomer IN hSvc(iId,OUTPUT lFound,OUTPUT c1,OUTPUT c2,OUTPUT c3,OUTPUT c4,OUTPUT d1,OUTPUT c5,OUTPUT cMessage).
            IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
            IF lFound THEN DO:
                oResponse:StatusCode = INTEGER(StatusCodeEnum:OK).
                oJson:Add("success",TRUE). oJson:Add("customerId",iId). oJson:Add("firstName",c1). oJson:Add("lastName",c2).
                oJson:Add("email",c3). oJson:Add("phone",c4). oJson:Add("dateOfBirth",STRING(d1,"9999-99-99")). oJson:Add("customerStatus",c5). oJson:Add("message",cMessage).
            END.
            ELSE DO: oResponse:StatusCode = INTEGER(StatusCodeEnum:NotFound). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
        END.
        oBody = NEW OpenEdge.Core.String(oJson:GetJsonText()).
    END.
    ELSE IF INDEX(cUri,"/notes/") > 0 THEN DO:
        iId = INTEGER(cId) NO-ERROR.
        IF ERROR-STATUS:ERROR OR iId <= 0 THEN DO: oResponse:StatusCode = INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message","Invalid Notes ID."). END.
        ELSE DO:
            RUN notes/NotesService.p PERSISTENT SET hSvc.
            RUN GetNote IN hSvc(iId,OUTPUT lFound,OUTPUT c1,OUTPUT i1,OUTPUT c2,OUTPUT d1,OUTPUT cMessage).
            IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
            IF lFound THEN DO:
                oResponse:StatusCode = INTEGER(StatusCodeEnum:OK).
                oJson:Add("success",TRUE). oJson:Add("notesId",iId). oJson:Add("caseMasterId",c1). oJson:Add("employeeId",i1).
                oJson:Add("noteText",c2). oJson:Add("createdDate",STRING(d1,"9999-99-99")). oJson:Add("message",cMessage).
            END.
            ELSE DO: oResponse:StatusCode = INTEGER(StatusCodeEnum:NotFound). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
        END.
        oBody = NEW OpenEdge.Core.String(oJson:GetJsonText()).
    END.
    ELSE IF INDEX(cUri,"/attachments/") > 0 THEN DO:
        iId = INTEGER(cId) NO-ERROR.
        IF ERROR-STATUS:ERROR OR iId <= 0 THEN DO: oResponse:StatusCode = INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message","Invalid Attachment ID."). END.
        ELSE DO:
            RUN attachment/AttachmentService.p PERSISTENT SET hSvc.
            RUN GetAttachment IN hSvc(iId,OUTPUT lFound,OUTPUT c1,OUTPUT i1,OUTPUT c2,OUTPUT c3,OUTPUT d1,OUTPUT cMessage).
            IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
            IF lFound THEN DO:
                oResponse:StatusCode = INTEGER(StatusCodeEnum:OK).
                oJson:Add("success",TRUE). oJson:Add("attachmentId",iId). oJson:Add("caseMasterId",c1). oJson:Add("employeeId",i1).
                oJson:Add("fileName",c2). oJson:Add("filePath",c3). oJson:Add("createdDate",STRING(d1,"9999-99-99")). oJson:Add("message",cMessage).
            END.
            ELSE DO: oResponse:StatusCode = INTEGER(StatusCodeEnum:NotFound). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
        END.
        oBody = NEW OpenEdge.Core.String(oJson:GetJsonText()).
    END.
    ELSE IF INDEX(cUri,"/audit/") > 0 THEN DO:
        iId = INTEGER(cId) NO-ERROR.
        IF ERROR-STATUS:ERROR OR iId <= 0 THEN DO: oResponse:StatusCode = INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message","Invalid Audit Log ID."). END.
        ELSE DO:
            RUN audit/AuditRepository.p PERSISTENT SET hSvc.
            RUN GetAuditLogById IN hSvc(iId,OUTPUT lFound,OUTPUT c1,OUTPUT i1,OUTPUT c2,OUTPUT c3,OUTPUT d1).
            IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
            IF lFound THEN DO:
                oResponse:StatusCode = INTEGER(StatusCodeEnum:OK).
                oJson:Add("success",TRUE). oJson:Add("auditLogId",iId). oJson:Add("tableName",c1). oJson:Add("recordId",i1).
                oJson:Add("action",c2). oJson:Add("performedBy",c3). oJson:Add("auditDate",STRING(d1,"9999-99-99")).
            END.
            ELSE DO: oResponse:StatusCode = INTEGER(StatusCodeEnum:NotFound). oJson:Add("success",FALSE). oJson:Add("message","Audit log not found."). END.
        END.
        oBody = NEW OpenEdge.Core.String(oJson:GetJsonText()).
    END.
    ELSE DO:
        oResponse:StatusCode = INTEGER(StatusCodeEnum:BadRequest).
        oJson:Add("success",FALSE). oJson:Add("message","Invalid GET resource.").
        oBody = NEW OpenEdge.Core.String(oJson:GetJsonText()).
    END.

    ASSIGN oResponse:Entity=oBody oResponse:ContentType="application/json" oResponse:ContentLength=oBody:Size.
    oWriter=NEW WebResponseWriter(oResponse). oWriter:Open(). oWriter:Close(). RETURN 0.
END METHOD.

METHOD OVERRIDE PROTECTED INTEGER HandlePost(INPUT poRequest AS OpenEdge.Web.IWebRequest):
    DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
    DEFINE VARIABLE oWriter AS OpenEdge.Web.WebResponseWriter NO-UNDO.
    DEFINE VARIABLE oBody AS OpenEdge.Core.String NO-UNDO.
    DEFINE VARIABLE oReq AS JsonObject NO-UNDO.
    DEFINE VARIABLE oJson AS JsonObject NO-UNDO.
    DEFINE VARIABLE cUri AS CHARACTER NO-UNDO.
    DEFINE VARIABLE hSvc AS HANDLE NO-UNDO.
    DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
    DEFINE VARIABLE cMessage AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c1 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c2 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c3 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c4 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c5 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c6 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE i1 AS INTEGER NO-UNDO.
    DEFINE VARIABLE i2 AS INTEGER NO-UNDO.
    DEFINE VARIABLE d1 AS DATE NO-UNDO.

    ASSIGN
        oResponse = NEW OpenEdge.Web.WebResponse()
        oJson     = NEW JsonObject()
        cUri      = STRING(poRequest:URI)
        oReq      = CAST(poRequest:Entity, JsonObject).

    IF INDEX(cUri,"/assignments") > 0 THEN DO:
        ASSIGN i1=oReq:GetInteger("assignmentId") c1=oReq:GetCharacter("caseMasterId") i2=oReq:GetInteger("employeeId").
        RUN assignment/AssignmentService.p PERSISTENT SET hSvc.
        RUN CreateAssignment IN hSvc(i1,c1,i2,OUTPUT lSuccess,OUTPUT cMessage).
        IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
        IF lSuccess THEN DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:Created). oJson:Add("success",TRUE). oJson:Add("message",cMessage). oJson:Add("assignmentId",i1). oJson:Add("caseMasterId",c1). oJson:Add("employeeId",i2). END.
        ELSE DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
    END.
    ELSE IF INDEX(cUri,"/employees") > 0 THEN DO:
        ASSIGN i1=oReq:GetInteger("employeeId") c1=oReq:GetCharacter("firstName") c2=oReq:GetCharacter("lastName") c3=oReq:GetCharacter("email") c4=oReq:GetCharacter("phone") c5=oReq:GetCharacter("department") c6=oReq:GetCharacter("designation").
        RUN employee/EmployeeService.p PERSISTENT SET hSvc.
        RUN CreateEmployee IN hSvc(i1,c1,c2,c3,c4,c5,c6,OUTPUT lSuccess,OUTPUT cMessage).
        IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
        IF lSuccess THEN DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:Created). oJson:Add("success",TRUE). oJson:Add("message",cMessage). oJson:Add("employeeId",i1). END.
        ELSE DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
    END.
    ELSE IF INDEX(cUri, "/customers") > 0 THEN DO:

        ASSIGN
            i1 = oReq:GetInteger("customerId")
            c1 = oReq:GetCharacter("firstName")
            c2 = oReq:GetCharacter("lastName")
            c3 = oReq:GetCharacter("email")
            c4 = oReq:GetCharacter("phone")
            c5 = oReq:GetCharacter("status")
            c6 = oReq:GetCharacter("dateOfBirth").

        /* REST JSON date format: YYYY-MM-DD */
        IF c6 = ?
            OR LENGTH(TRIM(c6)) <> 10
            OR SUBSTRING(c6, 5, 1) <> "-"
            OR SUBSTRING(c6, 8, 1) <> "-" THEN DO:

            oResponse:StatusCode =
                INTEGER(StatusCodeEnum:BadRequest).

            oJson:Add("success", FALSE).
            oJson:Add(
                "message",
                "dateOfBirth must use YYYY-MM-DD format."
            ).

        END.
        ELSE DO:

            d1 = DATE(
                INTEGER(SUBSTRING(c6, 6, 2)),
                INTEGER(SUBSTRING(c6, 9, 2)),
                INTEGER(SUBSTRING(c6, 1, 4))
            ) NO-ERROR.

            IF ERROR-STATUS:ERROR OR d1 = ? THEN DO:

                oResponse:StatusCode =
                    INTEGER(StatusCodeEnum:BadRequest).

                oJson:Add("success", FALSE).
                oJson:Add("message", "Invalid dateOfBirth.").

            END.
            ELSE DO:

                RUN customer/CustomerService.p
                    PERSISTENT SET hSvc.

                RUN CreateCustomer IN hSvc (
                    i1,
                    c1,
                    c2,
                    c3,
                    c4,
                    d1,
                    c5,
                    OUTPUT lSuccess,
                    OUTPUT cMessage
                ).

                IF VALID-HANDLE(hSvc) THEN
                    DELETE PROCEDURE hSvc.

                IF lSuccess THEN DO:
                    oResponse:StatusCode =
                        INTEGER(StatusCodeEnum:Created).

                    oJson:Add("success", TRUE).
                    oJson:Add("message", cMessage).
                    oJson:Add("customerId", i1).
                END.
                ELSE DO:
                    oResponse:StatusCode =
                        INTEGER(StatusCodeEnum:BadRequest).

                    oJson:Add("success", FALSE).
                    oJson:Add("message", cMessage).
                END.

            END.

        END.

    END.
    ELSE IF INDEX(cUri,"/notes") > 0 THEN DO:
        ASSIGN i1=oReq:GetInteger("notesId") c1=oReq:GetCharacter("caseMasterId") i2=oReq:GetInteger("employeeId") c2=oReq:GetCharacter("noteText").
        RUN notes/NotesService.p PERSISTENT SET hSvc.
        RUN CreateNote IN hSvc(i1,c1,i2,c2,OUTPUT lSuccess,OUTPUT cMessage).
        IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
        IF lSuccess THEN DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:Created). oJson:Add("success",TRUE). oJson:Add("message",cMessage). oJson:Add("notesId",i1). END.
        ELSE DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
    END.
    ELSE IF INDEX(cUri,"/attachments") > 0 THEN DO:
        ASSIGN i1=oReq:GetInteger("attachmentId") c1=oReq:GetCharacter("caseMasterId") i2=oReq:GetInteger("employeeId") c2=oReq:GetCharacter("fileName") c3=oReq:GetCharacter("filePath").
        RUN attachment/AttachmentService.p PERSISTENT SET hSvc.
        RUN CreateAttachment IN hSvc(i1,c1,i2,c2,c3,OUTPUT lSuccess,OUTPUT cMessage).
        IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
        IF lSuccess THEN DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:Created). oJson:Add("success",TRUE). oJson:Add("message",cMessage). oJson:Add("attachmentId",i1). END.
        ELSE DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
    END.
    ELSE IF INDEX(cUri,"/cases") > 0 THEN DO:
        ASSIGN c1=oReq:GetCharacter("caseMasterId") c2=oReq:GetCharacter("caseNumber") c3=oReq:GetCharacter("caseTitle") c4=oReq:GetCharacter("caseDescription") c5=oReq:GetCharacter("caseStatus") c6=oReq:GetCharacter("priority") i1=oReq:GetInteger("customerId").
        RUN caseManagement/CaseService.p PERSISTENT SET hSvc.
        RUN CreateCase IN hSvc(c1,c2,c3,c4,c5,c6,i1,OUTPUT lSuccess,OUTPUT cMessage).
        IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
        IF lSuccess THEN DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:Created). oJson:Add("success",TRUE). oJson:Add("message",cMessage). oJson:Add("caseMasterId",c1). END.
        ELSE DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
    END.
    ELSE DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message","Invalid POST resource."). END.

    oBody=NEW OpenEdge.Core.String(oJson:GetJsonText()). ASSIGN oResponse:Entity=oBody oResponse:ContentType="application/json" oResponse:ContentLength=oBody:Size.
    oWriter=NEW WebResponseWriter(oResponse). oWriter:Open(). oWriter:Close(). RETURN 0.
END METHOD.

METHOD OVERRIDE PROTECTED INTEGER HandlePut(INPUT poRequest AS OpenEdge.Web.IWebRequest):
    DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
    DEFINE VARIABLE oWriter AS OpenEdge.Web.WebResponseWriter NO-UNDO.
    DEFINE VARIABLE oBody AS OpenEdge.Core.String NO-UNDO.
    DEFINE VARIABLE oReq AS JsonObject NO-UNDO.
    DEFINE VARIABLE oJson AS JsonObject NO-UNDO.
    DEFINE VARIABLE cUri AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cId AS CHARACTER NO-UNDO.
    DEFINE VARIABLE hSvc AS HANDLE NO-UNDO.
    DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
    DEFINE VARIABLE cMessage AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c1 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c2 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c3 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c4 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c5 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE c6 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iId AS INTEGER NO-UNDO.
    DEFINE VARIABLE i1 AS INTEGER NO-UNDO.

    ASSIGN oResponse=NEW OpenEdge.Web.WebResponse() oJson=NEW JsonObject() cUri=STRING(poRequest:URI) cId=ENTRY(NUM-ENTRIES(cUri,"/"),cUri,"/") oReq=CAST(poRequest:Entity,JsonObject).

    IF INDEX(cUri,"/assignments/") > 0 THEN DO:
        iId=INTEGER(cId) NO-ERROR. i1=oReq:GetInteger("employeeId").
        IF ERROR-STATUS:ERROR OR iId <= 0 THEN DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message","Invalid Assignment ID."). END.
        ELSE DO:
            RUN assignment/AssignmentService.p PERSISTENT SET hSvc. RUN ReassignEmployee IN hSvc(iId,i1,OUTPUT lSuccess,OUTPUT cMessage). IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
            IF lSuccess THEN DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:OK). oJson:Add("success",TRUE). oJson:Add("message",cMessage). oJson:Add("assignmentId",iId). oJson:Add("employeeId",i1). END.
            ELSE DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
        END.
    END.
    ELSE IF INDEX(cUri,"/employees/") > 0 THEN DO:
        iId=INTEGER(cId) NO-ERROR.
        ASSIGN c1=oReq:GetCharacter("firstName") c2=oReq:GetCharacter("lastName") c3=oReq:GetCharacter("email") c4=oReq:GetCharacter("phone") c5=oReq:GetCharacter("department") c6=oReq:GetCharacter("designation").
        RUN employee/EmployeeService.p PERSISTENT SET hSvc. RUN UpdateEmployee IN hSvc(iId,c1,c2,c3,c4,c5,c6,OUTPUT lSuccess,OUTPUT cMessage). IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
        IF lSuccess THEN DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:OK). oJson:Add("success",TRUE). oJson:Add("message",cMessage). oJson:Add("employeeId",iId). END.
        ELSE DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
    END.
    ELSE IF INDEX(cUri,"/customers/") > 0 THEN DO:
        iId=INTEGER(cId) NO-ERROR.
        ASSIGN c1=oReq:GetCharacter("firstName") c2=oReq:GetCharacter("lastName") c3=oReq:GetCharacter("email") c4=oReq:GetCharacter("phone") c5=oReq:GetCharacter("customerStatus").
        RUN customer/CustomerService.p PERSISTENT SET hSvc. RUN UpdateCustomer IN hSvc(iId,c1,c2,c3,c4,c5,OUTPUT lSuccess,OUTPUT cMessage). IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
        IF lSuccess THEN DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:OK). oJson:Add("success",TRUE). oJson:Add("message",cMessage). oJson:Add("customerId",iId). END.
        ELSE DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
    END.
    ELSE IF INDEX(cUri,"/notes/") > 0 THEN DO:
        iId=INTEGER(cId) NO-ERROR. c1=oReq:GetCharacter("noteText").
        RUN notes/NotesService.p PERSISTENT SET hSvc. RUN UpdateNote IN hSvc(iId,c1,OUTPUT lSuccess,OUTPUT cMessage). IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
        IF lSuccess THEN DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:OK). oJson:Add("success",TRUE). oJson:Add("message",cMessage). oJson:Add("notesId",iId). END.
        ELSE DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
    END.
    ELSE IF INDEX(cUri,"/cases/") > 0 THEN DO:
        ASSIGN c1=oReq:GetCharacter("caseTitle") c2=oReq:GetCharacter("caseDescription") c3=oReq:GetCharacter("caseStatus") c4=oReq:GetCharacter("priority").
        RUN caseManagement/CaseService.p PERSISTENT SET hSvc. RUN UpdateCase IN hSvc(cId,c1,c2,c3,c4,OUTPUT lSuccess,OUTPUT cMessage). IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
        IF lSuccess THEN DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:OK). oJson:Add("success",TRUE). oJson:Add("message",cMessage). oJson:Add("caseMasterId",cId). END.
        ELSE DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
    END.
    ELSE DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message","Invalid PUT resource."). END.

    oBody=NEW OpenEdge.Core.String(oJson:GetJsonText()). ASSIGN oResponse:Entity=oBody oResponse:ContentType="application/json" oResponse:ContentLength=oBody:Size.
    oWriter=NEW WebResponseWriter(oResponse). oWriter:Open(). oWriter:Close(). RETURN 0.
END METHOD.

METHOD OVERRIDE PROTECTED INTEGER HandleDelete(INPUT poRequest AS OpenEdge.Web.IWebRequest):
    DEFINE VARIABLE oResponse AS OpenEdge.Net.HTTP.IHttpResponse NO-UNDO.
    DEFINE VARIABLE oWriter AS OpenEdge.Web.WebResponseWriter NO-UNDO.
    DEFINE VARIABLE oBody AS OpenEdge.Core.String NO-UNDO.
    DEFINE VARIABLE oJson AS JsonObject NO-UNDO.
    DEFINE VARIABLE cUri AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cId AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iId AS INTEGER NO-UNDO.
    DEFINE VARIABLE hSvc AS HANDLE NO-UNDO.
    DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
    DEFINE VARIABLE cMessage AS CHARACTER NO-UNDO.

    ASSIGN oResponse=NEW OpenEdge.Web.WebResponse() oJson=NEW JsonObject() cUri=STRING(poRequest:URI) cId=ENTRY(NUM-ENTRIES(cUri,"/"),cUri,"/").

    IF INDEX(cUri,"/assignments/") > 0 THEN DO:
        iId=INTEGER(cId) NO-ERROR.
        RUN assignment/AssignmentService.p PERSISTENT SET hSvc. RUN CloseAssignment IN hSvc(iId,OUTPUT lSuccess,OUTPUT cMessage). IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
        IF lSuccess THEN DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:OK). oJson:Add("success",TRUE). oJson:Add("message",cMessage). oJson:Add("assignmentId",iId). oJson:Add("assignmentStatus","Closed"). END.
        ELSE DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:NotFound). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
    END.
    ELSE IF INDEX(cUri,"/employees/") > 0 THEN DO:
        iId=INTEGER(cId) NO-ERROR. RUN employee/EmployeeService.p PERSISTENT SET hSvc. RUN DeleteEmployee IN hSvc(iId,OUTPUT lSuccess,OUTPUT cMessage). IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
        IF lSuccess THEN DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:OK). oJson:Add("success",TRUE). oJson:Add("message",cMessage). oJson:Add("employeeId",iId). END.
        ELSE DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:NotFound). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
    END.
    ELSE IF INDEX(cUri,"/customers/") > 0 THEN DO:
        iId=INTEGER(cId) NO-ERROR. RUN customer/CustomerService.p PERSISTENT SET hSvc. RUN DeleteCustomer IN hSvc(iId,OUTPUT lSuccess,OUTPUT cMessage). IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
        IF lSuccess THEN DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:OK). oJson:Add("success",TRUE). oJson:Add("message",cMessage). oJson:Add("customerId",iId). END.
        ELSE DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:NotFound). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
    END.
    ELSE IF INDEX(cUri,"/cases/") > 0 THEN DO:
        RUN caseManagement/CaseService.p PERSISTENT SET hSvc. RUN DeleteCase IN hSvc(cId,OUTPUT lSuccess,OUTPUT cMessage). IF VALID-HANDLE(hSvc) THEN DELETE PROCEDURE hSvc.
        IF lSuccess THEN DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:OK). oJson:Add("success",TRUE). oJson:Add("message",cMessage). oJson:Add("caseMasterId",cId). END.
        ELSE DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:NotFound). oJson:Add("success",FALSE). oJson:Add("message",cMessage). END.
    END.
    ELSE DO: oResponse:StatusCode=INTEGER(StatusCodeEnum:BadRequest). oJson:Add("success",FALSE). oJson:Add("message","Invalid DELETE resource."). END.

    oBody=NEW OpenEdge.Core.String(oJson:GetJsonText()). ASSIGN oResponse:Entity=oBody oResponse:ContentType="application/json" oResponse:ContentLength=oBody:Size.
    oWriter=NEW WebResponseWriter(oResponse). oWriter:Open(). oWriter:Close(). RETURN 0.
END METHOD.

END CLASS.
