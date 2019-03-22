
%{
#define YYSTYPE SymbolInfo*
#include <stdio.h>
#include <stdlib.h>
#include <typeinfo>
#include "asm_library.h"


using namespace std;     /* yyparse() stack type */


SymbolTable* table;
SymbolInfo* dummy=new SymbolInfo();
int yylex(void);
extern FILE* yyin;
extern int line_count;
extern int error_count;


string full_code;
string start_code =".MODEL SMALL\n.STACK 100H\n\n.DATA\n";
string dec_code="";
string dot_code = ".CODE\n\n";
string inside_main_code="MAIN PROC\n\nMOV AX, @DATA\nMOV DS, AX\n\n";
string main_code="";
string main_ret="MOV AH, 4CH\nINT 21H\n";



extern int loop_scope;
string var_type="";
string para_info[20][2];
string para_check[20][2];
int indx=0,sc_flag=0,check_flag=0,k=0,pno=0;
string func_ret_type="";
int func_scope_num=0;


ofstream logfile;
ofstream asmfile;
ofstream errorfile;
void yyerror(string str)
{
	logfile << "ERROR at Line " << line_count << " : " << str << endl << endl;
	cout << "    ERROR at Line " << line_count << " : " << str << endl << endl << endl;
}
int yylex(void);

SymbolInfo* insertID(SymbolInfo* s,bool func)
{
	SymbolInfo *a=table->LookUp(s);
				if(a != NULL && a->proto == true)
				{
					s->isFunc=func;
					s->para_num=k;
					s->ret_type=func_ret_type;
					s->func_scope_num = func_scope_num;
					func_scope_num=-1;
					//logfile<< "function scope number "<<s->func_scope_num<<endl;
					if(func == true ) {table->Insert_global(s);}
					return s;
				}
				else if ( a != NULL )
				{
					errorfile<<"error at line "<<line_count<<"multiple declaration"<<endl;
					error_count++;
					return dummy;
				}
				else
				{
					s->isFunc=func;
					
					s->data_type=var_type;
					if(func != true)
					{
						stringstream ss;
						ss<<table->n;
						dec_code = dec_code+s->name+ss.str()+" DW " +"?\n";
						//logfile<<"inside function "<<s->name+ss.str()<<endl;
						table->Insert(s);
					}
					if(func == true )
					{
						s->ret_type == func_ret_type;
						s->para_num=k;
						s->func_scope_num=func_scope_num;
						//logfile<< "function scope number "<<s->func_scope_num<<endl;
						table->Insert_global(s);
					}
					return s;
				}
}

SymbolInfo* manage_function(SymbolInfo* func,SymbolInfo* stmt)
{
	if(func->name == "main")
	{
		cout<<"****main"<<endl;
		//logfile<<"main function"<<endl;
		main_code = inside_main_code+main_code + stmt->code;
		main_code = main_code + main_ret+"MAIN ENDP\n\n";
		return dummy;
	}
	cout<<"function name: "<<func->name<<endl;
	SymbolInfo* s=new SymbolInfo();
	string code="";
	main_code=main_code+func->name+" PROC NEAR\n";
	main_code=main_code+stmt->code;
	main_code=main_code+func->name+" ENDP\n";
	//s->code=s->code+code;
	return dummy;
}
SymbolInfo* createArray(SymbolInfo* arra,SymbolInfo* size)
{
	SymbolInfo *s=table->LookUp(arra);
	if(s != NULL)
	{
		errorfile<<"error at line "<<line_count<<"multiple declaration"<<endl;
		error_count++;
		return dummy;
	}
	else if(size->intVal < 0) 
	{
		errorfile<<"error at line "<<line_count<<"invalid array size"<<endl;
		error_count++;
		return dummy;
	}
	else if(size -> data_type == "float")
	{
		errorfile<<"error at line "<<line_count<<" array size cannot be float"<<endl;
		error_count++;
		return dummy;
	}
		s=new SymbolInfo();
		s->name=arra->name;
		s->type="ID";
		s->isArray=true;
		s->array_size=size->intVal;
		s->data_type=var_type;
		s->create_array();	

		string array_code = "";				
		array_code = arra->name + " DW ";
		int length = size->intVal;
						
		for(int i = 0; i < length-1;i++){
			array_code += "?, " ;
		}
		array_code += "?\n";
	
		dec_code += array_code;	
		table->Insert(s);
		return s;
			//cout<<"##array created "<<s->isArray<<endl;
				
	
}

SymbolInfo* manage_if_else_code(SymbolInfo* expr, SymbolInfo* stmt_1, SymbolInfo* stmt_2)
{
	SymbolInfo* s = new SymbolInfo();
	
	string false_label = newLabel();
	string continue_label = newLabel();
	
	string code = ";if else\n";
	code = code + expr->code + "\n";
	stringstream ss;
	ss<<expr->ScopeNum;
	code = code + "MOV AX, " + expr->temp_name +ss.str()+ "\n";
	
	code = code + "CMP AX, 0\n";
	code = code + "JE " + false_label + "\n"; //else
	
	//label_true
	code = code + stmt_1->code + "\n";
	code = code + "JMP " + continue_label + "\n";
	
	//label_false
	code = code + false_label + ":\n";
	code = code + stmt_2->code + "\n";
	
	//label_continue
	code = code + continue_label + ":\n";
	
	s->code = s->code + code;
	
	return s;
}

SymbolInfo* manage_if_code(SymbolInfo* expr, SymbolInfo* stmt)
{
	SymbolInfo* s = new SymbolInfo();
	
	string false_label = newLabel();
	
	string code = ";if\n";
	code = code + expr->code + "\n";
	code = code + "MOV AX, " + expr->temp_name + "\n";
	code = code + "CMP AX, 0\n";
	code = code + "JE " + false_label + "\n";
	code = code + stmt->code + "\n";
	code = code + false_label + ":\n";

	return s;
}
SymbolInfo* findID(SymbolInfo* ID)
{
	SymbolInfo *s=table->LookUp(ID);
	if(s==NULL)
	{
		cout<<"id1"<<endl;
		errorfile<<"error at line "<<line_count<<"not declared"<<endl;
		error_count++;
		return dummy;
	}
	else 
	{
		return s;
	}			
}

SymbolInfo* findFunc(SymbolInfo* ID)
{
	SymbolInfo* s=table->LookUp(ID);
	if(s == NULL)
	{
		errorfile<<"error at line "<<line_count<<" "<<s->name<<" is not declared"<<endl;
		error_count++;
		return dummy;
	}
	else if(s->isFunc != true)
	{
		errorfile<<"error at line "<<line_count<<" "<<s->name<<" is not function"<<endl;
		error_count++;
		return dummy;
	}
	else if( s->isFunc == true)
	{
		return s;
	}
	return dummy;
	
}
SymbolInfo* findArray(SymbolInfo* array,SymbolInfo* indx)
{
	SymbolInfo* id=table->LookUp(array);
				
				if(id == NULL)
				{
					errorfile<<"error at line "<<line_count<<"not declared"<<endl;
					error_count++;
					return dummy;
					cout<<"*#*"<<endl;
				}
				
				else if(id->isArray == false )
				{
					errorfile<<"error at line "<<line_count<<id->name<<" is not array"<<endl;
					error_count++;
					return dummy;
					
				}
				else if(indx->intVal < 0)
				{
					
					errorfile<<"error at line "<<line_count<<"array index must be positive integer"<<endl;
					error_count++;
					return dummy;
					cout<<"***"<<endl;
				}
				else if(indx->intVal >= id->array_size)
				{
					errorfile<<"error at line "<<line_count<<" array index out of size"<<endl;
					error_count++;
					return dummy;
					cout<<"****"<<endl;
				}
				else if(indx->data_type == "float")
				{
					errorfile<<"error at line "<<line_count<<" array index cannot be float"<<endl;
					error_count++;
					return dummy;
				}
				else 
				{
					id->array_indx_holder=indx->intVal;
					//logfile<<$1->name<<" array index holder "<<id->array_indx_holder<<endl;
					return id->get_arr_ptr(indx->intVal);
					
				}
}
SymbolInfo* manage_assignID(SymbolInfo* ID,SymbolInfo* val)//not for array
{
	

	SymbolInfo *s=new SymbolInfo();
	if(ID->isArray == true && val->isArray != true)
	{
		errorfile<<"error at line "<<line_count<<"illegal operation on array."<<endl;
		error_count++;
	}
	else if(ID->isArray != true && val->isArray == true)
	{
		errorfile<<"error at line "<<line_count<<"illegal operation on array."<<endl;
		error_count++;
	}
	if(ID->data_type != "float" && val->data_type == "float")
	{
		//errorfile<<"error at line "<<line_count<<"type mismatchedd"<<endl;
		logfile<<"warning!!Casting float into nonfloat"<<endl;
		//error_count++;
	}
	if(ID->data_type == "int" && val-> data_type == "int") {ID->intVal = val->intVal;s->intVal = ID->intVal; }
	if(ID->data_type == "int" && val-> data_type == "float") {ID->intVal = val->floatVal;s->intVal = ID->intVal;}
	if(ID->data_type == "int" && val-> data_type == "char") {ID->intVal = val->charVal;s->intVal = ID->intVal;}
	if(ID->data_type == "float" && val-> data_type == "int") {ID->floatVal = val->intVal;s->floatVal = ID->floatVal;}
	if(ID->data_type == "float" && val-> data_type == "float") {ID->floatVal = val->floatVal;s->floatVal = ID->floatVal;}
	if(ID->data_type == "float" && val-> data_type == "char") {ID->floatVal = val->charVal;s->floatVal = ID->floatVal;}
	if(ID->data_type == "char" && val-> data_type == "int") {ID->charVal = val->intVal;s->charVal = ID->charVal;}
	if(ID->data_type == "char" && val-> data_type == "float") {ID->charVal = val->floatVal;s->charVal = ID->charVal;}
	if(ID->data_type == "char" && val-> data_type == "char") {ID->charVal = val->charVal;s->charVal = ID->charVal;}

	if(ID->array_indx_holder == -1)
	{
		s=assignCode(s, ID, val);
		s->code = val->code + ID->code + s->code;
	}
	
	else
	{
		
		s=array_assign_code(s,ID,val);
		//logfile<<"array info : "<<ID->array_indx_holder << val->array_indx_holder<<endl;
	}
	return s ;
				
}
SymbolInfo* manage_rel_logic(SymbolInfo* s1,SymbolInfo* s2,SymbolInfo* s3)
{
	SymbolInfo* s=new SymbolInfo();
	s->data_type="int";
	string opr=s2->name;
	int rel;
	if(s1->data_type == "int" && s3->data_type == "int")
	{
		int a,b;
		a=s1->intVal;
		b=s3->intVal;
		if (opr==">") {rel = a>b;}
		else if(opr=="<") {rel = a<b;}
		else if(opr==">=") {rel = a>=b;}
		else if(opr=="<=") {rel = a<=b;}
		else if(opr=="==") {rel = a==b;}
		else if(opr=="!=") {rel = a!=b;}
		else if(opr=="&&") {rel = a&&b;}
		else if(opr=="||") {rel = a||b;}
	}
	if(s1->data_type == "int" && s3->data_type == "float")
	{
		int a;
		float b;
		a=s1->intVal;
		b=s3->floatVal;
		if (opr==">") {rel = a>b;}
		else if(opr=="<") {rel = a<b;}
		else if(opr==">=") {rel = a>=b;}
		else if(opr=="<=") {rel = a<=b;}
		else if(opr=="==") {rel = a==b;}
		else if(opr=="!=") {rel = a!=b;}
		else if(opr=="&&") {rel = a&&b;}
		else if(opr=="||") {rel = a||b;}
	}
	if(s1->data_type == "float" && s3->data_type == "float")
	{
		float a,b;
		a=s1->floatVal;
		b=s3->floatVal;
		if (opr==">") {rel = a>b;}
		else if(opr=="<") {rel = a<b;}
		else if(opr==">=") {rel = a>=b;}
		else if(opr=="<=") {rel = a<=b;}
		else if(opr=="==") {rel = a==b;}
		else if(opr=="!=") {rel = a!=b;}
		else if(opr=="&&") {rel = a&&b;}
		else if(opr=="||") {rel = a||b;}
	}
	if(s1->data_type == "float" && s3->data_type == "int")
	{
		float a;
		int b;
		a=s1->floatVal;
		b=s3->intVal;
		if (opr==">") {rel = a>b;}
		else if(opr=="<") {rel = a<b;}
		else if(opr==">=") {rel = a>=b;}
		else if(opr=="<=") {rel = a<=b;}
		else if(opr=="==") {rel = a==b;}
		else if(opr=="!=") {rel = a!=b;}
		else if(opr=="&&") {rel = a&&b;}
		else if(opr=="||") {rel = a||b;}
	}
	s->intVal=rel;
	relop_logicop_code(s, s1, opr, s3);
	
	s->code = s3->code + s1->code + s->code;
	
	return s;


}
SymbolInfo* manage_add_op(SymbolInfo* s1, SymbolInfo* s2, SymbolInfo* s3)
{
	SymbolInfo* s = new SymbolInfo();	
	string op = s2->getName();
	if(s1->data_type == "float" || s3->data_type == "float") {s->data_type = "float";}	
	else {s->data_type = "int";}
	stringstream ss;
	if(op == "+")
	{
		
		if(s1->data_type == "int" && s3->data_type == "int") {s->intVal = s1->intVal + s3->intVal;}
		else if(s1->data_type == "int" && s3->data_type == "float") {s->floatVal = s1->intVal + s3->floatVal;}
		else if(s1->data_type == "float" && s3->data_type == "int") {s->floatVal = s1->floatVal + s3->intVal;}
		else if(s1->data_type == "float" && s3->data_type == "float") {s->floatVal = s1->floatVal + s3->floatVal;}
		addop_plus_code(s,s1,s3);
	}
	else if(op=="-")
	{
		if(s1->data_type == "int" && s3->data_type == "int") {s->intVal = s1->intVal - s3->intVal;}
		else if(s1->data_type == "int" && s3->data_type == "float") {s->floatVal = s1->intVal - s3->floatVal;}
		else if(s1->data_type == "float" && s3->data_type == "int") {s->floatVal = s1->floatVal - s3->intVal;}
		else if(s1->data_type == "float" && s3->data_type == "float") {s->floatVal = s1->floatVal - s3->floatVal;}
		addop_minus_code(s,s1,s3);
	}
	s->code=s3->code+s1->code+s->code;
	return s;
}
SymbolInfo* manage_mul_op(SymbolInfo* s1, SymbolInfo* s2, SymbolInfo* s3)
{
	SymbolInfo* s=new SymbolInfo();
	string opr=s2->name;
	stringstream ss;
	
	if( opr == "%")
	{
		if(s1->data_type == "float" || s3->data_type == "float")
		{
			errorfile<<"error at line "<<line_count<<"no modulous operation can be done on float"<<endl;
			error_count++;
		}
		else 
		{
			s->data_type="int";
			s->intVal = s1->intVal % s3->intVal;//logfile<<s->intVal<<endl;
			ss<<s->intVal;
			s->name=ss.str();
			mulop_mod_code(s, s1, s3);
		}
	}
	else if (opr == "*")
	{
		if(s1->data_type == "float" || s3->data_type == "float") s->data_type = "float";
		else s->data_type = "int";
		if(s1->data_type == "int" && s3->data_type == "int") {s->intVal = s1->intVal * s3->intVal;ss<<s->intVal;s->name=ss.str();}
		else if(s1->data_type == "int" && s3->data_type == "float") {s->floatVal = s1->intVal * s3->floatVal;ss<<s->floatVal;s->name=ss.str();}
		else if(s1->data_type == "float" && s3->data_type == "int") {s->floatVal = s1->floatVal * s3->intVal;ss<<s->floatVal;s->name=ss.str();}
		else if(s1->data_type == "float" && s3->data_type == "float"){ s->floatVal = s1->floatVal * s3->floatVal;ss<<s->floatVal;s->name=ss.str();}
		mulop_multiplication_code(s, s1, s3);
		cout<<s3->name<<endl;
	}
	else if(opr == "/")
	{
		if(s1->data_type == "float" || s3->data_type == "float") 
		{
			s->data_type = "float";	
		}
		else s->data_type = "int";
		if(s1->data_type == "int" && s3->data_type == "int") {s->intVal = s1->intVal / s3->intVal;ss<<s->intVal;s->name=ss.str();}
		else if(s1->data_type == "int" && s3->data_type == "float") {s->floatVal = s1->intVal / s3->floatVal;ss<<s->floatVal;s->name=ss.str();}
		else if(s1->data_type == "float" && s3->data_type == "int") {s->floatVal = s1->floatVal / s3->intVal;ss<<s->floatVal;s->name=ss.str();}
		else if(s1->data_type == "float" && s3->data_type == "float"){ s->floatVal = s1->floatVal / s3->floatVal;ss<<s->floatVal;s->name=ss.str();}
		mulop_division_code(s, s1, s3);
	}
	s->code = s3->code + s1->code + s->code;
	return s;
	
}
SymbolInfo* manage_unary_op(SymbolInfo* op,SymbolInfo* var)
{
	SymbolInfo* s = new SymbolInfo();
	string temp = newTemp();
	s->temp_name = temp;
	//logfile<<"temp_name "<<s->temp_name<<endl;
	
	string code = "";
	string v = s->temp_name;
	
	if(op->name == "+")
	{
		s-> data_type = var->data_type;
		s->intVal = var->intVal;
		s->floatVal = var->floatVal;
		s->charVal = var->charVal;
		
	}
	else if(op->name == "-")
	{
		s-> data_type = var->data_type;
		s->intVal = -var->intVal;
		s->floatVal = -var->floatVal;
		s->charVal = -var->charVal;
		code = code + "MOV AX, " + v + "\n";
		code = code + "NEG AX\n";
		code = code + "MOV " + temp + ", ax\n";
		
	}
	else if(op->name == "!")
	{
		s-> data_type = "int";
		if(var->data_type == "int") s-> intVal = !(var->intVal);
		else if(var->data_type == "float") s-> intVal = !(var->floatVal);
		else if(var->data_type == "char") s-> intVal = !(var->charVal);	
		string L1 = newLabel();
		
		code = code + "MOV AX, " + v + "\n";	
		code = code + "CMP AX, 0\n";
		code = code + "JE " + L1 + "\n";
		
		code = code + "MOV AX, 1\n";
		
		code = code + L1 + ":\n";
		code = code + "MOV " + temp +  ", AX\n";	
	}
	s->code = s->code + code;
	return s;
}

SymbolInfo* parameter_check(SymbolInfo* s1)
{
	SymbolInfo*s=table->LookUp(s1->getName());
	cout<<"check flag "<<s->para_num<<" "<<check_flag<<endl;
	if(s->para_num != check_flag)
	{
		errorfile<<"error at line "<<line_count<<" number of parameters are invalid "<<endl;
		error_count++;
		check_flag=0;
		return dummy;
	}
	else
	{
		SymbolInfo* a=new SymbolInfo();
		string code="";
		cout<<"check flag "<<check_flag<<endl;
		for(int i=0;i<check_flag;i++)
		{
			if(s->para_info[i][0]!=para_check[i][0])
			{				
				stringstream ss;
    				ss << (i+1);		
				errorfile<<ss.str() +"th argument mismatch in function " + s1->name<<endl;
				error_count++;
				check_flag=0;
				continue;
			}

			code=code+"MOV AX , "+para_check[i][1]+"\n";
			code=code+"MOV "+s->para_info[i][1]+" , AX\n";
			cout<<code<<endl;
			
		}
		a->code=a->code+code;
		check_flag=0;
		a->temp_name=newTemp();
		return a;
	
	}
}

SymbolInfo* manage_incop(SymbolInfo* s1)

{
	SymbolInfo* s = new SymbolInfo();
	s->data_type = s1->data_type;
	
	
	if(s1-> data_type == "int")		{s->intVal = s1->intVal; s1->intVal = s1->intVal + 1;}
	else if(s1-> data_type == "float")	{s->floatVal = s1->floatVal; s1->floatVal = s1->floatVal + 1; }
	else if(s1-> data_type == "char") 	{s->charVal = s1->charVal; s1->charVal = s1->charVal + 1; }

	//logfile<<s1->name<<" isArray "<<s1->array_indx_holder<<endl;
	if(s1->array_indx_holder != -1){array_incop(s,s1);}
	else {incop_code(s, s1);}	
	
	
	return s;
}

SymbolInfo* manage_decop(SymbolInfo* s1)
{
	SymbolInfo* s = new SymbolInfo();
	s->data_type = s1->data_type;
	
	
	if(s1-> data_type == "int")		{s->intVal = s1->intVal; s1->intVal = s1->intVal - 1; }
	else if(s1-> data_type == "float")	{s->floatVal = s1->floatVal; s1->floatVal = s1->floatVal - 1;}
	else if(s1-> data_type == "char") 	{s->charVal = s1->charVal; s1->charVal = s1->charVal - 1; }
		
	decop_code(s, s1);	
	
	
	return s;
}

SymbolInfo* manage_for_loop(SymbolInfo* init_cond, SymbolInfo* loop_cond, SymbolInfo* after_cond, SymbolInfo* body_stmt)
{
	SymbolInfo* s = new SymbolInfo();
	
	string loop_start = newLabel();
	string loop_end = newLabel();
	
	string code = ";for_loop\n";
	
	code = code + init_cond->code + "\n"; // initial statement
	
	code = code + loop_start + ":\n"; // start iteration
	
	code = code + loop_cond->code + "\n";
	code = code + "MOV AX, " + loop_cond->temp_name + "\n";
	code = code + "CMP AX, 0\n";    // loop condition checking
	code=code+";condition fail\n";
	code = code + "JE " + loop_end + "\n"; // condition fail
	code = code + body_stmt->code + "\n";
	code = code + after_cond->code + "\n";
	code=code+";repeat condition\n";
	code = code + "JMP " + loop_start + "\n"; // repeat
	
	code = code + loop_end + ":\n";
	code=code+";for loop finish\n";
	
	s-> code = s->code + code;
	
	return s;
}


SymbolInfo* manage_while_loop(SymbolInfo* loop_cond, SymbolInfo* body_stmt)
{
	SymbolInfo* s = new SymbolInfo();
	
	string loop_start = newLabel();
	string loop_end = newLabel();
	
	string code = ";while loop\n";
	
	code = code + loop_start + ":\n"; // start iteration
	
	code = code + loop_cond->code + "\n";
	
	code = code + "MOV AX, " + loop_cond->temp_name + "\n";
	code = code + "CMP AX, 0\n";    // loop condition checking
	code=code+";while condition fail\n";
	code = code + "JE " + loop_end + "\n"; // condition fail
	code = code + body_stmt->code + "\n";
	code=code+";while repeat\n";
	code = code + "JMP " + loop_start + "\n"; // repeat
	
	code = code + loop_end + ":\n";
	
	s-> code = s->code + code;
	
	return s;
}

//OK


SymbolInfo* val_print(SymbolInfo* s3)
{
		
	string data_type="";
	
	//if(dt == "int")	cout << "Value of " << s3->name << " = " << s3->intval << endl << endl << endl;
	//else if(dt == "float") cout << "Value of " << s3->name << " = " << s3->floatval << endl << endl << endl;
	//else if(dt == "char")  cout << "Value of " << s3->name << " = " << s3->charval << endl << endl << endl;
	
	SymbolInfo* s = table->LookUp(s3);
	string code = ";printline\n";
	
	//data_type=s->data_type;
	
	//logfile<<"**println "<<data_type<<endl;
	if(s == NULL )
	{
		errorfile<<"error at line "<<line_count<<" "<<s3->name<<" Not declared"<<endl;
		//logfile<<"NULL here"<<endl;
		error_count++;
		cout<<"got here1"<<endl;
		return dummy;
	}
	else if(s->data_type == "int")
	{
		string v = s->temp_name;
		
		code = code + "MOV AX, " + v + "\n";
		code = code + "CALL OUTDEC\n";
		
		code = code + "MOV AH, 2\n";
		code = code + "MOV DL, 0DH\n";
		code = code + "INT 21H\n";
		
		code = code + "MOV AH, 2\n";
		code = code + "MOV DL, 0AH\n";
		code = code + "INT 21H\n";
	}
	
	else if(s->data_type == "char")
	{
		code = code + "MOV AH, 2\n";
		code = code + "MOV DL, 0DH\n";
		code = code + "INT 21H\n";
		
		code = code + "MOV AH, 2\n";
		code = code + "MOV DL, 0AH\n";
		code = code + "INT 21H\n";
		
		code = code + "MOV DL, " + s3->temp_name + "\n";
		code = code + "INT 21H\n";
	}
	
	s-> code = s-> code + code;
	return s;
}


%}

