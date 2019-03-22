
#include<cstdlib>
#include "symbolInfo.h"
using namespace std;

extern ofstream logfile;
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
    int num_data=0;;
    ScopeTable(int n)
    {
        arra=new SymbolInfo*[n];
        size =n;
        for(int i=0;i<size;i++)
        {
	    SymbolInfo *s=new SymbolInfo();
            arra[i]=s;
        }
	//cout<<"size is "<<size<<endl;
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
	//cout<<"in the search"<<endl;
        for(int i=0;i<size;i++)
        {
            int j=0;
	    //cout<<"before temp"<<endl;
            temp=arra[i];
	    //cout<<"after temp"<<endl;
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
    SymbolInfo* Insert(string data,string type,string data_type)
    {
        bool srch;
	//cout<<"inside search"<<endl;
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
		temp->data_type=data_type;
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
		temp->data_type=data_type;
                temp->next=NULL;
                temp1->next=temp;
                cout<<"Inserted in ScopeTable#"<<n<<" at position "<<x<<","<<i<<endl;

            }
	    num_data++;
            return temp;

        }
        else
        {
            cout<<data<<" already exists in current scopetable"<<endl;
            return NULL;
        }
    }
	SymbolInfo* Insert(SymbolInfo* sym)
    {
        bool srch;
	//cout<<"inside search"<<endl;
        srch=Search(sym->name);
	
        if(srch==false)
        {
            int x;
            x=hash_function();
            temp1=arra[x];
	    stringstream ss;
	    sym->ScopeNum=n;
	    ss<<sym->ScopeNum;
	    sym->temp_name=sym->temp_name+ss.str();
            if(temp1==NULL)
            {
		arra[x]=sym;
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
		temp1->next=sym;
                cout<<"Inserted in ScopeTable#"<<n<<" at position "<<x<<","<<i<<endl;

            }
	    num_data++;
            return temp;
        }
        else
        {
            cout<<sym->name<<" already exists in current scopetable"<<endl;
            return NULL;
        }
    }
	
    
    SymbolInfo* Look_up(string data)
    {
       if(Search(data)==true)
       {
           cout<<"Found in ScopeTable#"<<n<<" at position "<<row<<","<<col<<" , "<<data<<endl;
           return temp;
       }
       //cout<<"Not Found"<<endl;
       return NULL;
    }
    bool Delete(string data)
    {
        if(Search(data)==false)
        {
           // cout<<"Not Found"<<endl;
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
	     num_data--;
            return true;
        }

    }
    void print()
    {
	if(num_data==0)return;
	int flag=0;
        cout<<"ScopeTable # "<<n<<endl;
        for(int i=0;i<size;i++)
        {
	    flag=0;
            temp=arra[i];
            
            while(temp!=NULL)
            {
		if(temp->name != "@")
		{
			cout<<i<<" --> ";
                	cout<<"< "<<temp->getName()<<" : "<<temp->getType()<<" > ";
			flag=1;
		}
                temp=temp->next;
            }
	    if(flag==1)cout<<endl;
        }

    }
    void print_file()
    {
	cout<<"number of data is "<<num_data<<" scopetable # "<<n<<endl;
        if(num_data==0)return;
	int flag=0;
	logfile<<"ScopeTable # "<<n<<endl;
        for(int i=0;i<size;i++)
        {
            temp=arra[i];
            flag=0;
            while(temp!=NULL)
            {
		if(temp->name != "rt")
                {
			logfile<<i<<" --> ";
			logfile<<"< "<<temp->getName()<<" , "<<temp->getType();
			//cout<<"&&& "<<temp->array_size<<endl;
			if(temp -> isArray == true )
			{
				logfile<<"{ ";
				for(int i=0;i<temp-> array_size;i++)
				{
					if(temp -> data_type=="float")
					{
						
						logfile<<temp -> array[i].floatVal<<" ,";
					}
					if(temp -> data_type=="int")
					{
						
						logfile<<temp -> array[i].intVal;
						if(i != temp->array_size-1)
						{
							logfile<<",";
						}
						
					}
				}
				logfile<<"} >";
			}
			else if(temp->floatVal != -99999.0)
				logfile<<" , "<<temp->floatVal<<" >";
			else if(temp->intVal != -99999)
				logfile<<" , "<<temp->intVal<<" >";
			else
				logfile<<" , -1e+007"<<" >";
			cout<<temp->getName()<<" "<<temp->intVal<<endl;
			flag=1;
		}
                temp=temp->next;
            }
	    if(flag==1)logfile<<endl;
        }
    }
   

};
