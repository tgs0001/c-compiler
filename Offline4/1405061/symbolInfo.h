#include <bits/stdc++.h>
#include<vector>
using namespace std;

extern ofstream logfile;


class SymbolInfo{
public:
    string name;
    string type;
    string data_type="00";
    int intVal=00;
    float floatVal=00;
    char charVal;
    bool boolVal;
    string code="";
    int array_indx_holder;
    string temp_name;  
    int array_size;
    SymbolInfo *array;
    bool isCreate=false;
    bool isArray=false;
    vector<int>intArray;
    int abc[123];
    vector<float>floatArray;
    vector<char>charArray;
    int ScopeNum;

    //for function
    bool isFunc=false;
    string func_name;
    int para_num=-1;
    string para_info[20][2];
    string ret_type;
    bool proto=false;
    int func_scope_num=-1;

    SymbolInfo *next=NULL;
    int value=0;
    
    SymbolInfo()
    {
    	name="rt";
    	type="";
	array_size = -1;
	intVal = -99999;
	floatVal = -99999.0;
	charVal = '!';
	temp_name = name;
	code = "";
	array_indx_holder = -1;
	
   }
    SymbolInfo(string name,string type)
    {
	this->name=name;
	this->type=type;
	array_size = -1;
	intVal = -99999;
	floatVal = -99999.0;
	charVal = '!';
	temp_name = name;
	code = "";
	array_indx_holder = -1;
	intArray.push_back(111);
	
    }
    
    SymbolInfo ( char* name, char* type )
	{
		this->name = string(name);
		this->type = string(type);
		array_size = -1;
		intVal = -99999;
		floatVal = -99999.0;
		charVal = '!';
		temp_name = name;
		code = "";
		array_indx_holder = -1;
		intArray.push_back(111);
		
	}
	SymbolInfo ( char* name, char* type ,char* data_type)
	{
		this->name = string(name);
		this->type = string(type);
		this->data_type=string(data_type);
		array_size = -1;
		intVal = -99999;
		floatVal = -99999.0;
		charVal = '!';
		temp_name = name;
		code = "";
		array_indx_holder = -1;
		intArray.push_back(111);
		
	}
	SymbolInfo ( char* name, char* type ,char* data_type,int value)
	{
		this->name = string(name);
		this->type = string(type);
		this->data_type=string(data_type);
		array_size = -1;
		intVal = -99999;
		floatVal = -99999.0;
		charVal = '!';
		temp_name = name;
		code = "";
		array_indx_holder = -1;
		intArray.push_back(111);
		value=1;
		
	}
	
    
    void create_array()
    {
	array=new SymbolInfo[array_size];
	//int *x=new int[10];
	//int a=3;
	//cout<<"integer size "<<sizeof(x)<<endl;
	for(int i=0;i<array_size;i++)
	{
		
		//SymbolInfo *a=new SymbolInfo();
		cout<<"array is going to be created"<<array_size<<endl;
		//array[i]=new SymbolInfo();
		array[i].type = type;
		array[i].name = name;
		array[i].data_type=data_type;
		array[i].array_indx_holder = i;
		if(data_type == "int") 
		{
			array[i].intVal = -1;
			cout<<"#######intval"<<endl;
			intArray.push_back(-1);
		}
		else if(data_type == "float") array[i].floatVal = -99999.0;
		else if(data_type == "char") array[i].charVal = '!';
	}
	printArray();
	//printVector();
	isArray=true;
	//cout<<"*****array created"<<endl;
    }

    void printArray()
    {
	if(isArray == false)
		cout<<"array is not created"<<endl;
	else
	{
		
		for(int i=0;i<array_size-1;i++)
		{
		cout<<"look at this "<<array[i].intVal<<" "<<sizeof(array[i])<<endl;
		}
	}
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
     SymbolInfo* get_arr_ptr(int i)
	{
		return &(array[i]);
	}
	

};









