module lsp::BasicStructures

import util::Maybe; // TODO: For optional values

/* Module to capture the structure of LSP data types as described in https://microsoft.github.io/language-server-protocol/specifications/specification-3-16/#uri
 */

alias integer = int;
alias uinteger = int;
alias decimal = int;


data Message
    = message(str jsonrpc);

data RequestId1 // Instead of integer | str
    = request_1_id(int int_id)
    | request_1_id(str str_id)
    ;

data RequestId2 // Instead of integer | str | null
    = request_2_id(int int_id)
    | request_2_id(str str_id)
    | request_2_id()
    ;

data RequestMessage // extends message. Params is of type: array | object, not sure how to capture desired behaviour in Rascal
    = request_message(str jsonrpc, RequestId1 id, str method, value params)
    ;

data ResponseId // Instead of integer | str | null
    = response_id(int int_id)
    | response_id(str str_id)
    | response_id()
    ;

data ResponseResult // Instead of string | number | boolean | object | null
    = result(str str_result)
    | result(int int_result)
    | result(bool bool_result)
    // | result(object result)
    | result()
    ;

data ResponseMessage // extends message.
    = response_message(str jsonrpc, RequestId2 id, ResponseResult result, ResponseError error);

data ResponseError
    = response_error(int code, str message, value \data);

data ErrorCodes
    = ParseError(int val = -37000)
    | InvalidRequest(int val = -32600)
    | MethodNotFound(int val = -32601)
    | InvalidParams(int val = -32602)
    | InternalError(int val = -32603)
    | jsonrpcReservedErrorRangeStart(int val = -32099)
    | serverErrorStart(int val = -32099)
    | ServerNotInitialized(int val = -32002)
    | UnknownErrorCode(int val = -32001)
    | jsonrpcReservedErrorRangeEnd(int val = -32000)
    | serverErrorEnd(int val = -32000)
    | lspReservedErrorRangeStart(int val = -32899)
    | ContentModified(int val = -32801)
    | RequestCancelled(int val = -32800)
    | lspReservedErrorRangeEnd(int val = -32800)
    ;

data NotificationMessage // extends Message
    = notification_message(str jsonrpc, str method, value params);

data CancelParams
    = cancel_params(int int_id)
    | cancel_params(str str_id)
    ;

data ProgressToken
    = progress_token(int int_token)
    | progress_token(str str_token)
    ;

data ProgressParams[&T] // Maybe easier to just use value type
    = progress_params(ProgressToken token, &T \value);
// data ProgressParams
//     = progress_params(ProgressToken token, value \value);

data Uri
    = uri(str uri);
data DocumentUri
    = document_uri(str document_uri);

// https://microsoft.github.io/language-server-protocol/specifications/specification-3-16/#position
data Position
    = position(
        /**
        * Line position in a document (zero-based).
        */
        int line,
        /**
        * Character offset on a line in a document (zero-based). Assuming that
        * the line is represented as a string, the `character` value represents
        * the gap between the `character` and `character + 1`.
        *
        * If the character value is greater than the line length it defaults back
        * to the line length.
        */
        int character
    ); // Both zero-based

/* A range in a text document expressed as (zero-based) start and end positions. A range is comparable to a selection in an editor. Therefore the end position is exclusive. If you want to specify a range that contains a line including the line ending character(s) then use an end position denoting the start of the next line. 
 */
data Range
    = range(Position \start, Position end);

data Location
    = location(DocumentUri document_uri, Range range);

data LocationLink
    = location_link(Range originSelectionRange, DocumentUri targetUri, Range targetRange, Range targetSelectionRange);

data Diagnostic
    = diagnostic(Range range, DiagnosticSeverity severity, str code, CodeDescription codeDescription, str source, str message, list[DiagnosticTag] tags, list[DiagnosticRelatedInformation] relatedInformation, value \data);

// Iffy, doesn't really match https://microsoft.github.io/language-server-protocol/specifications/specification-3-16/#diagnostic
data DiagnosticSeverity
    = error(int \one = 1)
    | warning(int two = 2)
    | information(int three = 3)
    | hint(int four = 4)
    ;
data DiagnosticTag
    = unnecessary(int \one = 1)
    | deprecated(int two = 2)
    ;

data DiagnosticRelatedInformation
    = diagnostic_related_information(Location location, str message);

