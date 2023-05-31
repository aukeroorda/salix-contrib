module salix::corel::Demo


// Use same definitions as used in the LanguageServer module
// import util::LanguageServer;

import corel::AST;
import corel::Syntax;
import corel::CST2AST;
import corel::CorelLanguageServer;

import salix::corel::Model;
import salix::corel::RecipeView;
import salix::corel::LspWebEditor; // For lspTest command? Maybe the command should be moved to a different module

import ParseTree;

import salix::Core;
import salix::App;
import salix::Index;

import String;
import IO; // Required for server to output to terminal, otherwise silently fails
import List;
import Type;
import lang::json::IO;
import lang::json::ast::JSON;




str small_recipe = "# Kip cashew met noodles\n## Ingredients:\n- [200 grams] {noedels}\n- [300 grams] {kip}\n## Instructions:\n- Kook de @noedels@.\n- Bak de @kip@.";

Model init() = <
    small_recipe,
    cst2ast(parse(#start[Recipe], small_recipe)),
    [],
    false,
    false,
    false
>;

SalixApp[Model] recipeApp(str id = "recipeDemo")
    = makeApp(
        id,
        init,
        // This path specification becomes prefixed with |lib://salix-core/...| which results in incorrect paths, so instead
        // provide our own html file.
        // withIndex("Recipe 3", id, recipeDemoView, css = ["/salix/corel/style.css"]),
        // withIndex("Recipe 3", id, recipeDemoView, css = ["/salix/demo/shop/test.css"]),  // This path refers to a css file in the salix-core library
        recipeDemoIndexReplacement("Recipe", id, recipeDemoHeader, recipeDemoBody),
        update
    );

App[Model] recipeWebApp()
    = webApp(
        recipeApp(),
        // |project://salix-contrib/|
        // |project://salix-contrib/src/main/rascal/salix/corel/index.html|,
        |project://salix-contrib/src/main/rascal|
    );





Model update(Msg msg, Model m) {
    // println("<msg.delta>");
    // println("hallo");
    
    switch(msg) {
        case addIngredient(str ingredient):
            m.last_valid_ast.ingredients.ingredients += [cst2ast(parse(#Ingredient, ingredient))];
        case removeIngredients():
            m.last_valid_ast.ingredients.ingredients = [];
        case testMessage():
        {
            println("parsing testMessage");
            Cmd ab = lspTest("recipeDemo", receiveMessage("originated from testMessage"), m.code);
            println("part 1 done");
            do(ab);
            println("did command");
        }
        case receiveMessage(str message):
            println("receiveMessage: <message>");
        case editorChange(map[str,value] delta):
            {
                println("delta is:");
                for (key <- delta) {
                    println("<key>, with value: <delta[key]>");
                }
                println("payload: <delta["payload"]>");
                // rprint("<delta["payload"]>");
                println("fromJSON starting 29");
                println("<typeOf(delta["payload"])>");
                // b = delta["payload"];
                // println("Now as b:");
                // println(b);
                // println(typeOf(b));
                // println("<b[0]>");
                // println("<b["start"]>");
                // println("<b.\start>");
                // println(b.action);
                // println(b["action"]);
                // try
                //     // b = parseJSON(#Node, delta["payload"]);
                //     // b = parseJSON(#Object, delta["payload"]);
                //     // b = parseJSON(#JSON, delta["payload"]);
                //     // map[str, value] payload = parseJSON(#map[str,value], req.parameters["payload"]);
                //     // map[str, value] payload;
                //     // b = fromJSON(#JSON, delta["payload"]);
                //     // println("<typeOf(delta["payload"])>");

                //     println(delta["payload"][0]);
                //     // println(delta["payload"]["start"]);
                // catch E:
                //     println(E);
                // println("readJSON passed");
                // println(b);

                // println("testbbbb2");
                // println("obj: <delta["payload"].\start>");
                // println("testaaaaaa2");
                // println("obj: <delta["payload"]["start"]>");
                // println("testaa2");
                // println("obj: <delta["payload"]["object"]>");
                // println("test3");
                // println("aa <fromJSON(#Node, delta["payload"])>");
                // m.src += "\nayyyy";
                // println("editor change, but not applying change to local model representation!!!!!");
                // println("<m.src>");
                // println(delta);
                // println(delta["payload"]);
                // ListOfStrs l = parse(#ListOfStrs, "<delta["payload"]>");
                // list[str] lines = [];
                // for (/WORD w := l) {
                //     lines += ["<w>"[1..-1]];
                // }
                // println(delta["payload"]);
                // println("<l.strs[0]>");
                // println("ok");
                // println("<lines>");
                // println(intercalate("\n", lines));
                println("parsing the liness");
                // list[str] lines = fromJSON(#list[str], delta["payload"]);
                // list[str] unescaped_lines = [];
                // for (str line <- delta["payload"]) {
                    // println("from <line> to <deescape(line)>");
                    // unescaped_lines += [deescape(line)];
                // }
                // m.src = intercalate("\n", unescaped_lines);
                m.src = intercalate("\n", delta["payload"]);
                println("deescaping src");
                m.src = deescape(m.src);
                rprint(m.src);
                println("deescaped src");
                println("parsed lines");
                // println(lines);
                // do(aceSetText("myAce", textUpdated(), m.code));
                try
                {
                    m.last_source_parsed = false;
                    m.last_source_to_ast = false;
                    m.last_source_outlined = false;

                    start[Recipe] cst = parse(#start[Recipe], m.src);
                    m.last_source_parsed = true;

                    ARecipe new_ast = cst2ast(cst);
                    m.last_valid_ast = new_ast;
                    m.last_source_to_ast = true;

                    m.outline = corelOutliner(cst);
                    m.last_source_outlined = true;
                    print(m.outline);
                }
                catch E:
                    print(E);
            }
    }

    return m;
}