%token CONST_INT CONST_FLOAT CONST_CHAR ID INCOP MULOP ADDOP RELOP LOGICOP ASSIGNOP LPAREN RPAREN RTHIRD LTHIRD LCURL RCURL COMMA SEMICOLON NOT DECOP IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE  STRING PRINTLN


%error-verbose

%left '+' '-'
%left '*' '/'

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%start program;

%%
program : program unit {logfile<<"line "<<line_count<<" : program : program unit"<<endl;}
	| unit {logfile<<"line "<<line_count<<" : program : unit"<<endl;}
	;
	
unit : var_declaration {logfile<<"line "<<line_count<<" : unit : var_declaration"<<endl;}
     | func_declaration {logfile<<"line "<<line_count<<" : unit : func_declaration"<<endl;}
     | func_definition {logfile<<"line "<<line_count<<" : unit : func_definition"<<endl;$$=$1;}
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON 
		{
			
			$2->para_num=k;
			$2->proto=true;
			pno=k;
			func_ret_type=$1->name;
			for(int i=0;i<k;i++)
			{
				$2->para_info[i][0]=para_info[i][0];
				$2->para_info[i][1]=para_info[i][1];
			}
			insertID($2,true);
			for(int i=0;i<k;i++)
			{
				para_info[i][0].clear();
				para_info[i][1].clear();
			}
			k=0;
			table->ExitScope();
			logfile<<"line "<<line_count<<" : func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl;
		}
		
		 ;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
		{
			
			$2->para_num=k;
			for(int i=0;i<k;i++)
			{
				$2->para_info[i][0]=para_info[i][0];
				$2->para_info[i][1]=para_info[i][1];
			}
			func_ret_type=$1->name;
			insertID($2,true);
			$$=manage_function($2,$6);
			for(int i=0;i<k;i++)
			{
				para_info[i][0].clear();
				para_info[i][1].clear();
			}
			k=0;
			logfile<<"line "<<line_count<<" : func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<$2->name<<endl;
		}
		
 		 ;
 		 