data CodeDescription
    = code_description(Uri href);


data Command
    = command(str title, str command, list[value] arguments);

data TextEdit
    = text_edit(Range range, str newText);
data ChangeAnnotation
    = change_annotation(str label, bool needsConfirmation, str description);
data ChangeAnnotationIdentifier // iffy
    = change_annotation_identifier(str changeAnnotationIdentifier);
data AnnotatedTextEdit // extends TextEdit; not sure how to capture that behaviour in Rascal
    = annotated_text_edit(Range range, str newText, ChangeAnnotationIdentifier annotationId);

data TextDocumentEdit // Not sure if the possible types for 'edits' are captured here as intended by the spec
    = text_document_edit(OptionalVersionedTextDocumentIdentifier textDocument, list[TextEdit] edits)
    | text_document_edit(OptionalVersionedTextDocumentIdentifier textDocument, list[AnnotatedTextEdit] annotated_edits)
    ;

// .. some missing structures

data TextDocumentIdentifier
    = text_document_identifier(DocumentUri uri);

data TextDocumentItem
    = text_document_item(DocumentUri uri, str languageId, int version, str text);

data VersionedTextDocumentIdentifier // extends TextDocumentIdentifier
    = versioned_text_document_identifier(DocumentUri uri, int version);

data OptionalVersionedTextDocumentIdentifier // extends TextDocumentIdentifier
    = optional_versioned_text_document_identifier(DocumentUri uri, int version); // version can also be 'null' here, not sure how to do that in Rascal

data TextDocumentPositionParams
    = text_document_position_params(TextDocumentIdentifier textDocument, Position position);

data DocumentFilter
    = document_filter(str language, str scheme, str pattern);

alias DocumentSelector = list[DocumentFilter]; // Not sure whether to use alias here or construct some ADT for it

data StaticRegistrationOptions
    = static_registration_options(str id);

data TextDocumentRegistrationOptions
    = text_document_registration_options(DocumentSelector documentSelector); // should be nullable

data MarkupKind
    = plain_text(str plain_text = "plain_text")
    | markdown(str markdown = "markdown");

data MarkupContent
    = markup_content(MarkupKind kind, str \value);

data MarkdownClientCapabilities
    = markdown_client_capabilities(str parser, str version);

data WorkDoneProgressBegin
    = work_done_progress_begin(str title, bool cancellable, str message, int percentage, str kind = "begin");
data WorkDoneProgressReport
    = work_done_progress_report(bool cancellable, str message, int percentage, str kind = "report");
data WorkDoneProgressEnd
    = work_done_progress_end(str message, str kind = "end");
data WorkDoneProgressParams
    = work_done_progress_params(ProgressToken workDoneToken);
data WorkDoneProgressOptions
    = work_done_progress_options(bool workDoneProgress);

data partialResultParams
    = partial_result_params(ProgressToken partialResultToken);

// alias TraceValue = "off" | "messages" | "verbose"; // Not sure how to capture this in Rascal
data TraceValue
    = off()
    | messages()
    | verbose()
    ;

data CreateFileOptions
    = create_file_options(bool overwrite, bool ignoreIfExists);

data CreateFile
    = create_file(DocumentUri uri, CreateFileOptions options, ChangeAnnotationIdentifier annotationId, str kind = "create");

data RenameFileOptions
    = rename_file_options(bool overwrite, bool ignoreIfExists);

data RenameFile
    = rename_file(DocumentUri oldUri, DocumentUri newUri, RenameFileOptions options, ChangeAnnotationIdentifier annotationId, str kind = "rename");

data DeleteFileOptions
    = delete_file_options(bool recursive, bool ignoreIfNotExists);

data DeleteFile
    = delete_file(DocumentUri uri, DeleteFileOptions options, ChangeAnnotationIdentifier annotationId, str kind = "delete");

data DocumentChanges // Capture the idea of the mixed-type list in the spec
    = document_changes(TextDocumentEdit text_document_edit)
    | document_changes(CreateFile create_file)
    | document_changes(RenameFile rename_file)
    | document_changes(DeleteFile delete_file)
    ;
data WorkspaceEdit
    = workspace_edit(map[DocumentUri uri, list[DocumentChanges] changes] documentChanges, map[ChangeAnnotationIdentifier id, ChangeAnnotation change_annotation] changeAnnotations);


