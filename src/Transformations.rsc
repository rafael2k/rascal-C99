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

/* Coccinelle semantic patch 2

@@
 struct net_device *dev;
 struct net_device_ops ops;
@@
- dev->netdev_ops = &ops;
+ netdev_attach_ops(dev, &ops);

*/

TranslationUnit conccinelle2(TranslationUnit unit) {
	code1 = conccinelle2_1(unit);
	return conccinelle2_2(code1);
}


TranslationUnit conccinelle2_1(TranslationUnit unit) = visit(unit) {
	  case (Statement) `<Identifier id1>-\>netdev_ops = &<Identifier id2>;` => (Statement) `netdev_attach_ops (&<Identifier id2>);`
};

TranslationUnit conccinelle2_2(TranslationUnit unit) = visit(unit) {
	 case (Expression) `netdev_attach_ops (<NonCommaExpression id1>)` => (Expression) `netdev_attach_ops (dev, <NonCommaExpression id1>)`
};

TranslationUnit conccinelle3(TranslationUnit unit) {

	top-down visit(unit) {
    	case (Expression)`<Expression exp1>` : { 
         println("Expr1 <exp1>"); 
		}
    	case (Expression)`<Expression id1> = <Expression id2>` : { 
         println("Expr11 <id1> Expr22 <id2>"); 
		}
		case (Identifier) `<Identifier id>` : {
		  println("Identifier <id>");
		}
		case (NonCommaExpression) `<NonCommaExpression id>` : {
		  println("NonCommaExpression <id>");
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

TranslationUnit parseaux(loc path){
	code1 = parse(#start[TranslationUnit], path, allowAmbiguity=true);
	return parse2(code1);
}

/* Run the transformations */
TranslationUnit runTests(int option){

	// C if sample 
	if (option == 1){
		code = parseaux(|project://rascal-C/c-source/teste1.c|);
		return transformNaiveIfStatement(code);
	}

	// coccinelle first example
	if (option == 2){
		code = parseaux(|project://rascal-C/c-source/teste2.c|);
		return conccinelle1(code);
	}

	// C99 bool feature
	if (option == 3){
		code = parseaux(|project://rascal-C/c-source/teste3.c|);
		return code;
	}
	
	// netdev backport coccinelle
	if (option == 4){
		code = parseaux(|project://rascal-C/c-source/teste4.c|);
		return conccinelle2(code);
	}
	

	// for visualization purposes...
    // render(visParsetree(code));
}