parameter_list  : parameter_list COMMA type_specifier ID 
		{
			insertID($4,false);
			para_info[k][0]=$4->data_type;
			para_info[k][1]=$4->temp_name;
			k++;
			logfile<<"line "<<line_count<<" : parameter_list : parameter_list COMMA type_specifier ID "<<$4->name<<endl;
		}
		| parameter_list COMMA type_specifier 
		{
			logfile<<"line "<<line_count<<" : parameter_list : parameter_list COMMA type_specifier"<<endl;
		}	 
 		| type_specifier ID 
		{
			//stringstream ss;
			sc_flag=1;
			table->EnterScope();
			func_scope_num=table->n;
			insertID($2,false);
			para_info[k][0]=$2->data_type;
			para_info[k][1]=$2->temp_name;
			k++;
			logfile<<"line "<<line_count<<" : parameter_list : type_specifier ID "<<$2->name<<endl;
			//logfile<<"scope creation 1"<<endl;
		}	
 		| type_specifier 
		{
			
			table->EnterScope();
			func_scope_num=table->n;
			logfile<<"line "<<line_count<<" : parameter_list : type_specifier"<<endl;
			//logfile<<"scope creation 2"<<endl;
		}
		| 
		{
			table->EnterScope();
			func_scope_num=table->n;
			//logfile<<"scope creation 3"<<endl;
		}
 		;
 		
