%{
	#include "y.tab.h"
	#include "string.h"

	int colNo = 1;
	int lineNo = 1;
	
%}

%%
":="		{ colNo++; return TOK_ASSIGN; }
"+"		{ colNo++; return TOK_ADD; }
"-"		{ colNo++; return TOK_SUB; }
"*"		{ colNo++; return TOK_MUL; }
"/"		{ colNo++; return TOK_DIV; }
"("		{ colNo++; return TOK_LEFT; }
")"		{ colNo++; return TOK_RIGHT; }
"PROGRAM" 	{ colNo+=7; return TOK_PROGRAM; }
"VAR"		{ colNo+=3; return TOK_VAR; }
"BEGIN"		{ colNo+=5; return TOK_BEG; }
"END"		{ colNo+=3; return TOK_END; }
"INTEGER"	{ colNo+=7; return TOK_INTEGER; }
"READ"		{ colNo+=4; return TOK_READ; }
"WRITE"		{ colNo+=5; return TOK_WRITE; }
"FOR"		{ colNo+=3; return TOK_FOR; }
"DO"		{ colNo+=2; return TOK_DO; }
"TO"		{ colNo+=2; return TOK_TO; }
"."		{ colNo++; return '.';}
","		{ colNo++; return ','; }
";"		{ colNo++; return ';'; }
":"		{ colNo++; return ':'; }
[1-9][0-9]*|0	{ yylloc.first_line=lineNo; yylloc.first_column = colNo; colNo+=strlen(yytext); yylval.val = atoi(yytext); return TOK_INT; }
[A-Za-z][A-Za-z0-9]*	{ yylloc.first_line=lineNo; yylloc.first_column = colNo; colNo+=strlen(yytext); yylval.sir = new char[strlen(yytext)+1]; strcpy(yylval.sir, yytext); return TOK_ID; }
\n		{ lineNo++; colNo=1; }
[ ]		{ colNo++; }
.		{ throw yytext; }
\r\n		{ lineNo++; colNo=1; }
%%
