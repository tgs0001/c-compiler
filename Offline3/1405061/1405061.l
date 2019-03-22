%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<iostream>
#include "y.tab.h"
#include "SymbolTable.h"
#include<typeinfo>



using namespace std;
extern YYSTYPE yylval;

extern SymbolTable *table;


void yyerror(char *);

int line_count=1;
int error_count=0;

extern ofstream logfile;
extern ofstream errorfile;

%}



TAB "\'\\t\'"
UNREC '[^A-Za-z0-9'\n]+'
SPACE " "
UN_CHAR (\'{CHAR}|{CHAR}\'|\'\\\')
string \"([^"\\\n]|\\(.|\r?\n))*\"
UN_FIN_STR \"([^"\\\n]|\\(.|\r?\n))*
UN_FIN_COM "/*"([^*]|\*+[^*/])*
COMMENT (\/\/.*)
MULTI_LINE_COMMENT (\/\/.*\\(.|[\r\n]).*)
MULTY_LINE_COMMENT "/*"([^*]|\*+[^*/])*\*+"/"
WHITESPACE [ \t\f\r\v]+ 
CHAR [a-zA-Z]
LETTER \'{CHAR}\'
UN_TER \'
EMP_CHAR \'\'
MULT_CHAR \'[ a-zA-Z]+\'
let [_a-zA-Z]
DIGIT [0-9]
DIGITS {DIGIT}+
FLOAT [0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?
ILL_FORMED {DIGITS}?E[+-]?{FLOAT}
ERROR_FLOAT {FLOAT}+{FLOAT}+
id {let}({let}|{DIGIT})*
ERROR_ID ({DIGIT}|{let})*
NEWLINE \n
%%

[\t\v] {}
{TAB} {	
}

"if"	{
			//fprintf(tokenout,"<IF>");
			//fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s \n",line_count,yytext);
			return IF;
	}
		
"else"	{
			//fprintf(tokenout,"<ELSE>");
			//fprintf(logout,"Line no %d: TOKEN <ELSE> Lexeme %s \n",line_count,yytext);
			return ELSE;
	}
"for"	{
			//fprintf(tokenout,"<FOR>");
			//fprintf(logout,"Line no %d: TOKEN <FOR> Lexeme %s \n",line_count,yytext);
			return FOR;
	}
"while" {
			//fprintf(tokenout,"<WHILE>");
			//fprintf(logout,"Line no %d: TOKEN <WHILE> Lexeme %s \n",line_count,yytext);
			return WHILE;
	}

"do" 	{
			//fprintf(tokenout,"<DO>");
			//fprintf(logout,"Line no %d: TOKEN <DO> Lexeme %s \n",line_count,yytext);
			return DO;
	}
"break" {
			//fprintf(tokenout,"<BREAK>");
			//fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme %s \n",line_count,yytext);
			return BREAK;
	}
"int" {
			//fprintf(tokenout,"<INT>");
			//fprintf(logout,"Line no %d: TOKEN <INT> Lexeme %s  found\n",line_count,yytext);
			cout<<typeid(yylval).name()<<"this is "<<endl;
			return INT;
	}
"char" {
			//fprintf(tokenout,"<CHAR>");
			//fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme %s  \n",line_count,yytext);
			return CHAR;
	}
"float" {
			//fprintf(tokenout,"<FLOAT>");
			//fprintf(logout,"Line no %d: TOKEN <FLOAT> Lexeme %s  \n",line_count,yytext);
			return FLOAT;
	}
"double" {
			//fprintf(tokenout,"<DOUBLE>");
			//fprintf(logout,"Line no %d: TOKEN <DOUBLE> Lexeme %s  \n",line_count,yytext);
			return DOUBLE;
	}
"void" {
			//fprintf(tokenout,"<VOID>");
			//fprintf(logout,"Line no %d: TOKEN <VOID> Lexeme %s  \n",line_count,yytext);
			return VOID;
	}
"return" {
			//fprintf(tokenout,"<RETURN>");
			//fprintf(logout,"Line no %d: TOKEN <RETURN> Lexeme %s  \n",line_count,yytext);
			return RETURN;
	}
"switch" {
			//fprintf(tokenout,"<SWITCH>");
			//fprintf(logout,"Line no %d: TOKEN <SWITCH> Lexeme %s  \n",line_count,yytext);
			return SWITCH;
	}
"case" {
			//fprintf(tokenout,"<CASE>");
			//fprintf(logout,"Line no %d: TOKEN <CASE> Lexeme %s  \n",line_count,yytext);
			return CASE;
	}
"default" {
			//fprintf(tokenout,"<DEFAULT>");
			//fprintf(logout,"Line no %d: TOKEN <DEFAULT> Lexeme %s  \n",line_count,yytext);
			return DEFAULT;
	}
"continue" {
			//fprintf(tokenout,"<CONTINUE>");
			//fprintf(logout,"Line no %d: TOKEN <CONTINUE> Lexeme %s  \n",line_count,yytext);
			return CONTINUE;
	}
"println" {
			return PRINTLN;
}


{id} {
			//fprintf(tokenout,"<ID, %s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <ID> Lexeme %s  \n",line_count,yytext);
			SymbolInfo *s= table->LookUp(yytext);
			if(s==NULL)
			{					
				s= new SymbolInfo(yytext, (char *)"ID");
			}
			yylval =s;
			cout<<"id is called"<<endl;		
			return ID;
				
}


"+"		{
			//fprintf(tokenout,"<ADDOP,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s \n",line_count,yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ADDOP");
			yylval = s;
			return ADDOP;

		}






"-"		{
			//fprintf(tokenout,"<ADDOP,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s \n",line_count,yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ADDOP");
			yylval = s;
			return ADDOP;
			//insert in symbol table and print symbol table content(only non empty buckets)
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
		}


"*"		|
"/"		|
"%"		{	
			//fprintf(tokenout,"<MULOP,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s \n",line_count,yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"MULOP");
			yylval = s;
			return MULOP;	
}

"++"		|
"--"		{
			//fprintf(tokenout,"<INCOP,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s\n",line_count,yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"INCOP");
			yylval = s;	
			return INCOP;
}

"<"		|
"<="		|
">"		|
">="		|
"=="		|
"!="		{
			//fprintf(tokenout,"<RELOP,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s \n",line_count,yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RELOP");
			yylval = s;
			return RELOP;
}
"="		{	
			//fprintf(tokenout,"<ASSIGNOP,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <ASSIGNOP> Lexeme %s \n",line_count,yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ASSIGNOP");
			yylval = s;
			return ASSIGNOP;
}

"&&"		|
"||"		{
			//fprintf(tokenout,"<LOGOP,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <LOGOP> Lexeme %s \n",line_count,yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LOGOP");
			yylval = s;
			return LOGICOP;
}	

"!"		{
			//fprintf(tokenout,"<NOT,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <NOT> Lexeme %s \n",line_count,yytext);
			return NOT;	
}
"("		{	
			//fprintf(tokenout,"<LPAREN,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <LPAREN> Lexeme %s \n",line_count,yytext);
			return LPAREN;	
		}
")"		{
			//fprintf(tokenout,"<RPAREN,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <RPAREN> Lexeme %s \n",line_count,yytext);
			return RPAREN;
		}

"{"		{
			//fprintf(tokenout,"<LCURL,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <LCURL> Lexeme %s \n",line_count,yytext);	
			return LCURL;
		}
		
"}"		{
			//fprintf(tokenout,"<RCURL,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s \n",line_count,yytext);	
			return RCURL;
		}
"["		{	
			//fprintf(tokenout,"<LTHIRD,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <LTHIRD> Lexeme %s \n",line_count,yytext);
			return LTHIRD;
		}
"]"		{
			//fprintf(tokenout,"<RTHIRD,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <RTHIRD> Lexeme %s \n",line_count,yytext);	
			return RTHIRD;
		}
","		{
			//fprintf(tokenout,"<COMMA,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s \n",line_count,yytext);
			return COMMA;	
		}
";"		{
			//fprintf(tokenout,"<SEMICOLON,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s \n",line_count,yytext);
			return SEMICOLON;
		}
{UN_CHAR} {
			//fprintf(logout,"Error at line %d: Unterminated character %s\n",line_count,yytext);
			error_count++;
}
{LETTER}  {	
			//fprintf(tokenout,"<CONST_CHAR,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s \n",line_count,yytext);
			//SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_CHAR");
			//st.insert(si);
			return CONST_CHAR;
}

{MULT_CHAR} {
			
			logfile<<endl<<"Line no"<<line_count<<" Multi character constant "<<yytext<<endl;
			//logfile << "type_specifier : INT\n\n";
			//fprintf(logfile,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s \n",line_count,yytext);
			errorfile<<endl<<"Line no"<<line_count<<" Multi character constant "<<yytext<<endl;
			error_count++;			
}
{UN_TER} {
			//fprintf(logout,"Line no %d: Unterminated character %s \n",line_count,yytext);
			logfile<<endl<<"Line no "<<line_count<<" Unterminated character "<<yytext<<endl;
			errorfile<<endl<<"Line no "<<line_count<<" Unterminated character "<<yytext<<endl;
			error_count++;
}
{EMP_CHAR} {
			//fprintf(logout,"Line no %d: Empty character constant %s \n",line_count,yytext);
			logfile<<endl<<"Line no "<<line_count<<"  Empty character constant "<<yytext<<endl;
			errorfile<<endl<<"Line no "<<line_count<<"  Empty character constant "<<yytext<<endl;
			error_count++;
	}

{DIGITS} {
			//fprintf(tokenout,"<CONST_INT,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s \n",line_count,yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CONST_INT");
			s->intVal = atoi(yytext);
			s->type = "int";
			yylval = s;
			return CONST_INT;
	}
{ERROR_ID} {
			//fprintf(logout,"Invalid prefix on ID or invalid suffix on number %s\n",yytext);
			logfile<<endl<<"Line no "<<line_count<<" Invalid prefix on ID or invalid suffix on number "<<yytext<<endl;
			errorfile<<endl<<"Line no "<<line_count<<" Invalid prefix on ID or invalid suffix on number "<<yytext<<endl;
			error_count++;
}
{FLOAT}  {
			//fprintf(tokenout,"<CONST_FLOAT,%s>",yytext);
			//fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s \n",line_count,yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CONST_FLOAT");
			s->floatVal = atof(yytext);
			s->type = "float";
			yylval = s;
			return CONST_FLOAT;	
	}
{ILL_FORMED}+ {
			//fprintf(logout,"Error at line %d: Ill formed number %s\n",line_count,yytext);	
		}
{ERROR_FLOAT}+ {
			//fprintf(logout,"Error at line %d: Too many decimal point %s\n",line_count,yytext);
			logfile<<endl<<"Error at line "<<line_count<<" Too many decimal point "<<yytext<<endl;
			errorfile<<endl<<"Error at line "<<line_count<<" Too many decimal point "<<yytext<<endl;
			error_count++;	
		}
		
{string} {
				//fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s\n",line_count,yytext);
				printf("STRING %s id found LENGTH IS %d \n",yytext,yyleng);
				char *p=new char[yyleng];
	int k=0;
	for(int i=0;i<yyleng;i++)
	{

		if(yytext[i]=='\\' && (i+1)<yyleng && yytext[i+1]=='\n')
		{
		line_count++;

		i=i+2;
		*(p+k)=yytext[i];
		}
		else if(yytext[i]=='\\' &&(i+1)<yyleng && yytext[i+1]=='t')
		{
		i=i+1;
		*(p+k)='\t';
		}
		else
		{
		*(p+k)=yytext[i];
		}
		if(yytext[i]=='\\' && (i+1) < yyleng)
		{
		printf("** backslash and new line  found at %d**",i);
		}
		if(yytext[i]=='\n')
		{
		printf("** new line found at %d**",i);
		}
		k++;
	}
	printf("string is %s\n",p);
	//fprintf(tokenout,"<STRING,%s>",p);
	return STRING;
}
{UN_FIN_COM} {
				//fprintf(logout,"Error at line %d: unfinished comment %s\n",line_count,yytext);
				logfile<<endl<<"Error at line "<<line_count<<"unfinished comment "<<yytext<<endl;
				errorfile<<endl<<"Error at line "<<line_count<<"unfinished comment "<<yytext<<endl;
				error_count++;	
}
{COMMENT} {
				//fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s \n",line_count,yytext);
}
{MULTI_LINE_COMMENT} {
				//fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s \n",line_count,yytext);
}
{MULTY_LINE_COMMENT} {
				//fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s \n",line_count,yytext);
				line_count++;

}
{UN_FIN_STR} {
				//fprintf(logout,"Error at %d: unfinished string %s\n",line_count,yytext);
				logfile<<endl<<"Error at line "<<line_count<<" unfinished string "<<yytext<<endl;
				errorfile<<endl<<"Error at line "<<line_count<<" unfinished string "<<yytext<<endl;
				error_count++;		
}
{NEWLINE} {line_count++;}
{UNREC} {	
			//fprintf(logout,"Error at line %d: unrecognized character %s \n",line_count,yytext);
			logfile<<endl<<"Error at line"<<line_count<<" unrecognized character "<<yytext<<endl;
			errorfile<<endl<<"Error at line"<<line_count<<" unrecognized character "<<yytext<<endl;
			error_count++;
			
}
<<EOF>> {
	//fprintf(logout,"Total Line Number: %d\nTotal errors: %d\n",line_count-1,error_count);
	return 0;}
. {
	logfile<<endl<<"Error at line"<<line_count<<" unrecognized character from dot "<<yytext<<endl;
	errorfile<<endl<<"Error at line"<<line_count<<" unrecognized character "<<yytext<<endl;
	error_count++;
  }
%%
int yywrap(void)
{
	return 1;
}