compound_statement : LCURL statements RCURL 
			{
				logfile<<"line "<<line_count<<" : compound_statement: LCURL statements RCURL"<<endl;
				$$=$2;
			}
 		    | LCURL RCURL 
			{
				$$=dummy;
				logfile<<"line "<<line_count<<" : compound_statement: LCURL RCURL"<<endl;
			}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
			{
				$$ = $2;
				logfile<<"line "<<line_count<<" : var_declaration : type_specifier declaration_list SEMICOLON "<<$2->name<<endl;
			}
 		 ;
 		 
type_specifier	: INT 
			{
				$$=$1;
				var_type="int";
				logfile << "line "<<line_count<<" : type_specifier : INT\n\n";
			}
 		| FLOAT
			{
				$$=$1;
				var_type="float";
				logfile << "line "<<line_count<<" : type_specifier : FLOAT\n\n";
			}
 		| VOID
			{
				$$=$1;
				var_type="void";
				logfile << "line "<<line_count<<" : type_specifier : VOID\n\n";
			}
 		;
 		
declaration_list : declaration_list COMMA ID
			{
				insertID($3,false);
				logfile << "line "<<line_count<<" : declaration_list : declaration_list COMMA ID "<<$3->name<<endl;
				cout<<"here is segmentation fault1"<<endl;
				
			}


 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD 
			{
				$$=createArray($3,$5);
				//cout<<"show all id 2 "<<s->name<<endl;
		 		logfile << "line "<<line_count<<" : declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD "<<endl;
				//delete $3;
				//delete $5;
				
		 	}
 		  | ID 
			{
				
				$$=insertID($1,false);
				logfile << "line "<<line_count<<" : declaration_list : ID "<<$1->name<<endl;
				
		 	}
 		  | ID LTHIRD CONST_INT RTHIRD 
			{
				$$=createArray($1,$3);
		 		logfile << "line "<<line_count<<" : declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD "<<$3->name<<endl;
				
			}
 		  ;
 		  
