#property strict
#include "valuables.mqh"

string current = USDJPY;
void OnInit(){

};

void OnTick(){
  Print(current == Symbol());
}
