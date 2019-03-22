#include<iostream>
#include "ScopeTable.h"
#include<fstream>
#include <stdlib.h>
using namespace std;

extern ofstream logfile;
extern int loop_scope;
class SymbolTable
{
public:
    ScopeTable *currentScope=NULL;
    ScopeTable *temp;
    int size;
    int n=0;
    SymbolTable (int n)
	{
		size=n;
	}
    void EnterScope()
    {
        n++;
        if(currentScope==NULL)
        {
            currentScope=new ScopeTable(size);
            currentScope->parentScope=NULL;
            currentScope->n=n;
	   // cout<<"scope created inside symboltable"<<endl;
        }
        else
        {
            temp=new ScopeTable(size);
            temp->parentScope=currentScope;
            currentScope=temp;
            currentScope->n=n;
        }
    }
    void ExitScope()
    {
        temp=currentScope;
        currentScope=currentScope->parentScope;
	//logfile<<"scopetable "<<temp->n<<" deleted"<<endl;
        delete temp;
    }
    SymbolInfo* Insert(string data,string type)
    {
       // return currentScope->Insert(data,type);

    }
    SymbolInfo* Insert(SymbolInfo* s)
    {
	
	return currentScope->Insert(s);
    }
    bool Remove(string data)
    {
        return currentScope->Delete(data);

    }
    SymbolInfo* LookUp(string data)
    {
        temp=currentScope;
        SymbolInfo *temp1;
        while(temp!=NULL)
        {
            temp1=temp->Look_up(data);
            if(temp1!=NULL)
            {
                return temp1;
            }
            temp=temp->parentScope;
        }
        //cout<<"Not Found"<<endl;
        return NULL;

    }
    SymbolInfo* LookUp_curParentScopeTable(string data,int j)
    {
	temp=currentScope;
	while(j > 0)
	{
		temp=temp->parentScope;
		SymbolInfo* temp1;
		temp1=temp->Look_up(data);
            if(temp1!=NULL)
            {
                return temp1;
		break;
            }
		j--;
	}
	
	return NULL;
    }
    SymbolInfo* LookUp_currentScopeTable(string data)
    {
	temp=currentScope;
	SymbolInfo* temp1;
	temp1=temp->Look_up(data);
            if(temp1!=NULL)
            {
                return temp1;
            }
	return NULL;
    }
    SymbolInfo* LookUp(SymbolInfo* s)
    {
	temp=currentScope;
	SymbolInfo* temp1=NULL;
	temp1=temp->Look_up(s->name);
	if(temp1 == NULL )
	{
		while(temp->parentScope != NULL)
		{
			temp=temp->parentScope;
		}
		temp1 = temp->Look_up(s->name);
	}
	return temp1;;
    }
    SymbolInfo* LookUp_globalScopeTable(string data)
    {
	temp=currentScope;
	while(temp->parentScope != NULL)
	{
		temp=temp->parentScope;
	}
	SymbolInfo* temp1;
	temp1=temp->Look_up(data);
            if(temp1!=NULL)
            {
                return temp1;
            }
	return NULL;
    }
    
    SymbolInfo* Insert_global(SymbolInfo* s)
    {
	temp=currentScope;
	while(temp->parentScope != NULL)
	{
		temp=temp->parentScope;
	}
	return temp->Insert(s);
    }
    void PrintCurrentScopeTable()
    {
        currentScope->print();
    }
    void PrintGlobalScopeTable()
    {
	temp=currentScope;
	while(temp->parentScope != NULL)
	{
		temp=temp->parentScope;
	}
	temp->print();
    }
    void PrintCurrentScopeTable_file()
    {
        currentScope->print_file();
    }
    void PrintGlobalScopeTable_file()
    {
	temp=currentScope;
	while(temp->parentScope != NULL)
	{
		temp=temp->parentScope;
	}
	temp->print_file();
    }
    
    void PrintAllScopeTable()
    {
        temp=currentScope;
        while(temp!=NULL)
        {
            temp->print();
            temp=temp->parentScope;
        }
    }
    void PrintAllScopeTable_file()
    {
	//currentScope->print_file();
	//int j=loop_scope;
	//temp=currentScope;
	//while(j>0)
	//{
	//	cout<<"loop started here  please check"<<endl;
	//	temp=temp->parentScope;
	//	temp->print_file();
	//	j--;
	//}
	//temp=currentScope;
	//while(temp->parentScope != NULL)
	//{
	//	temp=temp->parentScope;
	//}
	//temp->print_file();
        temp=currentScope;
        while(temp!=NULL)
        {
           temp->print_file();
           temp=temp->parentScope;
        }
    }
};