statements : statement 
			{
				$$=$1;
				logfile<<"line "<<line_count<<" : statements : statement"<<endl;
			}
	   | statements statement 
			{
				logfile<<"line "<<line_count<<" : statements : statements statement"<<endl;
				$$ = new SymbolInfo();
	   			$$->code = $1->code + $2->code;
	   			//delete $2;
			}
	   ;
	   
statement : var_declaration 
			{
				$$=$1;
				logfile<<"line "<<line_count<<" : statement : var_declaration"<<endl;
			}
	  | expression_statement 
			{
				$$=$1;
				logfile<<"line "<<line_count<<" : statement : expression_statement"<<endl;
			}
	  | compound_statement 
			{
				$$=$1;
				logfile<<"line "<<line_count<<" : statement : compound_statement"<<endl;
			}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement 
			{
				logfile<<"line "<<line_count<<" : statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl;
				 $$ = manage_for_loop($3, $4, $5, $7);
			}
	  | IF LPAREN expression RPAREN statement  %prec LOWER_THAN_ELSE
			{
				logfile<<"line "<<line_count<<" : statement : IF LPAREN expression RPAREN statement"<<endl;
				$$=manage_if_code($3,$5);
			}
	  | IF LPAREN expression RPAREN statement ELSE statement 
			{
				logfile<<"line "<<line_count<<" : statement : IF LPAREN expression RPAREN statement ELSE statement "<<endl;
				$$=manage_if_else_code($3,$5,$7);
			}
	  | WHILE LPAREN expression RPAREN statement 
			{
				logfile<<"line "<<line_count<<" : statement : WHILE LPAREN expression RPAREN statement "<<endl;
				$$ = manage_while_loop($3, $5);
			}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON 
			{
				logfile<<"line "<<line_count<<" : statement : PRINTLN LPAREN ID RPAREN SEMICOLON "<<$3->name<<" "<<$3->data_type<<endl;
				$$=val_print($3);
			}
	  | RETURN expression SEMICOLON 
			{
				logfile<<"line "<<line_count<<" : statement : RETURN expression SEMICOLON "<<endl;
				//$$=$2;
				//$$ = new SymbolInfo("return", "return");
				//$$->temp_name=newTemp();
	   			//$$->code = "\n\n;exit to dos\nMOV AH, 4ch\nINT 21H\n";
			}
	  ;
	  
