
%{
#define YYSTYPE SymbolInfo*
#include <stdio.h>
#include <stdlib.h>
#include "SymbolTable.h"
#include <typeinfo>


using namespace std;     /* yyparse() stack type */



SymbolTable* table;
int yylex(void);
extern FILE* yyin;
extern int line_count;
extern int error_count;

string var_type="";
ofstream logfile;
ofstream codefile;
ofstream errorfile;
void yyerror(string str)
{
	logfile << "ERROR at Line " << line_count << " : " << str << endl << endl;
	cout << "    ERROR at Line " << line_count << " : " << str << endl << endl << endl;
}
SymbolInfo* dummy;
int yylex(void);
string decl_code="";


SymbolInfo* insertID(SymbolInfo *s)
{
	if(table->LookUp(s->name) != NULL)
	{
		yyerror("Multiple Decalration");
		return NULL;
	}
	else
	{
		s->type=var_type;
		cout<<"inserting from here"<<endl;
		return table->Insert(s);
		
	}
}

SymbolInfo* make_array(SymbolInfo* s1,SymbolInfo* s2)
{

	cout<<"array started to make"<<endl;
	if(table->LookUp(s1->name) != NULL) {yyerror("Multiple Declaration of " + s1->name); error_count++; return dummy;}
	
	
	if(s2->type == "float") {yyerror("Array index must be of 'int' type");error_count++; return dummy;}
	
	int sz = s2->intVal;
	if(sz < 1) {yyerror("Invalid array size"); error_count++; return dummy;}
	s1->type = var_type;
	s1->arr_size = sz;
	SymbolInfo* s = table->insert(s1);
	s->create_array();
	return s;
}

%}

%token CONST_INT CONST_FLOAT CONST_CHAR ID INCOP MULOP ADDOP RELOP LOGICOP ASSIGNOP LPAREN RPAREN RTHIRD LTHIRD LCURL RCURL COMMA SEMICOLON NOT DECOP IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE  STRING PRINTLN 

%error-verbose

%start program;

%%
program : program unit 
	| unit {cout<<"program"<<endl;}
	;
	
unit : var_declaration
     | func_declaration
     | func_definition
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
		 ;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
 		 ;
 		 
parameter_list  : parameter_list COMMA type_specifier ID
		| parameter_list COMMA type_specifier	 
 		| type_specifier ID
 		| type_specifier
 		|
 		;
 		
compound_statement : LCURL statements RCURL
 		    | LCURL RCURL
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
 		 ;
 		 
type_specifier	: INT {logfile << "type_specifier : INT\n\n"; var_type = "int"; $$ = new SymbolInfo("int", "type");cout<<"got it"<<endl;}
 		| FLOAT{logfile << "type_specifier : FLOAT\n\n"; var_type = "float"; $$ = new SymbolInfo("float", "type");}
 		| VOID{;}
 		;
 		
declaration_list : declaration_list COMMA ID {logfile << "declaration_list : declaration_list COMMA ID\n" + $3->name +"\n\n"; $$=insertID($3);}


 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
		 		logfile << "declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n" + $3->name + "\n\n";
				$$ = make_array($3, $5);
		 		}




 		  | ID {
			logfile << "declaration_list : ID\n" + $1->name +"\n\n"; 
			$$ = insertID($1);
		 	}



 		  | ID LTHIRD CONST_INT RTHIRD {
						logfile << "declaration_list : ID LTHIRD CONST_INT RTHIRD\n" +  $1->name +"\n\n";
						$$ = make_array($1, $3);
						}
 		  ;
 		  
statements : statement
	   | statements statement
	   ;
	   
statement : var_declaration
	  | expression_statement
	  | compound_statement
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  | IF LPAREN expression RPAREN statement
	  | IF LPAREN expression RPAREN statement ELSE statement
	  | WHILE LPAREN expression RPAREN statement
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  | RETURN expression SEMICOLON
	  ;
	  
expression_statement 	: SEMICOLON			
			| expression SEMICOLON 
			;
	  
variable : ID 		
	 | ID LTHIRD expression RTHIRD 
	 ;
	 
 expression : logic_expression	
	   | variable ASSIGNOP logic_expression 	
	   ;
			
logic_expression : rel_expression 	
		 | rel_expression LOGICOP rel_expression 	
		 ;
			
rel_expression	: simple_expression 
		| simple_expression RELOP simple_expression	
		;
				
simple_expression : term 
		  | simple_expression ADDOP term 
		  ;
					
term :	unary_expression
     |  term MULOP unary_expression
     ;

unary_expression : ADDOP unary_expression  
		 | NOT unary_expression 
		 | factor 
		 ;
	
factor	: variable 
	| ID LPAREN argument_list RPAREN
	| LPAREN expression RPAREN
	| CONST_INT 
	| CONST_FLOAT
	| CONST_CHAR
	| variable INCOP 
	| variable DECOP
	;
	
argument_list : argument_list COMMA logic_expression
	      | logic_expression
	      |
	      ;
 
%%

int main(int argc, char const* argv[])
{
	logfile.open("log.txt");
	//codefile.open("input.c"); // 8086 code goes in here
	errorfile.open("error.txt");
	
	table = new SymbolTable(31);
	logfile << "\n";
	yyin = fopen(argv[1], "r");
	dummy = new SymbolInfo();
	decl_code = "\n";
	
	cout << "##############################################################################" << endl;
	cout << "##############################################################################" << endl;
	cout<< "Type is "<<typeid(yylval).name()<<" this is "<<endl;
	SymbolInfo* s;
	cout<< "Type is "<<typeid(s).name()<<" this is "<<endl;
	
   	yyparse();
   	
   	logfile << "\t\t symbol table:\n";
 	table->PrintCurrentScopeTable();
 	logfile << endl;
 	logfile << "Total Lines: " << line_count << endl << endl;
 	logfile << "Total Errors: " << error_count << endl << endl;
 	
 	decl_code = decl_code + "\n\n";
 	
 	//total_code = init_code + decl_code + main_code;
 	//total_code = total_code + "\n" + outdec + "\nEND MAIN\n";
 	//codefile << total_code << endl;

	//cout << temp_count << endl;
	//yylval=s;
 	
   	exit(0);
}
