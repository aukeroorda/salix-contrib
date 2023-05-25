module salix::corel::RecipeView

import corel::AST;
import corel::Syntax;
import corel::CST2AST;

import salix::HTML;
import salix::Node; // So we can construct a style node ourselves

// import salix::ace::Editor; // Move to using the un-modified ACE editor when we can properly parse the payload nodes (named fields are not working)
import salix::corel::LspWebEditor;
import salix::Core;
import salix::App;
import salix::Index;

import salix::corel::Model;

import ParseTree;

import String;
import IO; // Required for server to output to terminal, otherwise silently fails
import List;
import lang::json::IO;

// Function modelled after https://github.com/usethesource/salix-core/blob/a4764a4c8447698a2cf0cdc8a5612e90b383c0d0/src/main/rascal/salix/Index.rsc#L9
// This function can additionally take a block to insert into the header
public void(&T) recipeDemoIndexReplacement(str myTitle, str myId, void(&T) header ,void(&T) body) {
    return void(&T model) {
        recipeDemoIndex(
            myTitle,
            myId,
            () { header(model); }, // header
            () { body(model); } // body
        );
    };
}

void recipeDemoIndex(str myTitle, str myId, void() modelHeader, void() modelBody, list[str] css = [], list[str] scripts = []) {
    html(() {
        head(
            (){
            title_(myTitle);

            for (str c <- css) {
                link(\rel("stylesheet"), href(c));
            }

            for (str s <- scripts + ["/salix/salix.js"]) {
                script(\type("text/javascript"), src(s));
            }

            script("document.addEventListener(\"DOMContentLoaded\", function() {
                    '  window.$salix = new Salix(\"<myId>\");
                    '  $salix.start();
                    '});");

            modelHeader(); // Main change, can now provide a modelHeader to include scripts or css
            }
        );

        body(modelBody);
    });
}

void recipeDemoHeader(Model m) {
    script("console.log(\"Added recipeDemoHeader\");");
    recipeStyle();
}


void recipeDemoBody(Model m) {
  div(() {
    div(id("header"), () {
      h1("Corel Recipe demo");
      h2("m.last_source_parsed? <m.last_source_parsed>");
      h2("m.last_source_to_ast? <m.last_source_to_ast>");
      h2("m.last_source_outlined? <m.last_source_outlined>");
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


void recipeStyle() {
    style_(readFile(|project://salix-contrib/src/main/rascal/salix/corel/style.css|));
}