data WorkspaceEditClientCapabilities
    = workspace_edit_client_capabilities(bool documentChanges, list[ResourceOperationKind] resourceOperations, FailureHandlingKind failureHandling, bool normalizesLineEndings, map[str, bool] changeAnnotationSupport);

data ResourceOperationKind
    = create()
    | rename()
    | delete()
    ;

data FailureHandlingKind
    = abort()
    | transactional()
    | undo()
    | textOnlyTransactional()
    ;


data ClientInfo
    = client_info(str name, str version);

data InitializeParams // extends WorkDoneProgressParams
    = initialize_params(
        ProgressToken workDoneToken,
        int processId,
        ClientInfo client_info,
        str locale,
        str rootPath,
        DocumentUri rootUri,
        value initializeOptions,
        ClientCapabilities capabilities,
        TraceValue trace,
        list[WorkspaceFolder] workspaceFolder
    );

data TextDocumentClientCapabilities
    = text_document_client_capabilities(
        TextDocumentSyncClientCapabilities synchronization,
        CompletionClientCapabilities completion,
        HoverClientCapabilities hover,
        SignatureHelpClientCapabilities signatureHelp,
        DeclarationClientCapabilities declaration,
        DefinitionClientCapabilities definition,
        typeDefinitionClientCapabilities typeDefinition,
        ImplementationClientCapabilities implementation,
        ReferenceClientCapabilities references,
        DocumentHighlightClientCapabilities documentHighlight,
        DocumentSymbolClientCapabilities documentSymbol,
        CodeActionClientCapabilities codeAction,
        CodeLensClientCapabilities codeLens,
        DocumentLinkClientCapabilities documentLink,
        DocumentColorClientCapabilities colorProvider,
        DocumentFormattingClientCapabilities formatting,
        DocumentRangeFormattingClientCapabilities rangeFormatting,
        DocumentOnTypeFormattingClientCapabilities onTypeFormatting,
        RenameClientCapabilities rename,
        PublishDiagnosticsClientCapabilities publishDiagnostics,
        FoldingRangeClientCapabilities foldingRange,
        SelectionRangeClientCapabilities selectionRange,
        LinkedEditingRangeClientCapabilities linkedEditingRange,
        CallHierarchyClientCapabilities callHierarchy,
        SemanticToksnClientCapabilities semanticTokens,
        MonikerClientCapabilities moniker
    );

data FileOperationsClientCapabilities
    = file_operations_client_capabilities(
        bool dynamicRegistration,
        bool didCreate,
        bool willCreate,
        bool didRename,
        bool willRename,
        bool didDelete,
        bool willDelete
    );

data WorkspaceClientCapabilities
    = workspace_client_capabilities(
        bool applyEdit,
        WorkspaceEditClientCapabilities workspaceEdit,
        DidChangeConfigurationClientCapabilities didChangeConfiguration,
        DidChangeWatchedFilesClientCapabilities didChangeWatchedFiles,
        WorkspaceSymbolClientCapabilities symbol,
        ExecuteCommandClientCapabilities executeCommand,
        bool workspaceFolders,
        bool configuration,
        SemanticTokensWorkspaceClientCapabilities semanticTokens,
        CodeLensWorkspaceClientCapabilities codeLens,
        FileOperationsCapabilities fileOperations
    );

data WindowClientCapabilities
    = window_client_capabilities(
        bool workDoneProgress,
        ShowMessageRequestClientCapabilities showMessage,
        ShowDocumentClientCapabilities showDocument
    );


data GeneralClientCapabilities
    = general_client_capabilities(
        RegularExpressionsClientCapabilities regularExpressions,
        MarkdownClientCapabilities markdown
    );

data ClientCapabilities
    = client_capabilities(
        WorkspaceClientCapabilities workspace,
        TextDocumentClientCapabilities textDocument,
        WindowClientCapabilities window,
        GeneralClientCapabilities general,
        value experimental
    );

data ServerInfo
    = server_info(
        str name,
        str version
    );

data InitializeResult
    = initialize_result(
        ServerCapabilities capabilities,
        ServerInfo serverInfo
    );

// Missing InitializeError::unknowProtocolVersion

data InitializeError
    = initialize_error(
        bool retry
    );

// giving up ....
