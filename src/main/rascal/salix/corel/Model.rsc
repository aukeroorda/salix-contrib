module salix::corel::Model

import corel::AST;

import util::LanguageServer; // For definitions used in language contributions (outliner, summarizer, lenses etc)

/* The model includes the state of the online web-editor, and for instance the most recent valid AST to be able to render this next to the editor.
 */
public alias Model = tuple[
    str src, // An always up-to-date representation of the source code in the web editor
    ARecipe last_valid_ast,
    list[DocumentSymbol] outline,
    bool last_source_parsed,
    bool last_source_to_ast,
    bool last_source_outlined
    ];


// Enumerate LSP actions here
data Msg
    = addIngredient(str ingredient)
    | removeIngredients()
    | editorChange(map[str,value] delta)
    ;