expression_statement 	: SEMICOLON 
			{
				logfile<<"line "<<line_count<<" : expression_statement : SEMICOLON"<<endl;	
			}
			| expression SEMICOLON 
			{
				//$$=$1;
				//table->PrintAllScopeTable_file();
				logfile<<"line "<<line_count<<" : expression_statement : expression SEMICOLON"<<endl;
			}
			;
	  
variable : ID 
			{
				$$=findID($1);
				logfile<<"line "<<line_count<<" : variable : ID "<<$1->name<<endl;
			}
	 | ID LTHIRD expression RTHIRD
			{
				$$=findArray($1,$3);
				logfile<<"line "<<line_count<<" : variable : ID LTHIRD expression RTHIRD "<<$3->intVal<<endl;
			}
	 ;
	 
 expression : logic_expression 
			{
				cout<<"segmentation fault here maybe"<<endl;
				$$=$1;
				logfile<<"line "<<line_count<<" : expression : logic_expression"<<endl;
			}
	   | variable ASSIGNOP logic_expression
			{
				$$=manage_assignID($1,$3);
				logfile<<"line "<<line_count<<" expression : variable ASSIGNOP logic_expression "<<$3->intVal<<endl;
				table->PrintAllScopeTable_file();
			}
	   ;
			
logic_expression : rel_expression 	
			{
				$$=$1;
				logfile<<"line "<<line_count<<" : logic_expression : rel_expression"<<endl;
			}
		 | rel_expression LOGICOP rel_expression 
			{
				$$=manage_rel_logic($1,$2,$3);
				logfile<<"line "<<line_count<<" : logic_expression : rel_expression LOGICOP rel_expression "<<$$->intVal<<endl;
			}
		 ;
			
