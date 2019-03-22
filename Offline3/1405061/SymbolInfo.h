#include <bits/stdc++.h>
using namespace std;

class SymbolInfo{
public:
    string name;
    string type;
    int intVal;
    float floatVal;
    double doubleVal;
    char charVal;
    bool boolVal;
    string code;
    int array_indx_holder;
    string temp_name;  
    int arr_size;

    SymbolInfo *next=NULL;
    SymbolInfo()
    {
    	name="";
    	type="";
	arr_size = -1;
	intVal = -99999;
	floatVal = -99999;
	charVal = '!';
	temp_name = name;
	code = "";
	array_indx_holder = -1;
   }
    SymbolInfo(string name,string type)
    {
	this->name=name;
	this->type=type;
	arr_size = -1;
	intVal = -99999;
	floatVal = -99999;
	charVal = '!';
	temp_name = name;
	code = "";
	array_indx_holder = -1;
    }
    
    SymbolInfo ( char* name, char* type )
	{
		this->name = string(name);
		this->type = string(type);
		arr_size = -1;
		intVal = -99999;
		floatVal = -99999;
		charVal = '!';
		temp_name = name;
		code = "";
		array_indx_holder = -1;
	}
    string getName()
    {
        return name;
    }
    void setName(string name)
    {
        this->name=name;
    }
     string getType()
    {
        return type;
    }
    void setType(string type)
    {
        this->type=type;
    }

};
