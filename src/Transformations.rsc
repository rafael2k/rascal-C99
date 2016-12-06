module Transformations

import lang::c99::\syntax::C;
import IO;
import ParseTree;
import vis::Figure;
import vis::ParseTree;
import vis::Render;

/* Simple C example based on the Java one */
TranslationUnit transformNaiveIfStatement(TranslationUnit unit) = visit(unit) {
       case (Statement) `if (<Expression cond>) { return 1; } else { return 0; }` =>  (Statement) `return <Expression cond>;`
       case (Statement) `if (<Expression cond>)  return 1;  else return 0;` =>  (Statement) `return <Expression cond>;`   
};

/* Coccinelle semantic patch 1

@@ 
expression arg;
@@
- one(arg);
+ two(arg, NULL);

*/
TranslationUnit conccinelle1(TranslationUnit unit) = visit(unit) {
	case (Expression) `one (<NonCommaExpression id1>)` => (Expression) `two (<NonCommaExpression id1>, NULL)` 
};

/* TODO */
TranslationUnit conccinelle2(TranslationUnit unit) {

	top-down visit(unit) {
    	case (Expression)`<Identifier id1>` : { 
         println("Expr1 <id1>"); 
		}
	}

	return unit;
}


/* Small hack to cope with the #start[TranslationUnit] in the parse call */
TranslationUnit parse2(stmt)  {
  	visit(stmt) {
    	case (TranslationUnit)`<TranslationUnit unit>` : return unit;
  	};	
}

/* Run the transformations */
TranslationUnit runTests(){
	code1 = parse(#start[TranslationUnit], |project://rascal-C/c-source/teste2.c|, allowAmbiguity=true);
	code2 = parse2(code1);
	//return transformNaiveIfStatement(code2);

	//render(visParsetree(code2));

	return conccinelle1(code2);

}
