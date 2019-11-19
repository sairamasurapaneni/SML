grammar ProjLang;
A	:	'if';
TRUE	: 	'true';
FALSE 	:	'false';
THEN	:	'then';
ELSE	:	'else';
WHILE	:	'while';
C	:	'do';
D	:	'od';
EQUALS	:	':='
	;
LHS	:	'('
	;
RHS	:	')'
	;
LET	: 'let';
VAL	: 'val';
IN	:'in';
END	:'end';
FUN 	:'fun'
	;
EQUAL   : '=';
LF	:	'{'
	;
RF	:	'}'
	;
N	:	'!'
	;
RELOP	: 	'<'
	|	'=';
ADDOP	:	'+';
SUBOP	:	'-';
OR    : 	'|';
MULOP	: 	'*';
DIVOP	:	'/';
AND	:	'&';
SEMI	:	';';
ID  :	('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
    ;
NUM :	'0'..'9'+
    ;
WS  :   ( ' '
        | '\t'
        | '\r'
        | '\n'
        ) {$channel=HIDDEN;}
    ;
input returns [Expr v] : e=expr {$v =$e.v;}EOF;
expr returns [Expr v]:	A e1=expr THEN e2=expr ELSE e3=expr {$v=new IfExp ($e1.v,$e2.v,$e3.v);}
	|	LET VAL ID EQUAL f1=expr IN f2=expr END {$v=new LetValExp($ID.text,$f1.v,$f2.v);}
	|	WHILE h1=expr C h2=expr {$v=new WhileExp($h1.v,$h2.v);}
	|	LF i1=expr {$v=$i1.v;} (SEMI i2=expr{$v=new SeqExp($v,$i2.v);})* RF
	|	N j1=expr{$v=new NotExp($j1.v);}
	|	ID EQUALS k1=expr{$v=new AssnExp($ID.text,$k1.v);}
	|	l1=relexpr{$v=$l1.v;}
	;
relexpr returns [Expr v] : m1=arithexpr {$v=$m1.v;}  (x=(RELOP | EQUAL) m3 = arithexpr{ $v=new BinExp($v,BinOp.EQ,$m3.v);})?
	;

arithexpr returns [Expr v] :n1=term {$v=$n1.v;} (x=ADDOP n2=term { $v=new BinExp($v,BinOp.PLUS,$n2.v);}
	|SUBOP  n3=term{ $v=new BinExp($v,BinOp.DIFF,$n3.v);}
	|OR  n4=term{ $v=new BinExp($v,BinOp.OR,$n4.v);})*;
	

term returns [Expr v]	:o1=factor {$v=$o1.v;}  (x=MULOP o2 = factor{ $v=new BinExp($v,BinOp.TIMES,$o2.v);}
	|DIVOP  o3=factor{ $v=new BinExp($v,BinOp.DIV,$o3.v);}
	|AND  o4=factor{ $v=new BinExp($v,BinOp.AND,$o4.v);})*;

factor returns [Expr v]	: NUM {$v = new IntConst(Integer.parseInt($NUM.text));}
	| TRUE {$v=new BoolConst(Boolean.parseBoolean("true"));}
        | FALSE {$v=new BoolConst(Boolean.parseBoolean("false"));}
	| ID {$v=new VarExp($ID.text);}
	;


