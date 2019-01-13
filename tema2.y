%{
	#include <stdio.h>
        #include <string.h>
	#define ABORT return(1)
	#define ACCEPT return(0)

	int yylex();
	int yyerror(const char *mesaj);
	int init = 0;
	int Correct = 1;	
	char mesaj[500];

	class TVAR
	{
	  public:
	     char* nume;
	     int valoare;
	     TVAR* next;
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n);
             void add(char* n, int v = -1);
             int getValue(char* n);
	     void setValue(char* n, int v);
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, int v)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
	 this->next = NULL;
	}

	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	}

	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }

         void TVAR::add(char* n, int v)
	 {
	   TVAR* elem = new TVAR(n, v);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }

         int TVAR::getValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->valoare;
	     tmp = tmp->next;
	   }
	   return -1;
	  }

	  void TVAR::setValue(char* n, int v)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		tmp->valoare = v;
	      }
	      tmp = tmp->next;
	    }
	  }

	TVAR* ts = NULL;
%}

%union  { 
	   char* sir;
	   int val;
	}

%token 	TOK_ASSIGN TOK_ADD TOK_SUB TOK_MUL TOK_DIV TOK_LEFT TOK_RIGHT
%token TOK_PROGRAM TOK_VAR TOK_BEG TOK_END TOK_INTEGER TOK_READ TOK_WRITE TOK_FOR TOK_DO TOK_TO

%token <sir> TOK_ID
%token <val> TOK_INT

%locations

%start prog

%left TOK_ADD TOK_SUB
%left TOK_MUL TOK_DIV

%%

prog : 
	|
	TOK_PROGRAM prog_name TOK_VAR dec_list TOK_BEG stmt_list TOK_END'.'
	|
	error ';' prog
	{ Correct = 0; }
	;
prog_name: TOK_ID
	   ;
	
dec_list:  dec
	   |
	   dec_list';' dec
	   ;

dec:	   id_list':' type
	   ;

type:	   TOK_INTEGER
	   ;

id_list:   TOK_ID
	{
	  if(ts != NULL)
	  {
	   if(ts->exists($1) == 0)
	   {
	    ts->add($1);
	   }
	   else
	   {
	     sprintf(mesaj,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!", @1.first_line, @1.first_column, $1);
	     yyerror(mesaj);
	     YYERROR;
	   }
	}
	else
	{
	  ts = new TVAR();
	  ts->add($1);
	}
      }
	   |
	   id_list',' TOK_ID
	{
	  if(ts != NULL)
	  {
	   if(ts->exists($3) == 1)
	   {
	     ts->setValue($3, init);
	   }
	   else
	   {
	     sprintf(mesaj,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $3);
	     yyerror(mesaj);
	     YYERROR;
	   }
	 }
	 else
	 {
	  sprintf(mesaj,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $3);
	  yyerror(mesaj);
	  YYERROR;
	 }
       } 
	   ;	

stmt_list: stmt
	   |  
	   stmt_list';' stmt
	   ;

stmt:	   assign
	   |
	   read
	   |
	   write
	   |
  	   for
	   ;

assign:    TOK_ID TOK_ASSIGN exp
	{
	 if(ts != NULL)
	 {
	   if(ts->exists($1) == 1)
	   {
	     ts->setValue($1, init);
	   }
	   else
	   {
	     sprintf(mesaj,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	     yyerror(mesaj);
	     YYERROR;
	   }
	 }
	 else
	 {
	  sprintf(mesaj,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  yyerror(mesaj);
	  YYERROR;
	 }
       } 
	   ;

exp:	   term
	   |
	   exp TOK_ADD term
	   |
	   exp TOK_SUB term
	   ;

term:	   factor
	   |
	   term TOK_MUL factor
	   |
	   term TOK_DIV factor
	   ;

factor:	   TOK_ID
	{
	 if(ts != NULL)
	 {
	   if(ts->exists($1) == 1)
	   {
	     if(ts->getValue($1) == -1)
	     {
	       sprintf(mesaj,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost initializata!", @1.first_line, @1.first_column, $1);
	       yyerror(mesaj);
	       YYERROR;
	     }
	     else
	     {
	       printf("%d\n",ts->getValue($1));
	     }
	   }
	   else
	   {
	     sprintf(mesaj,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	     yyerror(mesaj);
	     YYERROR;
	   }
	 }
	 else
	 {
	   sprintf(mesaj,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	   yyerror(mesaj);
	   YYERROR;
	 }
       }
	   |
	   TOK_INT
	   |
	   TOK_LEFT exp TOK_RIGHT
	   ;

read:	   TOK_READ TOK_LEFT id_list TOK_RIGHT
	   ;

write:	   TOK_WRITE TOK_LEFT id_list TOK_RIGHT
	   ;

for:	   TOK_FOR index_exp TOK_DO body
	   ;

index_exp: TOK_ID TOK_ASSIGN exp TOK_TO exp
	   ;

body:	   stmt
	   |
	   TOK_BEG stmt_list TOK_END
	   ;
%%
int main()
{
     try
     {
 	yyparse();
     }
     catch(char *e)
     {
       printf("Eroare lexicala:   Atomul lexical %s nu face parte din alfabetul limbajului definit de gramatica ta!\n",e);
	ABORT;
     }

     if(Correct == 1)
     {
	printf("Rezultat:   Propozitia analizata este CORECTA.\n");
     }
	
     ACCEPT;
}

int yyerror(const char *mesaj)
{
	printf("Aveti o EROARE: %s\n", mesaj);
	ABORT;
}
