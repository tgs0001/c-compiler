
#include<cstdlib>
#include "symbolInfo.h"
using namespace std;

class ScopeTable
{
public:
    SymbolInfo **arra;
    SymbolInfo *temp;
    SymbolInfo *temp1;
    ScopeTable *parentScope=NULL;
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
        }
        delete arra;
    }
    int hash_function()
    {
        int x;
        x=rand()%size;
        return x;
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
    SymbolInfo* Insert(string data,string type)
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
                temp=new SymbolInfo();
                temp->setName(data);
                temp->setType(type);
                temp->next=NULL;
                temp1=temp;
                arra[x]=temp1;
                cout<<"Inserted in ScopeTable#"<<n<<" at position "<<x<<","<<0<<endl;
            }
            else
            {
                int i=1;
                while(temp1->next != NULL)
                {
                    temp1=temp1->next;
                    i++;
                }
                temp=new SymbolInfo;
                temp->setName(data);
                temp->setType(type);
                temp->next=NULL;
                temp1->next=temp;
                cout<<"Inserted in ScopeTable#"<<n<<" at position "<<x<<","<<i<<endl;

            }

            return temp;

        }
        else
        {
            cout<<data<<" already exists in current scopetable"<<endl;
            return NULL;
        }
    }
    SymbolInfo* Look_up(string data)
    {
       if(Search(data)==true)
       {
           cout<<"Found in ScopeTable#"<<n<<" at position "<<row<<","<<col<<endl;
           return temp;
       }
       //cout<<"Not Found"<<endl;
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
             cout<<"Found in ScopeTable#"<<n<<" at position "<<row<<","<<col<<endl;
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
