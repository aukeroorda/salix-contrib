module salix::corel::Demo


// Use same definitions as used in the LanguageServer module
// import util::LanguageServer;

import corel::AST;
import corel::Syntax;
import corel::CST2AST;

import ParseTree;

import salix::corel::LspWebEditor;
import salix::HTML;
import salix::Core;
import salix::App;
import salix::Index;

import String;
import IO; // Required for server to output to terminal, otherwise silently fails
import List;
import lang::json::IO;

extend lang::std::Layout;
syntax ListOfStrs
    = '[' {WORD ','}* strs ']';

syntax WORD
    = '\"' (![\"] | '\\\"')* '\"';

/* The model includes the state of the online web-editor, and for instance the most recent valid AST to be able to render this next to the editor.
 */
alias Model = tuple[ARecipe last_valid_ast, str src];
str small_recipe = "# Kip cashew met noodles\n## Ingredients:\n- [200 grams] {noedels}\n- [300 grams] {kip}\n## Instructions:\n- Kook de @noedels@.\n- Bak de @kip@.";

Model init() = <cst2ast(parse(#start[Recipe], small_recipe)), small_recipe>;

SalixApp[Model] recipeApp(str id = "recipeDemo") = makeApp(id, init, withIndex("Recipe", id, shopDemoView, css = ["/src/web-app/test.css"]), update);

App[Model] recipeWebApp()
    = webApp(
        recipeApp(),
        |lib://corel-language/|
    );

// Enumerate LSP actions here
data Msg
    = addIngredient(str ingredient)
    | removeIngredients()
    | editorChange(map[str,value] delta)
    ;




Model update(Msg msg, Model m) {
    // println("<msg.delta>");
    // println("hallo");
    
    switch(msg) {
        case addIngredient(str ingredient):
            m.last_valid_ast.ingredients.ingredients += [cst2ast(parse(#Ingredient, ingredient))];
        case removeIngredients():
            m.last_valid_ast.ingredients.ingredients = [];
        case editorChange(map[str,value] delta):
            {
                // m.src += "\nayyyy";
                // println("editor change, but not applying change to local model representation!!!!!");
                // println("<m.src>");
                // println(delta);
                // println(delta["payload"]);
                ListOfStrs l = parse(#ListOfStrs, "<delta["payload"]>");
                list[str] lines = [];
                for (/WORD w := l) {
                    lines += ["<w>"[1..-1]];
                }
                println(delta["payload"]);
                println("<l.strs[0]>");
                println("ok");
                println("<lines>");
                println(intercalate("\n", lines));
                m.src = intercalate("\n", lines);
                // list[str] lines = toJSON(#list[str], delta["payload"]);
                // println(lines);
                // do(aceSetText("myAce", textUpdated(), m.code));
                try
                {
                    ARecipe new_ast = cst2ast(parse(#Recipe, m.src));
                    m.last_valid_ast = new_ast;
                }
                catch:
                    ;
            }
    }

    return m;
}

void shopDemoView(Model m) {
  div(() {
    div(id("header"), () {
      h1("Corel Recipe demo");
    });
    ace("myAce", event=onAceChange(editorChange), code = m.src);
    viewIngredients(m.last_valid_ast.ingredients);
    // viewInstructions();
    viewRawSrc(m.src);
  });
}

void viewIngredients(AIngredients ingredients) {
    div((){
        h2(ingredients.ingredients_header);
        div(id("ingredient_list"));
        ol(() {
                for (int i <- [0..size(ingredients.ingredients)]) {
                    viewIngredient(ingredients.ingredients[i]);
                }
            }
        );
        div("Ingredients list size:", size(ingredients.ingredients));
        button(onClick(addIngredient("- fakeingredient")), "Add ingredient");
        button(onClick(removeIngredients()), "Remove ingredients");
    });
}

void viewIngredient(AIngredient ingredient) {
    li("<ingredient.words>");
}

void viewInstructions() {
    div();
}

void viewRawSrc(str src) {
    pre("<src>");
}

