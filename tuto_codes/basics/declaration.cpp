#include <iostream>
using namespace std;

int main(){
  int x = 3;
  auto f = [x](int y){return x+y;};
  x = 5;
  cout << f(10) << endl;
}

