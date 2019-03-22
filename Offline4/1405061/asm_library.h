#include <bits/stdc++.h>
#include "SymbolTable.h"
#include <string.h>
using namespace std;


int label_count = 0;
int temp_count = 0;

extern string dec_code;

extern ofstream debugfile;

string newLabel()
{
	stringstream ss;
	ss<<label_count;
	string label= "L" + ss.str();
	label_count++;
	return label;
}

string newTemp()
{
	
	stringstream ss;
	ss<<temp_count;
	string temp="t"+ss.str();
	dec_code = dec_code + temp + " DW ?\n";
	temp_count++;
	return temp;
}

SymbolInfo* assignCode(SymbolInfo* s, SymbolInfo* s1, SymbolInfo* s2)
{
	s-> temp_name = s1->name;
	
	string code = "";
	stringstream ss;
	ss<<s1->ScopeNum;
	cout<<ss.str()<<endl;
	code = ";assign id\n";
	code = code + "MOV AX, " + s2->temp_name+ "\n";
	code = code + "MOV " + s1->name+ss.str()+ ", AX\n";
	
	s-> code = s->code + code;
	
	return s;
	
}
SymbolInfo* array_assign_code(SymbolInfo* s,SymbolInfo* ID, SymbolInfo* val)
{
		s->code = val->code + ID->code + s->code;
		s->code=s->code+";array assign\n";
		s->code = s->code + "LEA DI, " + ID->name + "\n";
		s->code = s->code + "MOV AX, " + val->temp_name + "\n";

		stringstream ss;
		ss<<ID->array_indx_holder;

		s->code = s->code + "ADD DI, " + ss.str() +"\n";
		s->code = s->code + "ADD DI, " + ss.str() +"\n";
		
		s->code = s->code + "MOV [DI], AX\n";
		s->temp_name = newTemp();
		return s;

}