rel_expression	: simple_expression 
			{
				$$=$1;
				logfile<<"line "<<line_count<<" : rel_expression : simple_expression"<<endl;
			}
		| simple_expression RELOP simple_expression 
			{
				$$=manage_rel_logic($1,$2,$3);
				logfile<<"line "<<line_count<<" : rel_expression : simple_expression RELOP simple_expression"<<endl;
			}
		;
				
simple_expression : term
			{
				$$=$1;
				logfile<<"line "<<line_count<<" : simple_expression : term "<<endl;
				
			}
		  | simple_expression ADDOP term 
			{
				
				$$=manage_add_op($1,$2,$3);
				logfile<<"line "<<line_count<<" : simple_expression : simple_expression ADDOP term "<< $1->intVal<<" "<<$3->intVal<<endl;
			}
		  ;
					
term :	unary_expression
			{
				$$=$1;
				logfile<<"line "<<line_count<<" term :unary_expression"<<endl;
			}
     |  term MULOP unary_expression
			{
				$$=manage_mul_op($1,$2,$3);
				cout<<"MULOP operator "<<$3->name<<endl;
				logfile<<"line "<<line_count<<" : term: term MULOP unary_expression"<<endl;
			}
     ;

unary_expression : ADDOP unary_expression 
			{
				$$=manage_unary_op($1,$2);
				cout<<"line "<<line_count<<" : unary_expression : ADDOP unary_expression "<<$$->name<<endl;
				logfile<<"line "<<line_count<<" : unary_expression : ADDOP unary_expression"<<endl;
			}
		 | NOT unary_expression 
			{
				$$=manage_unary_op($1,$2);
				cout<<"not unary "<<$2->name;
				logfile<<"line "<<line_count<<" : unary_expression : NOT unary_expression"<<endl;
			}
		 | factor 
			{
				$$=$1;
				//logfile<<"factor "<<$$->name<<endl;
				logfile<<"line "<<line_count<<" : unary_expression : factor"<<endl;
			}
		 ;
	
