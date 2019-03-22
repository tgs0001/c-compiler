#include<iostream>
#include<cstdlib>
#include "Symbol.h"
using namespace std;

class ScopeTable
{
public:
    SymbolInfo **arra;
    SymbolInfo *temp;
    SymbolInfo *temp1;
    int n;//ScopeTable number
    int row;
    int col;
    int size;
    ScopeTable(int n)
    {
        arra=new SymbolInfo*[n];
        size =n;
        for(int i=0;i<size;i++)
        {
            arra[i]=NULL;
        }
        for(int i=0;i<size;i++)
        {

        }
    }
    ~ScopeTable()
    {
        for(int i=0;i<size;i++)
        {
            temp=arra[i];
            while(temp!=NULL)
            {
                temp1=temp;
                temp=temp->next;
                delete temp1;
            }
            cout<<endl;
        }
        delete arra;
    }
    int hash_function()
    {
        int x;
        x=rand()%size;
        return 4;
    }
    bool Search(string data)
    {

        for(int i=0;i<size;i++)
        {
            int j=0;
            temp=arra[i];
            if(temp==NULL)
            {
                 //cout<<size<<endl;
            }


            while(temp!=NULL)
            {
                if(data==temp->getName())
                {
                    row=i;
                    col=j;
                    return true;
                }
                temp=temp->next;
                j++;
            }
        }
        return false;
    }
    bool Insert(string data,string type)
    {
        bool srch;

        srch=Search(data);

        if(srch==false)
        {
            int x;
            x=hash_function();
            temp1=arra[x];
            if(temp1==NULL)
            {
                temp=new SymbolInfo;
                temp->setName(data);
                temp->setType(type);
                temp->next=NULL;
                temp1=temp;
                arra[x]=temp1;
            }
            else
            {

                while(temp1->next != NULL)
                {
                    temp1=temp1->next;
                    cout<<"else"<<endl;
                }
                temp=new SymbolInfo;
                temp->setName(data);
                temp->setType(type);
                temp->next=NULL;
                temp1->next=temp;

            }

        }
        else
        {
            cout<<data<<" already exists in current scopetable"<<endl;
        }
    }
    SymbolInfo* Look_up(string data)
    {
       if(Search(data)==true)
       {
           return temp;
       }
       cout<<"Not Found"<<endl;
       return NULL;
    }
    bool Delete(string data)
    {
        if(Search(data)==false)
        {
            cout<<"Not Found"<<endl;
            return false;
        }
        else
        {
            temp1=arra[row];
            if(temp1->getName()==data)
            {
                arra[row]=temp1->next;
                delete temp1;
            }
            else
            {

                while(temp1->next!=temp)
                {
                    temp1=temp1->next;
                }
                if(temp->next==NULL)
                {
                    delete temp;
                    temp1->next=NULL;
                }
                else
                {
                    SymbolInfo *temp2;
                    temp2=temp;
                    temp2=temp2->next;
                    delete temp;
                    temp1->next=temp2;
                }
            }
            return true;
        }

    }
    void print()
    {
        cout<<"ScopeTable # "<<n<<endl;
        for(int i=0;i<size;i++)
        {
            temp=arra[i];
            cout<<i<<" --> ";
            while(temp!=NULL)
            {
                cout<<"< "<<temp->getName()<<" : "<<temp->getType()<<" > ";
                temp=temp->next;
            }
            cout<<endl;
        }

    }

};

int main()
{
   ScopeTable obj(7);
   obj.n=1;
   obj.Insert("foo","function");
   obj.Insert("5","variable");
   obj.Insert("4","variable");
   obj.Insert("6","variable");
   SymbolInfo *temp;
   temp=obj.Look_up("foo");
   //cout<<temp->getType()<<endl;
   obj.print();
   obj.Delete("foo");
   obj.print();
}