void relop_logicop_code(SymbolInfo* s, SymbolInfo* var_1, string op, SymbolInfo* var_2)
{
	string code = "";
	string temp_var = newTemp();
	string false_label = newLabel();
	string true_label = newLabel();
	
	s->temp_name = temp_var;
	stringstream s1;
	s1<<var_1->ScopeNum;
	stringstream s2;
	s2<<var_2->ScopeNum;
	
	
	if(op == ">")
	{
		if(var_1->type != "CONST_INT" && var_1->type != "CONST_FLOAT")
		{code = code + "MOV AX, " + var_1->name +s1.str()+ "\n";}
		else {code = code + "MOV AX, " + var_1->name + "\n";}
		if(var_2->type != "CONST_INT" && var_2->type != "CONST_FLOAT")
		{code = code + "CMP AX, " + var_2->name +s2.str()+ "\n";}
		else {code = code + "CMP AX, " + var_2->name+ "\n";}
		code = code + "JG " + true_label + "\n";
		code = code + "MOV " + temp_var + ", 0\n";
		code = code + "JMP " + false_label + "\n";
		code = code + true_label + ":\n";
		code = code + "MOV " + temp_var + ", 1\n";
		code = code + false_label + ":\n";
	}
	
	else if(op=="<")
	{
		if(var_1->type != "CONST_INT" && var_1->type != "CONST_FLOAT")
		{code = code + "MOV AX, " + var_1->name +s1.str()+ "\n";}
		else {code = code + "MOV AX, " + var_1->name + "\n";}
		if(var_2->type != "CONST_INT" && var_2->type != "CONST_FLOAT")
		{code = code + "CMP AX, " + var_2->name +s2.str()+ "\n";}
		else {code = code + "CMP AX, " + var_2->name+ "\n";}
		code = code + "JL " + true_label + "\n";
		code = code + "MOV " + temp_var + ", 0\n";
		code = code + "JMP " + false_label + "\n";
		code = code + true_label + ":\n";
		code = code + "MOV " + temp_var + ", 1\n";
		code = code + false_label + ":\n";
	}
	
	else if(op==">=")
	{
		if(var_1->type != "CONST_INT" && var_1->type != "CONST_FLOAT")
		{code = code + "MOV AX, " + var_1->name +s1.str()+ "\n";}
		else {code = code + "MOV AX, " + var_1->name + "\n";}
		if(var_2->type != "CONST_INT" && var_2->type != "CONST_FLOAT")
		{code = code + "CMP AX, " + var_2->name +s2.str()+ "\n";}
		else {code = code + "CMP AX, " + var_2->name+ "\n";}
		code = code + "JGE " + true_label + "\n";
		code = code + "MOV " + temp_var + ", 0\n";
		code = code + "JMP " + false_label + "\n";
		code = code + true_label + ":\n";
		code = code + "MOV " + temp_var + ", 1\n";
		code = code + false_label + ":\n";
	}
	
	else if(op=="<=")
	{
		if(var_1->type != "CONST_INT" && var_1->type != "CONST_FLOAT")
		{code = code + "MOV AX, " + var_1->name +s1.str()+ "\n";}
		else {code = code + "MOV AX, " + var_1->name + "\n";}
		if(var_2->type != "CONST_INT" && var_2->type != "CONST_FLOAT")
		{code = code + "CMP AX, " + var_2->name +s2.str()+ "\n";}
		else {code = code + "CMP AX, " + var_2->name+ "\n";}
		code = code + "JLE " + true_label + "\n";
		code = code + "MOV " + temp_var + ", 0\n";
		code = code + "JMP " + false_label + "\n";
		code = code + true_label + ":\n";
		code = code + "MOV " + temp_var + ", 1\n";
		code = code + false_label + ":\n";
	}
	
	else if(op=="==")
	{
		if(var_1->type != "CONST_INT" && var_1->type != "CONST_FLOAT")
		{code = code + "MOV AX, " + var_1->name +s1.str()+ "\n";}
		else {code = code + "MOV AX, " + var_1->name + "\n";}
		if(var_2->type != "CONST_INT" && var_2->type != "CONST_FLOAT")
		{code = code + "CMP AX, " + var_2->name +s2.str()+ "\n";}
		else {code = code + "CMP AX, " + var_2->name+ "\n";}
		code = code + "JE " + true_label + "\n";
		code = code + "MOV " + temp_var + ", 0\n";
		code = code + "JMP " + false_label + "\n";
		code = code + true_label + ":\n";
		code = code + "MOV " + temp_var + ", 1\n";
		code = code + false_label + ":\n";
	}
	
	else if(op=="!=")
	{
		if(var_1->type != "CONST_INT" && var_1->type != "CONST_FLOAT")
		{code = code + "MOV AX, " + var_1->name +s1.str()+ "\n";}
		else {code = code + "MOV AX, " + var_1->name + "\n";}
		if(var_2->type != "CONST_INT" && var_2->type != "CONST_FLOAT")
		{code = code + "CMP AX, " + var_2->name +s2.str()+ "\n";}
		else {code = code + "CMP AX, " + var_2->name+ "\n";}
		code = code + "JNE " + true_label + "\n";
		code = code + "MOV " + temp_var + ", 0\n";
		code = code + "JMP " + false_label + "\n";
		code = code + true_label + ":\n";
		code = code + "MOV " + temp_var + ", 1\n";
		code = code + false_label + ":\n";
	}
	
	else if(op=="&&")
	{
		if(var_1->type != "CONST_INT" && var_1->type != "CONST_FLOAT")
		{code = code + "MOV AX, " + var_1->name +s1.str()+ "\n";}
		else {code = code + "MOV AX, " + var_1->name + "\n";}
		//code = code + "MOV AX, " + var_1->name +s1.str() + "\n";
		code = code + "CMP AX, 0\n";
		code = code + "je " + false_label + "\n";
		
		if(var_2->type != "CONST_INT" && var_2->type != "CONST_FLOAT")
		{code = code + "MOV AX, " + var_2->name +s2.str()+ "\n";}
		else {code = code + "MOV AX, " + var_2->name+ "\n";}

		code = code + "CMP AX, 0\n";
		code = code + "je " + false_label + "\n";
		
		code = code + "MOV " + temp_var + ", 1\n";
		code = code + "JMP " + true_label+"\n";
		
		
		code = code + false_label + ":\n";
		code = code + "MOV " + temp_var + ", 0\n";
		
		code = code + true_label + ":\n";
		
	}
	
	else if(op=="||")
	{
		if(var_1->type != "CONST_INT" && var_1->type != "CONST_FLOAT")
		{code = code + "MOV AX, " + var_1->name +s1.str()+ "\n";}
		else {code = code + "MOV AX, " + var_1->name + "\n";}
		code = code + "CMP AX, 0\n";
		code = code + "JNE " + true_label + "\n";
		
		if(var_2->type != "CONST_INT" && var_2->type != "CONST_FLOAT")
		{code = code + "MOV AX, " + var_2->name +s2.str()+ "\n";}
		else {code = code + "MOV AX, " + var_2->name+ "\n";}
		code = code + "CMP AX, 0\n";
		code = code + "JNE " + true_label + "\n";
		
		code = code + "MOV " + temp_var + ", 0\n";
		code = code + "JMP " + false_label+"\n";
		
		code = code + true_label + ":\n";
		code = code + "MOV " + temp_var + ", 1\n";
		
		code = code + true_label + ":\n";
		
	}
	
	s->code = s->code + code;

	return;
}
void addop_plus_code(SymbolInfo* s, SymbolInfo* var1, SymbolInfo* var2)
{

	string temp = newTemp();
	s->temp_name = temp;
	
	stringstream s1;
	s1<<var1->ScopeNum;
	stringstream s2;
	s2<<var2->ScopeNum;
	//stringstream s3;
	//s3<<var1->value;	
	//cout<<"var 1 is "<<var1->name<<" "<<var1->value<<endl;
	string code = "";
	if(var1->type != "CONST_INT" && var1->type !="CONST_FLOAT")
	{
	code = code + "MOV AX, " + var1->name +s1.str()+ "\n";
	}
	else 
	{
	code = code + "MOV AX, " + var1->name+ "\n";
	}
	if(var2->type != "CONST_INT" && var2->type !="CONST_FLOAT")
	{
	code = code + "ADD AX, " + var2->name +s2.str() +"\n";
	}
	else 
	{
	code = code + "ADD AX, " + var2->name  +"\n";
	}
	code = code + "MOV " + temp + ", AX\n";
	
	s->code = s->code + code;
	
	return;
}
void addop_minus_code(SymbolInfo* s, SymbolInfo* var1, SymbolInfo* var2)
{

	string temp = newTemp();
	s->temp_name = temp;
	
	stringstream s1;
	s1<<var1->ScopeNum;
	stringstream s2;
	s2<<var2->ScopeNum;	
	
	string code = "";
	if(var1->type != "CONST_INT" && var1->type !="CONST_FLOAT")
	{
	code = code + "MOV AX, " + var1->name +s1.str()+ "\n";
	}
	else 
	{
	code = code + "MOV AX, " + var1->name+ "\n";
	}
	if(var2->type != "CONST_INT" && var2->type !="CONST_FLOAT")
	{
	code = code + "SUB AX, " + var2->name +s2.str() +"\n";
	}
	else 
	{
	code = code + "SUB AX, " + var2->name  +"\n";
	}
	code = code + "MOV " + temp + ", AX\n";
	
	s->code = s->code + code;
	
	return;
}
void mulop_mod_code(SymbolInfo* s, SymbolInfo* var1, SymbolInfo* var2)
{
	string temp = newTemp();
	s->temp_name = temp;
	
	stringstream s1;
	s1<<var1->ScopeNum;
	stringstream s2;
	s2<<var2->ScopeNum;
	string code = "";
	
	code = code + "MOV DX, 0\n";
	
	if(var1->type != "CONST_INT" && var1->type !="CONST_FLOAT")
	{
	code = code + "MOV AX, " + var1->temp_name + "\n";
	}
	else 
	{
	code = code + "MOV AX, " + var1->temp_name+ "\n";
	}
	


	if(var2->type != "CONST_INT" && var2->type !="CONST_FLOAT")
	{
	code = code + "DIV " + var2->temp_name  +"\n";
	}
	else 
	{
	code = code + "DIV, " + var2->temp_name  +"\n";
	}
	
	
	code = code + "MOV " + temp + ", DX\n";
	
	s->code = s->code + code;
	
	return;
}
void mulop_multiplication_code(SymbolInfo* s, SymbolInfo* var1, SymbolInfo* var2)
{

	string temp = newTemp();
	s->temp_name = temp;
	
	stringstream s1;
	s1<<var1->ScopeNum;
	stringstream s2;
	s2<<var2->ScopeNum;

	string code = "";
	code=code+";multiplication\n";
	code = code + "MOV DX, 0\n";
	if(var1->type != "CONST_INT" && var1->type !="CONST_FLOAT")
	{
	code = code + "MOV AX, " + var1->temp_name +s1.str()+ "\n";
	}
	else 
	{
	code = code + "MOV AX, " + var1->temp_name+ "\n";
	}
	if(var2->type != "CONST_INT" && var2->type !="CONST_FLOAT")
	{
	code = code + "MUL " + var2->temp_name +"\n";
	cout<<"hello"<<var2->name+s2.str()<<endl;
	}
	else 
	{
	code = code + "MUL " + var2->temp_name  +"\n";
	}
	
	code = code + "MOV " + temp + ", AX\n";
	
	s->code = s->code + code;
	
	return;

}
void mulop_division_code(SymbolInfo* s, SymbolInfo* var1, SymbolInfo* var2)
{

	string temp = newTemp();
	s->temp_name = temp;
	
	stringstream s1;
	s1<<var1->ScopeNum;
	stringstream s2;
	s2<<var2->ScopeNum;

	string code = "";
	
	code = code + "MOV DX, 0\n";
	if(var1->type != "CONST_INT" && var1->type !="CONST_FLOAT")
	{
	code = code + "MOV AX, " + var1->temp_name +s1.str()+ "\n";
	}
	else 
	{
	code = code + "MOV AX, " + var1->temp_name+ "\n";
	}
	if(var2->type != "CONST_INT" && var2->type !="CONST_FLOAT")
	{
	code = code + "DIV " + var2->temp_name +s2.str() +"\n";
	}
	else 
	{
	code = code + "DIV, " + var2->temp_name  +"\n";
	}
	code = code + "MOV " + temp + ", AX\n";
	
	s->code = s->code + code;
	
	return;

}