factor	: variable 
			{
				if($1->array_indx_holder == -1){$$=$1;}
				else 
				{
					$$ = new SymbolInfo();
				 	
				 	string t = newTemp();
				 	$$->temp_name = t;
				 	
				 	string code = ";array found\n";
				 	stringstream ss;
					ss<<$1->array_indx_holder;
				 	code = code + "LEA DI, " + $1->name + "\n";
				 	code = code + "ADD DI, " + ss.str()+ "\n";
				 	code = code + "ADD DI, " + ss.str() +" \n";
				 	code = code + "MOV AX, [DI]\n";
				 	code = code + "MOV " + t + ", AX\n";
				 	
				 	$$-> code = $$->code + code;
				 	
				 	$$->intVal = $1->intVal;
				 	$$->floatVal = $1->floatVal;
				 	$$->charVal = $1->charVal;
				 	$$->data_type = $1->data_type;
				}
				
				logfile<<"line "<<line_count<<" : factor: variable "<<$$->temp_name<<"array "<<$$->code<<endl;
			}
	| ID LPAREN argument_list RPAREN
			{
				SymbolInfo* s=findFunc($1);
				if(s!=dummy)
				{		
					$$=parameter_check($1);
					$$->code=$$->code+"CALL "+$1->name+"\n";

				}
				else
				{
					//logfile<<"dummy found"<<endl;
					$$=dummy;
				}	
				logfile<<"line "<<line_count<<" : factor: ID LPAREN argument_list RPAREN "<<$$->code<<endl;
			}
	| LPAREN expression RPAREN 
			{
				$$=$2;
				logfile<<"line "<<line_count<<" : factor: LPAREN expression RPAREN"<<endl;
			}
	| CONST_INT 
			{
				$$=$1;
				logfile<<"line "<<line_count<<" : factor: CONST_INT "<<$$->intVal<<endl;
			}
	| CONST_FLOAT 
			{
				$$=$1;
				logfile<<"line "<<line_count<<" : factor: CONST_FLOAT"<<endl;
			}
	| CONST_CHAR 
			{
				$$=$1;
				logfile<<"line "<<line_count<<" : factor: CONST_CHAR"<<endl;
			}
	| variable INCOP 
			{
				$$=manage_incop($1);
				logfile<<"line "<<line_count<<" : factor: variable INCOP "<<$1->name<<" "<<$1->temp_name<<endl;
			}
	| variable DECOP 
			{
				$$=manage_decop($1);
				logfile<<"line "<<line_count<<" : factor: variable DECOP"<<endl;
			}
	;
	
argument_list : argument_list COMMA logic_expression 
			{
				para_check[check_flag][0]=$3->data_type;
				para_check[check_flag][1]=$3->temp_name;
				check_flag++;
				logfile<<"line "<<line_count<<" : argument_list : argument_list COMMA logic_expression"<<endl;
			}
	      | logic_expression 
			{
				para_check[check_flag][0]=$1->data_type;
				para_check[check_flag][1]=$1->temp_name;
				check_flag++;
				logfile<<"line "<<line_count<<" : argument_list : logic_expression"<<endl;
			}
	      | 
			{
				logfile<<"line "<<line_count<<" : argument_list : "<<endl;
			}

	      ;
 
%%

int main(int argc, char const* argv[])
{
	logfile.open("log.txt");
	asmfile.open("code.asm");
	errorfile.open("error.txt");
	
	table = new SymbolTable(31);
	yyin = fopen(argv[1], "r");
	table->EnterScope();
	logfile<<"scope creation main()"<<endl;
	
	cout << "##############################################################################" << endl;
	cout << "##############################################################################" << endl;
	
   	yyparse();
   	
	
 	logfile << endl;
 	logfile << "Total Lines: " << line_count << endl << endl;
 	logfile << "Total Errors: " << error_count << endl << endl;
	
	dec_code = dec_code + "\n\n";
 	
 	full_code = start_code + dec_code +dot_code+ main_code;
 	full_code = full_code + "\n"+outdec+"\nEND MAIN\n";
 	asmfile << full_code << endl;
 	

	table->PrintAllScopeTable_file();

   	exit(0);
}
