#include<iostream>
#include "Scope.h"
#include<fstream>
using namespace std;

class SymbolTable
{

public:
    ScopeTable *currentScope=NULL;
    ScopeTable *temp;
    int size;
    int n=0;
    void EnterScope()
    {
        n++;
        if(currentScope==NULL)
        {
            currentScope=new ScopeTable(size);
            currentScope->parentScope=NULL;
            currentScope->n=n;
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
        delete temp;
    }
    bool Insert(string data,string type)
    {
        return currentScope->Insert(data,type);

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
        cout<<"Not Found"<<endl;
        return NULL;

    }
    void PrintCurrentScopeTable()
    {
        currentScope->print();
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
};

int main()
{
    SymbolTable obj;
    //obj.size=7;
  //  obj.EnterScope();
//    obj.EnterScope();
    //obj.Insert("3","variable");
//    obj.Insert("4","function");
//    obj.Insert("5","function");
//     obj.PrintAllScopeTable();
//     obj.EnterScope();
   // obj.PrintCurrentScopeTable();
//    obj.LookUp("4");
//    obj.PrintAllScopeTable();

      int x;
      FILE *fp;
      fp=fopen("input.txt","r");
      fscanf(fp,"%d",&x);
      obj.size=x;
      obj.EnterScope();
      cout<<x<<endl;
      char c[50];
      char a[50];
      char b[50];
      string tc;
      string ta;
      string tb;
      while(!feof(fp))
      {

          fscanf(fp,"%s",c);
          tc=(string)c;
         // cout<<"Now "<<tc<<endl;

          if(tc=="I")
          {

             fscanf(fp,"%s",a);
             fscanf(fp,"%s",b);
             //cout<<"run"<<endl;
             ta=(string)a;
             tb=(string)b;
             obj.Insert(ta,tb);
             //cout<<ta<<tb;
          }
          else if(tc=="L")
          {
              fscanf(fp,"%s",a);
              ta=(string)a;
              obj.LookUp(a);
          }
          else if(tc=="D")
          {
              fscanf(fp,"%s",a);
              ta=(string)a;
              obj.Remove(ta);
              cout<<ta<<" deleted from current ScopeTable"<<endl;
          }
          else if(tc=="P")
          {
              fscanf(fp,"%s",a);
              ta=(string)a;
              if(ta=="A")
              {
                  obj.PrintAllScopeTable();
              }
              else if(ta=="C")
              {
                  obj.PrintCurrentScopeTable();
              }
          }
          else if(tc=="S")
          {
              obj.EnterScope();
          }
          else if(tc=="E")
          {
              obj.ExitScope();
          }

      }
}