void incop_code(SymbolInfo* s, SymbolInfo* v)
{
	string temp = newTemp();
	s->temp_name = temp;
	
	string code = ";incop _ code\n";
	
	stringstream s1;
	s1<<s->ScopeNum;
	stringstream s2;
	s2<<v->ScopeNum;

	
	if(v->type != "CONST_INT" && v->type != "CONST_FLOAT")
	{
	code = code + "MOV AX, " + v->temp_name + "\n"; 
	code = code + "MOV " + temp + ", AX\n";
	
	code = code + "INC AX\n";
	
	code = code + "MOV "+ v->temp_name + ", AX\n";
	}
	else
	{
	code = code + "MOV AX, " + v->temp_name + "\n"; 
	code = code + "MOV " + temp + ", AX\n";
	
	code = code + "INC AX\n";
	
	code = code + "MOV "+ v->temp_name + ", AX\n";
	}
	s->code = s->code + code;
	
	return;
}

void array_incop(SymbolInfo* s, SymbolInfo* ID)
{
	//s->code = val->code + ID->code + s->code;
		string code=";array incop\n";
		code = code + "LEA DI, " + ID->name + "\n";

		stringstream ss;
		ss<<ID->array_indx_holder;
		code = code + "ADD DI, " + ss.str() +"\n";
		code = code + "ADD DI, " + ss.str() +"\n";
		code = code + "MOV AX, [DI]\n";
		code=code+"INC AX\n";
		
		
		code = code + "MOV [DI], AX\n";
		
		s->code=s->code+code;
		return ;
}
void decop_code(SymbolInfo* s, SymbolInfo* v)
{
	string temp = newTemp();
	s->temp_name = temp;
	
	string code = "";
	
	stringstream s1;
	s1<<s->ScopeNum;
	stringstream s2;
	s2<<v->ScopeNum;

	

	if(v->type != "CONST_INT" && v->type != "CONST_FLOAT")
	{
	code = code + "MOV AX, " + v->temp_name + "\n"; 
	code = code + "MOV " + temp + ", AX\n";
	
	code = code + "DEC AX\n";
	
	code = code + "MOV "+ v->temp_name + ", AX\n";
	}
	else
	{
	code = code + "MOV AX, " + v->temp_name + "\n"; 
	code = code + "MOV " + temp + ", AX\n";
	
	code = code + "DEC AX\n";
	
	code = code + "MOV "+ v->temp_name + ", AX\n";
	}
	
	s->code = s->code + code;
	
	return;
}

string outdec = "OUTDEC PROC\n\
;INPUT AX\n\
PUSH AX\n\
PUSH BX\n\
PUSH CX\n\
PUSH DX\n\
OR AX,AX\n\
JGE @END_IF1\n\
PUSH AX\n\
MOV DL,'-'\n\
MOV AH,2\n\
INT 21H\n\
POP AX\n\
NEG AX\n\
\n\
@END_IF1:\n\
XOR CX,CX\n\
MOV BX,10D\n\
\n\
@REPEAT1:\n\
XOR DX,DX\n\
DIV BX\n\
PUSH DX\n\
INC CX\n\
OR AX,AX\n\
JNE @REPEAT1\n\
\n\
MOV AH,2\n\
\n\
@PRINT_LOOP:\n\
\n\
POP DX\n\
OR DL,30H\n\
INT 21H\n\
LOOP @PRINT_LOOP\n\
\n\
POP DX\n\
POP CX\n\
POP BX\n\
POP AX\n\
RET\n\
OUTDEC ENDP\n\
";
string indec="";
