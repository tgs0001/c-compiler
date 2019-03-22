using namespace std;
class SymbolInfo
{
    string name;
    string type;
public:
    SymbolInfo *next=NULL;
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
