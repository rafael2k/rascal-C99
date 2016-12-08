/*

Author: Rafael Diniz
Professor: Rodrigo Bonifácio de Almeida

Some transformations based in Coccinelle semantic patch present in the article:
 
Rodriguez, Luis R., and Julia Lawall. "Increasing Automation in the 
Backporting of Linux Drivers Using Coccinelle." Dependable Computing 
Conference (EDCC), 2015 Eleventh European. IEEE, 2015.

*/

module Transformations

import lang::c99::\syntax::C;
import IO;
import ParseTree;
// import vis::Figure;
// import vis::ParseTree;
// import vis::Render;

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

/* Cocinnelle semantic patch 3

Here the code match in the first part is used to identifier we are
in the correct file, and the second part make 2 lines insertion before
one other line present in the file.

@ simple_dev_pm depends on module_pci @
identifier pdev, hw, sc;
declarer name pci_dev;
declarer name ieee80211;
declarer name ath_softc;
@@
+compat_pci_suspend(pci_suspend);
+compat_pci_resume(pci_resume);
ath9k_stop_btcoex(sc);

*/

bool cocci_check_ids(TranslationUnit unit){
	bool pdev = false, hw = false, sc = false, pci_dev = false,
	 ieee80211_hw = false, ath_softc = false;

	top-down visit(unit) {
		case (Identifier) `pdev` : {
			// println("pdev");
			pdev = true;
		}
		case (Identifier) `hw` : {
			// println("hw");
			hw = true;
		}
		case (Identifier) `sc` : {
			// println("sc");
			sc = true;	
		}
		case (Identifier) `pci_dev` : {
			// println("pci_dev");
			pci_dev = true;	
		}
		case (Identifier) `ieee80211_hw` : {
			// println("ieee80211_hw");
			ieee80211_hw = true;	
		}
		case (Identifier) `ath_softc` : {
			// println("ath_softc");
			ath_softc = true;	
		}
	}
	
	return (pdev && hw && sc && pci_dev && ieee80211_hw && ath_softc);

}

TranslationUnit make_addition(TranslationUnit unit) = visit (unit) {
	  case (Statement) `ath9k_stop_btcoex(sc);` => (Statement) `ath9k_stop_btcoex(sc);` // (Statement) `compat_pci_suspend(pci_suspend);` (Statement) `compat_pci_resume(pci_resume);`
};

TranslationUnit conccinelle3(TranslationUnit unit) {

	/* First we check if there is the match of of the identifiers */
	if (cocci_check_ids(unit) == false){
		return unit;
	}

	/* Make the code addition */
	code = make_addition(unit);
	return code;

}

TranslationUnit sometests(TranslationUnit unit) {

	top-down visit(unit) {
		case (Statement) `ath9k_stop_btcoex(sc);` : {
			println("AAALLOOOUU");
		}
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
		code = parseaux(|file:///home/rafael2k/files/UnB/static_analysis/trabalho_final/rascal-C99/c-source/teste1.c|);
		return transformNaiveIfStatement(code);
	}

	// coccinelle first example
	if (option == 2){
		code = parseaux(|file:///home/rafael2k/files/UnB/static_analysis/trabalho_final/rascal-C99/c-source/teste2.c|);
		return conccinelle1(code);
	}

	// C99 bool feature
	if (option == 3){
		code = parseaux(|file:///home/rafael2k/files/UnB/static_analysis/trabalho_final/rascal-C99/c-source/teste3.c|);
		return code;
	}
	
	// netdev backport coccinelle
	if (option == 4){
		code = parseaux(|file:///home/rafael2k/files/UnB/static_analysis/trabalho_final/rascal-C99/c-source/teste4.c|);
		return conccinelle2(code);
	}
	
	// other coccinelle example
	if (option == 5){
		code = parseaux(|file:///home/rafael2k/files/UnB/static_analysis/trabalho_final/rascal-C99/c-source/pci.c|);
		return conccinelle3(code);
	}
	
	// C99 for (int i = 0; i < n; ++i) { ... } construct (with the type modifier
	// inside the for.
	if (option == 6){
		code = parseaux(|file:///home/rafael2k/files/UnB/static_analysis/trabalho_final/rascal-C99/c-source/teste5.c|);
		return (code);
	}

	// for visualization purposes...
    // render(visParsetree(code));
}
