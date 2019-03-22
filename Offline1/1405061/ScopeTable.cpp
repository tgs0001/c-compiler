#include<iostream>
#include "Symbol.h"
using namespace std;

int main()
{
    SymbolInfo obj1;
    obj1.setName("variable");
    cout<<obj1.getName();
}
