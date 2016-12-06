module Transformations

import lang::c99::\syntax::C;
import IO;
import ParseTree;

/* Simple C example */
TranslationUnit transformNaiveIfStatement(TranslationUnit unit) = visit(unit) {
       case (Statement) `if (<Expression cond>) { return 1; } else { return 0; }` =>  (Statement) `return <Expression cond>;`
       case (Statement) `if (<Expression cond>)  return 1;  else return 0;` =>  (Statement) `return <Expression cond>;`   
};


/* Small hack to cope with the #start[TranslationUnit] in the parse call */
TranslationUnit parse2(stmt)  {
  	visit(stmt) {
    	case (TranslationUnit)`<TranslationUnit unit>` : return unit;
  	};	
}

/* Run the transformations */
TranslationUnit runTests(){
	code1 = parse(#start[TranslationUnit], |project://rascal-C/c-source/teste1.c|);
	code2 = parse2(code1);
	return transformNaiveIfStatement(code2);

}
