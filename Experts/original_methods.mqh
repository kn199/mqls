#include "valuables.mqh"
#include "time.mqh"
#include "valuables.mqh"
#include "notice.mqh"

bool IntInclude(int &ag_int_array[], int target) {
  bool is_include = false;

  for (int count = 0; count < ArraySize(ag_int_array) - 1 ; count++ ) {
    if (ag_int_array[count] == target) {
      is_include = true;
    }
  }

  return(is_include);
};
