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
    ace("recipeDemo", event=onAceChange(editorChange), code = m.src);
    button(onClick(testMessage()), "test Message");
    // viewIngredients(m.last_valid_ast.ingredients);
    // viewInstructions();
    viewRawSrc(m.src);
    recipeRenderView(m.last_valid_ast);
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

void recipeRenderFrame(Model m) {
    iframe(recipeRenderView());
}

void recipeRenderView(ARecipe r) {
    div(() {
        header(() {
            h1(r.synopsis.name);
        });
        hr();
        h2(r.ingredients.ingredients_header);
        ol(() {
                for (/AIngredient ing := r.ingredients.ingredients) {
                    li(() {recipeRenderIngredient(ing);});
                }
            }
        );
        h2(r.instructions.instructions_header);
        ol((){
            for (/AInstruction ins := r.instructions.instructions) {
                li(() {recipeRenderInstruction(ins);});
            }
        });
        script(readFile(|project://salix-contrib/src/main/rascal/salix/corel/script.js|)); // Included last, to ensure it is ran after dom is complete
    });
}

void recipeRenderIngredient(AIngredient ing) {
    for (/AWord w := ing.words) {
        renderRecipeWord(w);
    }
}

void recipeRenderInstruction(AInstruction ins) {
    for (/AWord w := ins.words) {
        renderRecipeWord(w);
    }
}

void renderRecipeWord(AWord w) {
    if (w is quantity) {
        renderRecipeQuantity(w.quantity);
    }
    if (w is ingredient_def) {
        renderRecipeIngredientDef(w.ingredient_def);
    }
    if (w is ingredient_ref) {
        renderRecipeIngredientRef(w.ingredient_ref);
    }
    if (w is time) {
        renderRecipeTime(w.time);
    }
    if (w is temperature) {
        renderRecipeTemperature(w.temperature);
    }
    if (w is description_text) {
        renderRecipeDescriptionText(w.description_text);
    }
}

void renderRecipeQuantity(AQuantity q) {
    if (q is quantity_exact) {
        span(
            recipeNumberOrRangeToString(q.val) +
            " " +
            "<q.unit.unit>"
        );
    }
    if (q is quantity_count) {
        span(
            recipeNumberOrRangeToString(q.val) +
            " "
        );
    }
    if (q is quantity_unit) {
        span(
            "<q.unit.unit>" +
            " "
        );
    }
    if (q is quantity_empty) {
        ;
    }
}

str recipeNumberOrRangeToString(ANumberOrRange n) {
    if (n is number) {
        return recipeExactValueToString(n.val);
    }
    if (n is range) {
        return 
            recipeExactValueToString(n.lower) +
            " - " +
            recipeExactValueToString(n.upper)
        ;
    }
}

str recipeExactValueToString(AExactValue e) {
    if (e is sole_integral) {
        return "<e.nat>";
    }
    if (e is mixed) {
        return "<e.nat>" + recipeFractionToString(e.frac);
    }
    if (e is sole_fraction) {
        return recipeFractionToString(e.frac);
    }
}

str recipeFractionToString(AFraction f) {
    return toString(sup(f.numerator)) + "&frasl;" + toString(sub(f.denominator));
}

void renderRecipeIngredientDef(AIngredientDef def) {
    span(
        class("ingredient_def"),
        attr("tabindex", "0"),
        attr("data-ingredient-def", "<def.name>"),
        "<def.name>"
    );
}

void renderRecipeIngredientRef(AIngredientRef ref) {
    span(
        class("ingredient_ref"),
        attr("tabindex", "0"),
        attr("data-ingredient-ref", "<ref.name>"),
        "<ref.name>"
    );
}

void renderRecipeTime(ATime t) {
	int seconds = convert_to_seconds(t);
	str original_time_text = recipeNumberOrRangeToString(t.val);

	span(
		span(original_time_text, 
			 class("time_value"),
			 html5attr("data-original-text", original_time_text)),
		class("timer"),
		html5attr("tabindex", 0),
		html5attr("data-original-time", seconds),
		html5attr("data-current-time", seconds),
		" <t.unit.unit>"
	);
}

/* Frink functionality is not available, so therefore cannot convert times to seconds
 */
int convert_to_seconds(ATime t)
{
	// str frink_result = frink_parse("<frink_print(t.val)> <t.unit> -\> seconds");
	// // If it is a range, take the center value
	// real quantity;
	
	// if (t.val is range)
	// {
	// 	// Take the center of the range as quantity value
	// 	str stripped = replaceAll(replaceAll(frink_result, "[", ""), "]", "");
	// 	list[str] values = split(", ", stripped);
	// 	quantity = (toReal(values[0]) + toReal(values[1]))/2;
	// }
	// else
	// {
	// 	quantity = toReal(frink_result);
	// }
	
	// return toInt(quantity);

    return 20;
}

void renderRecipeTemperature(ATemperature t) {
    // From previous implementation
    // if (t.src in msgdocs.docs) {
	// 	abbr(
	// 		"<numberorrange2str(t.val)> <t.unit>",
	// 		html5attr("title", msgdocs.docs[t.src]),
	// 		html5attr("tabindex", 0),
	// 		class("temperature")
	// 		);
	// } else {
        // span(
        //     "<recipeNumberOrRangeToString(t.val)> <t.unit>",
        //     class("temperature")
        //     );
    // }

    if (t is temperature_exact) {
        abbr(
            attr("title", "unset temperature title"),
            attr("tabindex", 0),
            class("temperature"),
            "<recipeNumberOrRangeToString(t.val)> <t.unit>"
        );
    }
    if (t is temperature_count) {
        abbr(
            attr("title", "unset temperature title"),
            attr("tabindex", 0),
            class("temperature"),
            "<recipeNumberOrRangeToString(t.val)>"
        );
    }
    if (t is temperature_unit) {
        abbr(
            attr("title", "unset temperature title"),
            attr("tabindex", 0),
            class("temperature"),
            "<t.unit>"
        );
    }
    if (t is temperature_empty) {
        abbr(
            attr("title", "unset temperature title"),
            attr("tabindex", 0),
            class("temperature"),
            "empty temperature"
        );
    }
}

void renderRecipeDescriptionText(ADescriptionText d) {
    span("<d.text>");
}